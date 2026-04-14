import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:carousel_slider/carousel_controller.dart' show CarouselSliderController;
import 'package:cached_network_image/cached_network_image.dart';

import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';
import '../core/config/app_config.dart';

class HeroCarousel extends StatefulWidget {
  final VoidCallback? onShopNow;

  const HeroCarousel({
    Key? key,
    this.onShopNow,
  }) : super(key: key);

  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel> {
  int _currentIndex = 0;
  final CarouselSliderController _carouselController = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final carouselHeight = screenHeight * 0.64; // 640px equivalent

    return Container(
      height: carouselHeight,
      width: double.infinity,
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
              return _buildHeroSlide(slide, index);
            },
          ),
          
          // Navigation Arrows
          Positioned(
            left: 20,
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
            right: 20,
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
            bottom: 30,
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
    );
  }

  Widget _buildHeroSlide(Map<String, dynamic> slide, int index) {
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

    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 100),
        child: Row(
          children: [
            // Left side - Text content
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    slide['title'] ?? '',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: AppTheme.darkBlue,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingLG),
                  Text(
                    slide['subtitle'] ?? '',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.darkBlue,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingXL),
                  ElevatedButton(
                    onPressed: widget.onShopNow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: AppTheme.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
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
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Right side - Image
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(left: 60),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    decoration: BoxDecoration(
                      color: AppTheme.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_not_supported,
                          size: 48,
                          color: AppTheme.darkBlue.withOpacity(0.5),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Image not available',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.darkBlue.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
