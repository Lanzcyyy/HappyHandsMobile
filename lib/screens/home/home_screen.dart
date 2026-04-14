import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/products_provider.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/product_card.dart';
import 'categories_screen.dart';
import '../product/product_detail_screen.dart';

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
                        MaterialPageRoute(builder: (_) => const CategoriesScreen(initialSlug: 'baby-clothes')),
                      ),
                    ),
                    _CategoryChip(
                      label: 'Comfort Toys',
                      slug: 'comfort-toys',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CategoriesScreen(initialSlug: 'comfort-toys')),
                      ),
                    ),
                    _CategoryChip(
                      label: 'Educational',
                      slug: 'educational-toys',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CategoriesScreen(initialSlug: 'educational-toys')),
                      ),
                    ),
                    _CategoryChip(
                      label: 'Stroller Gear',
                      slug: 'stroller-gear',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CategoriesScreen(initialSlug: 'stroller-gear')),
                      ),
                    ),
                    _CategoryChip(
                      label: 'Safety',
                      slug: 'safety-and-health',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CategoriesScreen(initialSlug: 'safety-and-health')),
                      ),
                    ),
                    _CategoryChip(
                      label: 'Nursery',
                      slug: 'nursery-furniture',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CategoriesScreen(initialSlug: 'nursery-furniture')),
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
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                      MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: p.id)),
                    );
                  },
                );
              },
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
      child: ActionChip(
        label: Text(label),
        onPressed: onTap,
      ),
    );
  }
}

