// lib/models/candidate_session.dart
import 'package:json_annotation/json_annotation.dart';

import 'mock_interview_session.dart';

part 'candidate_session.g.dart';


@JsonSerializable()
class CandidateSession {
  @JsonKey(name: 'session_id')
  final String id;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  // server boolean flag column - true when completed
  @JsonKey(name: 'session_completed')
  final bool completed;

  @JsonKey(name: "session_completed_at")
  DateTime? sessionCompletedAt;

  @JsonKey(name:"session_type")
  String? sessionType;

  // optional: cached score (if available)
  final double? score;


  CandidateSession({
    required this.id,
    required this.createdAt,
    required this.completed,
    this.sessionCompletedAt,
    this.score,
    this.sessionType
  });

  SessionStatus get status => completed ? SessionStatus.completed : SessionStatus.inProgress;

  factory CandidateSession.fromJson(Map<String, dynamic> json) =>
      _$CandidateSessionFromJson(json);

  Map<String, dynamic> toJson() => _$CandidateSessionToJson(this);
}
