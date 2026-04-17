import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;

import '../core/config/app_config.dart';
import '../services/firebase_auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuthService _authService;
  static const Duration _roleLookupTimeout = Duration(seconds: 3);

  StreamSubscription<User?>? _sub;

  bool _isLoading = true;
  bool _isPerformingAuthAction = false;
  User? _user;
  String? _error;
  String? _backendAccessToken;
  String? _activeRole;

  AuthProvider({FirebaseAuthService? authService})
    : _authService = authService ?? FirebaseAuthService() {
    _sub = _authService.authStateChanges().listen((user) {
      _handleAuthStateChange(user);
    });
  }

  bool get isLoading => _isLoading;
  User? get user => _user;
  String? get error => _error;
  String? get backendAccessToken => _backendAccessToken;
  String? get activeRole => _activeRole;

  Future<void> register({
    required String email,
    required String password,
    String? displayName,
    String? role,
  }) async {
    _error = null;
    _isLoading = true;
    _isPerformingAuthAction = true;
    _activeRole = _normalizeRole(role ?? 'user');
    notifyListeners();

    try {
      final credential = await _authService.register(
        email: email,
        password: password,
        displayName: displayName,
      );

      final user = credential.user;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-not-created',
          message: 'Registration failed',
        );
      }

      unawaited(
        _saveUserRole(
          uid: user.uid,
          email: email.trim(),
          role: _activeRole ?? 'user',
          displayName: displayName?.trim(),
        ),
      );

      _scheduleBackendTokenRefresh();
    } on FirebaseAuthException catch (e) {
      _error = _formatFirebaseError('Registration failed', e);
      await _rollbackRegisteredUser();
    } catch (_) {
      _error = 'Registration failed. Please try again.';
      await _rollbackRegisteredUser();
    } finally {
      _isLoading = false;
      _isPerformingAuthAction = false;
      notifyListeners();
    }
  }

  Future<void> login({
    required String email,
    required String password,
    String? role,
  }) async {
    _error = null;
    _isLoading = true;
    _isPerformingAuthAction = true;
    _activeRole = _normalizeRole(role ?? 'user');
    notifyListeners();

    try {
      final credential = await _authService.login(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'Login failed',
        );
      }

      final storedRole = await _getStoredRole(user.uid);
      if (storedRole == null || storedRole != _activeRole) {
        unawaited(
          _saveUserRole(
            uid: user.uid,
            email: email.trim(),
            role: _activeRole ?? 'user',
            displayName: user.displayName?.trim(),
          ),
        );
      }

      _scheduleBackendTokenRefresh();
    } on FirebaseAuthException catch (e) {
      _error = _formatFirebaseError('Login failed', e);
    } catch (_) {
      _error = 'Login failed';
    } finally {
      _isLoading = false;
      _isPerformingAuthAction = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _backendAccessToken = null;
    _activeRole = null;
  }

  Future<void> resetPassword(String email) async {
    _error = null;
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.resetPassword(email);
    } on FirebaseAuthException catch (e) {
      _error = _formatFirebaseError('Password reset failed', e);
    } catch (_) {
      _error = 'Password reset failed';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> getIdToken() async {
    if (_backendAccessToken != null && _backendAccessToken!.isNotEmpty) {
      return _backendAccessToken;
    }
    return _authService.getIdToken();
  }

  Future<void> _saveUserRole({
    required String uid,
    required String email,
    required String role,
    String? displayName,
  }) async {
    developer.log('Registering user uid=$uid role=$role email=$email');
    final ref = FirebaseDatabase.instance.ref('users/$uid');
    await ref.update({
      'email': email,
      'role': role,
      if (displayName != null && displayName.isNotEmpty) 'name': displayName,
      'createdAt': ServerValue.timestamp,
      'updatedAt': ServerValue.timestamp,
    });
    developer.log('Firestore user role saved for uid=$uid');
  }

  Future<void> _handleAuthStateChange(User? user) async {
    _user = user;
    if (!_isPerformingAuthAction) {
      _isLoading = false;
    }

    if (user == null) {
      _backendAccessToken = null;
      _activeRole = null;
      notifyListeners();
      return;
    }

    try {
      final storedRole = await _getStoredRole(user.uid);
      _activeRole = storedRole ?? _activeRole ?? 'user';
    } catch (_) {
      _activeRole = _activeRole ?? 'user';
    }

    _scheduleBackendTokenRefresh();
    notifyListeners();
  }

  void _scheduleBackendTokenRefresh() {
    unawaited(_refreshBackendToken());
  }

  Future<void> _rollbackRegisteredUser() async {
    try {
      final user = _authService.currentUser;
      if (user == null) return;
      await user.delete();
      await _authService.logout();
      _user = null;
      _backendAccessToken = null;
      _activeRole = null;
      developer.log('Rolled back partially created auth user ${user.uid}');
    } catch (_) {
      // If rollback fails, sign out so the app does not remain in a bad session.
      try {
        await _authService.logout();
      } catch (_) {}
    }
  }

  Future<String?> _getStoredRole(String uid) async {
    DataSnapshot snapshot;
    try {
      snapshot = await FirebaseDatabase.instance
          .ref('users/$uid')
          .get()
          .timeout(_roleLookupTimeout);
    } on TimeoutException {
      return null;
    }

    if (!snapshot.exists || snapshot.value == null) {
      return null;
    }

    final data = snapshot.value;
    if (data is! Map) {
      return null;
    }

    final role = data['role']?.toString().trim().toLowerCase();
    if (role == null || role.isEmpty) {
      return null;
    }
    return _normalizeRole(role);
  }

  Future<void> _refreshBackendToken() async {
    try {
      final user = _authService.currentUser;
      final email = user?.email;
      if (user == null || email == null || email.isEmpty) return;

      final idToken = await _authService.getIdToken(forceRefresh: false);
      if (idToken == null || idToken.isEmpty) return;

      final base = AppConfig.apiBaseUrl.replaceAll(RegExp(r'/$'), '');
      final uri = Uri.parse('$base/auth/exchange');
      final response = await http
          .post(
            uri,
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'email': email, 'id_token': idToken}),
          )
          .timeout(AppConfig.requestTimeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return;
      }

      final body = jsonDecode(response.body);
      if (body is! Map<String, dynamic>) return;
      final data = body['data'];
      if (data is Map<String, dynamic>) {
        final token = data['access_token']?.toString().trim();
        if (token != null && token.isNotEmpty) {
          _backendAccessToken = token;
          notifyListeners();
        }
      }
    } catch (_) {
      // Non-fatal. Firebase auth still works even if backend token exchange fails.
    }
  }

  String _normalizeRole(String role) {
    final normalized = role.trim().toLowerCase();
    if (normalized == 'seller' || normalized == 'rider') {
      return normalized;
    }
    return 'user';
  }

  String _roleMismatchMessage(String role) {
    return 'This account is not registered as a ${_normalizeRole(role)}';
  }

  String _formatFirebaseError(String prefix, FirebaseAuthException error) {
    final message = error.message?.trim();
    if (message == null || message.isEmpty) {
      return '$prefix (${error.code})';
    }
    return '${error.code}: $message';
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
