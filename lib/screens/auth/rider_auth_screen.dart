import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';

class RiderAuthScreen extends StatelessWidget {
  const RiderAuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        title: const Text('Rider Login'),
        backgroundColor: AppTheme.white,
        foregroundColor: AppTheme.darkBlue,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, Rider!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.darkBlue,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Login or create an account to start delivering orders.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.mediumGray,
                    ),
              ),
              const SizedBox(height: 32),
              
              // Placeholder content
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(AppConstants.radiusLG),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.motorcycle_outlined,
                      size: 64,
                      color: AppTheme.primaryBlue.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Rider Authentication',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.darkBlue,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This screen is under development. Rider login and registration forms will be implemented here.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.mediumGray,
                          ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: AppTheme.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppConstants.radiusLG),
                          ),
                        ),
                        child: const Text('Go Back'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
