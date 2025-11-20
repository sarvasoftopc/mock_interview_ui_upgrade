import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/profile.dart';
import '../services/api_service.dart';

class ProfileProvider with ChangeNotifier {
  Profile? _profile;
  final ApiService api;


  ProfileProvider({required this.api});

  Profile? get profile => _profile;

  set profile(Profile? p) {
    _profile = p;
  }
  Future<void> loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString('profile_cache');
    if (s != null) {
      final j = jsonDecode(s);
      _profile = Profile.fromJson(j);
      notifyListeners();
    }
  }

  Future<void> _saveLocalCache() async {
    final prefs = await SharedPreferences.getInstance();
    if (_profile != null) {
      prefs.setString('profile_cache', jsonEncode(_profile!.toJson()));
    } else {
      prefs.remove('profile_cache');
    }
  }

  /// Loads profile for the authenticated user from server.
  /// Returns true if a profile was loaded (or updated) successfully,
  /// false if profile not found (404) or not loaded.
  /// Throws for unexpected errors (network issues, server errors).
  Future<bool> loadFromServer({bool force = false}) async {
    try {
      final resp = await api.getMyProfile();

      // network-level check
      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body);

        // backend returns {"ok": true, "profile": {...}}
        if (body == null) {
          // defensive: if body is null, treat as failure
          _profile = null;
          await _saveLocalCache();
          notifyListeners();
          return false;
        }

        // allow either direct profile or wrapped in 'profile' key
        final profileJson = body['profile'] ?? body;
        if (profileJson == null) {
          _profile = null;
          await _saveLocalCache();
          notifyListeners();
          return false;
        }

        _profile = Profile.fromJson(profileJson);
        await _saveLocalCache();
        notifyListeners();
        return true;
      }

      // Not authenticated
      if (resp.statusCode == 401 || resp.statusCode == 403) {
        // clear local profile if any
        _profile = null;
        await _saveLocalCache();
        notifyListeners();
        return false;
      }

      // Not found -> treat as "no profile yet"
      if (resp.statusCode == 404) {
        _profile = null;
        await _saveLocalCache();
        notifyListeners();
        return false;
      }

      // Other server error -> surface so caller can handle/log
      throw Exception('Failed to load profile: ${resp.statusCode} ${resp.body}');
    } catch (e) {
      // Optionally log the error here (debugPrint or your logger)
      debugPrint('[ProfileProvider] loadFromServer error: $e');
      rethrow; // rethrow so UI can show an error if desired
    }
  }


  Future<void> createOrUpdateProfile(Profile p) async {
    final resp = api.createOrUpdateProfile(p);

    if (resp.statusCode == 200) {
      final body = jsonDecode(resp.body);
      _profile = Profile.fromJson(body['profile']);
      await _saveLocalCache();
      notifyListeners();
    } else {
      throw Exception('failed to update profile: ${resp.statusCode}');
    }
  }

  // Helper: call analyze_cv endpoint (base64 encoded)
  Future<List<String>> analyzeCvText(String fileName, String cvText) async {
    var skills = await api.analyseCv(fileName,cvText);
    // optionally set cv_text preview
    if (_profile != null) {
      _profile!.cvText = cvText;
      await _saveLocalCache();
      notifyListeners();
    }
    return skills;
  }

  Future<String?> getUserId() async {
    String? userId = await api.getUserId();
    return userId;
  }

  // profile state
  // whenever you change state, call notifyListeners()
  void setProfile(Profile p) {
    _profile = p;
    notifyListeners();
  }
}
