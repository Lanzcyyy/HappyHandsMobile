import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;

import '../models/product.dart';
import '../services/firebase_database_service.dart'; // Updated Service

class ProductsProvider extends ChangeNotifier {
  final FirebaseDatabaseService _dbService;

  // Constructor now takes the Firebase service
  ProductsProvider(this._dbService);

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
      // 1. Fetch raw data from Firebase service
      final List<Map<String, dynamic>> data = await _dbService.getProducts();
      
      // 2. Map the data to your Product model
      _items = data.map((json) => Product.fromJson(json)).toList();
      
      developer.log("Successfully loaded ${_items.length} products from Firebase.");
    } catch (e) {
      _error = "Failed to load products: ${e.toString()}";
      developer.log("Error in ProductsProvider: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}