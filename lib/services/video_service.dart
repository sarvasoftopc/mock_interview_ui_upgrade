// import 'dart:async';
// import 'dart:convert';
// import 'dart:io' show File;
// import 'dart:typed_data';
//
// import 'package:flutter/foundation.dart';
// import 'package:camera/camera.dart';
//
// // WEB
// import 'dart:html' as html;
//
// class VideoService {
//   // -------------------------
//   // MOBILE
//   // -------------------------
//   CameraController? _mobileController;
//   CameraController? get mobileController => _mobileController;
//
//   // -------------------------
//   // WEB
//   // -------------------------
//   html.MediaStream? _webStream;
//   html.MediaRecorder? _webRecorder;
//
//   Completer<Uint8List>? _completer;
//   html.Blob? _blob;
//
//   html.MediaStream? get webStream => _webStream;
//
//   // ===========================================================
//   // INIT CAMERA
//   // ===========================================================
//   Future<void> initCamera() async {
//     if (kIsWeb) {
//       if (_webStream != null) return;  // already initialized
//
//       _webStream = await html.window.navigator.mediaDevices!
//           .getUserMedia({'video': true, 'audio': true});
//
//       return;
//     }
//
//     // MOBILE
//     final cams = await availableCameras();
//     _mobileController = CameraController(
//       cams.first,
//       ResolutionPreset.medium,
//       enableAudio: true,
//     );
//     await _mobileController!.initialize();
//   }
//
//   // ===========================================================
//   // START RECORDING
//   // ===========================================================
//   Future<void> startRecording() async {
//     if (kIsWeb) {
//       _blob = null;
//       _completer = Completer<Uint8List>();
//
//       _webRecorder = html.MediaRecorder(_webStream!);
//       html.Blob blob = html.Blob([]);
//
//       // Collect chunk
//       _webRecorder!.addEventListener("dataavailable", (event) {
//         blob = (event as dynamic).data;
//       });
//
//       // Finalize
//       _webRecorder!.addEventListener("stop", (event) {
//         final reader = html.FileReader();
//         reader.readAsArrayBuffer(blob);
//         reader.onLoadEnd.listen((_) {
//           final bytes = Uint8List.fromList(reader.result as List<int>);
//           if (!_completer!.isCompleted) {
//             _completer!.complete(bytes);
//           }
//         });
//
//         // IMPORTANT: DO NOT STOP TRACKS
//         // We keep camera running for next question preview
//       });
//
//       _webRecorder!.start();
//       return;
//     }
//
//     // MOBILE
//     if (_mobileController == null) {
//       throw Exception("Mobile camera not initialized");
//     }
//
//     await _mobileController!.startVideoRecording();
//   }
//
//   // ===========================================================
//   // STOP RECORDING
//   // ===========================================================
//   Future<Uint8List> stopRecording() async {
//     if (kIsWeb) {
//       _webRecorder!.stop();
//       return _completer!.future;
//     }
//
//     // MOBILE
//     final file = await _mobileController!.stopVideoRecording();
//     return await File(file.path).readAsBytes();
//   }
//
//   // ===========================================================
//   // WEB DATA URI ENCODER
//   // ===========================================================
//   String toWebDataUri(Uint8List bytes) {
//     return "data:video/webm;base64,${base64Encode(bytes)}";
//   }
//
//   // ===========================================================
//   // DISPOSE
//   // ===========================================================
//   Future<void> dispose() async {
//     try {
//       await _mobileController?.dispose();
//     } catch (_) {}
//
//     _mobileController = null;
//     _webStream = null;
//     _webRecorder = null;
//     _completer = null;
//     _blob = null;
//   }
//
//   Future<void> disposeCamera() async {
//     if (kIsWeb) {
//       try {
//         _webStream?.getTracks().forEach((t) => t.stop());
//       } catch (_) {}
//       _webStream = null;
//       _webRecorder = null;
//       return;
//     }
//
//     try {
//       await _mobileController?.dispose();
//     } catch (_) {}
//
//     _mobileController = null;
//   }
//
// }

export 'video_service_mobile.dart'
if (dart.library.html) 'video_service_web.dart';
