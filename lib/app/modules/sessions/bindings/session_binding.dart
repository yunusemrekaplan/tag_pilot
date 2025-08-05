import 'package:get/get.dart';

import '../../../domain/repositories/session_repository.dart';
import '../../../data/repositories/session_repository_impl.dart';
import '../../../domain/usecases/session_usecases.dart';
import '../controllers/session_controller.dart';

/// Session Binding (Clean Architecture)
/// SOLID: Dependency Inversion - Interface'leri bind eder, implementation'ları değil
/// SOLID: Single Responsibility - Sadece session dependency injection
class SessionBinding extends Bindings {
  @override
  void dependencies() {
    // Repository registration (Singleton)
    if (!Get.isRegistered<SessionRepository>()) {
      Get.lazyPut<SessionRepository>(
        () => SessionRepositoryImpl(),
        fenix: true,
      );
    }

    // Session Use Cases registration (Lazy loading)
    _registerSessionUseCases();
    _registerRideUseCases();
    _registerBusinessLogicUseCases();

    // Session Controller registration
    Get.lazyPut<SessionController>(
      () => SessionController(),
      fenix: true,
    );
  }

  void _registerSessionUseCases() {
    final repository = Get.find<SessionRepository>();

    // Session CRUD Use Cases
    Get.lazyPut<CreateSessionUseCase>(
      () => CreateSessionUseCase(repository),
    );

    Get.lazyPut<StartSessionUseCase>(
      () => StartSessionUseCase(repository),
    );

    Get.lazyPut<GetAllSessionsUseCase>(
      () => GetAllSessionsUseCase(repository),
    );

    Get.lazyPut<GetActiveSessionUseCase>(
      () => GetActiveSessionUseCase(repository),
    );

    Get.lazyPut<CompleteSessionUseCase>(
      () => CompleteSessionUseCase(repository),
    );

    Get.lazyPut<DeleteSessionUseCase>(
      () => DeleteSessionUseCase(repository),
    );

    Get.lazyPut<HasActiveSessionUseCase>(
      () => HasActiveSessionUseCase(repository),
    );

    // YENİ: Session State Management Use Cases
    Get.lazyPut<PauseSessionUseCase>(
      () => PauseSessionUseCase(repository),
    );

    Get.lazyPut<ResumeSessionUseCase>(
      () => ResumeSessionUseCase(repository),
    );

    Get.lazyPut<RestartSessionUseCase>(
      () => RestartSessionUseCase(repository),
    );
  }
}

void _registerRideUseCases() {
  final repository = Get.find<SessionRepository>();

  // Ride CRUD Use Cases - AddRideToSessionUseCase artık RideBinding'de
  Get.lazyPut<GetRidesBySessionUseCase>(
    () => GetRidesBySessionUseCase(repository),
  );

  Get.lazyPut<DeleteRideUseCase>(
    () => DeleteRideUseCase(repository),
  );
}

void _registerBusinessLogicUseCases() {
  final repository = Get.find<SessionRepository>();

  // Business Logic Use Cases
  Get.lazyPut<CalculateSessionEarningsUseCase>(
    () => CalculateSessionEarningsUseCase(repository),
  );

  Get.lazyPut<CalculateSessionNetProfitUseCase>(
    () => CalculateSessionNetProfitUseCase(repository),
  );

  Get.lazyPut<GetSessionRideCountUseCase>(
    () => GetSessionRideCountUseCase(repository),
  );

  Get.lazyPut<GetSessionStatisticsUseCase>(
    () => GetSessionStatisticsUseCase(repository),
  );
}
