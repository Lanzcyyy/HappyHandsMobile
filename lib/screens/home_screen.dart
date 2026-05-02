import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/hero_carousel.dart';
import '../widgets/product_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/custom_app_bar.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';
import '../core/config/app_config.dart';
import '../models/product.dart';
import '../screens/product_detail_screen.dart';
import '../screens/home/categories_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/auth_screen.dart';
import '../screens/auth/seller_auth_screen.dart';
import '../screens/auth/rider_auth_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _setupScrollListener();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _initializeData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadFeaturedProducts(refresh: true);
      context.read<ProductProvider>().loadProducts(refresh: true);

      // Load cart if user is logged in
      final authProvider = context.read<AuthProvider>();
      if (authProvider.user != null) {
        context.read<CartProvider>().loadCart(authProvider.backendAccessToken);
      }
    });
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        final productProvider = context.read<ProductProvider>();
        if (productProvider.hasMorePages && !productProvider.isLoading) {
          productProvider.loadMoreProducts();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: CustomAppBar(
        title: 'Happy Hands',
        showSearch: true,
        searchController: _searchController,
        onSearchChanged: (query) {
          setState(() {
            _isSearching = query.isNotEmpty;
          });
          if (query.isNotEmpty) {
            context.read<ProductProvider>().searchProducts(query);
          } else {
            context.read<ProductProvider>().clearSearch();
          }
        },
        onCartTap: () => _navigateToCart(),
        onProfileTap: () => _navigateToProfile(),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: AppTheme.primaryBlue,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isSearching) {
      return _buildSearchResults();
    }

    return SingleChildScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Carousel
          HeroCarousel(onShopNow: _scrollToProducts),

          // Featured Products Section
          _buildFeaturedSection(),

          // Categories Section
          _buildCategoriesSection(),

          // All Products Section (4-col grid + pagination)
          _buildAllProductsSection(),

          // Features Section (banner + feature cards)
          _buildFeaturesSection(),

          // Footer (Become a Seller / Rider)
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        if (productProvider.isLoadingSearch) {
          return const LoadingWidget();
        }

        if (productProvider.searchError != null) {
          return _buildErrorWidget(
            productProvider.searchError!,
            () => productProvider.searchProducts(_searchController.text),
          );
        }

        if (productProvider.searchResults.isEmpty) {
          return _buildEmptySearch();
        }

        return Padding(
          padding: const EdgeInsets.all(AppConstants.spacingMD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Search Results',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.darkBlue,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppConstants.spacingMD),
              _buildProductGrid(productProvider.searchResults),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeaturedSection() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        return Container(
          padding: const EdgeInsets.all(AppConstants.spacingLG),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'Top picks for your little ones',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.darkBlue,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Product Count
                  if (productProvider.featuredProducts.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacingSM,
                        vertical: AppConstants.spacingXS,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.lightGray,
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusSM,
                        ),
                      ),
                      child: Text(
                        '${productProvider.featuredProducts.length} products',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.mediumGray,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingMD),

              // Featured Products Grid
              if (productProvider.isLoadingFeatured)
                const LoadingWidget(height: 200)
              else if (productProvider.featuredProducts.isEmpty)
                _buildEmptyFeatured()
              else
                _buildProductGrid(productProvider.featuredProducts),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoriesSection() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shop by Category',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.darkBlue,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: AppConstants.spacingSM),
          Text(
            'Our collections',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.mediumGray),
          ),
          const SizedBox(height: AppConstants.spacingLG),

          // Categories Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: AppConstants.spacingMD,
              mainAxisSpacing: AppConstants.spacingMD,
            ),
            itemCount: AppConstants.categories.length,
            itemBuilder: (context, index) {
              final category = AppConstants.categories[index];
              return _buildCategoryCard(category);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, String> category) {
    return GestureDetector(
      onTap: () => _navigateToCategory(category['id']!),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.lightGray,
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
          border: Border.all(color: AppTheme.borderGray.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              category['icon'] ?? '📦',
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: AppConstants.spacingSM),
            Text(
              category['name'] ?? 'Category',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.darkBlue,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ── All Products: 4-column grid + pagination + footer ────────────────────

  static const int _pageSize = 12; // items per page
  int _currentPage = 1;

  int get _totalPages {
    final provider = context.read<ProductProvider>();
    final total = provider.products.length;
    return (total / _pageSize).ceil().clamp(1, 999);
  }

  List<Product> get _pagedProducts {
    final provider = context.read<ProductProvider>();
    final all = provider.products;
    final start = (_currentPage - 1) * _pageSize;
    final end = (start + _pageSize).clamp(0, all.length);
    if (start >= all.length) return [];
    return all.sublist(start, end);
  }

  Widget _buildAllProductsSection() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        return Container(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.spacingLG,
            AppConstants.spacingLG,
            AppConstants.spacingLG,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All Products',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.darkBlue,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  if (productProvider.products.isNotEmpty)
                    Text(
                      '${productProvider.products.length} items',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.mediumGray,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingMD),

              // ── Grid ────────────────────────────────────────────────────
              if (productProvider.isLoading && productProvider.products.isEmpty)
                const LoadingWidget(height: 300)
              else if (productProvider.products.isEmpty)
                _buildEmptyProducts()
              else
                _buildFourColumnGrid(_pagedProducts),

              // ── Pagination ───────────────────────────────────────────────
              if (productProvider.products.isNotEmpty) ...[
                const SizedBox(height: AppConstants.spacingLG),
                _buildPagination(productProvider),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildFourColumnGrid(List<Product> products) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // On very narrow screens fall back to 2 columns
        final cols = constraints.maxWidth < 400 ? 2 : 4;
        final spacing = 8.0;
        final itemW = (constraints.maxWidth - spacing * (cols - 1)) / cols;
        // image ~55 % + info ~45 % of card height
        final itemH = itemW * 1.55;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: itemW / itemH,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return _buildCompactProductCard(product);
          },
        );
      },
    );
  }

  /// Compact card designed for 4-column layout.
  Widget _buildCompactProductCard(Product product) {
    return GestureDetector(
      onTap: () => _navigateToProductDetail(product),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusSM),
          border: Border.all(
            color: AppTheme.borderGray.withValues(alpha: 0.4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 6,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppConstants.radiusSM),
                ),
                child: product.imageUrls.isNotEmpty
                    ? Image.network(
                        product.imageUrls.first.startsWith('http')
                            ? product.imageUrls.first
                            : '${AppConfig.uploadsBaseUrl}/${product.imageUrls.first}',
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _imagePlaceholder(),
                      )
                    : _imagePlaceholder(),
              ),
            ),

            // Info
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.darkBlue,
                        height: 1.2,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            '₱${product.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primaryBlue,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _addToCart(product),
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(
                              Icons.add_shopping_cart,
                              size: 11,
                              color: AppTheme.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: AppTheme.lightGray,
      child: const Center(
        child: Icon(Icons.image_outlined, color: AppTheme.mediumGray, size: 20),
      ),
    );
  }

  Widget _buildPagination(ProductProvider productProvider) {
    final total = _totalPages;
    if (total <= 1) return const SizedBox.shrink();

    // Show at most 5 page buttons around current page
    final List<int> pages = [];
    final start = (_currentPage - 2).clamp(1, total);
    final end = (_currentPage + 2).clamp(1, total);
    for (int i = start; i <= end; i++) {
      pages.add(i);
    }

    return Column(
      children: [
        const Divider(height: 1, color: AppTheme.borderGray),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 6,
          runSpacing: 6,
          children: [
            // Prev
            if (_currentPage > 1)
              _pageButton('‹', () => setState(() => _currentPage--)),

            // Page numbers
            for (final p in pages)
              _pageButton(
                '$p',
                () => setState(() => _currentPage = p),
                isActive: p == _currentPage,
              ),

            // Next
            if (_currentPage < total)
              _pageButton('›', () => setState(() => _currentPage++)),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Page $_currentPage of $total',
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.mediumGray,
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _pageButton(String label, VoidCallback onTap, {bool isActive = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minWidth: 34),
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryBlue : AppTheme.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusSM),
          border: Border.all(
            color: isActive ? AppTheme.primaryBlue : AppTheme.borderGray,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
              color: isActive ? AppTheme.white : AppTheme.darkBlue,
            ),
          ),
        ),
      ),
    );
  }

  // ── Features section (banner + features grid only; partner cards moved to footer) ──

  Widget _buildFeaturesSection() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLG),
      child: Column(
        children: [
          // Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppConstants.spacingXL),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryBlue.withValues(alpha: 0.1),
                  AppTheme.darkBlue.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(AppConstants.radiusMD),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 640;

                final bannerCopy = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bring Home Joyful Moments',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontSize: isNarrow ? 24 : null,
                            color: AppTheme.darkBlue,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: AppConstants.spacingSM),
                    Text(
                      'Curated baby essentials parents rave about—find a new favorite today.',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: isNarrow ? 15 : null,
                        color: AppTheme.mediumGray,
                      ),
                    ),
                  ],
                );

                final ecoCard = Container(
                  width: isNarrow ? double.infinity : 170,
                  padding: const EdgeInsets.all(AppConstants.spacingMD),
                  decoration: BoxDecoration(
                    color: AppTheme.successGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(FontAwesomeIcons.leaf, color: AppTheme.successGreen, size: 24),
                      const SizedBox(height: AppConstants.spacingXS),
                      Text(
                        'Eco-Friendly',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontSize: isNarrow ? 13 : null,
                          color: AppTheme.successGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Safe materials for your little ones',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: isNarrow ? 11 : null,
                          color: AppTheme.mediumGray,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );

                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      bannerCopy,
                      const SizedBox(height: AppConstants.spacingMD),
                      ecoCard,
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: bannerCopy),
                    const SizedBox(width: AppConstants.spacingXL),
                    ecoCard,
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: AppConstants.spacingXL),

          // Features Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.1,
              crossAxisSpacing: AppConstants.spacingMD,
              mainAxisSpacing: AppConstants.spacingMD,
            ),
            itemCount: AppConstants.features.length,
            itemBuilder: (context, index) {
              final feature = AppConstants.features[index];
              return _buildFeatureCard(feature);
            },
          ),
        ],
      ),
    );
  }

  /// 2-column grid used for featured products and search results.
  Widget _buildProductGrid(List<Product> products) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: AppConstants.spacingMD,
        mainAxisSpacing: AppConstants.spacingMD,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(
          product: product,
          onTap: () => _navigateToProductDetail(product),
          onAddToCart: () => _addToCart(product),
        );
      },
    );
  }

  Widget _buildFeatureCard(Map<String, String> feature) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMD),
      decoration: BoxDecoration(
        color: AppTheme.lightGray,
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        border: Border.all(color: AppTheme.borderGray.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(feature['icon'] ?? '📦', style: const TextStyle(fontSize: 22)),
          const SizedBox(height: AppConstants.spacingSM),
          Text(
            feature['title'] ?? 'Feature',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.darkBlue,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingXS),
          Text(
            feature['subtitle'] ?? 'Description',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 11,
              color: AppTheme.mediumGray,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ── Footer ────────────────────────────────────────────────────────────────

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spacingLG,
        AppConstants.spacingXL,
        AppConstants.spacingLG,
        AppConstants.spacingXXL,
      ),
      decoration: BoxDecoration(
        color: AppTheme.lightGray,
        border: Border(
          top: BorderSide(color: AppTheme.borderGray.withValues(alpha: 0.5)),
        ),
      ),
      child: Column(
        children: [
          // Partner CTA row
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 500;

              final sellerBtn = _buildFooterPartnerButton(
                icon: Icons.storefront_outlined,
                label: 'Become a Seller',
                sublabel: 'List products & reach customers',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SellerAuthScreen()),
                ),
              );

              final riderBtn = _buildFooterPartnerButton(
                icon: Icons.delivery_dining_outlined,
                label: 'Become a Rider',
                sublabel: 'Deliver orders & earn flexibly',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RiderAuthScreen()),
                ),
              );

              if (isWide) {
                return Row(
                  children: [
                    Expanded(child: sellerBtn),
                    const SizedBox(width: AppConstants.spacingMD),
                    Expanded(child: riderBtn),
                  ],
                );
              }
              return Column(
                children: [
                  sellerBtn,
                  const SizedBox(height: AppConstants.spacingMD),
                  riderBtn,
                ],
              );
            },
          ),

          const SizedBox(height: AppConstants.spacingXL),
          const Divider(color: AppTheme.borderGray),
          const SizedBox(height: AppConstants.spacingMD),

          // Brand line
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryBlue,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('👶', style: TextStyle(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Happy Hands',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppTheme.darkBlue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Your trusted baby essentials store',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.mediumGray,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFooterPartnerButton({
    required IconData icon,
    required String label,
    required String sublabel,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacingMD),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
          border: Border.all(
            color: AppTheme.primaryBlue.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusSM),
              ),
              child: Icon(icon, color: AppTheme.primaryBlue, size: 20),
            ),
            const SizedBox(width: AppConstants.spacingMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    sublabel,
                    style: const TextStyle(
                      color: AppTheme.mediumGray,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppTheme.mediumGray,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySearch() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FontAwesomeIcons.magnifyingGlass, size: 64, color: AppTheme.mediumGray),
            const SizedBox(height: AppConstants.spacingMD),
            Text(
              'No products found',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(color: AppTheme.mediumGray),
            ),
            const SizedBox(height: AppConstants.spacingSM),
            Text(
              'Try searching with different keywords',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.mediumGray),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyFeatured() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppTheme.lightGray,
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        border: Border.all(color: AppTheme.borderGray.withValues(alpha: 0.3)),
      ),
      child: const Center(child: Text('No featured products available yet.')),
    );
  }

  Widget _buildEmptyProducts() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: AppTheme.lightGray,
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        border: Border.all(color: AppTheme.borderGray.withValues(alpha: 0.3)),
      ),
      child: const Center(child: Text('No products available yet.')),
    );
  }

  Widget _buildErrorWidget(String error, VoidCallback onRetry) {
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
              'Something went wrong',
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
              onPressed: onRetry,
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

  Future<void> _refreshData() async {
    await Future.wait([
      context.read<ProductProvider>().refreshProducts(),
      context.read<ProductProvider>().loadFeaturedProducts(refresh: true),
    ]);
  }

  void _scrollToProducts() {
    // Scroll to products section
    // This would need to be implemented with a GlobalKey
  }

  void _navigateToProductDetail(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(productId: product.id),
      ),
    );
  }

  void _navigateToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CartScreen()),
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

  void _navigateToCategory(String categoryId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoriesScreen(initialSlug: categoryId),
      ),
    );
  }

  void _addToCart(Product product) async {
    final cartProvider = context.read<CartProvider>();
    final authProvider = context.read<AuthProvider>();

    final success = await cartProvider.addToCart(
      product: product,
      quantity: 1,
      authToken: authProvider.backendAccessToken,
    );

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppConstants.successAddedToCart),
          backgroundColor: AppTheme.successGreen,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cartProvider.error ?? AppConstants.errorGeneral),
          backgroundColor: AppTheme.errorRed,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
