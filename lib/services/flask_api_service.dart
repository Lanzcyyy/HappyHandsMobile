import '../core/network/api_client.dart';
import '../models/api_response.dart';
import '../models/cart_item.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../models/role.dart';
import '../models/seller_stats.dart';
import '../models/rider_models.dart';

class FlaskApiService {
  final ApiClient _api;

  FlaskApiService(this._api);

  List<Map<String, dynamic>> _readMapList(dynamic value) {
    if (value is List<dynamic>) {
      return value.whereType<Map<String, dynamic>>().toList();
    }

    if (value is Map<String, dynamic>) {
      final nested = value['items'] ?? value['products'] ?? value['categories'];
      if (nested is List<dynamic>) {
        return nested.whereType<Map<String, dynamic>>().toList();
      }
    }

    return const [];
  }

  Map<String, dynamic> _readMap(dynamic value) {
    return value is Map<String, dynamic> ? value : <String, dynamic>{};
  }

  Future<List<Product>> fetchProducts({int page = 1, int pageSize = 20}) async {
    final raw = await _api.getJson(
      '/products',
      query: {'page': '$page', 'page_size': '$pageSize'},
    );

    final parsed = ApiResponse.fromJson<dynamic>(raw, (data) => data);
    if (!parsed.isSuccess && raw['status'] != null) {
      throw Exception(parsed.message);
    }

    final payload = parsed.data ?? raw['data'] ?? raw;
    final items = _readMapList(payload);
    if (items.isNotEmpty) {
      return items.map(Product.fromJson).toList();
    }

    if (payload is List<dynamic>) {
      return payload
          .whereType<Map<String, dynamic>>()
          .map(Product.fromJson)
          .toList();
    }

    return const [];
  }

  Future<
    ({Category current, List<Category> categories, List<Product> products})
  >
  fetchCategory(String slug, {int page = 1, int perPage = 12}) async {
    final raw = await _api.getJson(
      '/categories/$slug',
      query: {'page': '$page', 'per_page': '$perPage'},
    );

    // Accept both legacy JSON and envelope JSON.
    final categoriesRaw = _readMapList(raw['categories'] ?? raw['data']);
    final currentRaw = _readMap(
      raw['current_category'] ?? raw['current'] ?? raw['data'],
    );
    final productsRaw = _readMapList(raw['products'] ?? raw['data']);

    final categories = categoriesRaw
        .whereType<Map<String, dynamic>>()
        .map(Category.fromJson)
        .where((c) => c.slug.isNotEmpty)
        .toList();

    final current = Category.fromJson(currentRaw);
    final products = productsRaw
        .whereType<Map<String, dynamic>>()
        .map(Product.fromJson)
        .toList();

    return (current: current, categories: categories, products: products);
  }

  Future<Product> fetchProduct(int id) async {
    final raw = await _api.getJson('/products/$id');
    final parsed = ApiResponse.fromJson<dynamic>(raw, (data) => data);
    if (!parsed.isSuccess && raw['status'] != null) {
      throw Exception(parsed.message);
    }

    final payload = parsed.data ?? raw['data'] ?? raw['product'] ?? raw;
    if (payload is Map<String, dynamic>) {
      return Product.fromJson(payload);
    }

    throw Exception('Invalid product response');
  }

  Future<List<CartItem>> fetchCart() async {
    final raw = await _api.getJson('/cart');
    final parsed = ApiResponse.fromJson<dynamic>(raw, (data) => data);

    if (!parsed.isSuccess && raw['status'] != null) {
      throw Exception(parsed.message);
    }

    final payload = parsed.data ?? raw['data'] ?? raw;
    final items = _readMapList(payload);
    return items.map(CartItem.fromJson).toList();
  }

  Future<void> addToCart({required int productId, int quantity = 1}) async {
    final raw = await _api.postJson('/cart', {
      'product_id': productId,
      'quantity': quantity,
    });
    final parsed = ApiResponse.fromJson<dynamic>(raw, (data) => data);
    if (!parsed.isSuccess) {
      throw Exception(parsed.message);
    }
  }

  Future<List<AppRole>> fetchRoles(String email) async {
    final raw = await _api.postJson('/roles', {'email': email});
    final parsed = ApiResponse.fromJson<dynamic>(raw, (data) => data);

    if (!parsed.isSuccess && raw['status'] != null) {
      throw Exception(parsed.message);
    }

    final payload = parsed.data ?? raw['data'] ?? raw;
    final roles = payload is Map<String, dynamic>
        ? (payload['roles'] as List<dynamic>? ?? const [])
        : const [];
    return roles
        .map((e) => AppRoleX.fromKey(e.toString()))
        .whereType<AppRole>()
        .toList();
  }

  Future<List<SellerSalesPoint>> fetchSellerSalesDaily() async {
    final raw = await _api.getJson(
      '/seller/stats/sales',
      query: {'range': 'daily'},
    );
    final ok = raw['success'] == true;
    if (!ok) {
      throw Exception(
        (raw['msg'] ?? 'Failed to fetch seller sales').toString(),
      );
    }
    final data = (raw['data'] as List<dynamic>? ?? const []);
    return data
        .whereType<Map<String, dynamic>>()
        .map(SellerSalesPoint.fromJson)
        .toList();
  }

  Future<List<SellerOrdersPoint>> fetchSellerOrdersDaily() async {
    final raw = await _api.getJson(
      '/seller/stats/orders',
      query: {'range': 'daily'},
    );
    final ok = raw['success'] == true;
    if (!ok) {
      throw Exception(
        (raw['msg'] ?? 'Failed to fetch seller orders stats').toString(),
      );
    }
    final data = (raw['data'] as List<dynamic>? ?? const []);
    return data
        .whereType<Map<String, dynamic>>()
        .map(SellerOrdersPoint.fromJson)
        .toList();
  }

  Future<List<SellerRecentOrder>> fetchSellerRecentOrders() async {
    final raw = await _api.getJson('/seller/stats/recent-orders');
    final ok = raw['success'] == true;
    if (!ok) {
      throw Exception(
        (raw['msg'] ?? 'Failed to fetch recent orders').toString(),
      );
    }
    final orders = (raw['orders'] as List<dynamic>? ?? const []);
    return orders
        .whereType<Map<String, dynamic>>()
        .map(SellerRecentOrder.fromJson)
        .toList();
  }

  Future<List<RiderOrderSummary>> fetchRiderOrders() async {
    final raw = await _api.getJson('/rider/orders');
    final ok = raw['success'] == true;
    if (!ok) {
      throw Exception(
        (raw['msg'] ?? 'Failed to fetch rider orders').toString(),
      );
    }
    final orders = (raw['orders'] as List<dynamic>? ?? const []);
    return orders
        .whereType<Map<String, dynamic>>()
        .map(RiderOrderSummary.fromJson)
        .toList();
  }
}
