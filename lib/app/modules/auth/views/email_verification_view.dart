import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_constants.dart';
import '../controllers/auth_controller.dart';

class EmailVerificationView extends GetView<AuthController> {
  const EmailVerificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(UIConstants.defaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              _buildIcon(),

              const SizedBox(height: 32),

              // Title
              _buildTitle(),

              const SizedBox(height: 16),

              // Description
              _buildDescription(),

              const SizedBox(height: 40),

              // Email info
              _buildEmailInfo(),

              const SizedBox(height: 32),

              // Action Buttons
              _buildActionButtons(),

              const SizedBox(height: 24),

              // Resend Button
              _buildResendButton(),

              const SizedBox(height: 16),

              // Sign Out Button
              _buildSignOutButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      height: 100,
      width: 100,
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.secondary,
          width: 2,
        ),
      ),
      child: const Icon(
        Icons.email_outlined,
        size: 50,
        color: AppColors.secondary,
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'Email Doğrulama',
      style: Get.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescription() {
    return Text(
      'Hesabınızı aktifleştirmek için email adresinize gönderilen doğrulama linkine tıklayın.',
      style: Get.textTheme.bodyMedium?.copyWith(
        color: AppColors.onSurfaceVariant,
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildEmailInfo() {
    return Obx(() {
      final email = controller.firebaseUser?.email ?? '';
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
          border: Border.all(
            color: AppColors.outline.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.email,
              color: AppColors.secondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                email,
                style: Get.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.verified_outlined,
              color: AppColors.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Check Verification Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => controller.checkEmailVerification(),
            icon: const Icon(Icons.refresh),
            label: const Text('Doğrulamayı Kontrol Et'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: AppColors.onSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResendButton() {
    return Obx(() {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: controller.isEmailVerificationSent
                  ? null
                  : () => controller.sendEmailVerification(),
              icon: const Icon(Icons.send),
              label: Text(
                controller.isEmailVerificationSent
                    ? 'Email Gönderildi'
                    : 'Doğrulama Emaili Gönder',
              ),
            ),
          ),
          if (controller.isEmailVerificationSent) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(UIConstants.defaultBorderRadius),
                border: Border.all(
                  color: AppColors.success.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: AppColors.success,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Doğrulama emaili gönderildi',
                    style: Get.textTheme.bodySmall?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      );
    });
  }

  Widget _buildSignOutButton() {
    return TextButton.icon(
      onPressed: () => _showSignOutDialog(),
      icon: const Icon(Icons.logout),
      label: const Text('Farklı Hesapla Giriş Yap'),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.onSurfaceVariant,
      ),
    );
  }

  void _showSignOutDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Oturumu Kapat'),
        content: const Text(
          'Oturumu kapatmak istediğinizden emin misiniz? Giriş ekranına yönlendirileceksiniz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(); // Dialog'u kapat
              controller.signOut(); // Oturumu kapat
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.onError,
            ),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
  }
}
