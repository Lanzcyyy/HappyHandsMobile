import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/loading_widget.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/product_card.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';
import '../core/config/app_config.dart';
import '../models/product.dart';
import 'auth_screen.dart';
import 'cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;
  int _selectedQuantity = 1;
  String? _selectedSize;
  String? _selectedColor;
  bool _isAddingToCart = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProductById(widget.productId);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: CustomAppBar(
        title: 'Product Details',
        onCartTap: () => _navigateToCart(),
        onProfileTap: () => _navigateToProfile(),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          final product = productProvider.selectedProduct;

          if (productProvider.isLoadingProduct) {
            return const LoadingWidget();
          }

          if (productProvider.productError != null) {
            return _buildErrorWidget(productProvider.productError!);
          }

          if (product == null) {
            return _buildEmptyWidget();
          }

          return _buildProductDetails(product);
        },
      ),
    );
  }

  Widget _buildProductDetails(Product product) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Images
          _buildProductImages(product),

          // Product Info
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacingLG),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name and Price
                _buildProductHeader(product),

                const SizedBox(height: AppConstants.spacingLG),

                // Product Description
                _buildProductDescription(product),

                const SizedBox(height: AppConstants.spacingLG),

                // Stock and Rating
                _buildProductMeta(product),

                const SizedBox(height: AppConstants.spacingLG),

                // Size Selection (if applicable)
                if (product.category?.toLowerCase().contains('clothing') ==
                    true)
                  _buildSizeSelection(),

                // Color Selection (if applicable)
                if (product.category?.toLowerCase().contains('clothing') ==
                    true)
                  _buildColorSelection(),

                const SizedBox(height: AppConstants.spacingXL),

                // Quantity Selection
                _buildQuantitySelector(product),

                const SizedBox(height: AppConstants.spacingXL),

                // Action Buttons
                _buildActionButtons(product),

                const SizedBox(height: AppConstants.spacingXL),

                // Related Products
                _buildRelatedProducts(product),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImages(Product product) {
    return SizedBox(
      height: 400,
      child: Stack(
        children: [
          // Image Carousel
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemCount: product.imageUrls.isNotEmpty
                ? product.imageUrls.length
                : 1,
            itemBuilder: (context, index) {
              if (product.imageUrls.isNotEmpty) {
                final imageUrl = product.imageUrls[index];
                final fullImageUrl = imageUrl.startsWith('http')
                    ? imageUrl
                    : '${AppConfig.uploadsBaseUrl}/$imageUrl';

                return CachedNetworkImage(
                  imageUrl: fullImageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => Container(
                    color: AppTheme.lightGray,
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryBlue,
                        ),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppTheme.lightGray,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          FontAwesomeIcons.image,
                          size: 48,
                          color: AppTheme.mediumGray,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No Image',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppTheme.mediumGray),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                // Default placeholder
                return Container(
                  color: AppTheme.lightGray,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        FontAwesomeIcons.image,
                        size: 48,
                        color: AppTheme.mediumGray,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No Image',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.mediumGray,
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),

          // Image Indicators
          if (product.imageUrls.length > 1)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: product.imageUrls.asMap().entries.map((entry) {
                  return GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(
                        entry.key,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      width: _currentImageIndex == entry.key ? 12 : 8,
                      height: _currentImageIndex == entry.key ? 12 : 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentImageIndex == entry.key
                            ? AppTheme.primaryBlue
                            : AppTheme.white.withValues(alpha: 0.6),
                        border: Border.all(
                          color: AppTheme.primaryBlue,
                          width: 1,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductHeader(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.name,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppTheme.darkBlue,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppConstants.spacingSM),
        Text(
          '₱${product.price.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            color: AppTheme.primaryBlue,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildProductDescription(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppTheme.darkBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppConstants.spacingSM),
        Text(
          product.description.isEmpty ? 'No description available.' : product.description,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppTheme.mediumGray,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildProductMeta(Product product) {
    return Row(
      children: [
        // Stock Status
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingMD,
            vertical: AppConstants.spacingSM,
          ),
          decoration: BoxDecoration(
            color: (product.stock != null && product.stock! > 0)
                ? AppTheme.successGreen.withValues(alpha: 0.1)
                : AppTheme.errorRed.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppConstants.radiusSM),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                FontAwesomeIcons.box,
                size: 16,
                color: (product.stock != null && product.stock! > 0)
                    ? AppTheme.successGreen
                    : AppTheme.errorRed,
              ),
              const SizedBox(width: AppConstants.spacingXS),
              Text(
                (product.stock != null && product.stock! > 0)
                    ? 'In Stock (${product.stock})'
                    : 'Out of Stock',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: (product.stock != null && product.stock! > 0)
                      ? AppTheme.successGreen
                      : AppTheme.errorRed,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: AppConstants.spacingMD),

        // Rating (if available)
        if (product.rating != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingMD,
              vertical: AppConstants.spacingSM,
            ),
            decoration: BoxDecoration(
              color: AppTheme.lightGray,
              borderRadius: BorderRadius.circular(AppConstants.radiusSM),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(FontAwesomeIcons.star, size: 16, color: Colors.amber),
                const SizedBox(width: AppConstants.spacingXS),
                Text(
                  product.rating!.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.darkBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (product.reviewCount != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    '(${product.reviewCount})',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppTheme.mediumGray),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSizeSelection() {
    const sizes = ['XS', 'S', 'M', 'L', 'XL'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Size',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppTheme.darkBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppConstants.spacingSM),
        Wrap(
          spacing: AppConstants.spacingSM,
          children: sizes.map((size) {
            final isSelected = _selectedSize == size;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedSize = size;
                });
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryBlue : AppTheme.white,
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryBlue
                        : AppTheme.borderGray,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                ),
                child: Center(
                  child: Text(
                    size,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: isSelected ? AppTheme.white : AppTheme.darkBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildColorSelection() {
    const colors = [
      {'name': 'Red', 'color': Colors.red},
      {'name': 'Blue', 'color': Colors.blue},
      {'name': 'Green', 'color': Colors.green},
      {'name': 'Yellow', 'color': Colors.yellow},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Color',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppTheme.darkBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppConstants.spacingSM),
        Wrap(
          spacing: AppConstants.spacingSM,
          children: colors.map((colorData) {
            final isSelected = _selectedColor == colorData['name'];
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedColor = colorData['name'] as String;
                });
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: colorData['color'] as Color,
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryBlue
                        : AppTheme.borderGray,
                    width: isSelected ? 3 : 1,
                  ),
                  borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: AppTheme.white, size: 20)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuantitySelector(Product product) {
    final maxQuantity = product.stock ?? 999;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quantity',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppTheme.darkBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppConstants.spacingSM),
        Row(
          children: [
            // Decrease Button
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.borderGray),
                borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              ),
              child: IconButton(
                onPressed: _selectedQuantity > 1
                    ? () {
                        setState(() {
                          _selectedQuantity--;
                        });
                      }
                    : null,
                icon: const Icon(Icons.remove, size: 16),
                padding: EdgeInsets.zero,
              ),
            ),

            // Quantity Display
            Container(
              width: 80,
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.borderGray),
                borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              ),
              child: Center(
                child: Text(
                  '$_selectedQuantity',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.darkBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            // Increase Button
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.borderGray),
                borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              ),
              child: IconButton(
                onPressed: _selectedQuantity < maxQuantity
                    ? () {
                        setState(() {
                          _selectedQuantity++;
                        });
                      }
                    : null,
                icon: const Icon(Icons.add, size: 16),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(Product product) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        return Column(
          children: [
            // Add to Cart Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed:
                    (product.stock != null && product.stock! > 0) &&
                        !_isAddingToCart
                    ? () => _addToCart(product)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: AppTheme.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusLG),
                  ),
                ),
                child: _isAddingToCart
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.white,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(FontAwesomeIcons.cartShopping, size: 18),
                          const SizedBox(width: AppConstants.spacingSM),
                          Text(
                            'Add to Cart',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: AppConstants.spacingMD),

            // Buy Now Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: (product.stock != null && product.stock! > 0)
                    ? () => _buyNow(product)
                    : null,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryBlue,
                  side: const BorderSide(color: AppTheme.primaryBlue, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusLG),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      FontAwesomeIcons.bolt,
                      size: 18,
                      color: AppTheme.primaryBlue,
                    ),
                    const SizedBox(width: AppConstants.spacingSM),
                    Text(
                      'Buy Now',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRelatedProducts(Product product) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        // Get related products (same category or random for now)
        final relatedProducts = productProvider.products
            .where((p) => p.id != product.id)
            .take(4)
            .toList();

        if (relatedProducts.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Related Products',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.darkBlue,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppConstants.spacingMD),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: AppConstants.spacingMD,
                mainAxisSpacing: AppConstants.spacingMD,
              ),
              itemCount: relatedProducts.length,
              itemBuilder: (context, index) {
                final relatedProduct = relatedProducts[index];
                return ProductCard(
                  product: relatedProduct,
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProductDetailScreen(productId: relatedProduct.id),
                      ),
                    );
                  },
                  onAddToCart: () => _addToCart(relatedProduct),
                );
              },
            ),
          ],
        );
      },
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
              FontAwesomeIcons.triangleExclamation,
              size: 64,
              color: AppTheme.errorRed,
            ),
            const SizedBox(height: AppConstants.spacingMD),
            Text(
              'Error loading product',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(color: AppTheme.errorRed),
            ),
            const SizedBox(height: AppConstants.spacingSM),
            Text(
              error,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.mediumGray),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingLG),
            ElevatedButton(
              onPressed: () {
                context.read<ProductProvider>().loadProductById(
                  widget.productId,
                );
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

  Widget _buildEmptyWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FontAwesomeIcons.boxOpen,
              size: 64,
              color: AppTheme.mediumGray,
            ),
            const SizedBox(height: AppConstants.spacingMD),
            Text(
              'Product not found',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(color: AppTheme.mediumGray),
            ),
            const SizedBox(height: AppConstants.spacingSM),
            Text(
              'The product you are looking for does not exist.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.mediumGray),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addToCart(Product product) async {
    setState(() => _isAddingToCart = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final cartProvider = context.read<CartProvider>();
      final success = await cartProvider.addToCart(
        product: product,
        quantity: _selectedQuantity,
        size: _selectedSize,
        color: _selectedColor,
        authToken: authProvider.backendAccessToken,
      );

      if (success) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(AppConstants.successAddedToCart),
            backgroundColor: AppTheme.successGreen,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(cartProvider.error ?? AppConstants.errorGeneral),
            backgroundColor: AppTheme.errorRed,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isAddingToCart = false);
    }
  }

  void _buyNow(Product product) {
    // Add to cart and navigate to checkout
    _addToCart(product).then((_) {
      if (!mounted) return;
      // ignore: use_build_context_synchronously
      Navigator.pushNamed(context, '/checkout');
    });
  }

  void _navigateToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CartScreen()),
    );
  }

  void _navigateToProfile() {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.user == null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AuthScreen()),
      );
    } else {
      // Navigate to profile screen (to be implemented)
    }
  }
}
