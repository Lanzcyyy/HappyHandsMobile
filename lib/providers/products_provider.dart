import 'package:flutter/foundation.dart';

import '../core/network/api_exceptions.dart';
import '../models/product.dart';
import '../services/flask_api_service.dart';

class ProductsProvider extends ChangeNotifier {
  final FlaskApiService _api;

  ProductsProvider(this._api);

  bool _isLoading = false;
  String? _error;
  List<Product> _items = const [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Product> get items => _items;

  Future<void> fetch() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _items = await _api.fetchProducts();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

