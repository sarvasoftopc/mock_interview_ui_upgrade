// import 'dart:typed_data';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import '../../services/video_service.dart';
//
// // WEB
// import 'dart:html' as html;
// import 'dart:ui_web' as ui;
//
// class VideoRecorder extends StatefulWidget {
//   final VideoService service;
//   final bool isRecording;
//   final VoidCallback onStart;
//   final Future<void> Function() onStop;
//   final Future<void> Function()? onPlay;
//   final VoidCallback deleteRecording;
//   final bool isPlayEnabled;
//
//   const VideoRecorder({
//     required this.service,
//     required this.isRecording,
//     required this.onStart,
//     required this.onStop,
//     required this.deleteRecording,
//     required this.isPlayEnabled,
//     this.onPlay,
//     super.key,
//   });
//
//   @override
//   State<VideoRecorder> createState() => _VideoRecorderState();
// }
//
// class _VideoRecorderState extends State<VideoRecorder> {
//   html.VideoElement? _videoElement;
//
//   @override
//   void initState() {
//     super.initState();
//     widget.service.initCamera().then((_) => setState(() {}));
//   }
//
//   // -------------------------------------------------------
//   // WEB PREVIEW — single persistent <video> (NO FLICKER)
//   // -------------------------------------------------------
//   Widget _webPreview(html.MediaStream stream) {
//     if (_videoElement == null) {
//       _videoElement = html.VideoElement()
//         ..autoplay = true
//         ..muted = true
//         ..srcObject = stream
//         ..style.width = '100%'
//         ..style.height = '100%'
//         ..style.objectFit = 'cover';
//     }
//
//     final viewId = "web-preview-${_videoElement.hashCode}";
//     ui.platformViewRegistry.registerViewFactory(viewId, (_) => _videoElement!);
//
//     return HtmlElementView(viewType: viewId);
//   }
//
//   // -------------------------------------------------------
//   // PREVIEW (WEB + MOBILE)
//   // -------------------------------------------------------
//   Widget _preview() {
//     if (kIsWeb) {
//       final s = widget.service.webStream;
//       if (s == null) {
//         return const SizedBox(
//           height: 260,
//           child: Center(child: CircularProgressIndicator()),
//         );
//       }
//       return SizedBox(height: 260, child: _webPreview(s));
//     }
//
//     final controller = widget.service.mobileController;
//     if (controller == null || !controller.value.isInitialized) {
//       return const SizedBox(
//         height: 260,
//         child: Center(child: CircularProgressIndicator()),
//       );
//     }
//
//     return AspectRatio(
//       aspectRatio: controller.value.aspectRatio,
//       child: CameraPreview(controller),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         _preview(),
//
//         const SizedBox(height: 12),
//
//         // Controls Row
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             if (!widget.isRecording)
//               ElevatedButton(
//                 onPressed: widget.onStart,
//                 child: const Text("Start Video"),
//               ),
//             if (widget.isRecording)
//               ElevatedButton(
//                 onPressed: () async => await widget.onStop(),
//                 child: const Text("Stop"),
//               ),
//
//             const SizedBox(width: 10),
//
//             // Play Last always shows IF enabled by provider
//             if (widget.isPlayEnabled)
//               ElevatedButton(
//                 onPressed: () async {
//                   if (widget.onPlay != null) {
//                     await widget.onPlay!();
//                   }
//                 },
//                 child: const Text("Play Last"),
//               ),
//
//             const SizedBox(width: 8),
//
//             TextButton(
//               onPressed: widget.deleteRecording,
//               child: const Text("Delete"),
//             ),
//           ],
//         )
//       ],
//     );
//   }
//
//   @override
//   void dispose() {
//     widget.service.disposeCamera();
//     super.dispose();
//   }
//
// }

export 'video_recorder_mobile.dart'
if (dart.library.html) 'video_recorder_web.dart';
