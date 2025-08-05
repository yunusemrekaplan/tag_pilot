import 'package:get/get.dart';
import '../../../domain/repositories/ride_repository.dart';
import '../../../data/repositories/ride_repository_impl.dart';
import '../../../domain/services/database_service.dart';
import '../../../domain/services/auth_service.dart';
import '../../../domain/services/error_handler_service.dart';
import '../../../domain/usecases/ride_usecases.dart';

import '../controllers/ride_controller.dart';

/// Ride Binding
/// SOLID: Dependency Inversion - IoC Container
/// Clean Architecture: Dependency injection layer
class RideBinding implements Bindings {
  @override
  void dependencies() {
    _registerRepository();
    _registerBasicUseCases();
    _registerSearchFilterUseCases();
    _registerAnalyticsUseCases();
    _registerTimeBasedUseCases();
    _registerAdvancedMetricsUseCases();

    _registerController();
  }

  void _registerRepository() {
    // Repository Registration (Singleton check)
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
  }

  void _registerBasicUseCases() {
    final repository = Get.find<RideRepository>();

    // Basic Read Operations
    Get.lazyPut<GetAllRidesUseCase>(
      () => GetAllRidesUseCase(repository),
    );

    Get.lazyPut<GetRidesByDateRangeUseCase>(
      () => GetRidesByDateRangeUseCase(repository),
    );

    Get.lazyPut<GetRidesByProfitabilityUseCase>(
      () => GetRidesByProfitabilityUseCase(repository),
    );

    Get.lazyPut<GetTopRidesUseCase>(
      () => GetTopRidesUseCase(repository),
    );
  }

  void _registerSearchFilterUseCases() {
    final repository = Get.find<RideRepository>();

    // Search & Filter Operations
    Get.lazyPut<SearchRidesUseCase>(
      () => SearchRidesUseCase(repository),
    );

    Get.lazyPut<FilterRidesUseCase>(
      () => FilterRidesUseCase(repository),
    );

    Get.lazyPut<WatchAllRidesUseCase>(
      () => WatchAllRidesUseCase(repository),
    );
  }

  void _registerAnalyticsUseCases() {
    final repository = Get.find<RideRepository>();

    // Analytics Operations
    Get.lazyPut<GetRideAnalyticsUseCase>(
      () => GetRideAnalyticsUseCase(repository),
    );

    Get.lazyPut<GetPerformanceMetricsUseCase>(
      () => GetPerformanceMetricsUseCase(repository),
    );

    Get.lazyPut<GetProfitabilityAnalysisUseCase>(
      () => GetProfitabilityAnalysisUseCase(repository),
    );
  }

  void _registerTimeBasedUseCases() {
    final repository = Get.find<RideRepository>();

    // Time-based Stats
    Get.lazyPut<GetDailyRideStatsUseCase>(
      () => GetDailyRideStatsUseCase(repository),
    );

    Get.lazyPut<GetWeeklyRideStatsUseCase>(
      () => GetWeeklyRideStatsUseCase(repository),
    );

    Get.lazyPut<GetMonthlyRideStatsUseCase>(
      () => GetMonthlyRideStatsUseCase(repository),
    );
  }

  void _registerAdvancedMetricsUseCases() {
    final repository = Get.find<RideRepository>();

    // Advanced Metrics
    Get.lazyPut<GetAverageRideEarningsUseCase>(
      () => GetAverageRideEarningsUseCase(repository),
    );

    Get.lazyPut<GetAverageRideDistanceUseCase>(
      () => GetAverageRideDistanceUseCase(repository),
    );

    Get.lazyPut<GetAverageRideProfitUseCase>(
      () => GetAverageRideProfitUseCase(repository),
    );

    Get.lazyPut<GetBestPerformingRideUseCase>(
      () => GetBestPerformingRideUseCase(repository),
    );

    Get.lazyPut<GetWorstPerformingRideUseCase>(
      () => GetWorstPerformingRideUseCase(repository),
    );
  }

  void _registerController() {
    // Controller Registration
    Get.lazyPut<RideController>(
      () => RideController(),
    );
  }
}
