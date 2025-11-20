import 'package:flutter/foundation.dart';

import '../services/storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  final StorageService _storage;
  bool _darkMode = false;
  int _speechRate = 1;
  bool _initialized = false;

  SettingsProvider([StorageService? storage]) : _storage = storage ?? StorageService() {
    _init();
  }

  Future<void> _init() async {
    if (_initialized) return;
    final dark = _storage.getJson('settings.darkMode');
    if (dark is bool) {
      _darkMode = dark as bool;
    } else {
      final s = _storage.getString('settings.darkMode');
      if (s != null) {
        _darkMode = s.toLowerCase() == 'true';
      }
    }
    final rate = _storage.getString('settings.speechRate');
    if (rate != null) {
      _speechRate = int.tryParse(rate) ?? _speechRate;
    } else {
      final rj = _storage.getJson('settings.speechRate');
      if (rj is int) _speechRate = rj as int;
    }
    _initialized = true;
    notifyListeners();
  }

  Future<void> init() async => _init();

  bool get darkMode => _darkMode;
  int get speechRate => _speechRate;

  Future<void> setDarkMode(bool value) async {
    _darkMode = value;
    await _storage.setString('settings.darkMode', value.toString());
    notifyListeners();
  }

  Future<void> setSpeechRate(int rate) async {
    if (rate < 0 || rate > 3) throw RangeError('speechRate must be between 0 and 3');
    _speechRate = rate;
    await _storage.setString('settings.speechRate', rate.toString());
    notifyListeners();
  }
}
