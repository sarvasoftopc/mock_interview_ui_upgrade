import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:sarvasoft_moc_interview/models/answer.dart';
import 'package:sarvasoft_moc_interview/models/generatequestions.dart';
import 'package:sarvasoft_moc_interview/models/session_analysis.dart';
import 'package:sarvasoft_moc_interview/providers/adaptive_session_provider.dart';
import 'package:sarvasoft_moc_interview/providers/session_provider.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

import '../models/local_turn.dart';
import '../models/mock_interview_session.dart';
import '../services/api_service.dart';
import '../services/audio_service.dart';
import '../services/file_service.dart';
import '../services/storage_service.dart';
import 'file_ops_stub.dart'
if (dart.library.io) 'file_ops_io.dart';
import 'web_audio_helper_stub.dart'
if (dart.library.html) 'web_audio_helper.dart';

// Note: don't import dart:html globally — only use it via dynamic when kIsWeb is true


class InterviewProvider extends ChangeNotifier {
  final ApiService api;
  final AudioService audio;
  final FileService _fileService;
  SessionType _sessionType = SessionType.normal;
  final StorageService _storage = StorageService();

  List<InterviewQuestion> _questions = [];
  CurrentMockSession? _currentSession;
  Uint8List? _lastRecordingBytes;
  int _currentIndex = 0;
  bool _hasRecording = false;
  bool get hasRecording => _hasRecording;

  Uint8List? get lastRecordingBytes => _lastRecordingBytes;

  List<InterviewQuestion> get questions => _questions;
  int get currentIndex => _currentIndex;
  CurrentMockSession? get currentSession => _currentSession;

  InterviewQuestion? get currentQuestion =>
      _questions.isNotEmpty && _currentIndex >= 0 && _currentIndex < _questions.length
          ? _questions[_currentIndex]
          : null;


  InterviewProvider({
    required this.api,
    required this.audio,
    FileService? fileService,
  }) : _fileService = fileService ?? FileService();

  Future<void> loadQuestions(List<InterviewQuestion> fetched) async {
    _questions = fetched;
    _currentIndex = 0;
    if(_sessionType == SessionType.normal) {
      notifyListeners();
    }
  }

  // Future<void> startSession(String sessionId) async {
  //   final id = !sessionId.isEmpty?sessionId : _generateId();
  //   _currentSession = CurrentMockSession(id: id, startedAt: DateTime.now(), answers: []);
  //   await _storage.setJson('sessions/latest', _currentSession!.toJson());
  //   notifyListeners();
  // }
  Future<void> startSession(String sessionId,SessionType sessionType) async {
    final id = !sessionId.isEmpty?sessionId : _generateId();
    _sessionType = sessionType;
    _currentSession = CurrentMockSession(id: id, startedAt: DateTime.now(), answers: [],type: sessionType);
    await _storage.setJson('sessions/latest', _currentSession!.toJson());
    if(_sessionType == SessionType.normal) {
      notifyListeners();
    }
  }

  String _generateId() {
    final r = Random();
    final parts = List.generate(4, (_) => r.nextInt(1 << 32).toRadixString(16));
    return parts.join('-');
  }

  // ---------- Recording lifecycle (UI calls these) ----------
  Future<void> startAnswerRecording() async {
    await audio.startRecording();
  }

