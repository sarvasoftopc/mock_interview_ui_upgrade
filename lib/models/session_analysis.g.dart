// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_analysis.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionAnalysis _$SessionAnalysisFromJson(Map<String, dynamic> json) =>
    SessionAnalysis(
      per_answer_analysis: (json['per_answer_analysis'] as List<dynamic>)
          .map((e) => PerAnswerAnalysis.fromJson(e as Map<String, dynamic>))
          .toList(),
      overall_relevance: (json['overall_relevance'] as num).toInt(),
      overall_completeness: (json['overall_completeness'] as num).toInt(),
      overall_accuracy: (json['overall_accuracy'] as num).toInt(),
      overall_fluency: (json['overall_fluency'] as num).toInt(),
      candidateToneAnalysis: (json['candidate_tone_analysis'] as num).toInt(),
      overall_confidence: (json['overall_confidence'] as num).toInt(),
      overall_score: (json['overall_score'] as num).toInt(),
      strengths: (json['strengths'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      weaknesses: (json['weaknesses'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      summary: json['summary'] as String,
      skills_breakdown: SkillsBreakdown.fromJson(
        json['skills_breakdown'] as Map<String, dynamic>,
      ),
      progress_tracking: ProgressTracking.fromJson(
        json['progress_tracking'] as Map<String, dynamic>,
      ),
      job_fit_analysis: JobFitAnalysis.fromJson(
        json['job_fit_analysis'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$SessionAnalysisToJson(SessionAnalysis instance) =>
    <String, dynamic>{
      'per_answer_analysis': instance.per_answer_analysis
          .map((e) => e.toJson())
          .toList(),
      'overall_relevance': instance.overall_relevance,
      'overall_completeness': instance.overall_completeness,
      'overall_accuracy': instance.overall_accuracy,
      'overall_fluency': instance.overall_fluency,
      'candidate_tone_analysis': instance.candidateToneAnalysis,
      'overall_confidence': instance.overall_confidence,
      'overall_score': instance.overall_score,
      'strengths': instance.strengths,
      'weaknesses': instance.weaknesses,
      'recommendations': instance.recommendations,
      'summary': instance.summary,
      'skills_breakdown': instance.skills_breakdown.toJson(),
      'progress_tracking': instance.progress_tracking.toJson(),
      'job_fit_analysis': instance.job_fit_analysis.toJson(),
    };
