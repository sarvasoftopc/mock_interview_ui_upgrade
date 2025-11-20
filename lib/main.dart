import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:sarvasoft_moc_interview/utils/env_config.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

import 'app.dart';
import 'providers/providers.dart';



bool mock = true;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize services required at startup
  // await  dotenv.load(fileName: ".env");
  //
  // await Providers.registerAll();
  // await _loadEnv();
  // await Supabase.initialize(
  //   url: dotenv.env['SUPABASE_URL']!,
  //   anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  //   authOptions: const FlutterAuthClientOptions(
  //     // This is the key part for deep links on mobile
  //     authFlowType: AuthFlowType.pkce,
  //   ),
  // );
  //
  // runApp(const InterviewPrepApp());
  // if (!kReleaseMode) {
  //   try {
  //     await dotenv.load(fileName: ".env");
  //     print("✅ Loaded local .env file for dev mode");
  //   } catch (e) {
  //     print("⚠️ No .env file found (continuing with dart-defines)");
  //   }
  // }

   await Providers.registerAll();
  //
  // await Supabase.initialize(
  //   url: Env.supabaseUrl,
  //   anonKey: Env.supabaseAnonKey,
  //   authOptions: const FlutterAuthClientOptions(
  //     authFlowType: AuthFlowType.pkce,
  //   ),
  // );
  //
  // runApp(const InterviewPrepApp());
  WidgetsFlutterBinding.ensureInitialized();

  // Optional: validate before initialization
  Env.validate();

  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  runApp(const InterviewPrepApp());
}