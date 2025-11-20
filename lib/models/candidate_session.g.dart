// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'candidate_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CandidateSession _$CandidateSessionFromJson(Map<String, dynamic> json) =>
    CandidateSession(
      id: json['session_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      completed: json['session_completed'] as bool,
      sessionCompletedAt: json['session_completed_at'] == null
          ? null
          : DateTime.parse(json['session_completed_at'] as String),
      score: (json['score'] as num?)?.toDouble(),
      sessionType: json['session_type'] as String?,
    );

Map<String, dynamic> _$CandidateSessionToJson(CandidateSession instance) =>
    <String, dynamic>{
      'session_id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'session_completed': instance.completed,
      'session_completed_at': instance.sessionCompletedAt?.toIso8601String(),
      'session_type': instance.sessionType,
      'score': instance.score,
    };
