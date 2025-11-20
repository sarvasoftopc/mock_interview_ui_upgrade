// audio_service_io.dart
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:record/record.dart';

class AudioService {
  bool _initialized = false;
  bool _recording = false;

  // You had AudioRecorder from platform_utils.dart; keep it
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  late Uint8List _lastRecording;

  Future<void> init() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      throw Exception("Microphone permission not granted");
    }
    _initialized = true;
    debugPrint('AudioService initialized (real/native)');
  }

  // Start recording. Returns empty bytes (we read real bytes on stop).
  Future<Uint8List> startRecording() async {
    if (!_initialized) await init();

    _recording = true;

    final tempPath =
        '${Directory.systemTemp.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      ),
      path: tempPath,
    );

    return Uint8List(0);
  }

  // Stop recording and return bytes
  Future<Uint8List> stopRecording() async {
    _recording = false;
    final path = await _recorder.stop();

    if (path == null) {
      throw Exception("No audio file created");
    }

    final file = File(path);
    final bytes = await file.readAsBytes();

      _lastRecording = bytes;
    return bytes;
  }

  // Play using just_audio: write last bytes to a temp file and play
  Future<void> play() async {
    if (_lastRecording.isEmpty) {
      debugPrint('[AudioService IO] No last recording to play');
      return;
    }

    final tempFile = File(
        '${Directory.systemTemp.path}/playback_${DateTime.now().millisecondsSinceEpoch}.m4a');
    await tempFile.writeAsBytes(_lastRecording, flush: true);

    await _player.setFilePath(tempFile.path);
    await _player.play();
  }


  Future<void> stopPlay() async {
    await _player.stop();
  }

  Future<void> dispose() async {
    await _player.dispose();
  }

  // Reset the last recording buffer
  void clearLastRecording() {
    _lastRecording = Uint8List(0);
  }
}
