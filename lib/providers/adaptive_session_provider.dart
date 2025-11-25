import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:sarvasoft_moc_interview/models/generatequestions.dart';
import 'package:sarvasoft_moc_interview/providers/interview_provider.dart';
import 'package:sarvasoft_moc_interview/providers/session_provider.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/adaptive_models.dart';
import '../models/local_turn.dart';
import '../models/mock_interview_session.dart';
import '../services/api_service.dart';
import '../services/audio_service.dart';
import '../services/auth_service.dart';
import '../services/file_service.dart';
import '../services/storage_service.dart';
import 'file_ops_stub.dart' if (dart.library.io) 'file_ops_io.dart';
import 'web_audio_helper_stub.dart'
    if (dart.library.html) 'web_audio_helper.dart';

/// ----------------------
/// Background helpers
/// ----------------------
/// Must be top-level for `compute` and `Isolate.run`.
Map<String, dynamic> _parseWs(String raw) =>
    json.decode(raw) as Map<String, dynamic>;

Map<String, dynamic> _normalizeMap(Map<String, dynamic> m) {
  // Place any heavy/iterative pure transformations here if needed.
  // For now, just clone to ensure we work on an isolated copy.
  return Map<String, dynamic>.from(m);
}

Uint8List _decodeBase64(String b64) => base64Decode(b64);

class AdaptiveSessionProvider extends ChangeNotifier {
  final ApiService api;
  final AudioService audio;
  final FileService _fileService;

  final StorageService _storage = StorageService();
  InterviewProvider? interview_provider;
  SessionProvider? sessionProvider;
  String? sessionId;
  WebSocketChannel? _channel;
  StreamSubscription? _sub;
  bool connected = false;

  bool _navigatedToSessions = false;
  Map<int, LocalTurn> turns = <int, LocalTurn>{};

  LocalTurn? _currentTurn;
  LocalTurn? _lastTurn;

  Uint8List? _lastRecording;
  LocalTurn? get currentTurn => _currentTurn;
  LocalTurn? get lastturn => _lastTurn;
  // final summary
  Map<String, dynamic>? finalSummary;

  bool _hasRecording = false;
  bool get hasRecording => _hasRecording;
  bool get navigateToSessions => _navigatedToSessions;
  Uint8List? get lastRecording => _lastRecording;

  double? finalScore;

  // config
  final String backendBase;
  final String wsBase;
  final AuthService authService;

  // history of answers + feedback
  List<LocalTurn> historicalTurnFeedbacks = [];

  AdaptiveSessionProvider({
    required this.backendBase,
    required this.wsBase,
    required this.authService,
    required this.audio,
    required this.api,
    FileService? fileService,
  }) : _fileService = fileService ?? FileService();

  set navigatedToSessions(bool navigatedToSessions) {
    _navigatedToSessions = navigatedToSessions;
  }

