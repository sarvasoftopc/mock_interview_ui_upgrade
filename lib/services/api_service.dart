import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:sarvasoft_moc_interview/models/generatequestions.dart';
import 'package:sarvasoft_moc_interview/models/profile.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

import '../models/analysis.dart';
import '../models/mock_interview_session.dart';
import '../models/question.dart';
import 'auth_service.dart';

abstract class ApiService {
  Future<List<Question>> fetchQuestions(int count);
  Future<Map<String, dynamic>> submitSessionData(String sessionId, CurrentMockSession? payload);
  Future<GenerateQuestionsResponse?> generateQuestionsFromSkills({required Analysis analysis});
  Future<GenerateQuestionsResponse?> getSkillSummary(String? cvData,String? jdData);
  Future<GenerateQuestionsResponse?> getpendingMockInterviewForSession(String sessionId);
  Future<Map<String, dynamic>?> fetchSessionDetails(String sessionId);
  Future<List<Map<String, dynamic>>> fetchCandidateSessions();

  Future<Analysis> getLastCvJdAnalysis();

  Future<List<String>> analyseCv(String fileName, String cvText);

  createOrUpdateProfile(Profile p);

  Future getMyProfile();

  Future<String?> getUserId();

  Future<GenerateQuestionsResponse?> startSkillBasedSessoin(String jsonEncode);

  Future<Map<String, dynamic>?> fetchAdaptiveInterviewSummary(String sessionId) async {}

  Future<Map<String, dynamic>> getInsights();

  Future<Map<String, dynamic>> getCoachingForSession(String sessionId, String sessionType);
}

class ApiServiceImpl implements ApiService {
  final String baseUrl ; // change for emulator/device
  List<Map<String, dynamic>> _templates = [];
  List<String> _topics = ['scalability', 'oop', 'testing'];
  final AuthService authService;

  ApiServiceImpl({
    required this.authService,
    required this.baseUrl,
  }){
    _loadConfig();
  }
  // ApiServiceImpl(this.authService) {
  //   _loadConfig();
  // }

  Future<void> _loadConfig() async {
    try {
      final raw = await rootBundle.loadString('assets/config.json');
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final templates = json['questions'] as List<dynamic>?;
      final topics = json['topics'] as List<dynamic>?;
      if (templates != null) {
        _templates = templates.map((e) => Map<String, dynamic>.from(e)).toList();
      }
      if (topics != null) {
        _topics = topics.map((e) => e.toString()).toList();
      }
    } catch (_) {
      // fallback to internal templates
      _templates = [
        {
          'textTemplate': 'Explain {topic} and how you approached it',
          'tags': ['system', 'design'],
          'difficulty': 'medium'
        },
        {
          'textTemplate': 'Describe a time you solved {topic}',
          'tags': ['behavioral'],
          'difficulty': 'easy'
        },
      ];
    }
  }

  @override
  Future<List<Question>> fetchQuestions(int count) async {
    await Future.delayed(const Duration(milliseconds: 120));
    final list = <Question>[];
    for (var i = 0; i < count; i++) {
      final t = _templates.isNotEmpty ? _templates[i % _templates.length] : null;
      final topic = _topics.isNotEmpty ? _topics[i % _topics.length] : 'general';
      final text = t != null
          ? (t['question'] as String)
          //.replaceAll('{topic}', topic)
          : 'Explain $topic';
      final id = 'q${i + 1}';
      final tags = t != null ? List<String>.from(t['tags'] as List<dynamic>) : ['general'];
      final difficulty = t != null ? t['difficulty'] as String : 'easy';
      list.add(Question(id: id, text: text, tags: tags, difficulty: difficulty,tts: ""));
    }
    return list;
  }

