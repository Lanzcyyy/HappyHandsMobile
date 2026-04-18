import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../models/product.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';
import '../core/config/app_config.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final bool showAddToCart;
  final double? width;
  final double? height;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onAddToCart,
    this.showAddToCart = true,
    this.width,
    this.height,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isHovered = false;
  // ignore: unused_field
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = widget.width ?? (screenWidth > 600 ? 200 : screenWidth * 0.45);
    final cardHeight = widget.height ?? cardWidth * 1.3;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: cardWidth,
          height: cardHeight,
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(AppConstants.radiusMD),
            border: Border.all(
              color: AppTheme.borderGray.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(AppConstants.radiusMD),
                          topRight: Radius.circular(AppConstants.radiusMD),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(AppConstants.radiusMD),
                          topRight: Radius.circular(AppConstants.radiusMD),
                        ),
                        child: _buildProductImage(),
                      ),
                    ),
                    // Stock badge if low stock
                    if (widget.product.stock != null && widget.product.stock! < 5)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.errorRed,
                            borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                          ),
                          child: Text(
                            'Only ${widget.product.stock} left',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppTheme.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Product Info
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.spacingSM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Product Name
                      Flexible(
                        child: Text(
                          widget.product.name,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.black,
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 2),
                      // Price and Stock
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Price
                          Flexible(
                            child: Text(
                              '₱${widget.product.price.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppTheme.black,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Stock
                          if (widget.product.stock != null)
                            Text(
                              '${widget.product.stock}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.mediumGray,
                                fontSize: 10,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Add to Cart Button
                      if (widget.showAddToCart)
                        SizedBox(
                          width: double.infinity,
                          height: 28,
                          child: ElevatedButton(
                            onPressed: widget.onAddToCart,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryBlue,
                              foregroundColor: AppTheme.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppConstants.radiusLG),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(FontAwesomeIcons.cartShopping, size: 10),
                                const SizedBox(width: 4),
                                Text(
                                  'Add',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    if (widget.product.imageUrls.isNotEmpty) {
      return PageView.builder(
        itemCount: widget.product.imageUrls.length,
        onPageChanged: (index) {
          setState(() {
            _currentImageIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final imageUrl = widget.product.imageUrls[index];
          final fullImageUrl = imageUrl.startsWith('http')
              ? imageUrl
              : '${AppConfig.uploadsBaseUrl}/$imageUrl';
          
          return CachedNetworkImage(
            imageUrl: fullImageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: AppTheme.lightGray,
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.mediumGray),
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
                    size: 32,
                    color: AppTheme.mediumGray,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No Image',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.mediumGray,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      // Default image placeholder
      return Container(
        color: AppTheme.lightGray,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FontAwesomeIcons.image,
              size: 32,
              color: AppTheme.mediumGray,
            ),
            const SizedBox(height: 8),
            Text(
              'No Image',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.mediumGray,
              ),
            ),
          ],
        ),
      );
    }
  }
}

