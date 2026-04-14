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

  Future<List<Product>> fetchProducts({int page = 1, int pageSize = 20}) async {
    final raw = await _api.getJson('/products', query: {
      'page': '$page',
      'page_size': '$pageSize',
    });

    final parsed = ApiResponse.fromJson<Map<String, dynamic>>(raw, (data) {
      return (data as Map<String, dynamic>?) ?? <String, dynamic>{};
    });

    if (!parsed.isSuccess) {
      throw Exception(parsed.message);
    }

    final items = (parsed.data?['items'] as List<dynamic>? ?? const []);
    return items.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<({Category current, List<Category> categories, List<Product> products})> fetchCategory(
    String slug, {
    int page = 1,
    int perPage = 12,
  }) async {
    final raw = await _api.getJson('/categories/$slug', query: {
      'page': '$page',
      'per_page': '$perPage',
    });

    // This endpoint is legacy JSON (not envelope). Normalize here.
    final categoriesRaw = (raw['categories'] as List<dynamic>? ?? const []);
    final currentRaw = raw['current_category'] as Map<String, dynamic>? ?? const {};
    final productsRaw = (raw['products'] as List<dynamic>? ?? const []);

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
    final parsed = ApiResponse.fromJson<Map<String, dynamic>>(raw, (data) {
      return (data as Map<String, dynamic>?) ?? <String, dynamic>{};
    });

    if (!parsed.isSuccess || parsed.data == null) {
      throw Exception(parsed.message);
    }

    return Product.fromJson(parsed.data!);
  }

  Future<List<CartItem>> fetchCart() async {
    final raw = await _api.getJson('/cart');
    final parsed = ApiResponse.fromJson<Map<String, dynamic>>(raw, (data) {
      return (data as Map<String, dynamic>?) ?? <String, dynamic>{};
    });

    if (!parsed.isSuccess) {
      throw Exception(parsed.message);
    }

    final items = (parsed.data?['items'] as List<dynamic>? ?? const []);
    return items.map((e) => CartItem.fromJson(e as Map<String, dynamic>)).toList();
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
    final parsed = ApiResponse.fromJson<Map<String, dynamic>>(raw, (data) {
      return (data as Map<String, dynamic>?) ?? <String, dynamic>{};
    });

    if (!parsed.isSuccess) {
      throw Exception(parsed.message);
    }

    final roles = (parsed.data?['roles'] as List<dynamic>? ?? const []);
    return roles
        .map((e) => AppRoleX.fromKey(e.toString()))
        .whereType<AppRole>()
        .toList();
  }

  Future<List<SellerSalesPoint>> fetchSellerSalesDaily() async {
    final raw = await _api.getJson('/seller/stats/sales', query: {'range': 'daily'});
    final ok = raw['success'] == true;
    if (!ok) {
      throw Exception((raw['msg'] ?? 'Failed to fetch seller sales').toString());
    }
    final data = (raw['data'] as List<dynamic>? ?? const []);
    return data.whereType<Map<String, dynamic>>().map(SellerSalesPoint.fromJson).toList();
  }

  Future<List<SellerOrdersPoint>> fetchSellerOrdersDaily() async {
    final raw = await _api.getJson('/seller/stats/orders', query: {'range': 'daily'});
    final ok = raw['success'] == true;
    if (!ok) {
      throw Exception((raw['msg'] ?? 'Failed to fetch seller orders stats').toString());
    }
    final data = (raw['data'] as List<dynamic>? ?? const []);
    return data.whereType<Map<String, dynamic>>().map(SellerOrdersPoint.fromJson).toList();
  }

  Future<List<SellerRecentOrder>> fetchSellerRecentOrders() async {
    final raw = await _api.getJson('/seller/stats/recent-orders');
    final ok = raw['success'] == true;
    if (!ok) {
      throw Exception((raw['msg'] ?? 'Failed to fetch recent orders').toString());
    }
    final orders = (raw['orders'] as List<dynamic>? ?? const []);
    return orders.whereType<Map<String, dynamic>>().map(SellerRecentOrder.fromJson).toList();
  }

  Future<List<RiderOrderSummary>> fetchRiderOrders() async {
    final raw = await _api.getJson('/rider/orders');
    final ok = raw['success'] == true;
    if (!ok) {
      throw Exception((raw['msg'] ?? 'Failed to fetch rider orders').toString());
    }
    final orders = (raw['orders'] as List<dynamic>? ?? const []);
    return orders.whereType<Map<String, dynamic>>().map(RiderOrderSummary.fromJson).toList();
  }
}

