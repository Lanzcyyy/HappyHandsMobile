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
    Key? key,
    required this.product,
    this.onTap,
    this.onAddToCart,
    this.showAddToCart = true,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isHovered = false;
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
              color: AppTheme.borderGray.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
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
                    children: [
                      // Product Name
                      Text(
                        widget.product.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppConstants.spacingXS),
                      // Price and Stock
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Price
                          Text(
                            '₱${widget.product.price.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.black,
                            ),
                          ),
                          // Stock
                          if (widget.product.stock != null)
                            Text(
                              'Stock: ${widget.product.stock}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.mediumGray,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.spacingSM),
                      // Add to Cart Button
                      if (widget.showAddToCart)
                        SizedBox(
                          width: double.infinity,
                          height: 32,
                          child: ElevatedButton(
                            onPressed: widget.onAddToCart,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryBlue,
                              foregroundColor: AppTheme.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppConstants.radiusLG),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  FontAwesomeIcons.shoppingCart,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Add',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
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

