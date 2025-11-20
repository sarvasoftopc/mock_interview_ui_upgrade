import 'package:flutter/foundation.dart';

class SttService {
  bool _initialized = false;

  Future<void> init() async {
    _initialized = true;
    debugPrint('SttService initialized (mock)');
  }

  Future<String> transcribe(Uint8List audioBytes) async {
    if (!_initialized) await init();
    await Future.delayed(const Duration(milliseconds: 200));
    return 'Transcribed text (mock)';
  }
}
