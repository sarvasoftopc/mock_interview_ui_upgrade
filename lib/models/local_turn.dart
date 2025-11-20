
import 'package:sarvasoft_moc_interview/models/generatequestions.dart';

import 'adaptive_models.dart';

enum TurnStatus { pending, uploading, uploaded, processing, processed, failed,session_completed }

class LocalTurn {
  //current turn
  int currentTurn = 0;
  InterviewQuestion interviewQuestion;

  //current difficulty
  //int currentDifficulty;
  // Current question
  // String currentQuestion;
  // String currentQuestionId;
  // String currentQuestionttsUrl;
  // List<String> currentHints = [];
  // List<String> currentTags = [];
  // List<String> currentTopics= [];

  //Current answer
  String? currentAnswerLocalPath;
  String? currentAnswerUrl;

  TurnStatus status;

  DateTime createdAt;
  AnswerFeedback? answerFeedback;




  LocalTurn({
    required this.currentTurn,
    required this.interviewQuestion,
    this.status = TurnStatus.pending,

    //answers
    this.currentAnswerLocalPath,
    this.currentAnswerUrl,
    DateTime? createdAt,

  }) : createdAt = createdAt ?? DateTime.now();

  get currentInterviewQuestion => interviewQuestion;



  Map<String, dynamic> toJson() => {
    'turn_index': currentTurn,
    'currentQuestion': interviewQuestion,
    // 'difficulty': currentDifficulty,
    // 'question_id': currentQuestionId,
    // 'question': currentQuestion,
    // 'question_url': currentQuestionttsUrl,
    // 'hints': currentHints,
    // 'tags': currentTags,
    // 'topics': currentTopics,
    'status': status.toString(),

    'answer_local_Path': currentAnswerLocalPath,
    'answer_tts_url': currentAnswerUrl,

    'createdAt': createdAt.toIso8601String(),
  };
}