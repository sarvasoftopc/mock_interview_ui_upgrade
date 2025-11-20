// lib/utils/env_config.dart
class Env {
  static const String supabaseUrl =
  String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static const String supabaseAnonKey =
  String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  static void validate() {
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw Exception(
          'Missing environment variables: SUPABASE_URL or SUPABASE_ANON_KEY.');
    }
  }
}
