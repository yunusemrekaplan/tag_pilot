import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import '../utils/app_constants.dart';

/// Navigation Service
/// SOLID: Single Responsibility - Sadece navigation logic'inden sorumlu
/// SOLID: Dependency Inversion - High-level routing logic, low-level GetX details'a bağımlı değil
class NavigationService extends GetxService {
  /// Navigation'ın gerekli olup olmadığını kontrol et
  /// SOLID: Single Responsibility - Navigation decision logic'i ayrı
  bool _shouldNavigate(String targetRoute) {
    return Get.currentRoute != targetRoute;
  }

  /// Navigation için specialized methods
  void navigateToEmailVerification() {
    if (_shouldNavigate(AppRoutes.emailVerification)) {
      Get.offAllNamed(AppRoutes.emailVerification);
      _logNavigation(AppRoutes.emailVerification, 'Email verification needed');
    }
  }

  void navigateToVehicleForm() {
    if (_shouldNavigate(AppRoutes.vehicleForm)) {
      Get.offAllNamed(AppRoutes.vehicleForm);
      _logNavigation(AppRoutes.vehicleForm, 'Vehicle form needed');
    }
  }

  void navigateToMainApp() {
    if (_shouldNavigate(AppRoutes.navigation)) {
      Get.offAllNamed(AppRoutes.navigation);
      _logNavigation(AppRoutes.navigation, 'User authenticated');
    }
  }

  void navigateToLogin() {
    if (_shouldNavigate(AppRoutes.login)) {
      Get.offAllNamed(AppRoutes.login);
      _logNavigation(AppRoutes.login, 'Logout or auth required');
    }
  }

  /// Navigation logging (debugging için)
  void _logNavigation(String route, String reason) {
    if (AppConstants.enableLogging) {
      print('🧭 Navigation: $route ($reason)');
    }
  }
}
