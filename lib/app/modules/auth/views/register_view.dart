import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_constants.dart';
import '../../../core/utils/form_validator.dart';
import '../../../routes/app_routes.dart';
import '../controllers/auth_controller.dart';

class RegisterView extends GetView<AuthController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Kayıt Ol'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(UIConstants.defaultPadding),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                // Header
                _buildHeader(),

                const SizedBox(height: 40),

                // Register Form
                _buildRegisterForm(
                  nameController,
                  emailController,
                  passwordController,
                  confirmPasswordController,
                ),

                const SizedBox(height: 24),

                // Register Button
                Obx(() => _buildRegisterButton(
                      formKey,
                      nameController,
                      emailController,
                      passwordController,
                    )),

                const SizedBox(height: 32),

                // Divider
                _buildDivider(),

                const SizedBox(height: 24),

                // Google Sign-In Button
                Obx(() => _buildGoogleSignInButton()),

                const SizedBox(height: 24),

                // Login Link
                _buildLoginLink(),

                const SizedBox(height: 20),
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
        // Icon
        Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            color: AppColors.secondary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.person_add,
            color: AppColors.onSecondary,
            size: 30,
          ),
        ),

        const SizedBox(height: 16),

        // Title
        Text(
          'Hesap Oluştur',
          style: Get.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),

        const SizedBox(height: 8),

        // Subtitle
        Text(
          'TAG-Pilot\'a hoş geldiniz',
          style: Get.textTheme.bodyMedium?.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRegisterForm(
    TextEditingController nameController,
    TextEditingController emailController,
    TextEditingController passwordController,
    TextEditingController confirmPasswordController,
  ) {
    return Column(
      children: [
        // Name Field
        TextFormField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Ad Soyad',
            hintText: 'Adınızı ve soyadınızı girin',
            prefixIcon: Icon(Icons.person_outline),
          ),
          textInputAction: TextInputAction.next,
          validator: FormValidator.validateName,
        ),

        const SizedBox(height: 16),

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
            hintText: 'En az 6 karakter',
            prefixIcon: Icon(Icons.lock_outline),
          ),
          obscureText: true,
          textInputAction: TextInputAction.next,
          validator: FormValidator.validatePassword,
        ),

        const SizedBox(height: 16),

        // Confirm Password Field
        TextFormField(
          controller: confirmPasswordController,
          decoration: const InputDecoration(
            labelText: 'Şifre Tekrar',
            hintText: 'Şifrenizi tekrar girin',
            prefixIcon: Icon(Icons.lock_outline),
          ),
          obscureText: true,
          textInputAction: TextInputAction.done,
          validator: (value) => FormValidator.validateConfirmPassword(
              value, passwordController.text),
        ),
      ],
    );
  }

  Widget _buildRegisterButton(
    GlobalKey<FormState> formKey,
    TextEditingController nameController,
    TextEditingController emailController,
    TextEditingController passwordController,
  ) {
    return ElevatedButton(
      onPressed: controller.isLoading
          ? null
          : () async {
              if (formKey.currentState!.validate()) {
                await controller.registerWithEmailPassword(
                  email: emailController.text.trim(),
                  password: passwordController.text,
                  name: nameController.text.trim(),
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
          : const Text('Hesap Oluştur'),
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
          : Image.asset(
              'assets/icons/google.png',
              height: 20,
              width: 20,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.alternate_email,
                color: AppColors.primary,
              ),
            ),
      label: const Text('Google ile Kayıt Ol'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.onSurface,
        side: const BorderSide(color: AppColors.outline),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Zaten hesabınız var mı? ',
          style: Get.textTheme.bodyMedium?.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        TextButton(
          onPressed: () => Get.offNamed(AppRoutes.login),
          child: const Text(
            'Giriş Yap',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
