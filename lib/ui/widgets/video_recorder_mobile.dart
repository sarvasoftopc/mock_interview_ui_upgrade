import 'package:flutter/material.dart';

class VideoRecorder extends StatelessWidget {
  final dynamic service;
  final bool isRecording;
  final VoidCallback? onStart;
  final Future<void> Function()? onStop;
  final Future<void> Function()? onPlay;
  final VoidCallback? deleteRecording;
  final bool isPlayEnabled;

  const VideoRecorder({
    super.key,
    this.service,
    this.isRecording = false,
    this.onStart,
    this.onStop,
    this.onPlay,
    this.deleteRecording,
    this.isPlayEnabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return const Text(
      "Video recording is only supported on Web.",
      style: TextStyle(fontSize: 16),
    );
  }
}
