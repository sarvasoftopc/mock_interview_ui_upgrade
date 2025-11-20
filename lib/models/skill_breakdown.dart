// lib/models/session_analysis.dart
import 'package:json_annotation/json_annotation.dart';

part 'skill_breakdown.g.dart';


@JsonSerializable()
class SkillsBreakdown {
  final int technical;
  final int communication;
  final int problem_solving;
  final int confidence;

  SkillsBreakdown({
    required this.technical,
    required this.communication,
    required this.problem_solving,
    required this.confidence,
  });

  factory SkillsBreakdown.fromJson(Map<String, dynamic> json) =>
      _$SkillsBreakdownFromJson(json);
  Map<String, dynamic> toJson() => _$SkillsBreakdownToJson(this);
}