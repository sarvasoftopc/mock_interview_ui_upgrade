// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mock_interview_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CurrentMockSession _$CurrentMockSessionFromJson(Map<String, dynamic> json) =>
    CurrentMockSession(
        id: json['id'] as String,
        startedAt: DateTime.parse(json['startedAt'] as String),
        answers: (json['answers'] as List<dynamic>?)
            ?.map((e) => Answer.fromJson(e as Map<String, dynamic>))
            .toList(),
        status:
            $enumDecodeNullable(_$SessionStatusEnumMap, json['status']) ??
            SessionStatus.pending,
        score: (json['score'] as num?)?.toDouble(),
      )
      ..sessionType = $enumDecodeNullable(
        _$SessionTypeEnumMap,
        json['sessionType'],
      )
      ..analysis = json['analysis'] == null
          ? null
          : SessionAnalysis.fromJson(json['analysis'] as Map<String, dynamic>);

Map<String, dynamic> _$CurrentMockSessionToJson(CurrentMockSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'startedAt': instance.startedAt.toIso8601String(),
      'sessionType': _$SessionTypeEnumMap[instance.sessionType],
      'answers': instance.answers,
      'status': _$SessionStatusEnumMap[instance.status]!,
      'analysis': instance.analysis,
      'score': instance.score,
    };

const _$SessionStatusEnumMap = {
  SessionStatus.pending: 'pending',
  SessionStatus.inProgress: 'inProgress',
  SessionStatus.completed: 'completed',
  SessionStatus.failed: 'failed',
};

const _$SessionTypeEnumMap = {
  SessionType.adaptive: 'adaptive',
  SessionType.normal: 'normal',
};
