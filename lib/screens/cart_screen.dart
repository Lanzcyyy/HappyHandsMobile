import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/loading_widget.dart';
import '../widgets/custom_app_bar.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';
import '../models/cart_item.dart';
import '../screens/auth_screen.dart';
import '../screens/checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.user != null) {
        context.read<CartProvider>().loadCart(authProvider.backendAccessToken);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: CustomAppBar(
        title: 'Shopping Cart',
        onCartTap: () => Navigator.pop(context),
        onProfileTap: () => _navigateToProfile(),
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          // Check if user is logged in
          final authProvider = context.read<AuthProvider>();
          if (authProvider.user == null) {
            return _buildLoginPrompt();
          }

          if (cartProvider.isLoading) {
            return const LoadingWidget();
          }

          if (cartProvider.error != null) {
            return _buildErrorWidget(cartProvider.error!);
          }

          if (cartProvider.isEmpty) {
            return _buildEmptyCart();
          }

          return _buildCartContent(cartProvider);
        },
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FontAwesomeIcons.userLock,
              size: 64,
              color: AppTheme.mediumGray,
            ),
            const SizedBox(height: AppConstants.spacingMD),
            Text(
              'Login Required',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.darkBlue,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppConstants.spacingSM),
            Text(
              'Please login to view your shopping cart.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.mediumGray,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingXL),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: AppTheme.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingXL,
                  vertical: AppConstants.spacingMD,
                ),
              ),
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FontAwesomeIcons.shoppingCart,
              size: 64,
              color: AppTheme.mediumGray,
            ),
            const SizedBox(height: AppConstants.spacingMD),
            Text(
              'Your cart is empty',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.darkBlue,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppConstants.spacingSM),
            Text(
              'Add some products to your cart to get started.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.mediumGray,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingXL),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: AppTheme.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingXL,
                  vertical: AppConstants.spacingMD,
                ),
              ),
              child: const Text('Continue Shopping'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FontAwesomeIcons.exclamationTriangle,
              size: 64,
              color: AppTheme.errorRed,
            ),
            const SizedBox(height: AppConstants.spacingMD),
            Text(
              'Error loading cart',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.errorRed,
              ),
            ),
            const SizedBox(height: AppConstants.spacingSM),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.mediumGray,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingLG),
            ElevatedButton(
              onPressed: () {
                final authProvider = context.read<AuthProvider>();
                if (authProvider.user != null) {
                  context.read<CartProvider>().loadCart(authProvider.backendAccessToken);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: AppTheme.white,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartContent(CartProvider cartProvider) {
    return Column(
      children: [
        // Cart Items
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppConstants.spacingMD),
            itemCount: cartProvider.cartItems.length,
            itemBuilder: (context, index) {
              final cartItem = cartProvider.cartItems[index];
              return _buildCartItem(cartItem, cartProvider);
            },
          ),
        ),
        
        // Cart Summary and Checkout
        _buildCartSummary(cartProvider),
      ],
    );
  }

  Widget _buildCartItem(CartItem cartItem, CartProvider cartProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMD),
      padding: const EdgeInsets.all(AppConstants.spacingMD),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        border: Border.all(
          color: AppTheme.borderGray.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              border: Border.all(
                color: AppTheme.borderGray.withOpacity(0.3),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              child: CachedNetworkImage(
                imageUrl: cartItem.product.imageUrl ?? cartItem.product.imageUrls.firstOrNull ?? '',
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppTheme.lightGray,
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppTheme.lightGray,
                  child: Icon(
                    FontAwesomeIcons.image,
                    color: AppTheme.mediumGray,
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: AppConstants.spacingMD),
          
          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name
                Text(
                  cartItem.product.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.darkBlue,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: AppConstants.spacingXS),
                
                // Product Variants
                if (cartItem.size != null || cartItem.color != null)
                  Row(
                    children: [
                      if (cartItem.size != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.spacingSM,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.lightGray,
                            borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                          ),
                          child: Text(
                            'Size: ${cartItem.size}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.mediumGray,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppConstants.spacingSM),
                      ],
                      if (cartItem.color != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.spacingSM,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.lightGray,
                            borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                          ),
                          child: Text(
                            'Color: ${cartItem.color}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.mediumGray,
                            ),
                          ),
                        ),
                    ],
                  ),
                
                const SizedBox(height: AppConstants.spacingXS),
                
                // Price
                Text(
                  '₱${cartItem.product.price.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          
          // Quantity Controls and Remove Button
          Column(
            children: [
              // Remove Button
              IconButton(
                onPressed: cartProvider.isUpdating
                    ? null
                    : () => _removeFromCart(cartItem, cartProvider),
                icon: const Icon(
                  FontAwesomeIcons.trash,
                  color: AppTheme.errorRed,
                  size: 16,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
              ),
              
              const SizedBox(height: AppConstants.spacingSM),
              
              // Quantity Controls
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.borderGray),
                  borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Decrease Button
                    IconButton(
                      onPressed: cartProvider.isUpdating
                          ? null
                          : () => _decrementQuantity(cartItem, cartProvider),
                      icon: const Icon(Icons.remove, size: 16),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                    
                    // Quantity Display
                    Container(
                      width: 40,
                      height: 32,
                      alignment: Alignment.center,
                      child: Text(
                        '${cartItem.quantity}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.darkBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    
                    // Increase Button
                    IconButton(
                      onPressed: cartProvider.isUpdating
                          ? null
                          : () => _incrementQuantity(cartItem, cartProvider),
                      icon: const Icon(Icons.add, size: 16),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCartSummary(CartProvider cartProvider) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLG),
      decoration: BoxDecoration(
        color: AppTheme.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Summary Details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal (${cartProvider.itemCount} items)',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.mediumGray,
                ),
              ),
              Text(
                '₱${cartProvider.subtotal.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.darkBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppConstants.spacingSM),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Shipping',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.mediumGray,
                ),
              ),
              Text(
                '₱${cartProvider.shippingCost.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.darkBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const Divider(height: AppConstants.spacingLG),
          
          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.darkBlue,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '₱${cartProvider.total.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppConstants.spacingLG),
          
          // Checkout Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: cartProvider.isUpdating
                  ? null
                  : () => _proceedToCheckout(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: AppTheme.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusLG),
                ),
              ),
              child: cartProvider.isUpdating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.white),
                      ),
                    )
                  : const Text(
                      'Proceed to Checkout',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _incrementQuantity(CartItem cartItem, CartProvider cartProvider) async {
    final authProvider = context.read<AuthProvider>();
    await cartProvider.incrementQuantity(
      cartItem: cartItem,
      authToken: authProvider.backendAccessToken,
    );
  }

  Future<void> _decrementQuantity(CartItem cartItem, CartProvider cartProvider) async {
    final authProvider = context.read<AuthProvider>();
    await cartProvider.decrementQuantity(
      cartItem: cartItem,
      authToken: authProvider.backendAccessToken,
    );
  }

  Future<void> _removeFromCart(CartItem cartItem, CartProvider cartProvider) async {
    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Item'),
        content: Text('Are you sure you want to remove ${cartItem.product.name} from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (shouldRemove == true) {
      final authProvider = context.read<AuthProvider>();
      await cartProvider.removeFromCart(
        cartItem: cartItem,
        authToken: authProvider.backendAccessToken,
      );
    }
  }

  void _proceedToCheckout() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CheckoutScreen()),
    );
  }

  void _navigateToProfile() {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.user == null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );
    } else {
      // Navigate to profile screen (to be implemented)
    }
  }
}
