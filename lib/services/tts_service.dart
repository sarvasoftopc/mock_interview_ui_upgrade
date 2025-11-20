import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';

import '../utils/env_config.dart';
class TtsService {
//   final String baseUrl=dotenv.env['SUPABASE_URL']!+"/storage/v1/";
   final String baseUrl = "${Env.supabaseUrl}/storage/v1";
  bool _initialized = false;
  late final AudioPlayer _audioPlayer;
   late final FlutterTts _tts;
  Future<void> init() async {
    _initialized = true;
    _audioPlayer = AudioPlayer();
    _tts = FlutterTts();
    debugPrint('TtsService initialized (mock)');
  }

  // Keep original default constructor behaviour by giving baseUrl default ''
  TtsService();

   Future<bool> setUrl(String url) async {
     try {
       // Stop current playback first to ensure player accepts new source
       await _audioPlayer.stop();

       // If the content at the same URL may change, add cache-buster:
       final uri = Uri.parse(url).replace(
         queryParameters: {
           ...Uri.parse(url).queryParameters,
           'cb': DateTime.now().millisecondsSinceEpoch.toString(),
         },
       );

       // Use setUrl (returns Duration? when loaded) OR setAudioSource
       final duration = await _audioPlayer.setUrl(uri.toString());
       debugPrint('setUrl returned duration: $duration');

       return duration != null;
     } catch (e, st) {
       debugPrint('setUrl error: $e\n$st');
       return false;
     }
   }

  Future<bool> setFile(String filePath) async {
    try {
      debugPrint("🔊 Setting audio file: $filePath");

      // Attempt to load the file
      await _audioPlayer.setFilePath(filePath);
      debugPrint("✅ Audio file set successfully");
      return true;
    } on PlayerException catch (e) {
      debugPrint("❌ PlayerException: ${e.message}");
    } on PlayerInterruptedException catch (e) {
      debugPrint("❌ Playback interrupted: ${e.message}");
    } catch (e) {
      debugPrint("❌ Unknown error setting audio file: $e");
    }

    return false;
  }

  Future<void> speak(String text, String? ttsfile,{double rate = 1.0, double pitch = 1.0}) async {
    if (!_initialized) await init();
    // Mock speak: just debug log

    debugPrint('TTS speaking: $text (rate=$rate pitch=$pitch)');
    if(ttsfile != null && ttsfile.isNotEmpty){
      bool result = await setUrlsAndPlay(baseUrl+ttsfile);
      if(!result){
        await _tts.awaitSpeakCompletion(true);
        await _tts.speak(text);
        // Wait briefly to allow TTS finish event (flutter_tts sometimes completes early)
        // Or listen to TTS completion callbacks and resume after that instead
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }

  }


   Future<bool> setUrlsAndPlay(String url1) async {
     try {
       debugPrint('Setting and playing: $url1');

       final ok = await setUrl(url1);
       if (!ok) {
         debugPrint('Failed to set url');
         return false;
       }

       // Ensure the player is ready before play (optional but safe)
       await _audioPlayer.processingStateStream.firstWhere(
             (s) => s == ProcessingState.ready || s == ProcessingState.completed,
       );

       await _audioPlayer.play();

       // wait until finished
       await _audioPlayer.processingStateStream.firstWhere(
             (s) => s == ProcessingState.completed,
       );

       return true;
     } catch (e, st) {
       debugPrint('setUrlsAndPlay error: $e\n$st');
       return false;
     }
   }


  Future<bool> play() async {
    try {
      await _audioPlayer.play();

      debugPrint("✅ Prompt playback started");

      // ⏳ Wait until playback completes
      await _audioPlayer.processingStateStream
          .firstWhere((state) => state == ProcessingState.completed);

      debugPrint("✅ Prompt playback completed");
      return true;
    } on PlayerException catch (e) {
      debugPrint("❌ PlayerException: ${e.message}");
    } on PlayerInterruptedException catch (e) {
      debugPrint("❌ Playback interrupted: ${e.message}");
    } catch (e) {
      debugPrint("❌ Unknown playback error: $e");
    }

    return false;
  }


  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> resume() async {
    await _audioPlayer.play();
  }

  bool get isPlaying => _audioPlayer.playing;

  void dispose() {
    _audioPlayer.dispose();
  }
}
