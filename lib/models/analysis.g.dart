// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analysis.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Analysis _$AnalysisFromJson(Map<String, dynamic> json) => Analysis(
  matchedSkills:
      (json['matched_skills'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      [],
  missingSkills:
      (json['missing_skills'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      [],
  cvSkills:
      (json['cv_skills'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      [],
  jdSkills:
      (json['jd_skills'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      [],
  extraInCv:
      (json['extra_in_cv'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      [],
  matchScorePercent: (json['match_score_percent'] as num?)?.toInt() ?? 0,
  summary: json['summary'] as String? ?? '',
  sessionId: json['session_id'] as String? ?? '',
);

Map<String, dynamic> _$AnalysisToJson(Analysis instance) => <String, dynamic>{
  'matched_skills': instance.matchedSkills,
  'missing_skills': instance.missingSkills,
  'cv_skills': instance.cvSkills,
  'jd_skills': instance.jdSkills,
  'extra_in_cv': instance.extraInCv,
  'match_score_percent': instance.matchScorePercent,
  'summary': instance.summary,
  'session_id': instance.sessionId,
};
