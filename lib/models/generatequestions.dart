import 'analysis.dart';

class GenerateQuestionsRequest {
  final String? candidateId;
  final String? cvText;
  final String? jdText;
  final int numQuestions;
  final List<String>? matchedSkills;
  final List<String>? missingSkills;

  GenerateQuestionsRequest({
    this.candidateId,
    this.cvText,
    this.jdText,
    this.numQuestions = 6,
    this.matchedSkills = const [],
    this.missingSkills = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      "candidate_id": candidateId,
      "cv_text": cvText,
      "jd_text": jdText,
      "num_questions": numQuestions,
      "matched_skills": matchedSkills,
      "missing_skills": missingSkills,
    };
  }
}

class InterviewQuestion {
  final String question;
  final List<String> tags;
  List<String>? hints;
  List<String>? topics;
  final String difficulty;
  final String? ttsFile;
  String id="";

  // ✅ Getters
  String get getQuestion => question;
  List<String> get getTags => tags;
  List<String>? get getHints => hints;
  List<String>? get getTopics => topics;
  String get getDifficulty => difficulty;
  String? get getTtsFile => ttsFile;
  String get getId => id;
  InterviewQuestion({
    required this.question,
    required this.tags,
    required this.difficulty,
    this.ttsFile,
    this.hints,
    required this.id,
    this.topics
  });

  factory InterviewQuestion.fromJson(Map<String, dynamic> json) {
    return InterviewQuestion(
      question: json["question"],
      tags: List<String>.from(json["tags"] ?? []),
      difficulty: json["difficulty"] ?? "medium",
      ttsFile: json["tts_file"],
      id: json["id"],
      hints: List<String>.from(json["tags"] ?? []),
        topics:List<String>.from(json["topics"] ?? []),
    );
  }
}


class GenerateQuestionsResponse {
  final String sessionId;
  final String createdAt;
  final String candidateId;
  final Analysis analysis;
  List<InterviewQuestion> questions=[];
  final List<String> topics;
  final String sessionType;
  GenerateQuestionsResponse({
    required this.sessionId,
    required this.createdAt,
    required this.analysis,
    required this.candidateId,
    required this.questions,
    required this.topics,
    required this.sessionType
  });

  factory GenerateQuestionsResponse.fromJson(Map<String, dynamic> json) {
    final analysisJson = json["analysis"] ?? {};
    return GenerateQuestionsResponse(
      analysis: Analysis.fromJson(analysisJson),
      questions: (json["questions"] as List? ?? [])
          .map((q) => InterviewQuestion.fromJson(q))
          .toList(),
      topics: List<String>.from(json["topics"] ?? []),
      sessionId: json["session_id"] ?? "",
      createdAt: json["created_at"] ?? "",
      candidateId: analysisJson["candidate_id"]?? "",
      sessionType: json["session_type"] ?? "cv/skills"

    );
  }

}