  Future<void> startSession(
    Map startPayload,
    InterviewProvider interviewProvider,
    SessionProvider sessionProvider,
  ) async {
    interview_provider = interviewProvider;
    this.sessionProvider = sessionProvider;
    historicalTurnFeedbacks.clear();
    final token = await authService.getAccessToken();
    final uri = Uri.parse('$backendBase/sessions/start_adaptive');
    final resp = await http.post(
      uri,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(startPayload),
    );
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('start_adaptive failed: ${resp.statusCode}');
    }
    final body = jsonDecode(resp.body);
    sessionId = body['session_id'] ?? body['sessionId'] ?? body['id'];
    if (sessionId == null) {
      throw Exception('session id missing');
    } else if (sessionId != null) {
      //Using interview provider to keep track of current mock session
      interviewProvider.startSession(sessionId!, SessionType.adaptive);
    }
    await _connectWs();
  }

  Future<void> _connectWs() async {
    if (sessionId == null) throw Exception('sessionId null');
    final candidateId = await authService.getUserId();
    final wsUrl = '$wsBase/ws/sessions/$sessionId?token=${candidateId!}';
    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
    connected = true;
    notifyListeners();
    _sub = _channel!.stream.listen(
      _onMessage,
      onDone: _onDone,
      onError: _onError,
      cancelOnError: false,
    );
  }

  /// UPDATED: offload WS parsing/normalization off UI isolate.
  Future<void> _onMessage(dynamic raw) async {
    try {
      // Parse on a background isolate
      final Map<String, dynamic> parsed = await Isolate.run(() {
        if (raw is String) return _parseWs(raw);
        if (raw is Map) return Map<String, dynamic>.from(raw);
        throw ArgumentError('Unsupported WS payload ${raw.runtimeType}');
      });

      // If you add any heavy pure transforms, keep them off the UI too
      final Map<String, dynamic> normalized = await compute(
        _normalizeMap,
        parsed,
      );

      // Apply to state quickly on UI
      _handleMap(normalized);
    } catch (e) {
      debugPrint('ws parse error $e');
    }
  }

  void _handleMap(Map msg) {
    final t = msg['type']?.toString();
    if (t == 'ai_question') {
      LocalTurn turn = LocalTurn(
        currentTurn: msg['turn_index'],
        interviewQuestion: InterviewQuestion(
          question: msg['question'],
          tags: (msg['tags'] is List) ? List<String>.from(msg['tags']) : [],
          difficulty: msg['difficulty'].toString(),
          ttsFile: msg['tts_file'].toString(),
          id: msg['question_id'].toString(),
          hints: (msg['hints'] is List) ? List<String>.from(msg['hints']) : [],
          topics: (msg['topics'] is List)
              ? List<String>.from(msg['topics'])
              : [],
        ),
        // currentDifficulty: msg['difficulty'] is num ? (msg['difficulty'] as num).toInt() :0,
        // currentQuestionId : msg['question_id'].toString(),
        // currentQuestion: msg['question'],
        // currentQuestionttsUrl : msg['tts_file'].toString(),
        // currentHints: (msg['hints'] is List) ? List<String>.from(msg['hints']) : [],
        // currentTags: (msg['tags'] is List) ? List<String>.from(msg['tags']) : [],
        // currentTopics: (msg['topics'] is List) ? List<String>.from(msg['topics']) : []
      );

      // simplest
      if (_currentTurn != null) {
        if (msg.containsKey('score')) {
          final analysis = msg['score'] as Map;
          var candidateAnswer = '';
          if (msg.containsKey("candidate_answer")) {
            candidateAnswer = msg['candidate_answer'];
          }
          var answerfeedback = _storeAnswerFeedback(analysis, candidateAnswer);
          turns[_currentTurn?.currentTurn]?.answerFeedback = answerfeedback;
          _lastTurn = turns[_currentTurn?.currentTurn];
        }
        //get answer to last question
        //get score of last answer
      }

      historicalTurnFeedbacks.add(turn);
      turns[turn.currentTurn] = turn;
      _currentTurn = turn;
      // sometimes analysis of previous answer may be embedded
      if (msg.containsKey('analysis')) {
        final analysis = msg['analysis'] as Map;
        _storeFeedbackFromAnalysis(analysis);
      }
      //interview_provider?.initalizeReplaceDataWithAdaptiveData(_currentTurn,sessionId);
      notifyListeners();
      return;
    }

    if (t == 'session_end') {
      finalScore = (msg['score'] is num)
          ? (msg['score'] as num).toDouble()
          : null;
      finalSummary = msg['summary'] is Map
          ? Map<String, dynamic>.from(msg['summary'])
          : null;
      // ensure listeners update
      var analysis = msg["summary"];

      //Session analysis stored
      interview_provider?.storeSessionAnalysis(analysis, sessionProvider!);
      // ...
      _setStatus(TurnStatus.session_completed);
      _closeWs();
      return;
    }

    // analysis-only message
    if (msg.containsKey('score') || msg.containsKey('rationale')) {
      _storeFeedbackFromAnalysis(msg);
      notifyListeners();
      return;
    }
  }

  void _storeFeedbackFromAnalysis(Map m) {
    // The server may send which question it's analysing. Try to get question_id or fallback to current.
    final qid =
        m['question_id']?.toString() ?? _currentTurn?.interviewQuestion.getId;
    final turnIndex = m['turn_index'] ?? _currentTurn?.currentTurn;
    final question =
        m['question']?.toString() ??
        _currentTurn?.interviewQuestion.getQuestion;
    final feedback = AnswerFeedback(
      score: m['score'] != null ? (m['score'] as num).toDouble() : null,
      rationale: m['rationale']?.toString(),
      modelAnswer:
          m['model_answer']?.toString() ?? m['modelAnswer']?.toString(),
    );
    _currentTurn?.answerFeedback = (feedback);
  }

  // two options to send answer:
  // - Option A: embed audio bytes as base64 inside the candidate_answer data
  // - Option B: upload audio to /upload and then send only reference id to ws
  //
  // We'll provide both — prefer option B for large audio files.

  Future<void> sendCandidateAnswerText({
    required String text,
    required bool endSession,
  }) async {
    if (_channel == null) throw Exception('ws not connected');
    final payload = {
      'type': 'candidate_answer',
      'data': {
        'turn_index': _currentTurn?.currentTurn,
        'question_id': _currentTurn?.interviewQuestion.getId,
        'question': _currentTurn?.interviewQuestion.getQuestion,
        'text': text,
        'end_session': endSession,
        'client_message_id': _randomClientId(),
      },
    };
    _channel!.sink.add(jsonEncode(payload));
  }

  Future<void> sendCandidateAnswerWithAudioBase64({
    required Uint8List audioBytes,
    required String audioMime, // e.g. 'audio/webm' or 'audio/wav'
    required bool endSession,
  }) async {
    if (_channel == null) throw Exception('ws not connected');
    final base64Audio = base64Encode(audioBytes);
    final payload = {
      'type': 'candidate_answer',
      'data': {
        'turn_index': _currentTurn?.currentTurn,
        'question_id': _currentTurn?.interviewQuestion.getId,
        'question': _currentTurn?.interviewQuestion.getQuestion,
        'audio_base64': base64Audio,
        'audio_mime': audioMime,
        'end_session': endSession,
        'client_message_id': _randomClientId(),
      },
    };
    _channel!.sink.add(jsonEncode(payload));
  }

  Future<void> uploadAudioAndSend({
    required Uint8List audioBytes, // e.g. '/upload_answer_audio'
    required bool endSession,
  }) async {
    //TODO: this will be done when the cadidate submits the question's answeer
    if (_currentTurn == null ||
        _currentTurn?.interviewQuestion.getId == null ||
        sessionId == null) {
      debugPrint("current turn have null data");
    }
    // before upload
    _setStatus(TurnStatus.processing);
    String? audioUrl = _currentTurn?.currentAnswerLocalPath!;
    final filename =
        "${sessionId}_${_currentTurn?.interviewQuestion.getId}.wav";
    try {
      if (audioUrl!.startsWith('data:audio')) {
        // Web base64 data URI
        final comma = audioUrl.indexOf(',');
        final base64Part = audioUrl.substring(comma + 1);
        // Decode base64 OFF the UI isolate
        final bytes = await Isolate.run(() => _decodeBase64(base64Part));

        final storage = Supabase.instance.client.storage.from(
          'interview-audio',
        );
        // when starting upload (both web + native branches)
        _setStatus(TurnStatus.uploading);
        await storage.uploadBinary(
          filename,
          bytes,
          fileOptions: const FileOptions(cacheControl: '3600'),
        );
        final signedUrl = await storage.createSignedUrl(
          filename,
          60 * 60 * 24 * 7,
        );
        audioUrl = signedUrl;
      } else if (await fileExists(audioUrl)) {
        // Native file
        final bytes = await readFileBytes(audioUrl);
        // when starting upload (both web + native branches)
        _setStatus(TurnStatus.uploading);
        final storage = Supabase.instance.client.storage.from(
          'interview-audio',
        );
        await storage.uploadBinary(
          filename,
          bytes,
          fileOptions: const FileOptions(cacheControl: '3600'),
        );
        final signedUrl = await storage.createSignedUrl(
          filename,
          60 * 60 * 24 * 7,
        );
        audioUrl = signedUrl;
      }
    } catch (e) {
      debugPrint(
        '[Upload] failed for ${_currentTurn?.interviewQuestion.getId}: $e',
      );
    }

    final payload = {
      'type': 'candidate_answer',
      'data': {
        'turn_index': _currentTurn?.currentTurn,
        'question_id': _currentTurn?.interviewQuestion.getId,
        'question': _currentTurn?.interviewQuestion.getQuestion,
        'audio_url': audioUrl,
        'end_session': endSession,
        'client_message_id': _randomClientId(),
      },
    };
    //{type: candidate_answer, data: {turn_index: 1, question_id: 74324904-9d5a-4177-b751-ec1d5f009103, question: What is a linked list and how does it differ from an array?, audio_url: https://rudfesyxjdqadzratayj.supabase.co/storage/v1/object/sign/interview-audio/69004539-059a-4432-a1f2-b6b3bc7431df_74324904-9d5a-4177-b751-ec1d5f009103.wav?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV9hM2Y1Y2RhZC00NDg3LTQwMjctODE0Ni1mYjBkMzc0MDM4YzIiLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJpbnRlcnZpZXctYXVkaW8vNjkwMDQ1MzktMDU5YS00NDMyLWExZjItYjZiM2JjNzQzMWRmXzc0MzI0OTA0LTlkNWEtNDE3Ny1iNzUxLWVjMWQ1ZjAwOTEwMy53YXYiLCJpYXQiOjE3NjI3ODg1NzgsImV4cCI6MTc2MzM5MzM3OH0.9x2R6zgwbHGDnxqYJ8IHM886P_j0bVsg1qqQRUzjHGg, end_session: false, client_message_id: 1762788579490}}
    print("payload:$payload");
    // after creating the final payload, before sending
    _setStatus(TurnStatus.uploaded);

    await _safeWsSend(payload);
  }

  Future<void> _safeWsSend(Map<String, dynamic> payload) async {
    if (_channel == null) {
      debugPrint('[WS] no channel; not sending');
      return;
    }

    // If the sink is already closed, Future.done completes (no isCompleted, so try a microtask wait).
    var closed = false;
    await Future.any([
      _channel!.sink.done.then((_) => closed = true),
      Future<void>.delayed(const Duration(milliseconds: 0)),
    ]);

    if (closed) {
      debugPrint('[WS] sink is closed; payload not sent: ${payload['type']}');
      return;
    }

    _channel!.sink.add(jsonEncode(payload));
    _setStatus(TurnStatus.processed);
    debugPrint('[WS] sent ${payload['type']}');
  }

  String _randomClientId() => DateTime.now().millisecondsSinceEpoch.toString();

  void _onError(error) {
    connected = false;
    notifyListeners();
  }

  void _onDone() {
    connected = false;
    notifyListeners();
  }

  void _closeWs() {
    _sub?.cancel();
    try {
      _channel?.sink.close();
    } catch (_) {}
    _channel = null;
    connected = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _closeWs();
    super.dispose();
  }

  // ---------- Recording lifecycle (UI calls these) ----------
  Future<void> startAnswerRecording() async {
    await audio.startRecording();
  }

  Future<String> stopAnswerRecording() async {
    if (_currentTurn == null ||
        _currentTurn?.interviewQuestion.getId == null ||
        sessionId == null)
      throw Exception('No active question or session');
    // Start/stop handled by AudioService mock: it will generate bytes directly
    final bytes = await audio.stopRecording();

    // For mobile platforms we preserve the existing behavior: save to a local file and store the path.
    // For web we cannot use dart:io File paths, so we store a data URI (base64) in audioPath.
    String localPath = '';
    if (kIsWeb) {
      // store as data URI so upload logic can detect and upload bytes directly
      if (bytes.isNotEmpty) {
        final b64 = base64Encode(bytes);
        localPath = 'data:audio/webm;base64,$b64'; // note webm on web
      }
    } else {
      // Save audio via FileService (existing behavior)
      localPath = await _fileService.saveAudio(
        sessionId!,
        _currentTurn!.interviewQuestion.getId,
        bytes,
      );
      _currentTurn?.currentAnswerLocalPath = localPath;
    }

    _lastRecording = bytes;
    _hasRecording = bytes.isNotEmpty;

    print("file stored at:$localPath");

    //Store the current answer in interview provider's session
    if (_currentTurn != null && _currentTurn?.interviewQuestion != null) {
      String id = _currentTurn!.interviewQuestion.getId;
      await interview_provider?.storeAnswer(id, localPath);
    }
    notifyListeners();
    return localPath;
  }

  Future<void> playLastRecording() async {
    if (_currentTurn == null ||
        _currentTurn?.interviewQuestion.getId == null ||
        sessionId == null)
      return;
    final path = _currentTurn?.currentAnswerLocalPath!;
    if (path == null || path.isEmpty) {
      debugPrint('[InterviewProvider] No recording to play.');
      return;
    }

    if (kIsWeb) {
      await playWebAudio(path);
    } else {
      await audio.play();
    }
  }

  AnswerFeedback _storeAnswerFeedback(
    Map answerScoreMap,
    String candidateAnswwe,
  ) {
    // The server may send which question it's analysing. Try to get question_id or fallback to current.
    final feedback = AnswerFeedback(
      score: (answerScoreMap['score'] as num).toDouble(),
      rationale: answerScoreMap['rationale']?.toString(),
      modelAnswer: answerScoreMap['model_answer']?.toString(),
      candidateAnswer: candidateAnswwe,
    );
    return feedback;
  }

  Future<void> clearLocalAudioFiles({required bool onlyProcessed}) async {}

  void removeTurn(LocalTurn t) {}

  Future<void> stopLasPlay() async {
    if (kIsWeb) {
      await stopWebAudioPlayback();
    } else {
      await audio.stopPlay();
    }
  }

  /// Delete the last recording for the current question (UI 'delete' action)
  Future<bool> deleteRecording() async {
    final q = _currentTurn?.currentInterviewQuestion;
    if (q == null || sessionId == null) return false;

    if (_currentTurn?.currentAnswerLocalPath != null) {
      final path = _currentTurn?.currentAnswerLocalPath;
      if (path != null && path.isNotEmpty) {
        if (kIsWeb) {
          debugPrint('[Web] Removing in-memory recording reference.');
        } else {
          await deleteFileIfExists(path);
        }
      }

      _currentTurn?.currentAnswerLocalPath = null;
      _currentTurn?.currentAnswerUrl = null;

      audio.clearLastRecording();
      notifyListeners();
      return true;
    }
    return false;
  }

  void _setStatus(TurnStatus s) {
    final ct = _currentTurn;
    if (ct == null) return;

    // update the current turn
    ct.status = s;

    // mirror into the map so UI reading from turns[...] also stays in sync
    final idx = ct.currentTurn;
    final existing = turns[idx];
    if (existing != null) {
      existing.status = s;
      turns[idx] = existing;
    }

    notifyListeners();
  }
}
