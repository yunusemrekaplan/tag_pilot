import 'package:get/get.dart';

import '../controllers/vehicle_controller.dart';

/// Clean Architecture uyumlu Vehicle Binding
/// SOLID: Single Responsibility - Sadece vehicle controller dependency injection
/// Repository ve Use Case'ler ApplicationBinding'de hallediliyor
/// Bu binding sadece controller'ı register eder
class VehicleBinding extends Bindings {
  @override
  void dependencies() {
    // Vehicle Controller'ı register et
    // Dependencies (repositories, use cases) ApplicationBinding'de hallediliyor
    _registerControllers();
  }

  /// Controller'ları register et
  void _registerControllers() {
    Get.lazyPut<VehicleController>(
      () => VehicleController(),
      fenix: true,
    );
  }
}
