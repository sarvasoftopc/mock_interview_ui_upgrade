import 'package:json_annotation/json_annotation.dart';
import 'package:sarvasoft_moc_interview/models/answer.dart';
import 'package:sarvasoft_moc_interview/models/session_analysis.dart';

part 'mock_interview_session.g.dart';

enum SessionStatus { pending, inProgress, completed ,failed}
enum SessionType { adaptive, normal}


@JsonSerializable()
class CurrentMockSession {
  final String id;
  final DateTime startedAt;
  SessionType? sessionType;
  final List<Answer> answers;
  SessionStatus status;
  SessionAnalysis? analysis;
  double? score;
  CurrentMockSession({
    required this.id,
    required this.startedAt,
    List<Answer>? answers,
    this.status = SessionStatus.pending,
    this.score,
    SessionType? type,
    SessionAnalysis? sessionAnalysis,
  }) : answers = answers ?? [],sessionType = type ?? SessionType.normal;

  /// Factory that uses the generated helper
  factory CurrentMockSession.fromJson(Map<String, dynamic> json) =>
      _$CurrentMockSessionFromJson(json);

  /// Method that uses the generated helper
  Map<String, dynamic> toJson() => _$CurrentMockSessionToJson(this);
}
