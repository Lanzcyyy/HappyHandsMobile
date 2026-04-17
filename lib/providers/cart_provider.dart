import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;

import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../core/constants/app_constants.dart';

class CartProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<CartItem> _cartItems = [];
  bool _isLoading = false;
  bool _isUpdating = false;
  String? _error;

  // Getters
  List<CartItem> get cartItems => List.unmodifiable(_cartItems);
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  String? get error => _error;
  
  int get itemCount {
    return _cartItems.fold(0, (sum, item) => sum + item.quantity);
  }
  
  double get subtotal {
    return _cartItems.fold(0.0, (sum, item) => sum + item.subtotal);
  }
  
  double get shippingCost => itemCount > 0 ? 30.0 : 0.0; // Flat rate shipping from web
  
  double get total => subtotal + shippingCost;
  
  bool get isEmpty => _cartItems.isEmpty;
  bool get isNotEmpty => _cartItems.isNotEmpty;

  // Load cart from API
  Future<void> loadCart(String? authToken) async {
    if (authToken == null || authToken.isEmpty) {
      _cartItems.clear();
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final cartItems = await _apiService.getCart(authToken);
      _cartItems = cartItems;
      developer.log('Loaded ${cartItems.length} items in cart');
    } catch (e) {
      _error = e.toString();
      developer.log('Error loading cart: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add item to cart
  Future<bool> addToCart({
    required Product product,
    required int quantity,
    String? size,
    String? color,
    String? authToken,
  }) async {
    if (authToken == null || authToken.isEmpty) {
      _error = AppConstants.errorAuth;
      notifyListeners();
      return false;
    }

    _isUpdating = true;
    _error = null;
    notifyListeners();

    try {
      // Check if item already exists with same variants
      final existingItemIndex = _cartItems.indexWhere(
        (item) => item.product.id == product.id && 
                  item.size == size && 
                  item.color == color,
      );

      if (existingItemIndex != -1) {
        // Update existing item quantity
        final existingItem = _cartItems[existingItemIndex];
        final updatedItem = await _apiService.updateCartItem(
          cartItemId: existingItem.id,
          quantity: existingItem.quantity + quantity,
          authToken: authToken,
        );
        
        _cartItems[existingItemIndex] = updatedItem;
      } else {
        // Add new item
        final cartItem = await _apiService.addToCart(
          productId: product.id,
          quantity: quantity,
          size: size,
          color: color,
          authToken: authToken,
        );
        
        _cartItems.add(cartItem);
      }

      developer.log('Added ${product.name} to cart');
      return true;
    } catch (e) {
      _error = e.toString();
      developer.log('Error adding to cart: $e');
      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  // Update item quantity
  Future<bool> updateItemQuantity({
    required CartItem cartItem,
    required int quantity,
    String? authToken,
  }) async {
    if (authToken == null || authToken.isEmpty) {
      _error = AppConstants.errorAuth;
      notifyListeners();
      return false;
    }

    if (quantity <= 0) {
      return removeFromCart(cartItem: cartItem, authToken: authToken);
    }

    _isUpdating = true;
    _error = null;
    notifyListeners();

    try {
      final updatedItem = await _apiService.updateCartItem(
        cartItemId: cartItem.id,
        quantity: quantity,
        authToken: authToken,
      );

      final index = _cartItems.indexWhere((item) => item.id == cartItem.id);
      if (index != -1) {
        _cartItems[index] = updatedItem;
      }

      developer.log('Updated ${cartItem.product.name} quantity to $quantity');
      return true;
    } catch (e) {
      _error = e.toString();
      developer.log('Error updating cart item: $e');
      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  // Remove item from cart
  Future<bool> removeFromCart({
    required CartItem cartItem,
    String? authToken,
  }) async {
    if (authToken == null || authToken.isEmpty) {
      _error = AppConstants.errorAuth;
      notifyListeners();
      return false;
    }

    _isUpdating = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.removeFromCart(
        cartItemId: cartItem.id,
        authToken: authToken,
      );

      _cartItems.removeWhere((item) => item.id == cartItem.id);
      developer.log('Removed ${cartItem.product.name} from cart');
      return true;
    } catch (e) {
      _error = e.toString();
      developer.log('Error removing from cart: $e');
      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  // Clear entire cart
  Future<bool> clearCart(String? authToken) async {
    if (authToken == null || authToken.isEmpty) {
      _error = AppConstants.errorAuth;
      notifyListeners();
      return false;
    }

    _isUpdating = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.clearCart(authToken);
      _cartItems.clear();
      developer.log('Cleared cart');
      return true;
    } catch (e) {
      _error = e.toString();
      developer.log('Error clearing cart: $e');
      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  // Get cart item by product ID and variants
  CartItem? getCartItem({
    required int productId,
    String? size,
    String? color,
  }) {
    try {
      return _cartItems.firstWhere(
        (item) => item.product.id == productId && 
                  item.size == size && 
                  item.color == color,
      );
    } catch (e) {
      return null;
    }
  }

  // Get quantity of product in cart
  int getProductQuantity({
    required int productId,
    String? size,
    String? color,
  }) {
    final item = getCartItem(productId: productId, size: size, color: color);
    return item?.quantity ?? 0;
  }

  // Check if product is in cart
  bool isProductInCart({
    required int productId,
    String? size,
    String? color,
  }) {
    return getCartItem(productId: productId, size: size, color: color) != null;
  }

  // Increment item quantity
  Future<bool> incrementQuantity({
    required CartItem cartItem,
    String? authToken,
  }) async {
    return await updateItemQuantity(
      cartItem: cartItem,
      quantity: cartItem.quantity + 1,
      authToken: authToken,
    );
  }

  // Decrement item quantity
  Future<bool> decrementQuantity({
    required CartItem cartItem,
    String? authToken,
  }) async {
    if (cartItem.quantity <= 1) {
      return removeFromCart(cartItem: cartItem, authToken: authToken);
    }
    
    return await updateItemQuantity(
      cartItem: cartItem,
      quantity: cartItem.quantity - 1,
      authToken: authToken,
    );
  }

  // Clear errors
  void clearErrors() {
    _error = null;
    notifyListeners();
  }

  // Clear cart locally (for logout)
  void clearLocalCart() {
    _cartItems.clear();
    _error = null;
    notifyListeners();
  }

  // Get cart summary for checkout
  Map<String, dynamic> getCartSummary() {
    return {
      'itemCount': itemCount,
      'subtotal': subtotal,
      'shippingCost': shippingCost,
      'total': total,
      'isEmpty': isEmpty,
      'items': cartItems.map((item) => {
        'id': item.id,
        'productId': item.product.id,
        'name': item.product.name,
        'price': item.product.price,
        'quantity': item.quantity,
        'subtotal': item.subtotal,
        'size': item.size,
        'color': item.color,
        'imageUrl': item.product.imageUrl,
      }).toList(),
    };
  }

}

