import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;

import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/api_service.dart';

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

  int get itemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  double get subtotal => _cartItems.fold(0.0, (sum, item) => sum + item.subtotal);
  double get shippingCost => itemCount > 0 ? 30.0 : 0.0;
  double get total => subtotal + shippingCost;
  bool get isEmpty => _cartItems.isEmpty;
  bool get isNotEmpty => _cartItems.isNotEmpty;

  // ── Local cart helpers ──────────────────────────────────────────────────
  int _nextLocalId = 1000;

  CartItem _makeLocalItem({
    required Product product,
    required int quantity,
    String? size,
    String? color,
  }) {
    return CartItem(
      id: _nextLocalId++,
      quantity: quantity,
      unitPrice: product.price,
      totalPrice: product.price * quantity,
      product: product,
      size: size,
      color: color,
      addedAt: DateTime.now(),
    );
  }

  // Load cart from API
  Future<void> loadCart(String? authToken) async {
    if (authToken == null || authToken.isEmpty) {
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
      developer.log('Cart API unavailable, keeping local cart: $e');
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
    _isUpdating = true;
    _error = null;
    notifyListeners();

    try {
      final existingIndex = _cartItems.indexWhere(
        (item) =>
            item.product.id == product.id &&
            item.size == size &&
            item.color == color,
      );

      if (authToken != null && authToken.isNotEmpty) {
        try {
          if (existingIndex != -1) {
            final existing = _cartItems[existingIndex];
            final updated = await _apiService.updateCartItem(
              cartItemId: existing.id,
              quantity: existing.quantity + quantity,
              authToken: authToken,
            );
            _cartItems[existingIndex] = updated;
          } else {
            final cartItem = await _apiService.addToCart(
              productId: product.id,
              quantity: quantity,
              size: size,
              color: color,
              authToken: authToken,
            );
            _cartItems.add(cartItem);
          }
          developer.log('Added ${product.name} to cart via API');
          return true;
        } catch (e) {
          developer.log('Cart API failed, adding locally: $e');
        }
      }

      // Local fallback
      if (existingIndex != -1) {
        final existing = _cartItems[existingIndex];
        _cartItems[existingIndex] = existing.copyWith(
          quantity: existing.quantity + quantity,
          totalPrice: existing.product.price * (existing.quantity + quantity),
        );
      } else {
        _cartItems.add(_makeLocalItem(
          product: product,
          quantity: quantity,
          size: size,
          color: color,
        ));
      }
      developer.log('Added ${product.name} to local cart');
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
    if (quantity <= 0) {
      return removeFromCart(cartItem: cartItem, authToken: authToken);
    }

    _isUpdating = true;
    _error = null;
    notifyListeners();

    try {
      if (authToken != null && authToken.isNotEmpty) {
        try {
          final updatedItem = await _apiService.updateCartItem(
            cartItemId: cartItem.id,
            quantity: quantity,
            authToken: authToken,
          );
          final index = _cartItems.indexWhere((item) => item.id == cartItem.id);
          if (index != -1) _cartItems[index] = updatedItem;
          return true;
        } catch (_) {}
      }

      // Local fallback
      final index = _cartItems.indexWhere((item) => item.id == cartItem.id);
      if (index != -1) {
        _cartItems[index] = _cartItems[index].copyWith(
          quantity: quantity,
          totalPrice: _cartItems[index].product.price * quantity,
        );
      }
      return true;
    } catch (e) {
      _error = e.toString();
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
    _isUpdating = true;
    _error = null;
    notifyListeners();

    try {
      if (authToken != null && authToken.isNotEmpty) {
        try {
          await _apiService.removeFromCart(
            cartItemId: cartItem.id,
            authToken: authToken,
          );
        } catch (_) {}
      }
      _cartItems.removeWhere((item) => item.id == cartItem.id);
      developer.log('Removed ${cartItem.product.name} from cart');
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  // Clear entire cart
  Future<bool> clearCart(String? authToken) async {
    _isUpdating = true;
    _error = null;
    notifyListeners();

    try {
      if (authToken != null && authToken.isNotEmpty) {
        try {
          await _apiService.clearCart(authToken);
        } catch (_) {}
      }
      _cartItems.clear();
      developer.log('Cleared cart');
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  CartItem? getCartItem({
    required int productId,
    String? size,
    String? color,
  }) {
    try {
      return _cartItems.firstWhere(
        (item) =>
            item.product.id == productId &&
            item.size == size &&
            item.color == color,
      );
    } catch (_) {
      return null;
    }
  }

  int getProductQuantity({required int productId, String? size, String? color}) {
    return getCartItem(productId: productId, size: size, color: color)?.quantity ?? 0;
  }

  bool isProductInCart({required int productId, String? size, String? color}) {
    return getCartItem(productId: productId, size: size, color: color) != null;
  }

  Future<bool> incrementQuantity({
    required CartItem cartItem,
    String? authToken,
  }) async {
    return updateItemQuantity(
      cartItem: cartItem,
      quantity: cartItem.quantity + 1,
      authToken: authToken,
    );
  }

  Future<bool> decrementQuantity({
    required CartItem cartItem,
    String? authToken,
  }) async {
    if (cartItem.quantity <= 1) {
      return removeFromCart(cartItem: cartItem, authToken: authToken);
    }
    return updateItemQuantity(
      cartItem: cartItem,
      quantity: cartItem.quantity - 1,
      authToken: authToken,
    );
  }

  void clearErrors() {
    _error = null;
    notifyListeners();
  }

  void clearLocalCart() {
    _cartItems.clear();
    _error = null;
    notifyListeners();
  }

  Map<String, dynamic> getCartSummary() {
    return {
      'itemCount': itemCount,
      'subtotal': subtotal,
      'shippingCost': shippingCost,
      'total': total,
      'isEmpty': isEmpty,
      'items': cartItems
          .map((item) => {
                'id': item.id,
                'productId': item.product.id,
                'name': item.product.name,
                'price': item.product.price,
                'quantity': item.quantity,
                'subtotal': item.subtotal,
                'size': item.size,
                'color': item.color,
                'imageUrl': item.product.imageUrl,
              })
          .toList(),
    };
  }
}
