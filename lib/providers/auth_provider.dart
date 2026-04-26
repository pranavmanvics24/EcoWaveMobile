import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  User? get user => _user;
  bool get isLoggedIn => _user != null;

  final ApiService _api = ApiService();

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('user');
    if (raw != null) {
      _user = User.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      _api.setToken(_user?.token);
    }
  }

  /// Simple email/name login — calls backend to get token
  Future<void> login(String email, String name) async {
    try {
      _user = await _api.login(email, name);
      _api.setToken(_user?.token);
      await _persist();
    } catch (_) {
      // Fallback or ignore for prototyping
      _user = User(email: email, name: name, token: '');
      _api.setToken(null);
      await _persist();
    }
    notifyListeners();
  }

  /// Google Auth login
  Future<void> loginWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );
      
      final GoogleSignInAccount? account = await googleSignIn.signIn();
      if (account == null) {
        // User cancelled login
        return;
      }
      
      // We got the base Google profile, now exchange it with backend
      final String email = account.email;
      final String name = account.displayName ?? email.split('@')[0];
      
      // Call backend to fetch JWT
      _user = await _api.login(email, name);
      _api.setToken(_user?.token);
      await _persist();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Google login error: $e');
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    _user = null;
    _api.setToken(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    if (_user != null) {
      await prefs.setString('user', jsonEncode(_user!.toJson()));
    }
  }
}
