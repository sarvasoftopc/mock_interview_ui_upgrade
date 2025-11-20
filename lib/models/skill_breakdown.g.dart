// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'skill_breakdown.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SkillsBreakdown _$SkillsBreakdownFromJson(Map<String, dynamic> json) =>
    SkillsBreakdown(
      technical: (json['technical'] as num).toInt(),
      communication: (json['communication'] as num).toInt(),
      problem_solving: (json['problem_solving'] as num).toInt(),
      confidence: (json['confidence'] as num).toInt(),
    );

Map<String, dynamic> _$SkillsBreakdownToJson(SkillsBreakdown instance) =>
    <String, dynamic>{
      'technical': instance.technical,
      'communication': instance.communication,
      'problem_solving': instance.problem_solving,
      'confidence': instance.confidence,
    };
