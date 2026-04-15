import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showSearch;
  final bool showBackButton;
  final TextEditingController? searchController;
  final Function(String)? onSearchChanged;
  final VoidCallback? onCartTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onBackTap;
  final List<Widget>? actions;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.showSearch = false,
    this.showBackButton = false,
    this.searchController,
    this.onSearchChanged,
    this.onCartTap,
    this.onProfileTap,
    this.onBackTap,
    this.actions,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 16);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMD),
      decoration: BoxDecoration(
        color: AppTheme.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Main App Bar
            Row(
              children: [
                // Back Button
                if (showBackButton)
                  IconButton(
                    onPressed: onBackTap ?? () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppTheme.darkBlue,
                    ),
                    tooltip: 'Back',
                  ),

                // Logo/Title
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppTheme.darkBlue,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                // Search Bar (if shown)
                if (showSearch)
                  Expanded(
                    flex: 2,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacingMD,
                      ),
                      child: TextField(
                        controller: searchController,
                        onChanged: onSearchChanged,
                        decoration: InputDecoration(
                          hintText: 'Search toys...',
                          prefixIcon: const Icon(
                            FontAwesomeIcons.search,
                            size: 16,
                            color: AppTheme.mediumGray,
                          ),
                          filled: true,
                          fillColor: AppTheme.lightGray,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppConstants.radiusFull,
                            ),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.spacingMD,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                  ),

                // Action Buttons
                Row(
                  children: [
                    // Notifications Button
                    IconButton(
                      onPressed: () {
                        // TODO: Implement notifications
                      },
                      icon: Stack(
                        children: [
                          const Icon(
                            FontAwesomeIcons.bell,
                            color: AppTheme.mediumGray,
                            size: 20,
                          ),
                          // Notification Badge (if any)
                          // Positioned(
                          //   top: 0,
                          //   right: 0,
                          //   child: Container(
                          //     width: 8,
                          //     height: 8,
                          //     decoration: const BoxDecoration(
                          //       color: AppTheme.errorRed,
                          //       shape: BoxShape.circle,
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),

                    // Cart Button
                    Consumer<CartProvider>(
                      builder: (context, cartProvider, child) {
                        return IconButton(
                          onPressed: onCartTap,
                          icon: Stack(
                            children: [
                              const Icon(
                                FontAwesomeIcons.shoppingCart,
                                color: AppTheme.mediumGray,
                                size: 20,
                              ),
                              // Cart Badge
                              if (cartProvider.itemCount > 0)
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Container(
                                    constraints: const BoxConstraints(
                                      minWidth: 18,
                                    ),
                                    height: 18,
                                    decoration: BoxDecoration(
                                      color: AppTheme.errorRed,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        cartProvider.itemCount > 99
                                            ? '99+'
                                            : '${cartProvider.itemCount}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              color: AppTheme.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 10,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),

                    // Profile Button
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        return GestureDetector(
                          onTap: onProfileTap,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppTheme.lightGray,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.borderGray,
                                width: 1,
                              ),
                            ),
                            child: authProvider.user?.photoURL != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.network(
                                      authProvider.user!.photoURL!,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return _buildAvatarPlaceholder(
                                              context,
                                              authProvider,
                                            );
                                          },
                                    ),
                                  )
                                : _buildAvatarPlaceholder(
                                    context,
                                    authProvider,
                                  ),
                          ),
                        );
                      },
                    ),

                    // Additional Actions
                    if (actions != null) ...actions!,
                  ],
                ),
              ],
            ),

            // Bottom Divider
            const Divider(height: 1, thickness: 1, color: AppTheme.borderGray),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarPlaceholder(
    BuildContext context,
    AuthProvider authProvider,
  ) {
    final initial = authProvider.user?.displayName?.isNotEmpty == true
        ? authProvider.user!.displayName![0].toUpperCase()
        : authProvider.user?.email?.isNotEmpty == true
        ? authProvider.user!.email![0].toUpperCase()
        : 'U';

    return Center(
      child: Text(
        initial,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: AppTheme.darkBlue,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
