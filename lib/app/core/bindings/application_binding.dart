import 'package:get/get.dart';

// Utils
import '../utils/app_constants.dart';

// Notification Services
import '../services/notification_service.dart';
import '../services/modern_notification_service.dart';

// Domain Repositories (Interfaces)
import '../../domain/repositories/vehicle_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../domain/repositories/package_repository.dart';
import '../../domain/repositories/session_repository.dart';
import '../../domain/repositories/user_preferences_repository.dart';
import '../../domain/repositories/expense_repository.dart';

// Data Repository Implementations
import '../../data/repositories/vehicle_repository_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../data/repositories/package_repository_impl.dart';
import '../../data/repositories/session_repository_impl.dart';
import '../../data/repositories/user_preferences_repository_impl.dart';
import '../../data/repositories/expense_repository_impl.dart';

// Domain Use Cases
import '../../domain/usecases/auth_usecases.dart';
import '../../domain/usecases/vehicle_usecases.dart';
import '../../domain/usecases/dashboard_usecases.dart';
import '../../domain/usecases/package_usecases.dart';
import '../../domain/usecases/session_usecases.dart';
import '../../domain/usecases/user_preferences_usecases.dart';
import '../../domain/usecases/expense_usecases.dart';

// Domain Services
import '../../domain/services/fuel_calculation_service.dart';
import '../../infrastructure/services/fuel_calculation_service_impl.dart';

/// Application Binding - Business Logic Dependencies
/// SOLID: Single Responsibility - Business logic dependency injection
/// SOLID: Dependency Inversion - Repository pattern implementation
/// Bu binding splash ekranında yüklenir ve tüm business logic dependency'lerini sağlar
class ApplicationBinding extends Bindings {
  @override
  void dependencies() {
    if (AppConstants.enableLogging) {
      print('🚀 Initializing application dependencies...');
    }

    // ============================================================================
    // NOTIFICATION SERVICES
    // ============================================================================

    _registerNotificationServices();

    // ============================================================================
    // REPOSITORIES
    // ============================================================================

    _registerRepositories();

    // ============================================================================
    // USE CASES
    // ============================================================================

    _registerUseCases();

    // ============================================================================
    // DOMAIN SERVICES
    // ============================================================================

    _registerDomainServices();

    if (AppConstants.enableLogging) {
      print('✅ Application dependencies initialized successfully');
    }
  }

  /// Notification servislerini register et
  void _registerNotificationServices() {
    Get.lazyPut<NotificationService>(
      () => ModernNotificationService(),
      fenix: true,
    );
  }

  /// Repository'leri register et
  /// SOLID: Dependency Inversion - Interface'ler concrete implementation'lara inject edilir
  void _registerRepositories() {
    // Auth Repository
    Get.lazyPut<AuthRepository>(
      () => AuthRepositoryImpl(),
      fenix: true,
    );

    // Vehicle Repository
    Get.lazyPut<VehicleRepository>(
      () => VehicleRepositoryImpl(),
      fenix: true,
    );

    // Dashboard Repository
    Get.lazyPut<DashboardRepository>(
      () => DashboardRepositoryImpl(),
      fenix: true,
    );

    // Package Repository
    Get.lazyPut<PackageRepository>(
      () => PackageRepositoryImpl(),
      fenix: true,
    );

    // Session Repository
    Get.lazyPut<SessionRepository>(
      () => SessionRepositoryImpl(),
      fenix: true,
    );

    // User Preferences Repository
    Get.lazyPut<UserPreferencesRepository>(
      () => UserPreferencesRepositoryImpl(),
      fenix: true,
    );

    // Expense Repository
    Get.lazyPut<ExpenseRepository>(
      () => ExpenseRepositoryImpl(),
      fenix: true,
    );
  }

  /// Use Case'leri register et
  /// SOLID: Single Responsibility - Her use case tek bir business operation
  void _registerUseCases() {
    _registerAuthUseCases();
    _registerVehicleUseCases();
    _registerDashboardUseCases();
    _registerPackageUseCases();
    _registerSessionUseCases();
    _registerUserPreferencesUseCases();
    _registerExpenseUseCases();
  }

