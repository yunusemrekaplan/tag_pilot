import 'package:get/get.dart';
import '../../../domain/usecases/session_usecases.dart';
import '../../../domain/repositories/session_repository.dart';
import '../../../data/repositories/session_repository_impl.dart';
import '../controllers/ride_form_controller.dart';

/// Ride Form Binding
/// SOLID: Dependency Inversion - Sadece form için gerekli dependencies
/// Clean Architecture: Dependency injection layer
class RideFormBinding implements Bindings {
  @override
  void dependencies() {
    _registerSessionDependencies();
    _registerController();
  }

  void _registerSessionDependencies() {
    // Session repository'sini sadece gerekli use case'ler için register et
    if (!Get.isRegistered<SessionRepository>()) {
      Get.lazyPut<SessionRepository>(
        () => SessionRepositoryImpl(),
      );
    }

    // Sadece form için gerekli session use case'lerini register et
    if (!Get.isRegistered<GetActiveSessionUseCase>()) {
      Get.lazyPut<GetActiveSessionUseCase>(
        () => GetActiveSessionUseCase(Get.find<SessionRepository>()),
      );
    }

    if (!Get.isRegistered<AddRideToSessionUseCase>()) {
      Get.lazyPut<AddRideToSessionUseCase>(
        () => AddRideToSessionUseCase(Get.find<SessionRepository>()),
      );
    }
  }

  void _registerController() {
    // Form Controller Registration
    Get.lazyPut<RideFormController>(
      () => RideFormController(),
    );
  }
}
