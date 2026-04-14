import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/config/app_config.dart';
import '../services/firebase_auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuthService _authService;

  StreamSubscription<User?>? _sub;

  bool _isLoading = true;
  User? _user;
  String? _error;
  String? _backendAccessToken;

  AuthProvider({FirebaseAuthService? authService})
      : _authService = authService ?? FirebaseAuthService() {
    _sub = _authService.authStateChanges().listen((u) {
      _user = u;
      _isLoading = false;
      if (u == null) {
        _backendAccessToken = null;
      } else {
        _refreshBackendToken();
      }
      notifyListeners();
    });
  }

  bool get isLoading => _isLoading;
  User? get user => _user;
  String? get error => _error;
  String? get backendAccessToken => _backendAccessToken;

  Future<void> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    _error = null;
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.register(email: email, password: password, displayName: displayName);
    } on FirebaseAuthException catch (e) {
      final msg = (e.message == null || e.message!.trim().isEmpty) ? null : e.message!.trim();
      _error = msg == null ? 'Registration failed (${e.code})' : '${e.code}: $msg';
    } catch (_) {
      _error = 'Registration failed';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    _error = null;
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.login(email: email, password: password);
      await _refreshBackendToken();
    } on FirebaseAuthException catch (e) {
      final msg = (e.message == null || e.message!.trim().isEmpty) ? null : e.message!.trim();
      _error = msg == null ? 'Login failed (${e.code})' : '${e.code}: $msg';
    } catch (_) {
      _error = 'Login failed';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _backendAccessToken = null;
  }

  Future<void> resetPassword(String email) async {
    _error = null;
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.resetPassword(email);
    } on FirebaseAuthException catch (e) {
      final msg = (e.message == null || e.message!.trim().isEmpty) ? null : e.message!.trim();
      _error = msg == null ? 'Password reset failed (${e.code})' : '${e.code}: $msg';
    } catch (_) {
      _error = 'Password reset failed';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Token used for Flask API calls.
  ///
  /// Prefer backend JWT (from `/api/auth/exchange`) so seller/rider endpoints
  /// can work without cookie-based sessions. Fallback to Firebase token.
  Future<String?> getIdToken() async {
    if (_backendAccessToken != null && _backendAccessToken!.isNotEmpty) {
      return _backendAccessToken;
    }
    return _authService.getIdToken();
  }

  Future<void> _refreshBackendToken() async {
    try {
      final u = _authService.currentUser;
      final email = u?.email;
      if (u == null || email == null || email.isEmpty) return;
      final idToken = await _authService.getIdToken(forceRefresh: false);
      if (idToken == null || idToken.isEmpty) return;

      final base = AppConfig.apiBaseUrl.replaceAll(RegExp(r'/$'), '');
      final uri = Uri.parse('$base/auth/exchange');
      final res = await http
          .post(
            uri,
            headers: const {'Content-Type': 'application/json', 'Accept': 'application/json'},
            body: jsonEncode({'email': email, 'id_token': idToken}),
          )
          .timeout(AppConfig.requestTimeout);

      final json = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode < 200 || res.statusCode >= 300) return;
      final data = json['data'] as Map<String, dynamic>?;
      final token = data?['access_token']?.toString();
      if (token != null && token.isNotEmpty) {
        _backendAccessToken = token;
        notifyListeners();
      }
    } catch (_) {
      // Non-fatal; app can still run with Firebase token for public endpoints.
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