  /// Auth Use Case'lerini register et
  void _registerAuthUseCases() {
    final authRepository = Get.find<AuthRepository>();

    Get.lazyPut<LoginWithEmailUseCase>(
      () => LoginWithEmailUseCase(authRepository),
      fenix: true,
    );

    Get.lazyPut<LoginWithGoogleUseCase>(
      () => LoginWithGoogleUseCase(authRepository),
      fenix: true,
    );

    Get.lazyPut<RegisterWithEmailUseCase>(
      () => RegisterWithEmailUseCase(authRepository),
      fenix: true,
    );

    Get.lazyPut<SendEmailVerificationUseCase>(
      () => SendEmailVerificationUseCase(authRepository),
      fenix: true,
    );

    Get.lazyPut<CheckEmailVerificationUseCase>(
      () => CheckEmailVerificationUseCase(authRepository),
      fenix: true,
    );

    Get.lazyPut<SendPasswordResetUseCase>(
      () => SendPasswordResetUseCase(authRepository),
      fenix: true,
    );

    Get.lazyPut<GetCurrentUserUseCase>(
      () => GetCurrentUserUseCase(authRepository),
      fenix: true,
    );

    Get.lazyPut<UpdateUserProfileUseCase>(
      () => UpdateUserProfileUseCase(authRepository),
      fenix: true,
    );

    Get.lazyPut<LogoutUseCase>(
      () => LogoutUseCase(authRepository),
      fenix: true,
    );

    Get.lazyPut<DeleteAccountUseCase>(
      () => DeleteAccountUseCase(authRepository),
      fenix: true,
    );

    Get.lazyPut<GetAuthStateUseCase>(
      () => GetAuthStateUseCase(authRepository),
      fenix: true,
    );

    Get.lazyPut<GetCurrentFirebaseUserUseCase>(
      () => GetCurrentFirebaseUserUseCase(authRepository),
      fenix: true,
    );
  }

  /// Vehicle Use Case'lerini register et
  void _registerVehicleUseCases() {
    final vehicleRepository = Get.find<VehicleRepository>();

    Get.lazyPut<CreateVehicleUseCase>(
      () => CreateVehicleUseCase(vehicleRepository),
      fenix: true,
    );

    Get.lazyPut<GetAllVehiclesUseCase>(
      () => GetAllVehiclesUseCase(vehicleRepository),
      fenix: true,
    );

    Get.lazyPut<GetVehicleByIdUseCase>(
      () => GetVehicleByIdUseCase(vehicleRepository),
      fenix: true,
    );

    Get.lazyPut<WatchVehiclesUseCase>(
      () => WatchVehiclesUseCase(vehicleRepository),
      fenix: true,
    );

    Get.lazyPut<GetDefaultVehicleUseCase>(
      () => GetDefaultVehicleUseCase(vehicleRepository),
      fenix: true,
    );

    Get.lazyPut<GetVehiclesByTypeUseCase>(
      () => GetVehiclesByTypeUseCase(vehicleRepository),
      fenix: true,
    );

    Get.lazyPut<UpdateVehicleUseCase>(
      () => UpdateVehicleUseCase(vehicleRepository),
      fenix: true,
    );

    Get.lazyPut<SetDefaultVehicleUseCase>(
      () => SetDefaultVehicleUseCase(vehicleRepository),
      fenix: true,
    );

    Get.lazyPut<DeleteVehicleUseCase>(
      () => DeleteVehicleUseCase(vehicleRepository),
      fenix: true,
    );

    Get.lazyPut<DeleteAllUserVehiclesUseCase>(
      () => DeleteAllUserVehiclesUseCase(vehicleRepository),
      fenix: true,
    );

    Get.lazyPut<IsVehiclePlateUniqueUseCase>(
      () => IsVehiclePlateUniqueUseCase(vehicleRepository),
      fenix: true,
    );

    Get.lazyPut<CalculateTotalFuelCostUseCase>(
      () => CalculateTotalFuelCostUseCase(vehicleRepository),
      fenix: true,
    );
  }

  /// Dashboard Use Case'lerini register et
  void _registerDashboardUseCases() {
    final dashboardRepository = Get.find<DashboardRepository>();

    Get.lazyPut<GetDashboardStatsUseCase>(
      () => GetDashboardStatsUseCase(dashboardRepository),
      fenix: true,
    );

    Get.lazyPut<WatchDashboardStatsUseCase>(
      () => WatchDashboardStatsUseCase(dashboardRepository),
      fenix: true,
    );

    Get.lazyPut<CalculateRealTimeStatsUseCase>(
      () => CalculateRealTimeStatsUseCase(dashboardRepository),
      fenix: true,
    );

    Get.lazyPut<RefreshDashboardCacheUseCase>(
      () => RefreshDashboardCacheUseCase(dashboardRepository),
      fenix: true,
    );

    Get.lazyPut<InitializeDashboardStatsUseCase>(
      () => InitializeDashboardStatsUseCase(dashboardRepository),
      fenix: true,
    );
  }

