import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sarvasoft_moc_interview/utils/env_config.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

import 'app.dart';
import 'providers/providers.dart';



bool mock = true;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

   await Providers.registerAll();

  WidgetsFlutterBinding.ensureInitialized();
  print("kIsWeb = $kIsWeb");
  print("Platform = ${defaultTargetPlatform}");

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