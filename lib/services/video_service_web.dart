import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'dart:html' as html;

class VideoService {
  html.MediaStream? _webStream;
  html.MediaRecorder? _webRecorder;
  Completer<Uint8List>? _completer;
  html.Blob? _blob;

  html.MediaStream? get webStream => _webStream;

  Future<void> initCamera() async {
    if (_webStream != null) return;

    _webStream = await html.window.navigator.mediaDevices!
        .getUserMedia({'video': true, 'audio': true});
  }

  Future<void> startRecording() async {
    _blob = null;
    _completer = Completer<Uint8List>();

    _webRecorder = html.MediaRecorder(_webStream!);
    html.Blob blob = html.Blob([]);

    _webRecorder!.addEventListener("dataavailable", (event) {
      blob = (event as dynamic).data;
    });

    _webRecorder!.addEventListener("stop", (event) {
      final reader = html.FileReader();
      reader.readAsArrayBuffer(blob);
      reader.onLoadEnd.listen((_) {
        final bytes = Uint8List.fromList(reader.result as List<int>);
        if (!_completer!.isCompleted) _completer!.complete(bytes);
      });
    });

    _webRecorder!.start();
  }

  Future<Uint8List> stopRecording() async {
    _webRecorder!.stop();
    return _completer!.future;
  }

  Future<void> dispose() async {
    _webStream = null;
    _webRecorder = null;
    _completer = null;
    _blob = null;
  }

  Future<void> disposeCamera() async {
    try {
      _webStream?.getTracks().forEach((t) => t.stop());
    } catch (_) {}
    _webStream = null;
    _webRecorder = null;
  }

  String toWebDataUri(Uint8List bytes) =>
      "data:video/webm;base64,${base64Encode(bytes)}";
}