  /// Package Use Case'lerini register et
  void _registerPackageUseCases() {
    final packageRepository = Get.find<PackageRepository>();

    Get.lazyPut<GetAllPackagesUseCase>(
      () => GetAllPackagesUseCase(packageRepository),
      fenix: true,
    );

    Get.lazyPut<GetPackageByIdUseCase>(
      () => GetPackageByIdUseCase(packageRepository),
      fenix: true,
    );

    Get.lazyPut<GetPackagesByTypeUseCase>(
      () => GetPackagesByTypeUseCase(packageRepository),
      fenix: true,
    );

    // GetActivePackagesUseCase - Will be implemented when needed
    // Get.lazyPut<GetActivePackagesUseCase>(
    //   () => GetActivePackagesUseCase(packageRepository),
    //   fenix: true,
    // );
  }

  /// Session Use Case'lerini register et
  void _registerSessionUseCases() {
    final sessionRepository = Get.find<SessionRepository>();

    Get.lazyPut<StartSessionUseCase>(
      () => StartSessionUseCase(sessionRepository),
      fenix: true,
    );

    // EndSessionUseCase - Will be implemented when needed
    // Get.lazyPut<EndSessionUseCase>(
    //   () => EndSessionUseCase(sessionRepository),
    //   fenix: true,
    // );

    Get.lazyPut<GetActiveSessionUseCase>(
      () => GetActiveSessionUseCase(sessionRepository),
      fenix: true,
    );

    Get.lazyPut<HasActiveSessionUseCase>(
      () => HasActiveSessionUseCase(sessionRepository),
      fenix: true,
    );

    Get.lazyPut<CompleteSessionUseCase>(
      () => CompleteSessionUseCase(sessionRepository),
      fenix: true,
    );

    Get.lazyPut<PauseSessionUseCase>(
      () => PauseSessionUseCase(sessionRepository),
      fenix: true,
    );

    Get.lazyPut<ResumeSessionUseCase>(
      () => ResumeSessionUseCase(sessionRepository),
      fenix: true,
    );

    // Session Statistics Use Cases - Dashboard için gerçek veriler
    Get.lazyPut<CalculateSessionEarningsUseCase>(
      () => CalculateSessionEarningsUseCase(sessionRepository),
      fenix: true,
    );

    Get.lazyPut<CalculateSessionFuelCostUseCase>(
      () => CalculateSessionFuelCostUseCase(sessionRepository),
      fenix: true,
    );

    Get.lazyPut<CalculateTotalDistanceUseCase>(
      () => CalculateTotalDistanceUseCase(sessionRepository),
      fenix: true,
    );

    // GetSessionHistoryUseCase - Will be implemented when needed
    // Get.lazyPut<GetSessionHistoryUseCase>(
    //   () => GetSessionHistoryUseCase(sessionRepository),
    //   fenix: true,
    // );

    // GetSessionStatsUseCase - Will be implemented when needed
    // Get.lazyPut<GetSessionStatsUseCase>(
    //   () => GetSessionStatsUseCase(sessionRepository),
    //   fenix: true,
    // );
  }

  /// User Preferences Use Case'lerini register et
  void _registerUserPreferencesUseCases() {
    final userPreferencesRepository = Get.find<UserPreferencesRepository>();

    Get.lazyPut<GetUserPreferencesUseCase>(
      () => GetUserPreferencesUseCase(userPreferencesRepository),
      fenix: true,
    );

    // UpdateUserPreferencesUseCase - Will be implemented when needed
    // Get.lazyPut<UpdateUserPreferencesUseCase>(
    //   () => UpdateUserPreferencesUseCase(userPreferencesRepository),
    //   fenix: true,
    // );

    Get.lazyPut<UpdateDailyTargetUseCase>(
      () => UpdateDailyTargetUseCase(userPreferencesRepository),
      fenix: true,
    );

    // ResetUserPreferencesUseCase - Will be implemented when needed
    // Get.lazyPut<ResetUserPreferencesUseCase>(
    //   () => ResetUserPreferencesUseCase(userPreferencesRepository),
    //   fenix: true,
    // );
  }

  /// Expense Use Case'lerini register et
  void _registerExpenseUseCases() {
    Get.lazyPut<ExpenseUseCases>(
      () => ExpenseUseCases(),
      fenix: true,
    );
  }

  /// Domain servislerini register et
  void _registerDomainServices() {
    Get.lazyPut<FuelCalculationService>(
      () => FuelCalculationServiceImpl(),
      fenix: true,
    );
  }
}
