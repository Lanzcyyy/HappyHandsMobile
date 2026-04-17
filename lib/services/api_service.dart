import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;

import '../core/config/app_config.dart';
import '../models/product.dart';
import '../models/cart_item.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<Map<String, String>> _getHeaders({String? authToken}) async {
    final headers = Map<String, String>.from(_defaultHeaders);
    if (authToken != null && authToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $authToken';
    }
    return headers;
  }

  Future<void> _logRequest(
    String method,
    Uri uri, {
    Map<String, dynamic>? body,
  }) async {
    if (AppConfig.enableNetworkLogging) {
      developer.log('API Request: $method ${uri.toString()}');
      if (body != null) {
        developer.log('Request Body: ${jsonEncode(body)}');
      }
    }
  }

  Future<void> _logResponse(
    String method,
    Uri uri,
    http.Response response,
  ) async {
    if (AppConfig.enableNetworkLogging) {
      developer.log(
        'API Response: $method ${uri.toString()} - Status: ${response.statusCode}',
      );
      developer.log('Response Body: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    final body = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      final message = body['message'] ?? 'Unknown error occurred';
      final error = body['error'] ?? message;
      throw ApiException(
        message: message,
        statusCode: response.statusCode,
        error: error,
      );
    }
  }

  // PRODUCTS API
  Future<List<Product>> getProducts({
    int page = 1,
    int limit = 12,
    String? category,
    String? search,
    String? sortBy,
    String? sortOrder,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (category != null) queryParams['category'] = category;
    if (search != null) queryParams['search'] = search;
    if (sortBy != null) queryParams['sort_by'] = sortBy;
    if (sortOrder != null) queryParams['sort_order'] = sortOrder;

    final uri = Uri.parse(
      '${AppConfig.apiBaseUrl}/products',
    ).replace(queryParameters: queryParams);
    await _logRequest('GET', uri);

    try {
      final response = await http
          .get(uri, headers: await _getHeaders())
          .timeout(AppConfig.requestTimeout);

      await _logResponse('GET', uri, response);
      final data = await _handleResponse(response);

      final productsData =
          data['data']?['products'] ?? data['products'] ?? data['data'] ?? [];
      return (productsData as List)
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Product> getProductById(int productId) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/products/$productId');
    await _logRequest('GET', uri);

    try {
      final response = await http
          .get(uri, headers: await _getHeaders())
          .timeout(AppConfig.requestTimeout);

      await _logResponse('GET', uri, response);
      final data = await _handleResponse(response);

      final productData = data['data'] ?? data['product'] ?? data;
      return Product.fromJson(productData as Map<String, dynamic>);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Product>> getFeaturedProducts({
    int page = 1,
    int limit = 12,
  }) async {
    final queryParams = {'page': page.toString(), 'limit': limit.toString()};

    final uri = Uri.parse(
      '${AppConfig.apiBaseUrl}/products/featured',
    ).replace(queryParameters: queryParams);
    await _logRequest('GET', uri);

    try {
      final response = await http
          .get(uri, headers: await _getHeaders())
          .timeout(AppConfig.requestTimeout);

      await _logResponse('GET', uri, response);
      final data = await _handleResponse(response);

      final productsData =
          data['data']?['products'] ?? data['products'] ?? data['data'] ?? [];
      return (productsData as List)
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Product>> getProductsByCategory(
    String category, {
    int page = 1,
    int limit = 12,
  }) async {
    return getProducts(category: category, page: page, limit: limit);
  }

  Future<List<Product>> searchProducts(
    String query, {
    int page = 1,
    int limit = 20,
  }) async {
    return getProducts(search: query, page: page, limit: limit);
  }

  // CART API
  Future<List<CartItem>> getCart(String authToken) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/cart');
    await _logRequest('GET', uri);

    try {
      final response = await http
          .get(uri, headers: await _getHeaders(authToken: authToken))
          .timeout(AppConfig.requestTimeout);

      await _logResponse('GET', uri, response);
      final data = await _handleResponse(response);

      final cartData =
          data['data']?['items'] ?? data['items'] ?? data['cart_items'] ?? [];
      return (cartData as List)
          .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<CartItem> addToCart({
    required int productId,
    required int quantity,
    String? size,
    String? color,
    required String authToken,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/cart');
    final body = <String, dynamic>{
      'product_id': productId,
      'quantity': quantity,
    };
    if (size != null) {
      body['size'] = size;
    }
    if (color != null) {
      body['color'] = color;
    }

    await _logRequest('POST', uri, body: body);

    try {
      final response = await http
          .post(
            uri,
            headers: await _getHeaders(authToken: authToken),
            body: jsonEncode(body),
          )
          .timeout(AppConfig.requestTimeout);

      await _logResponse('POST', uri, response);
      final data = await _handleResponse(response);

      final cartItemData = data['data'] ?? data['cart_item'] ?? data;
      return CartItem.fromJson(cartItemData as Map<String, dynamic>);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<CartItem> updateCartItem({
    required int cartItemId,
    required int quantity,
    required String authToken,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/cart/$cartItemId');
    final body = {'quantity': quantity};

    await _logRequest('PUT', uri, body: body);

    try {
      final response = await http
          .put(
            uri,
            headers: await _getHeaders(authToken: authToken),
            body: jsonEncode(body),
          )
          .timeout(AppConfig.requestTimeout);

      await _logResponse('PUT', uri, response);
      final data = await _handleResponse(response);

      final cartItemData = data['data'] ?? data['cart_item'] ?? data;
      return CartItem.fromJson(cartItemData as Map<String, dynamic>);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> removeFromCart({
    required int cartItemId,
    required String authToken,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/cart/$cartItemId');
    await _logRequest('DELETE', uri);

    try {
      final response = await http
          .delete(uri, headers: await _getHeaders(authToken: authToken))
          .timeout(AppConfig.requestTimeout);

      await _logResponse('DELETE', uri, response);
      await _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> clearCart(String authToken) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/cart');
    await _logRequest('DELETE', uri);

    try {
      final response = await http
          .delete(uri, headers: await _getHeaders(authToken: authToken))
          .timeout(AppConfig.requestTimeout);

      await _logResponse('DELETE', uri, response);
      await _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // AUTH API
  Future<Map<String, dynamic>> exchangeFirebaseToken({
    required String email,
    required String idToken,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/auth/exchange');
    final body = {'email': email, 'id_token': idToken};

    await _logRequest('POST', uri, body: body);

    try {
      final response = await http
          .post(uri, headers: await _getHeaders(), body: jsonEncode(body))
          .timeout(AppConfig.requestTimeout);

      await _logResponse('POST', uri, response);
      return await _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getUserRoles(String email) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/roles');
    final body = {'email': email};

    await _logRequest('POST', uri, body: body);

    try {
      final response = await http
          .post(uri, headers: await _getHeaders(), body: jsonEncode(body))
          .timeout(AppConfig.requestTimeout);

      await _logResponse('POST', uri, response);
      return await _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // CATEGORIES API
  Future<List<Map<String, dynamic>>> getCategories() async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/categories');
    await _logRequest('GET', uri);

    try {
      final response = await http
          .get(uri, headers: await _getHeaders())
          .timeout(AppConfig.requestTimeout);

      await _logResponse('GET', uri, response);
      final data = await _handleResponse(response);

      final categoriesData = data['data'] ?? data['categories'] ?? [];
      return (categoriesData as List)
          .map((item) => item as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic error) {
    if (error is ApiException) {
      return error;
    } else if (error is http.ClientException) {
      return NetworkException(error.message);
    } else {
      return ApiException(message: 'An unexpected error occurred');
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? error;

  ApiException({required this.message, this.statusCode, this.error});

  @override
  String toString() {
    return 'ApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
  }
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}
