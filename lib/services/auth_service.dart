import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _client = Supabase.instance.client;
  final _storage = const FlutterSecureStorage();

  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';
  static const _keyUserId = 'user_id';


  // Sign up with phone number metadata
  Future<AuthResponse> signUpWithPhone(String email, String password, {required String phone}) async {
    return _client.auth.signUp(
      email: email,
      phone: phone,                   // phone goes here
      password: password,
      data: {'phone': phone},          // metadata if you want to store it as well
      channel: OtpChannel.sms,         // send OTP via SMS
    );
  }

// Send OTP to phone
  Future<void> sendPhoneOtp(String phone) async {
    await _client.auth.verifyOTP(phone: phone, type: OtpType.sms);
  }

// Verify OTP
  Future<AuthResponse> verifyPhoneOtp(String phone, String otp) async {
    return _client.auth.verifyOTP(
      phone: phone,
      token: otp,
      type: OtpType.sms,
    );
  }

  //Signup with email and password
  Future<AuthResponse> signUp(String email, String password) async {
    final res = await _client.auth.signUp(email: email, password: password);
    if (res.user != null) {
      if(res.session!=null)
        await saveSession(res.session!);
    }
    return res;
  }

  //Sign in with email and password
  Future<AuthResponse> signIn(String email, String password) async {
    final res = await _client.auth.signInWithPassword(email: email, password: password);
    if (res.user != null) {
      if(res.session!=null)
        await saveSession(res.session!);
    }
    return res;
  }

  //sign out
  Future<void> signOut() async {
    await _client.auth.signOut();
    await _storage.deleteAll();
  }

  Future<String?> getAccessToken() async => await _storage.read(key: _keyAccessToken);
  Future<String?> getUserId() async => await _storage.read(key: _keyUserId);

  /// Restore session (on app start)
  // Future<void> restoreSession() async {
  //   final session = _client.auth.currentSession;
  //   if (session != null) {
  //     await _saveSession(session);
  //   }
  // }
  Future<void> saveSession(Session session) async {
    await _storage.write(key: _keyAccessToken, value: session.accessToken);
    await _storage.write(key: _keyRefreshToken, value: session.refreshToken);
    await _storage.write(key: _keyUserId, value: session.user?.id);
  }

}
