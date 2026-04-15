import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../providers/products_provider.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/product_card.dart';
import '../../widgets/role_card.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import 'categories_screen.dart';
import '../product/product_detail_screen.dart';
import '../role_selection_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('HappyHands'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: TextField(
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: 'Search products (coming soon)',
                    prefixIcon: const Icon(Icons.search),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              SizedBox(
                height: 44,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  scrollDirection: Axis.horizontal,
                  children: [
                    _CategoryChip(
                      label: 'Baby Clothes',
                      slug: 'baby-clothes',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CategoriesScreen(
                            initialSlug: 'baby-clothes',
                          ),
                        ),
                      ),
                    ),
                    _CategoryChip(
                      label: 'Comfort Toys',
                      slug: 'comfort-toys',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CategoriesScreen(
                            initialSlug: 'comfort-toys',
                          ),
                        ),
                      ),
                    ),
                    _CategoryChip(
                      label: 'Educational',
                      slug: 'educational-toys',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CategoriesScreen(
                            initialSlug: 'educational-toys',
                          ),
                        ),
                      ),
                    ),
                    _CategoryChip(
                      label: 'Stroller Gear',
                      slug: 'stroller-gear',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CategoriesScreen(
                            initialSlug: 'stroller-gear',
                          ),
                        ),
                      ),
                    ),
                    _CategoryChip(
                      label: 'Safety',
                      slug: 'safety-and-health',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CategoriesScreen(
                            initialSlug: 'safety-and-health',
                          ),
                        ),
                      ),
                    ),
                    _CategoryChip(
                      label: 'Nursery',
                      slug: 'nursery-furniture',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CategoriesScreen(
                            initialSlug: 'nursery-furniture',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      body: Builder(
        builder: (_) {
          if (products.isLoading) {
            return const LoadingWidget(label: 'Loading products...');
          }
          if (products.error != null) {
            return ErrorView(
              message: products.error!,
              onRetry: () => context.read<ProductsProvider>().fetch(),
            );
          }

          final items = products.items;
          return RefreshIndicator(
            onRefresh: () => context.read<ProductsProvider>().fetch(),
            child: CustomScrollView(
              slivers: [
                // Join Platform Section - AT TOP
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.lightGray,
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusXL,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Join Our Platform',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          color: AppTheme.darkBlue,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Become a partner today',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: AppTheme.mediumGray),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const RoleSelectionScreen(),
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryBlue,
                                foregroundColor: AppTheme.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppConstants.radiusLG,
                                  ),
                                ),
                              ),
                              child: const Text('Join Now'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Products Section Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Featured Products',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: AppTheme.darkBlue,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        Text(
                          '${items.length} items',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppTheme.mediumGray),
                        ),
                      ],
                    ),
                  ),
                ),

                // Products Grid (or empty state)
                if (items.isEmpty)
                  SliverToBoxAdapter(
                    child: Container(
                      height: 200,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: 48,
                            color: AppTheme.mediumGray.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No products available',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: AppTheme.mediumGray),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.all(12),
                    sliver: SliverGrid.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.72,
                          ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final p = items[index];
                        return ProductCard(
                          product: p,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    ProductDetailScreen(productId: p.id),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                // Bottom padding
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final String slug;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.slug,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(label: Text(label), onPressed: onTap),
    );
  }
}
