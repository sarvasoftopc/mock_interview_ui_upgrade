// lib/src/providers/cv_jd_provider.dart

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:sarvasoft_moc_interview/models/generatequestions.dart';
import 'package:sarvasoft_moc_interview/models/roles.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

import '../models/analysis.dart';
import '../services/api_service.dart';

class CvJdProvider extends ChangeNotifier {
  final ApiService api;

  CvJdProvider({required this.api});

  String _cvText = '';
  String _jdText = '';
  Map<String, dynamic>? _skillExtraction;
  List<InterviewQuestion> _questions = [];
  String? _type;
  List<String> _overlapSkills = [];
  List<String> _missingSkills = [];
  final List<Map<String, dynamic>> _templates = [];
  bool _loading = false;
  String? _error;
  bool _analysisDone = false;
  final bool _questionsGenerated = false;

  final List<String> _jdSkills = [];

  List<String> _additonalSkills = [];

  String _matchScore = "";

  String _summary = "";
  List<RoleModel> _roles = [];
  bool rolesLoaded = false;
  String _sessionId = "";
  Analysis _analysis = Analysis.empty();
  String get type => _type ?? 'cv/skills';
  String get cvText => _cvText;
  String get jdText => _jdText;
  String get summary => _summary;
  String get sessionId => _sessionId;
  Analysis get analysis => _analysis;
  Map<String, dynamic>? get skillExtraction => _skillExtraction;
  List<InterviewQuestion> get questions => _questions;
  String? get error => _error;
  bool get analysisDone => _analysisDone;
  bool get questionGenerate => _questionsGenerated;
  bool get loading => _loading;
  List<String> get overlapSkills => _overlapSkills;
  List<String> get missingSkills => _missingSkills;
  List<String> get jdSkills => _jdSkills;
  List<String> get additonalSkills => _additonalSkills;

  String get matchScore => _matchScore;

  Null get interviewsCompleted => null;

  Null get averageScore => null;

  Null get practiceHours => null;

  Null get analysesPerformed => null;

  List<RoleModel> get roles => _roles;

  set overlapSkills(List<String> value) {
    _overlapSkills = value;
  }

  set missingSkills(List<String> value) {
    _missingSkills = value;
  }

  set type(String value) {
    _type = value;
  }

  set summary(String value) {
    _summary = value;
  }

  set additonalSkills(List<String> value) {
    _additonalSkills = value;
  }

  set analysis(Analysis value) {
    _analysis = value;
  }

  // setters
  set questions(List<InterviewQuestion> value) {
    _questions = value;
  }

  set matchedScore(String value) {
    _matchScore = value;
  }

  set error(String? value) {
    _error = value;
  }

  set sessionId(String value) {
    _sessionId = value;
  }

  set loading(bool value) {
    _loading = value;
  }

  set analysisDone(bool value) {
    _analysisDone = value;
  }

  void updateCvText(String text) {
    _cvText = text;
    _error = null;
    _analysisDone = false;
    notifyListeners();
  }

  void updateJdText(String text) {
    _jdText = text;
    _error = null;
    _analysisDone = false;
    notifyListeners();
  }

