import 'package:flutter/foundation.dart';

import '../models/seller_stats.dart';
import '../services/flask_api_service.dart';

class SellerProvider extends ChangeNotifier {
  final FlaskApiService _api;

  SellerProvider(this._api);

  bool _isLoading = false;
  String? _error;

  List<SellerSalesPoint> sales = const [];
  List<SellerOrdersPoint> orders = const [];
  List<SellerRecentOrder> recentOrders = const [];

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadDashboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _api.fetchSellerSalesDaily(),
        _api.fetchSellerOrdersDaily(),
        _api.fetchSellerRecentOrders(),
      ]);
      sales = results[0] as List<SellerSalesPoint>;
      orders = results[1] as List<SellerOrdersPoint>;
      recentOrders = results[2] as List<SellerRecentOrder>;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