  //original play last recording method
  // Future<void> playLastRecording() async {
  //   await audio.play();
  // }
  /// Plays the last recording — works for mobile (File path) and web (data URI / URL).
  Future<void> playLastRecording() async {
    final q = currentQuestion;
    if (q == null || _currentSession == null) return;

    final answersForQ =
    _currentSession!.answers.where((a) => a.questionId == q.id).toList();
    final lastAnswer = answersForQ.isNotEmpty ? answersForQ.last : null;
    final path = lastAnswer?.audioPath;
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


  //original stop last recording method
  // Future<void> stopLasPlay() async {
  //   await audio.stopPlay();
  // }

  Future<void> stopLasPlay() async {
    if (kIsWeb) {
      await stopWebAudioPlayback();
    } else {
      await audio.stopPlay();
    }
  }

  /// Delete the last recording for the current question (UI 'delete' action)
  Future<bool> deleteRecording() async {
    final q = currentQuestion;
    if (q == null || _currentSession == null) return false;

    final answersForQ =
    _currentSession!.answers.where((a) => a.questionId == q.id).toList();
    final lastAnswer = answersForQ.isNotEmpty ? answersForQ.last : null;

    if (lastAnswer != null) {
      final path = lastAnswer.audioPath as String?;
      if (path != null && path.isNotEmpty) {
        if (kIsWeb) {
          debugPrint('[Web] Removing in-memory recording reference.');
        } else {
          await deleteFileIfExists(path);
        }
      }

      _currentSession!.answers.remove(lastAnswer);
      audio.clearLastRecording();
      await _storage.setJson(
          'sessions/${_currentSession!.id}', _currentSession!.toJson());
      notifyListeners();
      return true;
    }
    return false;
  }

  //stop answer recording original method
  // Future<void> stopAnswerRecording() async {
  //   final q = currentQuestion;
  //   if (q == null || _currentSession == null) throw Exception('No active question or session');
  //   // Start/stop handled by AudioService mock: it will generate bytes directly
  //   final bytes = await audio.stopRecording();
  //
  //   // Convert audio bytes to Base64 string
  //   final audioBase64 = base64Encode(bytes);
  //   // Save audio via FileService
  //
  //   final localPath = await _fileService.saveAudio(_currentSession!.id, q.id, bytes);
  //
  //   print("file stored at:"+localPath);
  //   // Upload to Supabase Storage
  //   final fileName = "${_currentSession!.id}_${q.id}.wav";
  //
  //   final answer = Answer(questionId: q.id,transcript: null,audioPath: localPath,timestamp: DateTime.now().toIso8601String());
  //
  //   print("answer to question:\n $answer");
  //
  //   _currentSession!.answers.add(answer);
  //
  //   // Persist session snapshot
  //   await _storage.setJson('sessions/${_currentSession!.id}', _currentSession!.toJson());
  //   // ✅ Update hasRecording so UI can enable Play
  //   _hasRecording = bytes.isNotEmpty;
  //   notifyListeners();
  // }

  Future<Uint8List> stopAnswerRecording() async {
    final q = currentQuestion;
    if (q == null || _currentSession == null) throw Exception('No active question or session');
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
      localPath = await _fileService.saveAudio(_currentSession!.id, q.id, bytes);
    }

    await storeAnswer(q.getId,localPath);
    // ✅ Update hasRecording so UI can enable Play
    _hasRecording = bytes.isNotEmpty;
    _lastRecordingBytes = bytes;
    return bytes;
    notifyListeners();
  }




  // ---------- Submission flow (all server/upload logic lives here) ----------
  /// Submit the active session: adds session to SessionProvider (inProgress)
  /// then launches background upload + backend call. UI only calls this method.
  // Future<void> submitSession() async {
  //   if (_currentSession == null) throw Exception('No active session to submit');
  //   final payload = _currentSession!.toJson();
  //   await api.submitSessionData(_currentSession!.id, _currentSession);
  // }

  // ---------- Submission flow (all server/upload logic lives here) ----------

