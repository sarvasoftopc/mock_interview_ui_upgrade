import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static StorageService? _instance;
  SharedPreferences? _prefs;

  factory StorageService() {
    _instance ??= StorageService._internal();
    return _instance!;
  }

  StorageService._internal();

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> setJson(String key, Map<String, dynamic> value) async {
    await init();
    await _prefs!.setString(key, jsonEncode(value));
  }

  Map<String, dynamic>? getJson(String key) {
    final s = _prefs?.getString(key);
    if (s == null) return null;
    try {
      final decoded = jsonDecode(s) as Map<String, dynamic>;
      return decoded;
    } catch (_) {
      return null;
    }
  }

  Future<void> setString(String key, String value) async {
    await init();
    await _prefs!.setString(key, value);
  }

  String? getString(String key) {
    return _prefs?.getString(key);
  }

  Future<void> remove(String key) async {
    await init();
    await _prefs!.remove(key);
  }
}
