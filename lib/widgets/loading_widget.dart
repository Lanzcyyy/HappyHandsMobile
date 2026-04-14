import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';

class LoadingWidget extends StatelessWidget {
  final double? height;
  final double? width;
  final bool useShimmer;
  final String? label;

  const LoadingWidget({
    Key? key,
    this.height,
    this.width,
    this.useShimmer = true,
    this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (label != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
            ),
            if (label != null) ...[
              const SizedBox(height: 12),
              Text(
                label!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      );
    }

    if (useShimmer) {
      return Shimmer.fromColors(
        baseColor: AppTheme.lightGray,
        highlightColor: AppTheme.white,
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: AppTheme.lightGray,
            borderRadius: BorderRadius.circular(AppConstants.radiusMD),
          ),
        ),
      );
    }

    return Container(
      height: height,
      width: width,
      alignment: Alignment.center,
      child: const CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
      ),
    );
  }
}

class ProductGridLoading extends StatelessWidget {
  final int itemCount;

  const ProductGridLoading({
    Key? key,
    this.itemCount = 6,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: AppConstants.spacingMD,
        mainAxisSpacing: AppConstants.spacingMD,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return const LoadingWidget(
          height: 250,
          useShimmer: true,
        );
      },
    );
  }
}

class CartItemLoading extends StatelessWidget {
  const CartItemLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMD),
      padding: const EdgeInsets.all(AppConstants.spacingMD),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        border: Border.all(
          color: AppTheme.borderGray.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          // Product Image
          Shimmer.fromColors(
            baseColor: AppTheme.lightGray,
            highlightColor: AppTheme.white,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.lightGray,
                borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              ),
            ),
          ),
          const SizedBox(width: AppConstants.spacingMD),
          
          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer.fromColors(
                  baseColor: AppTheme.lightGray,
                  highlightColor: AppTheme.white,
                  child: Container(
                    height: 16,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppTheme.lightGray,
                      borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.spacingSM),
                Shimmer.fromColors(
                  baseColor: AppTheme.lightGray,
                  highlightColor: AppTheme.white,
                  child: Container(
                    height: 14,
                    width: 100,
                    decoration: BoxDecoration(
                      color: AppTheme.lightGray,
                      borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                    ),
                  ),
                ),
                const Spacer(),
                Shimmer.fromColors(
                  baseColor: AppTheme.lightGray,
                  highlightColor: AppTheme.white,
                  child: Container(
                    height: 32,
                    width: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.lightGray,
                      borderRadius: BorderRadius.circular(AppConstants.radiusLG),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

