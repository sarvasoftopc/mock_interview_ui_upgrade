// audio_service_web.dart
// ✅ Flutter Web Audio Service using JS interop for MediaRecorder
// ✅ Works in Flutter 3.22 / Dart 3.3 and compiles cleanly

import 'dart:async';
import 'dart:html' as html;
import 'dart:js_util' as js_util;
// ignore: avoid_web_libraries_in_flutter
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:js/js_util.dart' show allowInterop;

//
// class AudioService {
//   bool _isRecording = false;
//   Uint8List _lastRecording = Uint8List(0);
//
//   html.MediaStream? _stream;
//   dynamic _recorder; // JS object (MediaRecorder)
//   final List<html.Blob> _chunks = [];
//   html.AudioElement? _audioElement;
//
//   Future<void> init() async {
//     debugPrint('[AudioService web] Initialized');
//   }
//
//   /// Start recording using the browser MediaRecorder API
//   Future<Uint8List> startRecording() async {
//     try {
//       _stream = await html.window.navigator.mediaDevices
//           ?.getUserMedia({'audio': true}) as html.MediaStream?;
//       if (_stream == null) throw Exception('Microphone not accessible');
//
//       _chunks.clear();
//
//       // Create JS MediaRecorder
//       _recorder = js_util.callConstructor(
//         js_util.getProperty(html.window, 'MediaRecorder'),
//         [_stream!, {'mimeType': 'audio/webm;codecs=opus'}],
//       );
//
//       // Attach JS event listeners
//       js_util.setProperty(_recorder, 'ondataavailable',
//               (event) => _onDataAvailable(event));
//
//       js_util.setProperty(_recorder, 'onstop', (event) async {
//         await _onStop();
//       });
//
//       js_util.callMethod(_recorder, 'start', []);
//       _isRecording = true;
//
//       debugPrint('[AudioService web] Recording started');
//       return Uint8List(0);
//     } catch (e) {
//       debugPrint('[AudioService web] Error starting recording: $e');
//       rethrow;
//     }
//   }
//
//   void _onDataAvailable(dynamic event) {
//     try {
//       final blob = js_util.getProperty(event, 'data');
//       if (blob != null) _chunks.add(blob as html.Blob);
//     } catch (e) {
//       debugPrint('[AudioService web] onDataAvailable error: $e');
//     }
//   }
//
//   Future<void> _onStop() async {
//     try {
//       final blob = html.Blob(_chunks);
//       final reader = html.FileReader();
//       reader.readAsArrayBuffer(blob);
//       await reader.onLoad.first;
//
//       final result = reader.result;
//       if (result is ByteBuffer) {
//         _lastRecording = Uint8List.view(result);
//       }
//
//       debugPrint('[AudioService web] Recording stopped (${_lastRecording.length} bytes)');
//     } catch (e) {
//       debugPrint('[AudioService web] onStop error: $e');
//     } finally {
//       _cleanup();
//     }
//   }
//
//   /// Stop recording and return recorded bytes
//   Future<Uint8List> stopRecording() async {
//     if (!_isRecording || _recorder == null) return Uint8List(0);
//     final completer = Completer<Uint8List>();
//
//     js_util.setProperty(_recorder, 'onstop', (event) async {
//       await _onStop();
//       completer.complete(_lastRecording);
//     });
//
//     js_util.callMethod(_recorder, 'stop', []);
//     _isRecording = false;
//
//     debugPrint('[AudioService web] Stopping recording...');
//     return completer.future;
//   }
//
//   /// Play recorded audio
//   Future<void> play() async {
//     if (_lastRecording.isEmpty) {
//       debugPrint('[AudioService web] No recording to play');
//       return;
//     }
//
//     try {
//       final blob = html.Blob([_lastRecording], 'audio/webm');
//       final url = html.Url.createObjectUrlFromBlob(blob);
//       _audioElement = html.AudioElement(url)
//         ..autoplay = true
//         ..controls = false;
//       html.document.body?.append(_audioElement!);
//       _audioElement!.onEnded.first.then((_) {
//         html.Url.revokeObjectUrl(url);
//         _audioElement?.remove();
//         _audioElement = null;
//       });
//     } catch (e) {
//       debugPrint('[AudioService web] play error: $e');
//     }
//   }
//
//   /// Stop all playback
//   Future<void> stopPlay() async {
//     try {
//       final audios = html.document.querySelectorAll('audio');
//       for (final a in audios) {
//         if (a is html.AudioElement) {
//           a.pause();
//           a.remove();
//         }
//       }
//       _audioElement = null;
//       debugPrint('[AudioService web] Playback stopped');
//     } catch (e) {
//       debugPrint('[AudioService web] stopPlay error: $e');
//     }
//   }
//
//   /// Delete/clear recorded audio
//   Future<void> deleteRecording() async {
//     _lastRecording = Uint8List(0);
//     _chunks.clear();
//     _audioElement?.remove();
//     _audioElement = null;
//     debugPrint('[AudioService web] Recording deleted');
//   }
//
//   void clearLastRecording() {
//     _lastRecording = Uint8List(0);
//   }
//
//   void _cleanup() {
//     try {
//       _stream?.getTracks().forEach((t) => t.stop());
//     } catch (_) {}
//     _stream = null;
//     _recorder = null;
//     _chunks.clear();
//   }
// }

