// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'answer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Answer _$AnswerFromJson(Map<String, dynamic> json) => Answer(
  questionId: json['questionId'] as String,
  transcript: json['transcript'] as String?,
  audioPath: json['audioPath'] as String? ?? "",
  timestamp: json['timestamp'] as String?,
);

Map<String, dynamic> _$AnswerToJson(Answer instance) => <String, dynamic>{
  'questionId': instance.questionId,
  'transcript': instance.transcript,
  'audioPath': instance.audioPath,
  'timestamp': instance.timestamp,
};
