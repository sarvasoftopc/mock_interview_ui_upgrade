class AnswerFeedback {
  final double? score; // 0..1
  final String? rationale;
  final String? modelAnswer;
  final String? candidateAnswer;
  final DateTime timestamp;

  AnswerFeedback({
    this.score,
    this.rationale,
    this.modelAnswer,
    this.candidateAnswer,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory AnswerFeedback.fromJson(Map j) => AnswerFeedback(
    score: j['score'] != null ? (j['score'] as num).toDouble() : null,
    rationale: j['rationale']?.toString(),
    modelAnswer: j['model_answer']?.toString() ?? j['modelAnswer']?.toString(),
    candidateAnswer: j['candidate_answer']?.toString()?? j['candidateAnswer']?.toString()
  );

  Map toJson() => {
    'score': score,
    'rationale': rationale,
    'model_answer': modelAnswer,
    'candidate_answer':candidateAnswer
  };
}
