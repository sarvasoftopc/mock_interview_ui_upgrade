// auth_provider.dart (example / minimal)
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthService get authService => _authService;  // <-- expose this

  String? _userId;
  String? _errorMessage;
  bool _loading = true;

  String? get userId => _userId;
  String? get errorMessage => _errorMessage;

  bool get isLoggedIn => _userId != null;

  AuthProvider() {
    _init();
  }

  bool get isLoading => _loading;

  Future<void> _init() async {
    final session = Supabase.instance.client.auth.currentSession;
    _userId = session?.user.id;
    _loading = false;

    Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      final event = data.event;
      if (event == AuthChangeEvent.signedOut) {
        _userId = null;
      } else if (event == AuthChangeEvent.signedIn || event == AuthChangeEvent.tokenRefreshed) {
        _userId = data.session?.user.id;
        if (data.session != null) {
          await _authService.saveSession(data.session!); // make saveSession public
        }
      }
      notifyListeners();
    });


    notifyListeners();
  }



  Future<void> signUp(String email, String password) async {
    try {
      final res = await _authService.signUp(email, password);
      _userId = res.user?.id;
      _errorMessage = null;
    } on AuthException catch (e) {
      if (e.message.contains("already registered")) {
        _errorMessage = "User already registered";
      } else {
        _errorMessage = e.message;
      }
      _userId = null;
    } catch (e) {
      _errorMessage = "Unexpected error: $e";
      _userId = null;
    }
    notifyListeners();
  }

  Future<void> signUpwithPhone(String email, String password, {required String phone}) async {
    try {
      final res = await _authService.signUpWithPhone(email, password, phone: phone); // Pass phone
      _userId = res.user?.id;
      _errorMessage = null;

      // Send OTP for phone verification
      await _authService.sendPhoneOtp(phone);
    } on AuthException catch (e) {
      if (e.message.contains("already registered")) {
        _errorMessage = "User already registered";
      } else {
        _errorMessage = e.message;
      }
      _userId = null;
    } catch (e) {
      _errorMessage = "Unexpected error: $e";
      _userId = null;
    }
    notifyListeners();
  }

  Future<void> verifyPhoneOtp(String phone, String otp) async {
    try {
      final res = await _authService.verifyPhoneOtp(phone, otp);
      if (res.user != null) {
        _userId = res.user!.id;
        _errorMessage = null;
      }
    } catch (e) {
      _errorMessage = "OTP verification failed: $e";
    }
    notifyListeners();
  }



  Future<void> signIn(String email, String password) async {
    try {
      final res = await _authService.signIn(email, password);
      _userId = res.user?.id;
      _errorMessage = null;
    } on AuthException catch (e) {
      if (e.message.contains("Invalid login credentials")) {
        _errorMessage = "User not found or wrong password";
      } else {
        _errorMessage = e.message;
      }
      _userId = null;
    } catch (e) {
      _errorMessage = "Unexpected error: $e";
      _userId = null;
    }
    notifyListeners();
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _userId = null;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> loadUser() async {
    _userId = await _authService.getUserId();
    _errorMessage = null;
    notifyListeners();
  }
}
