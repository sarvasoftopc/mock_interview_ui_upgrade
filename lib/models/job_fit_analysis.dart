import 'package:json_annotation/json_annotation.dart';

part 'job_fit_analysis.g.dart';

@JsonSerializable()
class JobFitAnalysis {
  final int fit_score;
  final List<String> strengths_for_role;
  final List<String> gaps_for_role;

  JobFitAnalysis({
    required this.fit_score,
    required this.strengths_for_role,
    required this.gaps_for_role,
  });

  factory JobFitAnalysis.fromJson(Map<String, dynamic> json) =>
      _$JobFitAnalysisFromJson(json);
  Map<String, dynamic> toJson() => _$JobFitAnalysisToJson(this);
}
