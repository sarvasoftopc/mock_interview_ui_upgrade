import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:sarvasoft_moc_interview/providers/adaptive_session_provider.dart';
import 'package:sarvasoft_moc_interview/providers/cv_jd_provider.dart';
import 'package:sarvasoft_moc_interview/providers/profile_provider.dart';
import 'package:sarvasoft_moc_interview/providers/session_provider.dart';
import 'package:sarvasoft_moc_interview/services/video_service.dart';

import '../services/api_service.dart';
import '../services/audio_service.dart';
import '../services/file_service.dart';
import '../services/storage_service.dart';
import '../services/stt_service.dart';
import '../services/tts_service.dart';
import 'auth_provider.dart';
import 'interview_provider.dart';
import 'settings_provider.dart';

class Providers {
  static List<SingleChildWidget> list() => [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (ctx) => SettingsProvider()),
        // Provide ApiService, StorageService, AudioService, FileService, TtsService, SttService
          Provider<ApiService>(
            create: (ctx) => ApiServiceImpl(authService: ctx.read<AuthProvider>().authService, baseUrl: "https://convolvulaceous-kati-coagulatory.ngrok-free.dev"),
          ),
        Provider<StorageService>(create: (_) => StorageService()),
        Provider<AudioService>(create: (_) => AudioService()),
        Provider<FileService>(create: (_) => FileService()),
        Provider<TtsService>(create: (_) => TtsService()),
        Provider<SttService>(create: (_) => SttService()),
    Provider<VideoService>(create: (_) => VideoService()),
       // CvJdProvider depends on ApiService
        ChangeNotifierProvider(
          create: (ctx) => CvJdProvider(api: ctx.read<ApiService>()),
        ),
        //ProfileProvider depends on ApiService, inject it via context
        ChangeNotifierProvider(
          create: (ctx) => ProfileProvider(api: ctx.read<ApiService>()),
        ),

      // InterviewProvider depends on ApiService and AudioService, inject them via context
        ChangeNotifierProvider(
          create: (ctx) => InterviewProvider(
            api: ctx.read<ApiService>(),
            audio: ctx.read<AudioService>(),
            video: ctx.read<VideoService>()
          ),
        ),
    //session provider
        ChangeNotifierProvider(
          create: (ctx) => SessionProvider( api: ctx.read<ApiService>()),
        ),
        ChangeNotifierProvider(
        create: (ctx) => AdaptiveSessionProvider(
        backendBase: "https://convolvulaceous-kati-coagulatory.ngrok-free.dev",
        wsBase: "wss://convolvulaceous-kati-coagulatory.ngrok-free.dev", // <-- changed to wss
        authService: ctx.read<AuthProvider>().authService,
          audio: ctx.read<AudioService>(), api:
        ctx.read<ApiService>()),



        ),
      ];

  static Future<void> registerAll() async {
    // Initialize long-running services here. StorageService init is required.
    final storage = StorageService();
    await storage.init();
    // Initialize audio and tts (they are allowed to be no-op/mocks)
    try {
      await AudioService().init();
    } catch (_) {}
    try {
      await TtsService().init();
    } catch (_) {}
  }
}
