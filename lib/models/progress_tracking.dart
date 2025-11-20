// lib/models/session_analysis.dart
import 'package:json_annotation/json_annotation.dart';

part 'progress_tracking.g.dart';

@JsonSerializable()
class ProgressTracking {
  final double? previous_sessions_avg;
  final double? improvement;

  ProgressTracking({this.previous_sessions_avg, this.improvement});

  factory ProgressTracking.fromJson(Map<String, dynamic> json) =>
      _$ProgressTrackingFromJson(json);
  Map<String, dynamic> toJson() => _$ProgressTrackingToJson(this);
}