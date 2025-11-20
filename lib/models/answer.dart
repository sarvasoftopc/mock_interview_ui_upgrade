import 'package:json_annotation/json_annotation.dart';

part 'answer.g.dart';

@JsonSerializable()
class Answer {
  final String questionId;
  final String? transcript;
  final String audioPath;
  final String timestamp;

  Answer({
    required this.questionId,
    this.transcript,
    this.audioPath = "",
    String? timestamp,
  }) : timestamp = timestamp ?? DateTime.now().toIso8601String();

  factory Answer.fromJson(Map<String, dynamic> json) => _$AnswerFromJson(json);
  Map<String, dynamic> toJson() => _$AnswerToJson(this);
}