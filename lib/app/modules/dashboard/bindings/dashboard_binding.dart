import 'package:get/get.dart';

import '../controllers/dashboard_controller.dart';
import '../controllers/dashboard_service.dart';
import '../controllers/session_service.dart';

/// Dashboard Binding - Clean Architecture compliant
/// Services ve Controller'ları register eder
class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    _registerServices();
    _registerControllers();
  }

  /// Service'leri register et
  void _registerServices() {
    Get.lazyPut<DashboardService>(
      () => DashboardService(),
      fenix: true,
    );

    Get.lazyPut<SessionService>(
      () => SessionService(),
      fenix: true,
    );
  }

  /// Controller'ları register et
  void _registerControllers() {
    Get.lazyPut<DashboardController>(
      () => DashboardController(),
      fenix: true,
    );
  }
}