  /// Submit the active session: adds session to SessionProvider (inProgress)
  /// then launches background upload + backend call. UI only calls this method.
  Future<void> submitSession(SessionProvider sessionProvider, {bool runInBackground = true}) async {
    if (_currentSession == null) throw Exception('No active session to submit');

    final sessionSnapshot = CurrentMockSession(
      id: _currentSession!.id,
      startedAt: _currentSession!.startedAt,
      answers: List<Answer>.from(_currentSession!.answers),
      status: SessionStatus.inProgress,
      score: _currentSession!.score,
    );

    // 1) Add to UI session list as inProgress
    //sessionProvider.addSession(sessionSnapshot);

    // 2) Persist a local snapshot (optional)
    //TODO: remove local storage
    await _storage.setJson('sessions/${sessionSnapshot.id}', sessionSnapshot.toJson());

    // IMPORTANT: Add to SessionProvider immediately (so UI shows an in-progress session)
    // Convert to MockInterviewSession (or keep CurrentMockSession if you have that model)
    final previewMockSession = CurrentMockSession(
      id: sessionSnapshot.id,
      startedAt: sessionSnapshot.startedAt,
      status: SessionStatus.inProgress,
      score: sessionSnapshot.score,
      // analysis is null for now
    );
    sessionProvider.addInProgressSession(previewMockSession);

    // 3) Run upload + backend call in background (unblocked)
    if (runInBackground) {
      // schedule the background job and don't await — UI stays responsive
      Future(() async {
        await _uploadAndSubmit(sessionSnapshot, sessionProvider);
      });
    } else {
      await _uploadAndSubmit(sessionSnapshot, sessionProvider);
    }
  }

  /// Internal: upload audio files to Supabase, call backend, update sessionProvider on completion/failure.
  Future<void> _uploadAndSubmit(CurrentMockSession session, SessionProvider sessionProvider) async {
    try {
      final uploadedAnswers = <Map<String, dynamic>>[];

          //Original for loop to upload audio files
          // for (final a in session.answers) {
          //   String audioUrl = a
          //       .audioPath; // by default keep original path (in case already remote)
          //
          //
          //   // if local file path exists, upload to Supabase bucket 'interview-audio'
          //   if (audioUrl != null && audioUrl.isNotEmpty &&
          //       await File(audioUrl).exists()) {
          //     debugPrint("uploading to supabase:" + audioUrl.toString());
          //
          //     final bytes = await File(audioUrl).readAsBytes();
          //     final filename = "${session.id}_${a.questionId}.wav";
          //     debugPrint("filename will be:" + filename);
          //     final storage = Supabase.instance.client.storage.from(
          //         'interview-audio');
          //
          //     // Upload bytes (overwrite: false -> set up as desired)
          //     try {
          //       await storage.uploadBinary(
          //         filename,
          //         bytes,
          //         fileOptions: const FileOptions(cacheControl: '3600'),
          //         retryAttempts: 3, // will retry up to 3 times
          //       );
          //       print('✅ Upload succeeded');
          //     } catch (e, st) {
          //       print('❌ Upload failed after 3 retries: $e');
          //       // handle error (show snackbar, log to Sentry, etc.)
          //     }
          //     // Create a signed URL (choose expiry you prefer). Using 7 days here.
          //     final signedUrl = await storage.createSignedUrl(
          //         filename, 60 * 60 * 24 * 7);
          //
          //     audioUrl = signedUrl;
          //   }
          //
          //   uploadedAnswers.add({
          //     'question_id': a.questionId,
          //     'audio_url': audioUrl,
          //     'transcript': a.transcript,
          //     'timestamp': a.timestamp,
          //   });
          // }

      for (final a in session.answers) {
        String audioUrl = a.audioPath;
        try {
          if (audioUrl.startsWith('data:audio')) {
            // Web base64 data URI
            final comma = audioUrl.indexOf(',');
            final base64Part = audioUrl.substring(comma + 1);
            final bytes = base64Decode(base64Part);
            final filename = "${session.id}_${a.questionId}.wav";
            final storage = Supabase.instance.client.storage.from('interview-audio');
            await storage.uploadBinary(filename, bytes,
                fileOptions: const FileOptions(cacheControl: '3600'));
            final signedUrl =
            await storage.createSignedUrl(filename, 60 * 60 * 24 * 7);
            audioUrl = signedUrl;
          } else if (await fileExists(audioUrl)) {
            // Native file
            final bytes = await readFileBytes(audioUrl);
            final filename = "${session.id}_${a.questionId}.wav";
            final storage = Supabase.instance.client.storage.from('interview-audio');
            await storage.uploadBinary(filename, bytes,
                fileOptions: const FileOptions(cacheControl: '3600'));
            final signedUrl =
            await storage.createSignedUrl(filename, 60 * 60 * 24 * 7);
            audioUrl = signedUrl;
          }
        } catch (e) {
          debugPrint('[Upload] failed for ${a.questionId}: $e');
        }

        uploadedAnswers.add({
          'question_id': a.questionId,
          'audio_url': audioUrl,
          'transcript': a.transcript,
          'timestamp': a.timestamp,
        });
      }



      // After you’ve uploaded audios and replaced audioPath with Supabase URLs:
      final updatedSession =
      CurrentMockSession(
        id: session.id,
        startedAt: session.startedAt,
        answers: uploadedAnswers
            .map((a) => Answer(
          questionId: a['question_id'],
          audioPath: a['audio_url'],
          transcript: a['transcript'],
          timestamp: a['timestamp'],
        ))
            .toList(),
        status: SessionStatus.inProgress,
      );

      String jsonString = jsonEncode(updatedSession.toJson());

      print(jsonString);

      debugPrint("session data:"+ updatedSession.toString());
      // Call your ApiService to send data to backend

      //update current session
      _currentSession = updatedSession;
      var resp = await api.submitSessionData(session.id, updatedSession);

      var analysis = resp['analysis'];

      await storeSessionAnalysis(analysis,sessionProvider);
    } catch (e, st) {
      debugPrint('[InterviewProvider] Failed to parse analysis: $e');
      // still mark as failed or keep in-progress until manual refresh
    }

  }


