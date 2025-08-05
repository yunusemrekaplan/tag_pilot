import 'package:get/get.dart';

import '../../../domain/repositories/reports_repository.dart';
import '../../../domain/repositories/ride_repository.dart';
import '../../../domain/repositories/expense_repository.dart';
import '../../../domain/repositories/session_repository.dart';
import '../../../data/repositories/reports_repository_impl.dart';
import '../../../data/repositories/ride_repository_impl.dart';
import '../../../data/repositories/expense_repository_impl.dart';
import '../../../data/repositories/session_repository_impl.dart';
import '../../../domain/services/database_service.dart';
import '../../../domain/services/auth_service.dart';
import '../../../domain/services/error_handler_service.dart';
import '../../../domain/usecases/reports_usecases.dart';
import '../controllers/reports_controller.dart';

/// Reports Module Binding - Optimize edilmiş
/// Clean Architecture: Dependency Injection - Sadece gerekli dependencies
/// SOLID: Dependency Inversion - Interface'leri register eder
class ReportsBinding extends Bindings {
  @override
  void dependencies() {
    _registerRepository();
    _registerUseCases();
    _registerController();
  }

  void _registerRepository() {
    // Required Repositories for Reports (only if not already registered)
    if (!Get.isRegistered<RideRepository>()) {
      Get.lazyPut<RideRepository>(
        () => RideRepositoryImpl(
          Get.find<DatabaseService>(),
          Get.find<AuthService>(),
          Get.find<ErrorHandlerService>(),
        ),
        fenix: true,
      );
    }

    if (!Get.isRegistered<ExpenseRepository>()) {
      Get.lazyPut<ExpenseRepository>(
        () => ExpenseRepositoryImpl(),
        fenix: true,
      );
    }

    if (!Get.isRegistered<SessionRepository>()) {
      Get.lazyPut<SessionRepository>(
        () => SessionRepositoryImpl(),
        fenix: true,
      );
    }

    // Reports Repository Implementation
    Get.lazyPut<ReportsRepository>(
      () => ReportsRepositoryImpl(),
      fenix: true,
    );
  }

  void _registerUseCases() {
    final repository = Get.find<ReportsRepository>();

    // ============================================================================
    // TEMEL RAPOR USE CASES (Sadece gerekli olanlar)
    // ============================================================================

    Get.lazyPut<GenerateDailyReportUseCase>(
      () => GenerateDailyReportUseCase(repository),
    );

    Get.lazyPut<GenerateWeeklyReportUseCase>(
      () => GenerateWeeklyReportUseCase(repository),
    );

    Get.lazyPut<GenerateMonthlyReportUseCase>(
      () => GenerateMonthlyReportUseCase(repository),
    );

    Get.lazyPut<GenerateCustomReportUseCase>(
      () => GenerateCustomReportUseCase(repository),
    );

    Get.lazyPut<GetEarningsTrendUseCase>(
      () => GetEarningsTrendUseCase(repository),
    );
  }

  void _registerController() {
    // Controller
    Get.lazyPut<ReportsController>(
      () => ReportsController(),
      fenix: true,
    );
  }
}