// audio_service_web.dart
// Web-only AudioService using browser MediaRecorder via js interop.
//
// NOTE: This file is web-only. Keep your native/mobile AudioService unchanged.
// It uses dart:html + dart:js_util which are still the practical option today
// for MediaRecorder interop in Flutter web apps.

// ignore_for_file: avoid_web_libraries_in_flutter


class AudioService {
  bool _isRecording = false;
  Uint8List _lastRecording = Uint8List(0);

  html.MediaStream? _stream;
  dynamic _recorderJs; // JS MediaRecorder object (untyped)
  final List<html.Blob> _chunks = [];
  html.AudioElement? _audioElement;

  Future<void> init() async {
    // No-op for web
    debugPrint('[AudioService web] init');
  }

  /// Start recording using MediaRecorder
  Future<Uint8List> startRecording() async {
    try {
      if (_isRecording) {
        debugPrint('[AudioService web] startRecording ignored: already recording');
        return Uint8List(0);
      }
      // Request microphone
      final maybe = html.window.navigator.mediaDevices;
      if (maybe == null) throw Exception('MediaDevices not available');

      final streamObj = await maybe.getUserMedia({'audio': true});
      _stream = streamObj as html.MediaStream?;

      if (_stream == null) {
        throw Exception('Microphone not accessible');
      }

      // Clear previous chunks
      _chunks.clear();

      // Create JS MediaRecorder: new MediaRecorder(stream, { mimeType: 'audio/webm;codecs=opus' })
      final mediaRecorderCtor = js_util.getProperty(html.window, 'MediaRecorder');
      if (mediaRecorderCtor == null) {
        throw Exception('MediaRecorder not supported in this browser');
      }

      // options JS object
      String mime = 'audio/webm;codecs=opus';
      try {
        // try the preferred type; if not supported, pass empty options to let browser choose
        final supportCheck = js_util.callMethod(js_util.getProperty(html.window, 'MediaRecorder'), 'isTypeSupported', [mime]);
        if (supportCheck != true) {
          mime = 'audio/webm';
          final support2 = js_util.callMethod(js_util.getProperty(html.window, 'MediaRecorder'), 'isTypeSupported', [mime]);
          if (support2 != true) mime = '';
        }
      } catch (_) {
        mime = '';
      }
      final options = mime.isEmpty ? js_util.jsify({}) : js_util.jsify({'mimeType': mime});

      // call constructor
      _recorderJs = js_util.callConstructor(mediaRecorderCtor, [_stream!, options]);

      // set ondataavailable handler
      js_util.setProperty(_recorderJs, 'ondataavailable', allowInterop((event) {
        try {
          final blob = js_util.getProperty(event, 'data');
          if (blob != null) {
            _chunks.add(blob as html.Blob);
          }
        } catch (e) {
          debugPrint('[AudioService web] ondataavailable error: $e');
        }
      }));

      // optional onerror handler (safe)
      js_util.setProperty(_recorderJs, 'onerror', allowInterop((error) {
        debugPrint('[AudioService web] MediaRecorder error: $error');
      }));

      // start recording
      js_util.callMethod(_recorderJs, 'start', []);

      _isRecording = true;
      debugPrint('[AudioService web] recording started');
      return Uint8List(0);
    } catch (e, st) {
      debugPrint('[AudioService web] startRecording failed: $e\n$st');
      rethrow;
    }
  }

