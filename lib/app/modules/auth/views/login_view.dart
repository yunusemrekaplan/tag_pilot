import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_constants.dart';
import '../../../core/utils/form_validator.dart';
import '../../../routes/app_routes.dart';
import '../controllers/auth_controller.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(UIConstants.defaultPadding),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),

                // App Logo & Title
                _buildHeader(),

                const SizedBox(height: 60),

                // Login Form
                _buildLoginForm(emailController, passwordController),

                const SizedBox(height: 24),

                // Login Button
                Obx(() => _buildLoginButton(
                    formKey, emailController, passwordController)),

                const SizedBox(height: 16),

                // Forgot Password
                _buildForgotPassword(),

                const SizedBox(height: 32),

                // Divider
                _buildDivider(),

                const SizedBox(height: 24),

                // Google Sign-In Button
                Obx(() => _buildGoogleSignInButton()),

                const SizedBox(height: 40),

                // Register Link
                _buildRegisterLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // App Icon/Logo
        Container(
          height: 80,
          width: 80,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.local_taxi,
            color: AppColors.onPrimary,
            size: 40,
          ),
        ),

        const SizedBox(height: 24),

        // App Title
        Text(
          AppConstants.appName,
          style: Get.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),

        const SizedBox(height: 8),

        // Subtitle
        Text(
          'Taksi şoförleri için kâr yönetimi',
          style: Get.textTheme.bodyMedium?.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm(
    TextEditingController emailController,
    TextEditingController passwordController,
  ) {
    return Column(
      children: [
        // Email Field
        TextFormField(
          controller: emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            hintText: 'ornek@email.com',
            prefixIcon: Icon(Icons.email_outlined),
          ),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          validator: FormValidator.validateEmail,
        ),

        const SizedBox(height: 16),

        // Password Field
        TextFormField(
          controller: passwordController,
          decoration: const InputDecoration(
            labelText: 'Şifre',
            hintText: 'Şifrenizi girin',
            prefixIcon: Icon(Icons.lock_outline),
          ),
          obscureText: true,
          textInputAction: TextInputAction.done,
          validator: FormValidator.validatePassword,
        ),
      ],
    );
  }

  Widget _buildLoginButton(
    GlobalKey<FormState> formKey,
    TextEditingController emailController,
    TextEditingController passwordController,
  ) {
    return ElevatedButton(
      onPressed: controller.isLoading
          ? null
          : () async {
              if (formKey.currentState!.validate()) {
                await controller.signInWithEmailPassword(
                  email: emailController.text.trim(),
                  password: passwordController.text,
                );
              }
            },
      child: controller.isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.onPrimary),
              ),
            )
          : const Text('Giriş Yap'),
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => Get.toNamed(AppRoutes.forgotPassword),
        child: const Text('Şifremi Unuttum'),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'VEYA',
            style: Get.textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildGoogleSignInButton() {
    return OutlinedButton.icon(
      onPressed:
          controller.isLoading ? null : () => controller.signInWithGoogle(),
      icon: controller.isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : Container(
              height: 20,
              width: 20,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF4285F4), // Google Blue
                    Color(0xFF34A853), // Google Green
                    Color(0xFFFBBC05), // Google Yellow
                    Color(0xFFEA4335), // Google Red
                  ],
                ),
              ),
              child: const Center(
                child: Text(
                  'G',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
      label: const Text('Google ile Giriş Yap'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.onSurface,
        side: const BorderSide(color: AppColors.outline),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Hesabınız yok mu? ',
          style: Get.textTheme.bodyMedium?.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        TextButton(
          onPressed: () => Get.toNamed(AppRoutes.register),
          child: const Text(
            'Kayıt Ol',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