  @override
  Future<Map<String, dynamic>> submitSessionData(String sessionId, CurrentMockSession? payload) async {
    if (payload == null) {
      throw Exception("Payload cannot be null");
    }
    final token = await authService.getAccessToken();
    final candidateId = await authService.getUserId();

    try {
      var encoder = JsonEncoder.withIndent('  ');
      var prettyJson = encoder.convert(payload);

      print("Submitting session data for candidate $candidateId:\n$prettyJson");

    }
    catch(Exception){
      print("unable to convert payload to json format");
    }
    if (token == null) {
      throw AuthException("Not authenticated");
    }

    final response = await http.post(
      Uri.parse("$baseUrl/submit-session"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(payload.toJson()),
    );

    if (response.statusCode == 401) {
      throw AuthException("Session expired");
    }
    if (response.statusCode != 200) {
      throw Exception("Backend error: ${response.body}");
    }

   // var sessionAnalysis = SessionAnalysis.fromJson(jsonDecode(response.body));

    var decoded =  jsonDecode(response.body);
    return jsonDecode(decoded['analysis']);
  }

  @override
  Future<GenerateQuestionsResponse?> generateQuestionsFromSkills({
   required Analysis analysis
  }) async {
    final token = await authService.getAccessToken();
    final candidateId = await authService.getUserId();

    if (token == null) {
      throw AuthException("Not authenticated");
    }

    final response = await http.post(
      Uri.parse("$baseUrl/generate-questions"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(analysis.toJson()),
    );

    if (response.statusCode == 401) {
      throw AuthException("Session expired");
    }
    if (response.statusCode != 200) {
      throw Exception("Backend error: ${response.body}");
    }

    return GenerateQuestionsResponse.fromJson(jsonDecode(response.body));
  }

  @override
  Future<GenerateQuestionsResponse?> getSkillSummary(String? cvData, String? jdData) async{
    final token = await authService.getAccessToken();
    final candidateId = await authService.getUserId();

    if (token == null) {
      throw AuthException("Not authenticated");
    }

    final response = await http.post(
      Uri.parse("$baseUrl/skill-analysis"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(GenerateQuestionsRequest(
        candidateId: candidateId ?? "unknown",
        cvText: cvData,
        jdText: jdData,
        matchedSkills: [],
        missingSkills: [],
      ).toJson()),
    );

    if (response.statusCode == 401) {
      throw AuthException("Session expired");
    }
    if (response.statusCode != 200) {
      throw Exception("Backend error: ${response.body}");
    }

    return GenerateQuestionsResponse.fromJson(jsonDecode(response.body));
  }
  //
  @override
  Future<GenerateQuestionsResponse?> getpendingMockInterviewForSession(String sessionId) async {
    final token = await authService.getAccessToken();
    final candidateId = await authService.getUserId();

    if (token == null) {
      throw AuthException("Not authenticated");
    }

    final response = await http.post(
      Uri.parse("$baseUrl/get-session"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "session_id": sessionId
      }),
    );

    if (response.statusCode == 401) {
      throw AuthException("Session expired");
    }
    if (response.statusCode != 200) {
      throw Exception("Backend error: ${response.body}");
    }

    return GenerateQuestionsResponse.fromJson(jsonDecode(response.body));
  }

  @override
  Future<List<Map<String, dynamic>>> fetchCandidateSessions() async{
    final token = await authService.getAccessToken();
    final candidateId = await authService.getUserId();

    if (token == null) {
      throw AuthException("Not authenticated");
    }

    final response = await http.post(
      Uri.parse("$baseUrl/get-candidate-sessions"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "candidate_id": candidateId
      }),
    );

    if (response.statusCode == 401) {
      throw AuthException("Session expired");
    }
    if (response.statusCode != 200) {
      throw Exception("Backend error: ${response.body}");
    }

    final List<dynamic> decoded = jsonDecode(response.body);
    final List<Map<String, dynamic>> data = decoded.cast<Map<String, dynamic>>();
    return data;
  }


  @override
  Future<Analysis> getLastCvJdAnalysis() async {
    final candidateId = await authService.getUserId();
    final token = await authService.getAccessToken();

    if (token == null) {
      throw AuthException("Not authenticated");
    }


    final response = await http.post(
      Uri.parse("$baseUrl/candidate-last-session"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "candidate_id": candidateId
      }),
    );

    if (response.statusCode == 401) {
      throw AuthException("Session expired");
    }
    else if (response.statusCode != 200) {
      throw Exception("Backend error: ${response.body}");
    }

    print("Last analysis response: ${response.body}");
    final Map<String, dynamic> data = jsonDecode(response.body);
    return Analysis.fromJson(data);
  }

  @override
  Future<List<String>> analyseCv(String fileName, String cvText) async{
    final token = await authService.getAccessToken();

    if (token == null) {
      throw AuthException("Not authenticated");
    }
    final url = Uri.parse("$baseUrl/analyze_cv");
    final resp = await http.post(url,  headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    }, body: jsonEncode({"fileName": fileName, "fileData": cvText}));
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      // 🔹 Extract the nested list
      final analysis = data['analysis']; // this is a Map<String, dynamic>
      final List<dynamic>? rawSkills = analysis?['cv_skills']; // can be null or list

