import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import 'api_exceptions.dart';

typedef TokenProvider = Future<String?> Function();

class ApiClient {
  final http.Client _client;
  final TokenProvider _tokenProvider;

  ApiClient({
    http.Client? client,
    required TokenProvider tokenProvider,
  })  : _client = client ?? http.Client(),
        _tokenProvider = tokenProvider;

  Uri _uri(String path, [Map<String, String>? query]) {
    final base = AppConfig.apiBaseUrl.replaceAll(RegExp(r'/$'), '');
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return Uri.parse('$base/$cleanPath').replace(queryParameters: query);
  }

  Future<Map<String, String>> _headers({bool jsonBody = false}) async {
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    if (jsonBody) {
      headers['Content-Type'] = 'application/json';
    }

    final token = await _tokenProvider();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<Map<String, dynamic>> getJson(String path, {Map<String, String>? query}) async {
    final res = await _client
        .get(_uri(path, query), headers: await _headers())
        .timeout(AppConfig.requestTimeout);
    return _decode(res);
  }

  Future<Map<String, dynamic>> postJson(String path, Map<String, dynamic> body) async {
    final res = await _client
        .post(
          _uri(path),
          headers: await _headers(jsonBody: true),
          body: jsonEncode(body),
        )
        .timeout(AppConfig.requestTimeout);
    return _decode(res);
  }

  Map<String, dynamic> _decode(http.Response res) {
    Map<String, dynamic> json;
    try {
      json = jsonDecode(res.body) as Map<String, dynamic>;
    } catch (e) {
      throw ApiException('Invalid server response', statusCode: res.statusCode, cause: e);
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return json;
    }

    final msg = (json['message'] ?? 'Request failed').toString();
    throw ApiException(msg, statusCode: res.statusCode, cause: json);
  }
}

