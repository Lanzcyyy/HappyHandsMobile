import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../../core/constants/app_constants.dart';
import '../../models/category.dart';
import '../../models/product.dart';
import '../../models/api_response.dart';
import '../../services/flask_api_service.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/product_card.dart';
import '../product/product_detail_screen.dart';

class CategoriesScreen extends StatefulWidget {
  final String initialSlug;

  const CategoriesScreen({super.key, required this.initialSlug});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  bool _loading = true;
  String? _error;
  String _slug = '';
  List<Category> _categories = const [];
  List<Product> _products = const [];

  @override
  void initState() {
    super.initState();
    _slug = widget.initialSlug;
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = FlaskApiService(ApiClient(tokenProvider: () async => null));
      final res = await api.fetchCategory(_slug);
      if (!mounted) return;
      setState(() {
        _categories = res.categories;
        _products = res.products;
        _loading = false;
      });
    } catch (e) {
      try {
        final api = ApiClient(tokenProvider: () async => null);
        final response = await api.getJson(
          '/products',
          query: {'page': '1', 'page_size': '24', 'category': _slug},
        );

        final parsed = ApiResponse.fromJson<Map<String, dynamic>>(response, (
          data,
        ) {
          return (data as Map<String, dynamic>?) ?? <String, dynamic>{};
        });

        final dynamic responseData = response['data'];
        final dynamic payload = parsed.data ?? responseData ?? response;
        final List<dynamic> productsRaw = payload is Map<String, dynamic>
            ? (payload['items'] as List<dynamic>? ??
                  payload['products'] as List<dynamic>? ??
                  const [])
            : payload is List<dynamic>
            ? payload
            : const [];
        final products = productsRaw
            .whereType<Map<String, dynamic>>()
            .map(Product.fromJson)
            .toList();

        if (!mounted) return;
        setState(() {
          _categories = AppConstants.categories
              .map(
                (entry) => Category(
                  slug: entry['id'] ?? '',
                  name: entry['name'] ?? '',
                ),
              )
              .toList();
          _products = products;
          _loading = false;
          _error = products.isEmpty
              ? 'No products found for this category.'
              : null;
        });
      } catch (fallbackError) {
        if (!mounted) return;
        setState(() {
          _error = fallbackError.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: Builder(
        builder: (_) {
          if (_loading) {
            return const LoadingWidget(label: 'Loading category...');
          }
          if (_error != null) {
            return ErrorView(message: _error!, onRetry: _load);
          }

          return Column(
            children: [
              SizedBox(
                height: 48,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final c = _categories[index];
                    final selected = c.slug == _slug;
                    return ChoiceChip(
                      label: Text(c.name),
                      selected: selected,
                      onSelected: (_) {
                        setState(() => _slug = c.slug);
                        _load();
                      },
                    );
                  },
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final p = _products[index];
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
            ],
          );
        },
      ),
    );
  }
}
