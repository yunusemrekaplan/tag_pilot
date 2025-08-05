import 'package:get/get.dart';

import '../controllers/splash_controller.dart';
import '../../../core/bindings/application_binding.dart';

/// Splash Binding - Clean Architecture uyumlu
/// SOLID: Single Responsibility - Splash ve application dependency injection
/// SOLID: Dependency Inversion - Controller ve servislerin dependency'lerini manage eder
/// Bu binding splash ekranında tüm business logic dependency'lerini de yükler
class SplashBinding extends Bindings {
  @override
  void dependencies() {
    // Application dependencies'lerini yükle (business logic)
    ApplicationBinding().dependencies();

    // Splash Controller'ı register et
    Get.lazyPut<SplashController>(
      () => SplashController(),
    );
  }
}