  void next() {
    if (_questions.isEmpty) return;
    if (_currentIndex < _questions.length - 1) {
      _currentIndex++;
      notifyListeners();
    }
  }

  void previous() {
    if (_questions.isEmpty) return;
    if (_currentIndex > 0) {
      _currentIndex--;
      notifyListeners();
    }
  }

  void clearLastRecording() {
    _lastRecordingBytes = null;
  }

  void initalizeReplaceDataWithAdaptiveData(LocalTurn? currentTurn, String? sessionId){
    if(sessionId!=null && currentTurn!=null) {
      InterviewQuestion question = InterviewQuestion(question: currentTurn.interviewQuestion.getQuestion,
          tags: currentTurn.interviewQuestion.getTags, difficulty: currentTurn.interviewQuestion.getDifficulty.toString(),
          id: currentTurn.interviewQuestion.getId);
      List<InterviewQuestion> firstQuestion = [];
      firstQuestion.add(question);
      loadQuestions(firstQuestion);
      startSession(sessionId,SessionType.adaptive);
    }
  }

  Future<void> storeAnswer(String id, String localPath) async{

    print("file stored at:" + localPath);
    // Create Answer object using audioPath (on web it's a data URI)
    final answer = Answer(
      questionId: id,
      transcript: null,
      audioPath: localPath,
      timestamp: DateTime.now().toIso8601String(),
    );

    print("answer to question:\n $answer");

    _currentSession!.answers.add(answer);

    // Persist session snapshot
    await _storage.setJson('sessions/${_currentSession!.id}', _currentSession!.toJson());
  }

  Future<void> storeSessionAnalysis(analysis, SessionProvider sessionProvider) async {

    final session_analysis = SessionAnalysis.fromJson(analysis);

    _currentSession?.analysis = session_analysis;
    _currentSession?.score =session_analysis.overall_score?.toDouble();
    _currentSession?.status = SessionStatus.completed;
    // Finally update SessionProvider so it flips UI to completed and caches analysis:
    sessionProvider.updateSessionStatusFromMock(_currentSession!);
  }

  Future<Map<String, dynamic>> getInsights() async {
    return await api.getInsights();
  }


}
