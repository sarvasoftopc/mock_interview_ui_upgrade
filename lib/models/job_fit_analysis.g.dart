// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_fit_analysis.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JobFitAnalysis _$JobFitAnalysisFromJson(Map<String, dynamic> json) =>
    JobFitAnalysis(
      fit_score: (json['fit_score'] as num).toInt(),
      strengths_for_role: (json['strengths_for_role'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      gaps_for_role: (json['gaps_for_role'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$JobFitAnalysisToJson(JobFitAnalysis instance) =>
    <String, dynamic>{
      'fit_score': instance.fit_score,
      'strengths_for_role': instance.strengths_for_role,
      'gaps_for_role': instance.gaps_for_role,
    };
