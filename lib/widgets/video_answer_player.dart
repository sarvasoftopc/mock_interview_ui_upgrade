import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoAnswerPlayer extends StatefulWidget {
  final String path; // data URI on web, file path on mobile

  const VideoAnswerPlayer({required this.path, super.key});

  @override
  State<VideoAnswerPlayer> createState() => _VideoAnswerPlayerState();
}

class _VideoAnswerPlayerState extends State<VideoAnswerPlayer> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    // WEB: use network() with data URI
    if (kIsWeb) {
      _controller = VideoPlayerController.network(widget.path);
    }
    // MOBILE: use file()
    else {
      _controller = VideoPlayerController.file(File(widget.path));
    }

    await _controller!.initialize();
    setState(() {});
    _controller!.play();
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    if (c == null || !c.value.isInitialized) {
      return const SizedBox(
        height: 240,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return AspectRatio(
      aspectRatio: c.value.aspectRatio,
      child: Stack(
        children: [
          VideoPlayer(c),
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: VideoProgressIndicator(c, allowScrubbing: true),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
