import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sarvasoft_moc_interview/models/mock_interview_session.dart';

import '../models/candidate_session.dart';
import '../models/generatequestions.dart';
import '../models/session_analysis.dart';
import '../services/api_service.dart';
import 'cv_jd_provider.dart';
import 'interview_provider.dart';

/// A provider that holds the list of sessions (completed + in-progress) and
/// caches session details (analysis) returned by backend.
class SessionProvider extends ChangeNotifier {
  final ApiService api;

  SessionProvider({required this.api});

  bool _loading = false;
  bool get loading => _loading;

  final List<CandidateSession> _sessions = [];
  List<CandidateSession> get sessions => List.unmodifiable(_sessions);

  /// cached full session analysis keyed by sessionId
  final Map<String, SessionAnalysis> _analysisCache = {};

  /// raw payload cache in case you need full JSON
  final Map<String, Map<String, dynamic>> _rawCache = {};

  // ---------- Fetch sessions from backend (Supabase candidate_session table) ----------
  Future<void> fetchSessions() async {
    _loading = true;
    try {
      final List<Map<String, dynamic>> raw = await api.fetchCandidateSessions();
      _sessions.clear();
      _sessions.addAll(raw.map((m) => CandidateSession.fromJson(m)));
      _sessions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e, st) {
      debugPrint('[SessionProvider] fetchSessions error: $e\n$st');
      // keep previous sessions on error
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  CandidateSession? getSessionById(String id) {
    try {
      return _sessions.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  SessionAnalysis? getAnalysisFor(String sessionId) =>
      _analysisCache[sessionId];

  Map<String, dynamic>? getRawFor(String sessionId) => _rawCache[sessionId];

  // ---------- Add a new in-progress session to list (called by InterviewProvider) ----------
  void addInProgressSession(CurrentMockSession session) {
    // Convert CurrentMockSession-like object to CandidateSession
    final s = CandidateSession(
      id: session.id,
      createdAt: session.startedAt,
      completed: false,
      score: session.score,
    );

    // Insert at top
    _sessions.removeWhere((x) => x.id == s.id);
    _sessions.insert(0, s);
    notifyListeners();
  }

  // ---------- Update session status when backend returns analysis ----------
  void updateSessionStatusFromMock(CurrentMockSession updated) {
    // updated should include id, status, score and analysis
    final index = _sessions.indexWhere((s) => s.id == updated.id);
    final completedFlag = updated.status == SessionStatus.completed;

    final candidateSession = CandidateSession(
      id: updated.id,
      createdAt: updated.startedAt,
      completed: completedFlag,
      score: updated.score,
    );

    if (index >= 0) {
      _sessions[index] = candidateSession;
    } else {
      _sessions.insert(0, candidateSession);
    }

    // Cache analysis if present
    if (updated.analysis != null) {
      _analysisCache[updated.id] = updated.analysis!;
      // Also cache raw if you have it; optional
      _rawCache[updated.id] = updated.analysis!.toJson();
    }

    notifyListeners();
  }

  // ---------- Pull fresh details from backend (on SessionDetail screen open) ----------
  Future<SessionAnalysis?> fetchSessionDetails(
    String sessionId,
    String sessionType,
  ) async {
    // if cached, return quickly
    if (_analysisCache.containsKey(sessionId)) return _analysisCache[sessionId];

    if (sessionType == "skills/adaptive") {
      try {
        final Map<String, dynamic>? payload = await api
            .fetchAdaptiveInterviewSummary(sessionId);
        if (payload == null) return null;

        // payload expected to be backend top-level response {status, session_id, analysis: {...}}
        // final analysisMap = payload['analysis'] as Map<String, dynamic>? ?? payload;
        final analysis = SessionAnalysis.fromJson(payload);

        _analysisCache[sessionId] = analysis;
        _rawCache[sessionId] = Map<String, dynamic>.from(payload);
        // notifyListeners();
        return analysis;
      } catch (e, st) {
        debugPrint('[SessionProvider] fetchSessionDetails error: $e\n$st');
        return null;
      }
    } else {
      try {
        final Map<String, dynamic>? payload = await api.fetchSessionDetails(
          sessionId,
        );
        if (payload == null) return null;

        // payload expected to be backend top-level response {status, session_id, analysis: {...}}
        // final analysisMap = payload['analysis'] as Map<String, dynamic>? ?? payload;
        final analysis = SessionAnalysis.fromJson(payload);

        _analysisCache[sessionId] = analysis;
        _rawCache[sessionId] = Map<String, dynamic>.from(payload);
        // notifyListeners();
        return analysis;
      } catch (e, st) {
        debugPrint('[SessionProvider] fetchSessionDetails error: $e\n$st');
        return null;
      }
    }
  }

  /// Optional: remove cached analysis (for refresh or deletion)
  void clearSessionCache(String sessionId) {
    _analysisCache.remove(sessionId);
    _rawCache.remove(sessionId);
    notifyListeners();
  }

  // lib/providers/session_provider.dart (inside SessionProvider class)

  /// Called when the user taps a session row.
  /// - If session is completed -> fetch details and navigate to session detail screen.
  /// - If session is not completed -> show bottom sheet asking to continue.
  ///     - If user chooses Continue -> call ApiService.getSession(sessionId) to fetch pending questions
  ///       then navigate to question screen with the returned payload.
  ///     - If user cancels -> dismiss bottom sheet and return.
  Future<void> openSession(
    BuildContext context,
    String sessionId,
    String? sessionType,
  ) async {
    print("Getting session with id:$sessionId");
    final session = getSessionById(sessionId);
    if (session == null) {
      print("session not found");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Session not found')));
      return;
    }

    if (session.completed) {
      print("getting completed session details");
      // Completed -> ensure analysis cached and navigate to details screen
      try {
        // Optionally show a quick loader while fetching
        _showBlockingLoader(context, message: 'Loading session details...');
        final SessionAnalysis? analysis = await fetchSessionDetails(
          sessionId,
          sessionType!,
        );
        Navigator.of(context).pop(); // remove loader
        if (analysis == null) {
          print("session analysis not found");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to load session analysis')),
          );
          return;
        }
        // Navigate to the SessionDetailScreen. That screen will read cached analysis from provider.
        Navigator.pushNamed(
          context,
          '/sessionDetail',
          arguments: {'sessionId': sessionId, 'sessionType': sessionType},
        );

        return;
      } catch (e) {
        Navigator.of(context).pop(); // ensure loader removed on error
        debugPrint('[SessionProvider] openSession(fetch details) error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error loading session details')),
        );
        return;
      }
    } else {
      bool done = false;
      // Incomplete -> ask user whether to continue the mock interview
      final bool? proceed = await _showContinueBottomSheet(context);
      if (proceed != true) {
        // user cancelled
        return;
      }

      // user chose to continue -> fetch session (questions) then navigate to question screen
      try {
        _showBlockingLoader(
          context,
          message: 'Preparing your mock interview...',
        );
        final GenerateQuestionsResponse? qsResp = await api
            .getpendingMockInterviewForSession(sessionId);
        if (qsResp == null) {
          done = false;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No questions available for this session'),
            ),
          );
          return;
        }

        final provider = context.read<InterviewProvider>();

        final cvJdProvider = context.read<CvJdProvider>();

        cvJdProvider.sessionId = qsResp.sessionId;
        cvJdProvider.questions = qsResp.questions;
        cvJdProvider.analysisDone = true;
        cvJdProvider.error = null;
        print("current session with session id:${cvJdProvider.sessionId}");
        provider.loadQuestions(cvJdProvider.questions);
        provider.startSession(cvJdProvider.sessionId, SessionType.normal);
        done = true;
      } catch (e, st) {
        Navigator.of(context).pop(); // remove loader if shown
        done = false;
        debugPrint('[SessionProvider] openSession(getSession) error: $e\n$st');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load questions. Try again.')),
        );
        return;
      } finally {
        // Always remove loader if it was shown. Use rootNavigator to match showDialog.
        try {
          Navigator.of(context, rootNavigator: true).pop();
        } catch (_) {
          // ignore — safe-guard in case the dialog was already popped
        }
      }
      // Navigate to your question screen. Pass sessionId and payload (adapt argument keys to your question screen).
      if (done) {
        Navigator.of(context).pushNamed('/question');
      }
    }
  }

  /// Shows a bottom sheet that asks user whether to continue the incomplete session.
  /// Returns true when user selects Continue, false when Cancel or dismiss.
  Future<bool?> _showContinueBottomSheet(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: false,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Incomplete session',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'This mock interview is incomplete. Do you want to continue the interview now?',
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: const Text('Continue'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  /// Simple blocking loader dialog displayed while network operations are in progress.
  /// Removes itself by calling Navigator.of(context).pop() after the work completes.
  void _showBlockingLoader(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      useRootNavigator: true, // <--- add this
      barrierDismissible: false,
      builder: (ctx) => WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              if (message != null) ...[
                const SizedBox(height: 12),
                Text(message, style: const TextStyle(color: Colors.white)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> getSessionCoaching(
    String sessionId,
    String sessionType,
  ) async {
    return await api.getCoachingForSession(sessionId, sessionType);
  }
}
