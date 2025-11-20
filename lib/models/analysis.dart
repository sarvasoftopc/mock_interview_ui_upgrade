import 'package:json_annotation/json_annotation.dart';

part 'analysis.g.dart';
@JsonSerializable()
class Analysis {
  @JsonKey(name: "matched_skills", defaultValue: [])
  final List<String> matchedSkills;

  @JsonKey(name: "missing_skills", defaultValue: [])
  final List<String> missingSkills;

  @JsonKey(name: "cv_skills", defaultValue: [])
  final List<String> cvSkills;

  @JsonKey(name: "jd_skills", defaultValue: [])
  final List<String> jdSkills;

  @JsonKey(name: "extra_in_cv", defaultValue: [])
  final List<String> extraInCv;

  @JsonKey(name: "match_score_percent", defaultValue: 0)
  final int matchScorePercent;

  @JsonKey(name: "summary", defaultValue: "")
  final String summary;

  @JsonKey(name: "session_id", defaultValue: "")
  final String sessionId;






  Analysis({
    required this.matchedSkills,
    required this.missingSkills,
    required this.cvSkills,
    required this.jdSkills,
    required this.extraInCv,
    required this.matchScorePercent,
    required this.summary,
    required this.sessionId
  });

  Analysis.empty()
      : matchedSkills = const [],
        missingSkills = const [],
        cvSkills = const [],
        jdSkills = const [],
        extraInCv = const [],
        matchScorePercent = 0,
        summary = "",
        sessionId = "";

  factory Analysis.fromJson(Map<String, dynamic> json) =>
      _$AnalysisFromJson(json);

  Map<String, dynamic> toJson() => _$AnalysisToJson(this);
}