  /// Stop recording and return bytes
  Future<Uint8List> stopRecording() async {
    if (!_isRecording || _recorderJs == null) {
      debugPrint('[AudioService web] stopRecording ignored: not recording');
      return Uint8List(0);
    }

    final completer = Completer<Uint8List>();

    js_util.setProperty(_recorderJs, 'onstop', allowInterop((event) async {
      try {
        // combine blobs into one blob
        final blob = html.Blob(_chunks);
        final reader = html.FileReader();
        reader.readAsArrayBuffer(blob);
        // wait for load
        await reader.onLoad.first;
        final result = reader.result;
        if (result is ByteBuffer) {
          _lastRecording = Uint8List.view(result);
        } else if (result is List<int>) {
          _lastRecording = Uint8List.fromList(result);
        } else {
          _lastRecording = Uint8List(0);
        }
        completer.complete(_lastRecording);
      } catch (e, st) {
        completer.completeError(e);
        debugPrint('[AudioService web] onstop handler error: $e\n$st');
      } finally {
        _cleanup();
      }
    }));


    // call stop
    try {
      js_util.callMethod(_recorderJs, 'stop', []);
    } catch (e) {
      // some browsers may throw if recorder not in expected state; still finalize
      debugPrint('[AudioService web] call stop threw: $e');
      // attempt manual cleanup and resolve with whatever bytes we have
      try {
        final blob = html.Blob(_chunks);
        final reader = html.FileReader();
        reader.readAsArrayBuffer(blob);
        await reader.onLoad.first;
        final result = reader.result;
        if (result is ByteBuffer) _lastRecording = Uint8List.view(result);
      } catch (_) {}
      _cleanup();
      return _lastRecording;
    }

    _isRecording = false;
    debugPrint('[AudioService web] stopRecording triggered');
    return completer.future;
  }

  /// Play last recorded bytes (creates a blob URL and plays it)
  Future<void> play() async {
    if (_lastRecording.isEmpty) {
      debugPrint('[AudioService web] nothing to play');
      return;
    }

    try {
      // remove previous audio element
      try {
        _audioElement?.pause();
        _audioElement?.remove();
      } catch (_) {}

      final blob = html.Blob([_lastRecording], 'audio/webm');
      final url = html.Url.createObjectUrlFromBlob(blob);
      _audioElement = html.AudioElement(url)
        ..autoplay = true
        ..controls = false;
      html.document.body?.append(_audioElement!);

      // cleanup when ended
      _audioElement!.onEnded.first.then((_) {
        try {
          _audioElement?.remove();
        } catch (_) {}
        try {
          html.Url.revokeObjectUrl(url);
        } catch (_) {}
        _audioElement = null;
      });
      debugPrint('[AudioService web] playing');
    } catch (e, st) {
      debugPrint('[AudioService web] play error: $e\n$st');
    }
  }

  /// Stop playback (remove any audio tags)
  Future<void> stopPlay() async {
    try {
      final els = html.document.querySelectorAll('audio');
      for (final el in els) {
        if (el is html.AudioElement) {
          try {
            el.pause();
            el.remove();
          } catch (_) {}
        }
      }
      _audioElement = null;
      debugPrint('[AudioService web] stopped play');
    } catch (e) {
      debugPrint('[AudioService web] stopPlay error: $e');
    }
  }

  /// Delete recorded bytes and cleanup
  Future<void> deleteRecording() async {
    _lastRecording = Uint8List(0);
    _chunks.clear();
    try {
      _audioElement?.remove();
    } catch (_) {}
    _audioElement = null;
    debugPrint('[AudioService web] deleted recording');
  }

  void clearLastRecording() {
    _lastRecording = Uint8List(0);
  }

  void _cleanup() {
    try {
      _stream?.getTracks().forEach((t) => t.stop());
    } catch (_) {}
    _stream = null;
    _recorderJs = null;
    _chunks.clear();
  }
}
