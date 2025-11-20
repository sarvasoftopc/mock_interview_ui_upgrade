// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_tracking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProgressTracking _$ProgressTrackingFromJson(Map<String, dynamic> json) =>
    ProgressTracking(
      previous_sessions_avg: (json['previous_sessions_avg'] as num?)
          ?.toDouble(),
      improvement: (json['improvement'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ProgressTrackingToJson(ProgressTracking instance) =>
    <String, dynamic>{
      'previous_sessions_avg': instance.previous_sessions_avg,
      'improvement': instance.improvement,
    };
