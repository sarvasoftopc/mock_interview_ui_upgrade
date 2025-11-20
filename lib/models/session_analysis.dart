
import 'package:json_annotation/json_annotation.dart';
import 'package:sarvasoft_moc_interview/models/per_answer_analysis.dart';
import 'package:sarvasoft_moc_interview/models/progress_tracking.dart';
import 'package:sarvasoft_moc_interview/models/skill_breakdown.dart';

import 'job_fit_analysis.dart';

part 'session_analysis.g.dart';

@JsonSerializable(explicitToJson: true)
class SessionAnalysis {
  final List<PerAnswerAnalysis> per_answer_analysis;

  // session-level metrics
  final int overall_relevance;
  final int overall_completeness;
  final int overall_accuracy;
  final int overall_fluency;
  @JsonKey(name: 'candidate_tone_analysis')
  final int candidateToneAnalysis;
  final int overall_confidence;
  final int overall_score;

  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> recommendations;
  final String summary;

  final SkillsBreakdown skills_breakdown;
  final ProgressTracking progress_tracking;
  final JobFitAnalysis job_fit_analysis;

  SessionAnalysis({
    required this.per_answer_analysis,
    required this.overall_relevance,
    required this.overall_completeness,
    required this.overall_accuracy,
    required this.overall_fluency,
    required this.candidateToneAnalysis,
    required this.overall_confidence,
    required this.overall_score,
    required this.strengths,
    required this.weaknesses,
    required this.recommendations,
    required this.summary,
    required this.skills_breakdown,
    required this.progress_tracking,
    required this.job_fit_analysis,
  });

  factory SessionAnalysis.fromJson(Map<String, dynamic> json) =>
      _$SessionAnalysisFromJson(json);

  Map<String, dynamic> toJson() => _$SessionAnalysisToJson(this);
}
