import 'package:flutter/foundation.dart';

import '../models/rider_models.dart';
import '../services/flask_api_service.dart';

class RiderProvider extends ChangeNotifier {
  final FlaskApiService _api;

  RiderProvider(this._api);

  bool _isLoading = false;
  String? _error;
  List<RiderOrderSummary> _orders = const [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<RiderOrderSummary> get orders => _orders;

  Future<void> loadOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _orders = await _api.fetchRiderOrders();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