  Future<void> extractSkillsAndFetchQuestions() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await api.generateQuestionsFromSkills(
        analysis: _analysis,
      );
      if (response != null) {
        _sessionId = response.sessionId;
        _questions = response.questions;
        _type = response.sessionType;
        _analysisDone = true;
        _error = null;
      }
    } on AuthException {
      _error = 'Session Expired! Please Login Again.';
      _questions = [];
      // You can call AuthProvider.signOut() here via context
    } catch (e) {
      _error = 'Failed to process and fetch questions: $e';
      _questions = [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<GenerateQuestionsResponse?> startSkillSession({
    required List<String> skills,
    required int difficulty,
    required bool useVoice,
    required bool includeBehavioral,
    required String mode,
    String? role,
  }) async {
    final body = {
      "mode": mode,
      "skills": skills,
      "difficulty": difficulty,
      "useVoice": useVoice,
      "includeBehavioral": includeBehavioral,
      if (role != null) "role": role,
    };

    final response = await api.startSkillBasedSessoin(jsonEncode(body));
    if (response != null) {
      _type = response.sessionType;
      _sessionId = response.sessionId;
      _questions = response.questions;
      _analysisDone = true;
      _error = null;
    }
    return null;
  }

  void clear() {
    _cvText = '';
    _jdText = '';
    _skillExtraction = null;
    _questions = [];
    _error = null;
    _loading = false;
    _type = '';
    notifyListeners();
  }

  Future<void> performSkillanalyis() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await api.getSkillSummary(_cvText, _jdText);
      if (response != null) {
        _sessionId = response.sessionId;
        _analysis = response.analysis;
        _overlapSkills = response.analysis.matchedSkills;
        _missingSkills = response.analysis.missingSkills;
        _additonalSkills = response.analysis.extraInCv;
        _matchScore = response.analysis.matchScorePercent.toString();
        _summary = response.analysis.summary;
        _type = response.sessionType;
        _analysisDone = true;
        _error = null;
      }
    } on AuthException {
      _error = 'Session Expired! Please Login Again.';
      _questions = [];
      // You can call AuthProvider.signOut() here via context
    } catch (e) {
      _error = 'Failed to process and fetch questions: $e';
      _questions = [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // --- NEW: fetch the last CV+JD analysis for the candidate ---
  Future<void> fetchLastAnalysis() async {
    loading = true;
    notifyListeners();

    try {
      // Api should return a Map<String,dynamic> shaped similarly to your SessionAnalysis or a DTO with fields
      final Analysis resp = await api.getLastCvJdAnalysis();
      print("last skill analysis report recevied");
      if (resp != null) {
        print("analysis response:${resp!.sessionId}");
      }
      if (resp == null) {
        // clear or leave old values
        overlapSkills = [];
        missingSkills = [];
        additonalSkills = [];
        summary = "";
        matchedScore = "0";
        sessionId = "";
        type = "";
        questions = [];
      } else {
        print("skill analysis receieved:${resp.sessionId}");
        analysis = resp;
        // adapt keys to what your backend returns — example below:
        overlapSkills = resp.matchedSkills;
        missingSkills = resp.missingSkills;
        additonalSkills = resp.extraInCv;
        summary = resp.summary;
        matchedScore = resp.matchScorePercent.toString();
        sessionId = resp.sessionId;
        type = "cv/jd";
        questions = [];
      }
    } catch (e, st) {
      debugPrint('[CvJdProvider] fetchLastAnalysis error: $e\n$st');
      // optionally surface error
    } finally {
      loading = false;
      print("notifyListeners called");
      notifyListeners();
    }
  }

  /// Called from Drawer (UI). Provider handles fetching and navigation.
  Future<bool> prepareSkillDashboard(BuildContext context) async {
    // Fetch latest analysis first
    // await fetchLastAnalysis();
    // print("calling skills dashboard");
    // // Navigate to skill dashboard screen (so screen reads provider state)
    // Navigator.pushNamed(context, '/skills');

    try {
      await fetchLastAnalysis();
      // any other preparation logic
      return true;
    } catch (e, st) {
      debugPrint('[CvJdProvider] prepareSkillDashboard error: $e\n$st');
      return false;
    }
  }

  // Optional: convenience to ensure analysis is available when screen opens directly
  Future<void> ensureAnalysisLoaded() async {
    if (_analysisDone || _overlapSkills.isNotEmpty || (_matchScore != "0")) {
      // already loaded
      return;
    }
    await fetchLastAnalysis();
  }

  Future<void> getRoles() async {
    _roles = await api.fetchRoles();
    rolesLoaded = true;
    notifyListeners();
  }
}
