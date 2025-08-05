import 'package:get/get.dart';

import '../controllers/auth_controller.dart';

/// Clean Architecture uyumlu Authentication Binding
/// SOLID: Single Responsibility - Sadece auth controller dependency injection
/// Repository ve Use Case'ler ApplicationBinding'de hallediliyor
/// Bu binding sadece controller'ı register eder
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Auth Controller'ı register et
    // Dependencies (repositories, use cases) ApplicationBinding'de hallediliyor
    _registerControllers();
  }

  /// Controller'ları register et
  void _registerControllers() {
    Get.lazyPut<AuthController>(
      () => AuthController(),
      fenix: true,
    );
  }
}
