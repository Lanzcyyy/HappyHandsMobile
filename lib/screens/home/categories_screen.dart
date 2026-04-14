import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/category.dart';
import '../../models/product.dart';
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
      final api = context.read<FlaskApiService>();
      final res = await api.fetchCategory(_slug);
      if (!mounted) return;
      setState(() {
        _categories = res.categories;
        _products = res.products;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: Builder(
        builder: (_) {
          if (_loading) return const LoadingWidget(label: 'Loading category...');
          if (_error != null) return ErrorView(message: _error!, onRetry: _load);

          return Column(
            children: [
              SizedBox(
                height: 48,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
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
                          MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: p.id)),
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

