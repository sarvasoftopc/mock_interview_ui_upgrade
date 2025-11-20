// audio_service.dart
// Re-export the correct platform implementation.
// When compiled for web, the web file is used. Otherwise the io/native file is used.

export 'audio_service_io.dart'
if (dart.library.html) 'audio_service_web.dart';
// class AudioService {
//   bool _initialized = false;
//   bool _recording = false;
//   // ✅ Correct way: factory constructor
//   final AudioRecorder _recorder = AudioRecorder();
//   final AudioPlayer _player = AudioPlayer();
//
//   late Uint8List _lastRecording;
//
//
//   Future<void> init() async {
//     final hasPermission = await _recorder.hasPermission();
//     if (!hasPermission) {
//       throw Exception("Microphone permission not granted");
//     }
//     _initialized = true;
//     debugPrint('AudioService initialized (real)');
//   }
//
//   Future<Uint8List> startRecording() async {
//     if (!_initialized) await init();
//
//     _recording = true;
//
//     // Start recording to a temp file
//     final tempPath = '${Directory.systemTemp.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
//
//     await _recorder.start(
//       const RecordConfig(
//         encoder: AudioEncoder.aacLc,
//         bitRate: 128000,
//         sampleRate: 16000,
//       ),
//       path: tempPath,
//     );
//
//     // Nothing to return yet, actual audio will be read on stop()
//     return Uint8List(0);
//   }
//
//   Future<Uint8List> stopRecording() async {
//     _recording = false;
//     final path = await _recorder.stop();
//
//     if (path == null) {
//       throw Exception("No audio file created");
//     }
//
//
//     // You can also save the file to permanent storage if needed
//
//     final file = File(path);
//     // Read bytes from file
//     final bytes = await file.readAsBytes();
//
//     // Save to _lastRecording so we can play it later
//     _lastRecording = bytes;
//
//     return bytes;
//
//   }
//
//
//   Future<void> play() async {
//     // Write the audio bytes to a temp file for playback
//     final tempFile =
//     File('${Directory.systemTemp.path}/playback_${DateTime.now().millisecondsSinceEpoch}.m4a');
//     await tempFile.writeAsBytes(_lastRecording, flush: true);
//
//     await _player.setFilePath(tempFile.path);
//     await _player.play();
//   }
//
//   Future<void> dispose() async {
//     await _player.dispose();
//   }
//
//   Future<void> stopPlay() async {
//     await _player.stop();
//   }
//
//   void clearLastRecording() {
//     _lastRecording.clear();
//   }
// }
