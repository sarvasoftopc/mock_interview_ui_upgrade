// web_audio_helper.dart
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:flutter/foundation.dart';

Future<void> playWebAudio(String path) async {
  if (!kIsWeb) return;
  try {
    // Accept data: URI or http(s) URL
    if (path.startsWith('data:') || path.startsWith('http')) {
      final audio = html.AudioElement(path)
        ..autoplay = true
        ..controls = false;
      html.document.body?.append(audio);
      audio.onEnded.first.then((_) => audio.remove());
    } else {
      // Unknown path - ignore
      debugPrint('[WebAudio] Unknown path format: $path');
    }
  } catch (e) {
    debugPrint('[WebAudio] play error: $e');
  }
}

Future<void> stopWebAudioPlayback() async {
  if (!kIsWeb) return;
  try {
    final audioTags = html.document.querySelectorAll('audio');
    for (final element in audioTags) {
      if (element is html.AudioElement) {
        element.pause();
        element.remove();
      }
    }
  } catch (e) {
    debugPrint('[WebAudio] stop error: $e');
  }
}
