// lib/models/session_analysis.dart
import 'package:json_annotation/json_annotation.dart';

part 'per_answer_analysis.g.dart';

@JsonSerializable(explicitToJson: true)
class PerAnswerAnalysis {
  final int relevance;
  final int completeness;
  final int accuracy;
  final int fluency;
  final int confidence;
  final int score;
  final String model_answer;
  final String candidate_answer;
  final String question_id;
  final String question;
  final String feedback;

  PerAnswerAnalysis({
    required this.relevance,
    required this.completeness,
    required this.accuracy,
    required this.fluency,
    required this.confidence,
    required this.score,
    required this.model_answer,
    required this.question_id,
    required this.question,
    required this.candidate_answer,
    required this.feedback,
  });

  factory PerAnswerAnalysis.fromJson(Map<String, dynamic> json) =>
      _$PerAnswerAnalysisFromJson(json);
  Map<String, dynamic> toJson() => _$PerAnswerAnalysisToJson(this);
}

