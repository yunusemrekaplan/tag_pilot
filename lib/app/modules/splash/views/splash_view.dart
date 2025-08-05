import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_constants.dart';
import '../controllers/splash_controller.dart';

/// Splash View - Modern ve temiz tasarım
/// SOLID: Single Responsibility - Sadece splash UI'ından sorumlu
class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary,
                AppColors.primary.withOpacity(0.8),
                AppColors.secondary.withOpacity(0.1),
              ],
              stops: const [0.0, 0.7, 1.0],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Section
                  _buildLogoSection(),

                  const SizedBox(height: 80),

                  // Progress Section
                  _buildProgressSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Logo ve app name section
  Widget _buildLogoSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo Container
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.onPrimary,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            Icons.directions_car_filled,
            size: 50,
            color: AppColors.primary,
          ),
        ),

        const SizedBox(height: 24),

        // App Name
        Text(
          AppConstants.appName,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.onPrimary,
            letterSpacing: 1.2,
          ),
        ),

        const SizedBox(height: 8),

        // App Tagline
        Text(
          'TAG Sürücüleri İçin Finansal Asistan',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.onPrimary.withOpacity(0.8),
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Progress ve status section
  Widget _buildProgressSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress Indicator
          Obx(() => Container(
                width: double.infinity,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.onPrimary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: controller.progress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.onPrimary,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.onPrimary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              )),

          const SizedBox(height: 24),

          // Status Message
          Obx(() => AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  controller.statusMessage,
                  key: ValueKey(controller.statusMessage),
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.onPrimary.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              )),

          const SizedBox(height: 32),

          // Progress Percentage (opsiyonel)
          Obx(() => Text(
                '${(controller.progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.onPrimary.withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                ),
              )),
        ],
      ),
    );
  }
}
