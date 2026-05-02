import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/config/app_config.dart';

/// Represents a logged-in user from the MySQL/Flask backend.
class MysqlUser {
  final int id;
  final String username;
  final String email;
  final String? name;

  const MysqlUser({
    required this.id,
    required this.username,
    required this.email,
    this.name,
  });

  String get displayName => name ?? username;
  String? get photoURL => null;

  factory MysqlUser.fromJson(Map<String, dynamic> json) {
    return MysqlUser(
      id: (json['id'] as num?)?.toInt() ??
          (json['user_id'] as num?)?.toInt() ??
          0,
      username: (json['username'] ?? json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      name: json['name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
        'name': name,
      };
}

/// Talks to POST /api/register and POST /api/login on the Flask backend.
/// Persists the JWT and user info in SharedPreferences.
class MysqlAuthService {
  static const _keyToken = 'mysql_auth_token';
  static const _keyUser = 'mysql_auth_user';

  // ── Persistence ──────────────────────────────────────────────────────────

  Future<void> _persist(String token, MysqlUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await prefs.setString(_keyUser, jsonEncode(user.toJson()));
  }

  Future<void> _clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUser);
  }

  Future<String?> getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  Future<MysqlUser?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyUser);
    if (raw == null) return null;
    try {
      return MysqlUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  // ── API calls ─────────────────────────────────────────────────────────────

  Future<({MysqlUser user, String token})> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/register');
    developer.log('MysqlAuthService.register → $uri');

    final http.Response response = await _post(uri, {
      'username': username,
      'email': email,
      'password': password,
    });

    final body = _decodeBody(response);
    developer.log('register response ${response.statusCode}: ${response.body}');

    if (response.statusCode == 200 || body['status'] == 'success') {
      final data = (body['data'] as Map<String, dynamic>?) ?? {};
      final token = (data['access_token'] ?? '').toString();
      final userJson = (data['user'] as Map<String, dynamic>?) ??
          {'id': data['id'], 'username': username, 'email': email};
      final user = MysqlUser.fromJson(userJson);
      await _persist(token, user);
      developer.log('Registered: ${user.email}');
      return (user: user, token: token);
    }

    throw _extractError(body, 'Registration failed');
  }

  Future<({MysqlUser user, String token})> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/login');
    developer.log('MysqlAuthService.login → $uri');

    final http.Response response = await _post(uri, {
      'username': email, // Flask accepts email in the username field
      'email': email,
      'password': password,
    });

    final body = _decodeBody(response);
    developer.log('login response ${response.statusCode}: ${response.body}');

    if (response.statusCode == 200 && body['status'] == 'success') {
      final data = (body['data'] as Map<String, dynamic>?) ?? {};
      final token = (data['access_token'] ?? '').toString();
      final userJson = (data['user'] as Map<String, dynamic>?) ??
          {'id': data['user_id'], 'username': email, 'email': email};
      final user = MysqlUser.fromJson(userJson);
      await _persist(token, user);
      developer.log('Logged in: ${user.email}');
      return (user: user, token: token);
    }

    throw _extractError(body, 'Invalid email or password');
  }

  Future<void> logout() async {
    await _clear();
    developer.log('MysqlAuthService: logged out');
  }

  // ── HTTP helper ───────────────────────────────────────────────────────────

  Future<http.Response> _post(
    Uri uri,
    Map<String, dynamic> body,
  ) async {
    try {
      return await http
          .post(
            uri,
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(AppConfig.requestTimeout);
    } on TimeoutException {
      throw 'Request timed out. Make sure the Flask server is running at ${AppConfig.apiBaseUrl}';
    } on SocketException catch (e) {
      throw 'Cannot reach server at ${AppConfig.apiBaseUrl}.\n'
          'Make sure Flask is running and you passed the correct IP with:\n'
          '--dart-define=API_BASE_URL=http://YOUR_PC_IP:5500/api\n'
          '(Detail: ${e.message})';
    } on http.ClientException catch (e) {
      throw 'Connection failed: ${e.message}';
    } catch (e) {
      // On web, SocketException is not thrown — CORS or network errors
      // surface as generic exceptions.
      if (kIsWeb) {
        throw 'Cannot reach server at ${AppConfig.apiBaseUrl}.\n'
            'Make sure Flask is running and you used:\n'
            '--dart-define=API_BASE_URL=http://YOUR_PC_IP:5500/api\n'
            '(Detail: $e)';
      }
      throw 'Unexpected error: $e';
    }
  }

  // ── Decode helpers ────────────────────────────────────────────────────────

  Map<String, dynamic> _decodeBody(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}
    return {};
  }

  String _extractError(Map<String, dynamic> body, String fallback) {
    final msg = body['message']?.toString().trim() ??
        body['error']?.toString().trim() ??
        body['msg']?.toString().trim();
    if (msg != null && msg.isNotEmpty) return msg;
    return fallback;
  }
}