      // 🔹 Convert to a list of strings safely
      final List<String> skills = rawSkills?.map((e) => e.toString()).toList() ?? [];

      return skills;
    } else {
      throw Exception('failed analyze cv');
    }
  }

  @override
  createOrUpdateProfile(Profile p) async {
    final url = Uri.parse("$baseUrl/create_or_update");
    final token = await authService.getAccessToken();

    if (token == null) {
      throw AuthException("Not authenticated");
    }
    final resp = await http.post(url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(p.toJson()));

    return resp;
  }

  @override
  Future getMyProfile() async{
    final url = Uri.parse("$baseUrl/me");
    final candidateId = await authService.getUserId();
    final token = await authService.getAccessToken();

    if (token == null) {
      throw AuthException("Not authenticated");
    }
    final resp = await http.post(url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
        "candidate_id": candidateId
        }));

    return resp;
  }

  @override
  Future<String?> getUserId()  async{
    final candidateId = await authService.getUserId();
    return candidateId;
  }

  @override
  Future<GenerateQuestionsResponse?> startSkillBasedSessoin(String jsonEncode) async {
    final url = Uri.parse("$baseUrl/generate-questions-from-skills");
    final candidateId = await authService.getUserId();
    final token = await authService.getAccessToken();

    if (token == null) {
      throw AuthException("Not authenticated");
    }
    final response = await http.post(url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode);
    if (response.statusCode == 401) {
      throw AuthException("Session expired");
    }
    if (response.statusCode != 200) {
      throw Exception("Backend error: ${response.body}");
    }
    return GenerateQuestionsResponse.fromJson(jsonDecode(response.body));
  }


  @override
  Future<Map<String, dynamic>?> fetchSessionDetails(String sessionId) async {
    print("fetchign session details for session id: ${sessionId}");
    final token = await authService.getAccessToken();

    if (token == null) {
      throw AuthException("Not authenticated");
    }

    final response = await http.post(
      Uri.parse("$baseUrl/get-session-analysis"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "session_id": sessionId
      }),
    );

    if (response.statusCode == 401) {
      print("auth error 401");
      throw AuthException("Session expired");
    }
    if (response.statusCode != 200) {
      print("error fetching session details: ${response.body}");
      throw Exception("Backend error: ${response.body}");
    }
    print("session details response: ${response.body}");
    final Map<String, dynamic> data = jsonDecode(response.body);
    return data;
  }

  @override
  Future<Map<String, dynamic>?> fetchAdaptiveInterviewSummary(String sessionId)async {
    print("fetchign session details for session id: ${sessionId}");
    final token = await authService.getAccessToken();

    if (token == null) {
      throw AuthException("Not authenticated");
    }

    final response = await http.post(
      Uri.parse("$baseUrl/get-adaptive-interview-summary"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "session_id": sessionId
      }),
    );

    if (response.statusCode == 401) {
      print("auth error 401");
      throw AuthException("Session expired");
    }
    if (response.statusCode != 200) {
      print("error fetching session details: ${response.body}");
      throw Exception("Backend error: ${response.body}");
    }
    print("session details response: ${response.body}");
    final Map<String, dynamic> data = jsonDecode(response.body);
    return data;
  }

  @override
  Future<Map<String, dynamic>> getInsights() async{
    final token = await authService.getAccessToken();

    if (token == null) {
      throw AuthException("Not authenticated");
    }

    final response = await http.get(
      Uri.parse("$baseUrl/insights/get-insights/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      }
    );

    if (response.statusCode == 401) {
      print("auth error 401");
      throw AuthException("Session expired");
    }
    if (response.statusCode != 200) {
      print("error fetching session details: ${response.body}");
      throw Exception("Backend error: ${response.body}");
    }
    print("session details response: ${response.body}");
    final Map<String, dynamic> data = jsonDecode(response.body);
    return data;
  }

  @override
  Future<Map<String, dynamic>> getCoachingForSession(String sessionId, String sessionType) async{
    final type = sessionType == "skills/adaptive" ? 1 : 0;
    final token = await authService.getAccessToken();
    final resp = await http.post(
    Uri.parse('$baseUrl/sessions/$sessionId/$type/generate_coaching'),
    headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
    );
    final data = jsonDecode(resp.body)['session_coaching'];
    return data;
  }

}
