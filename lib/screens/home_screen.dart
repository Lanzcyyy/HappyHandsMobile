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
import '../models/product.dart';
import '../screens/product_detail_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/auth_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

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
          HeroCarousel(
            onShopNow: _scrollToProducts,
          ),
          
          // Featured Products Section
          _buildFeaturedSection(),
          
          // Categories Section
          _buildCategoriesSection(),
          
          // All Products Section
          _buildAllProductsSection(),
          
          // Features Section
          _buildFeaturesSection(),
          
          // Bottom padding
          const SizedBox(height: AppConstants.spacingXXL),
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
                  Text(
                    'Top picks for your little ones',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.darkBlue,
                      fontWeight: FontWeight.w700,
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
                        borderRadius: BorderRadius.circular(AppConstants.radiusSM),
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
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.darkBlue,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppConstants.spacingSM),
          Text(
            'Our collections',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.mediumGray,
            ),
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
          border: Border.all(
            color: AppTheme.borderGray.withOpacity(0.3),
          ),
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

  Widget _buildAllProductsSection() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        return Container(
          padding: const EdgeInsets.all(AppConstants.spacingLG),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'All Products',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.darkBlue,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppConstants.spacingMD),
              
              // Products Grid
              if (productProvider.isLoading && productProvider.products.isEmpty)
                const LoadingWidget(height: 300)
              else if (productProvider.products.isEmpty)
                _buildEmptyProducts()
              else
                Column(
                  children: [
                    _buildProductGrid(productProvider.products),
                    
                    // Load More Button
                    if (productProvider.hasMorePages)
                      Padding(
                        padding: const EdgeInsets.only(top: AppConstants.spacingLG),
                        child: productProvider.isLoading
                            ? const LoadingWidget(height: 50)
                            : ElevatedButton(
                                onPressed: () => productProvider.loadMoreProducts(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryBlue,
                                  foregroundColor: AppTheme.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppConstants.spacingXL,
                                    vertical: AppConstants.spacingMD,
                                  ),
                                ),
                                child: const Text('Load More'),
                              ),
                      ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

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
                  AppTheme.primaryBlue.withOpacity(0.1),
                  AppTheme.darkBlue.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(AppConstants.radiusMD),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bring Home Joyful Moments',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: AppTheme.darkBlue,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: AppConstants.spacingSM),
                          Text(
                            'Curated baby essentials parents rave about—find a new favorite today.',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppTheme.mediumGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingXL),
                    Container(
                      padding: const EdgeInsets.all(AppConstants.spacingMD),
                      decoration: BoxDecoration(
                        color: AppTheme.successGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            FontAwesomeIcons.leaf,
                            color: AppTheme.successGreen,
                            size: 24,
                          ),
                          const SizedBox(height: AppConstants.spacingXS),
                          Text(
                            'Eco-Friendly',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppTheme.successGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Safe materials for your little ones',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.mediumGray,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppConstants.spacingXL),
          
          // Features Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
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

  Widget _buildFeatureCard(Map<String, String> feature) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMD),
      decoration: BoxDecoration(
        color: AppTheme.lightGray,
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        border: Border.all(
          color: AppTheme.borderGray.withOpacity(0.3),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            feature['icon'] ?? '📦',
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: AppConstants.spacingSM),
          Text(
            feature['title'] ?? 'Feature',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.darkBlue,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingXS),
          Text(
            feature['subtitle'] ?? 'Description',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
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

  Widget _buildEmptySearch() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FontAwesomeIcons.search,
              size: 64,
              color: AppTheme.mediumGray,
            ),
            const SizedBox(height: AppConstants.spacingMD),
            Text(
              'No products found',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.mediumGray,
              ),
            ),
            const SizedBox(height: AppConstants.spacingSM),
            Text(
              'Try searching with different keywords',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.mediumGray,
              ),
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
        border: Border.all(
          color: AppTheme.borderGray.withOpacity(0.3),
        ),
      ),
      child: const Center(
        child: Text('No featured products available yet.'),
      ),
    );
  }

  Widget _buildEmptyProducts() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: AppTheme.lightGray,
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        border: Border.all(
          color: AppTheme.borderGray.withOpacity(0.3),
        ),
      ),
      child: const Center(
        child: Text('No products available yet.'),
      ),
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
              FontAwesomeIcons.exclamationTriangle,
              size: 64,
              color: AppTheme.errorRed,
            ),
            const SizedBox(height: AppConstants.spacingMD),
            Text(
              'Something went wrong',
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
    // Navigate to category screen (to be implemented)
  }

  void _addToCart(Product product) async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.user == null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );
      return;
    }

    final cartProvider = context.read<CartProvider>();
    final success = await cartProvider.addToCart(
      product: product,
      quantity: 1,
      authToken: authProvider.backendAccessToken,
    );

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
