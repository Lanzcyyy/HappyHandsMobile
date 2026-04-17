import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';
import '../core/config/app_config.dart';

class HeroCarousel extends StatefulWidget {
  final VoidCallback? onShopNow;

  const HeroCarousel({super.key, this.onShopNow});

  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel> {
  int _currentIndex = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  double _carouselHeight(double screenHeight, bool isMobile) {
    if (isMobile) {
      return (screenHeight * 0.56).clamp(440.0, 500.0).toDouble();
    }

    return (screenHeight * 0.50).clamp(520.0, 620.0).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final isMobile = screenWidth < 768;
    final carouselHeight = _carouselHeight(screenHeight, isMobile);

    return SizedBox(
      height: carouselHeight,
      width: double.infinity,
      child: ClipRect(
        child: Stack(
          children: [
            // Carousel
            CarouselSlider.builder(
              carouselController: _carouselController,
              options: CarouselOptions(
                height: carouselHeight,
                viewportFraction: 1.0,
                enlargeCenterPage: false,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 5),
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                autoPlayCurve: Curves.easeInOut,
                pauseAutoPlayOnManualNavigate: true,
                pauseAutoPlayOnTouch: true,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
              itemCount: AppConstants.heroSlides.length,
              itemBuilder: (context, index, realIndex) {
                final slide = AppConstants.heroSlides[index];
                return _buildHeroSlide(slide, index, isMobile: isMobile);
              },
            ),

            // Navigation Arrows
            Positioned(
              left: isMobile ? 10 : 20,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () => _carouselController.previousPage(),
                    icon: const Icon(Icons.chevron_left),
                    iconSize: 24,
                    color: AppTheme.darkBlue,
                  ),
                ),
              ),
            ),

            Positioned(
              right: isMobile ? 10 : 20,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () => _carouselController.nextPage(),
                    icon: const Icon(Icons.chevron_right),
                    iconSize: 24,
                    color: AppTheme.darkBlue,
                  ),
                ),
              ),
            ),

            // Dot Indicators
            Positioned(
              bottom: isMobile ? 18 : 24,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: AppConstants.heroSlides.asMap().entries.map((entry) {
                  return GestureDetector(
                    onTap: () => _carouselController.animateToPage(entry.key),
                    child: Container(
                      width: _currentIndex == entry.key ? 12 : 8,
                      height: _currentIndex == entry.key ? 12 : 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentIndex == entry.key
                            ? AppTheme.primaryBlue
                            : AppTheme.white.withOpacity(0.6),
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
      ),
    );
  }

  Widget _buildHeroSlide(
    Map<String, dynamic> slide,
    int index, {
    required bool isMobile,
  }) {
    LinearGradient gradient;
    String imagePath;

    switch (slide['gradient']) {
      case 'gradient1':
        gradient = AppTheme.heroGradient1;
        break;
      case 'gradient2':
        gradient = AppTheme.heroGradient2;
        break;
      case 'gradient3':
        gradient = AppTheme.heroGradient3;
        break;
      default:
        gradient = AppTheme.heroGradient1;
    }

    imagePath = slide['image'] ?? 'photo1.png';
    final imageUrl = '${AppConfig.staticBaseUrl}/images/$imagePath';

    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive padding
        final horizontalPadding = isMobile ? 20.0 : 80.0;
        final verticalPadding = isMobile ? 16.0 : 40.0;

        return SizedBox.expand(
          child: Container(
            decoration: BoxDecoration(gradient: gradient),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: isMobile
                  ? _buildMobileLayout(slide, imageUrl)
                  : _buildDesktopLayout(slide, imageUrl),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileLayout(Map<String, dynamic> slide, String imageUrl) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Image on top for mobile
        _buildCarouselImage(imageUrl, isMobile: true),
        const SizedBox(height: 12),
        // Text content below
        _buildTextContent(slide, isMobile: true),
      ],
    );
  }

  Widget _buildDesktopLayout(Map<String, dynamic> slide, String imageUrl) {
    return Row(
      children: [
        // Left side - Text content
        Expanded(flex: 1, child: _buildTextContent(slide, isMobile: false)),
        const SizedBox(width: 40),
        // Right side - Image
        Expanded(
          flex: 1,
          child: _buildCarouselImage(imageUrl, isMobile: false),
        ),
      ],
    );
  }

  Widget _buildTextContent(
    Map<String, dynamic> slide, {
    required bool isMobile,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: isMobile
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          slide['title'] ?? '',
          style: isMobile
              ? Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.darkBlue,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  fontSize: 24,
                )
              : Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: AppTheme.darkBlue,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  fontSize: 48,
                ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
        ),
        const SizedBox(height: 12),
        Text(
          slide['subtitle'] ?? '',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppTheme.darkBlue,
            height: 1.4,
            fontSize: isMobile ? 13 : 16,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: widget.onShopNow,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryBlue,
            foregroundColor: AppTheme.white,
            elevation: 0,
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 24 : 32,
              vertical: isMobile ? 12 : 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusLG),
            ),
          ),
          child: Text(
            'Shop now',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              fontSize: isMobile ? 13 : 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCarouselImage(String imageUrl, {required bool isMobile}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.radiusLG),
      child: Container(
        height: isMobile ? 170 : null,
        constraints: isMobile
            ? const BoxConstraints(maxHeight: 190, maxWidth: 280)
            : const BoxConstraints(maxHeight: 360, maxWidth: 450),
        child: Image.network(
          imageUrl,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: isMobile ? 170 : 300,
              width: isMobile ? 280 : 400,
              decoration: BoxDecoration(
                color: AppTheme.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryBlue,
                  ),
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: isMobile ? 170 : 300,
              width: isMobile ? 280 : 400,
              decoration: BoxDecoration(
                color: AppTheme.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_not_supported,
                    size: isMobile ? 40 : 48,
                    color: AppTheme.darkBlue.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Image not available',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.darkBlue.withValues(alpha: 0.7),
                      fontSize: isMobile ? 12 : 14,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
