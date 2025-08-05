import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/services/auth_service.dart';
import '../../routes/app_routes.dart';

/// Authentication Middleware
/// GetX Route Guard - Korumalı sayfalara erişim kontrolü
class AuthMiddleware extends GetMiddleware {
  final AuthService _authService = Get.find<AuthService>();

  @override
  int? get priority => 1; // Yüksek öncelik

  @override
  RouteSettings? redirect(String? route) {
    // Route null ise veya boşsa, redirect yapma
    if (route == null || route.isEmpty) {
      return null;
    }

    // Splash, login, register gibi açık sayfalarda middleware çalışmasın
    if (_isPublicRoute(route)) {
      return null;
    }

    // Kullanıcı authentication kontrolü
    if (!_isUserAuthenticated()) {
      // Authentication gerekli ama kullanıcı giriş yapmamış
      return const RouteSettings(name: AppRoutes.login);
    }

    // Email verification kontrolü
    if (!_isEmailVerified()) {
      // Kullanıcı giriş yapmış ama email doğrulanmamış
      return const RouteSettings(name: AppRoutes.emailVerification);
    }

    // Authentication ve verification OK - route'a devam et
    return null;
  }

  /// Kullanıcı giriş yapmış mı?
  bool _isUserAuthenticated() {
    final user = _authService.currentUser;
    return user != null;
  }

  /// Email doğrulanmış mı?
  bool _isEmailVerified() {
    final user = _authService.currentUser;
    return user?.emailVerified ?? false;
  }

  /// Public route mu? (Middleware çalışmasın)
  bool _isPublicRoute(String route) {
    const publicRoutes = [
      AppRoutes.splash,
      AppRoutes.login,
      AppRoutes.register,
      AppRoutes.emailVerification,
      AppRoutes.forgotPassword,
      AppRoutes.notFound,
    ];

    return publicRoutes.contains(route);
  }
}

/// Optional: Sadece Email Verification Gerektiren Middleware
class EmailVerificationMiddleware extends GetMiddleware {
  final AuthService _authService = Get.find<AuthService>();

  @override
  int? get priority => 2; // AuthMiddleware'den sonra çalışır

  @override
  RouteSettings? redirect(String? route) {
    // Route null ise veya boşsa, redirect yapma
    if (route == null || route.isEmpty) {
      return null;
    }

    // Sadece specific route'larda email verification kontrolü yap
    if (!_requiresEmailVerification(route)) {
      return null;
    }

    // Email verification kontrolü
    if (!_isEmailVerified()) {
      return const RouteSettings(name: AppRoutes.emailVerification);
    }

    return null;
  }

  bool _isEmailVerified() {
    final user = _authService.currentUser;
    return user?.emailVerified ?? false;
  }

  /// Bu route email verification gerektiriyor mu?
  bool _requiresEmailVerification(String route) {
    // Tüm ana uygulama sayfaları email verification gerektirir
    const verificationRequiredRoutes = [
      AppRoutes.dashboard,
      AppRoutes.navigation,
      AppRoutes.vehicles,
      AppRoutes.sessions,
      AppRoutes.rides,
      AppRoutes.expenses,
    ];

    return verificationRequiredRoutes.contains(route);
  }
}
