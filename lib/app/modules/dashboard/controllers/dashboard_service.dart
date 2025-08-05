import 'package:get/get.dart';

import '../../../core/utils/app_constants.dart';
import '../../../data/models/dashboard_stats_model.dart';
import '../../../data/models/package_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/vehicle_model.dart';
import '../../../domain/services/auth_service.dart';
import '../../../domain/services/error_handler_service.dart';
import '../../../domain/usecases/auth_usecases.dart';
import '../../../domain/usecases/dashboard_usecases.dart';
import '../../../domain/usecases/package_usecases.dart';
import '../../../domain/usecases/user_preferences_usecases.dart';
import '../../../domain/usecases/vehicle_usecases.dart' as vehicle_usecases;
import 'session_service.dart';

/// Dashboard Business Logic Service
/// Tüm dashboard işlemleri burada merkezi olarak yönetilir
class DashboardService extends GetxService {
  // Dependencies
  late final AuthService _authService;
  late final ErrorHandlerService _errorHandler;

  // Use Cases
  late final GetCurrentUserUseCase _getCurrentUserUseCase;
  late final GetDashboardStatsUseCase _getDashboardStatsUseCase;
  late final WatchDashboardStatsUseCase _watchDashboardStatsUseCase;
  late final RefreshDashboardCacheUseCase _refreshDashboardCacheUseCase;
  late final GetAllPackagesUseCase _getAllPackagesUseCase;
  late final GetUserPreferencesUseCase _getUserPreferencesUseCase;
  late final UpdateDailyTargetUseCase _updateDailyTargetUseCase;
  late final vehicle_usecases.GetDefaultVehicleUseCase _getDefaultVehicleUseCase;
  late final vehicle_usecases.GetAllVehiclesUseCase _getAllVehiclesUseCase;

  // State
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final Rx<DashboardStatsModel> dashboardStats = DashboardStatsModel.empty().obs;
  final RxList<PackageModel> availablePackages = <PackageModel>[].obs;
  final Rx<VehicleModel?> selectedVehicle = Rx<VehicleModel?>(null);
  final RxDouble breakEvenPoint = 0.0.obs;
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;

  // Getters
  String? get userId => _authService.currentUserId;
  double get todayEarnings => dashboardStats.value.todayEarnings;
  double get weeklyEarnings => dashboardStats.value.weeklyEarnings;
  double get monthlyEarnings => dashboardStats.value.monthlyEarnings;
  double get totalEarnings => dashboardStats.value.totalEarnings;
  int get todayRides => dashboardStats.value.todayRides;
  int get weeklyRides => dashboardStats.value.weeklyRides;
  int get monthlyRides => dashboardStats.value.monthlyRides;
  int get totalRides => dashboardStats.value.totalRides;
  double get todayExpenses => dashboardStats.value.todayExpenses;
  double get weeklyExpenses => dashboardStats.value.weeklyExpenses;
  double get monthlyExpenses => dashboardStats.value.monthlyExpenses;
  double get todayProfit => dashboardStats.value.todayProfit;
  double get weeklyProfit => dashboardStats.value.weeklyProfit;
  double get monthlyProfit => dashboardStats.value.monthlyProfit;

  @override
  void onInit() {
    super.onInit();
    _initializeDependencies();
  }

  void _initializeDependencies() {
    _authService = Get.find<AuthService>();
    _errorHandler = Get.find<ErrorHandlerService>();
    _getCurrentUserUseCase = Get.find<GetCurrentUserUseCase>();
    _getDashboardStatsUseCase = Get.find<GetDashboardStatsUseCase>();
    _watchDashboardStatsUseCase = Get.find<WatchDashboardStatsUseCase>();
    _refreshDashboardCacheUseCase = Get.find<RefreshDashboardCacheUseCase>();
    _getAllPackagesUseCase = Get.find<GetAllPackagesUseCase>();
    _getUserPreferencesUseCase = Get.find<GetUserPreferencesUseCase>();
    _updateDailyTargetUseCase = Get.find<UpdateDailyTargetUseCase>();
    _getDefaultVehicleUseCase = Get.find<vehicle_usecases.GetDefaultVehicleUseCase>();
    _getAllVehiclesUseCase = Get.find<vehicle_usecases.GetAllVehiclesUseCase>();
  }

  /// Dashboard'u başlat
  Future<void> initialize() async {
    if (userId == null) return;

    isLoading.value = true;
    try {
      await Future.wait([
        _loadCurrentUser(),
        _loadDashboardStats(),
        _loadAvailablePackages(),
        _loadUserPreferences(),
      ]);

      _startRealtimeUpdates();

      if (AppConstants.enableLogging) {
        print('✅ Dashboard initialized successfully');
      }
    } catch (e) {
      _handleError('Dashboard başlatılırken hata', e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Dashboard verilerini yenile
  Future<void> refreshDashboard() async {
    if (userId == null) return;

    isRefreshing.value = true;
    try {
      final params = DashboardParams(userId: userId!);
      await _refreshDashboardCacheUseCase.call(params);

      final stats = await _getDashboardStatsUseCase.call(params);
      dashboardStats.value = stats;

      // Session service'i de güncelle
      final sessionService = Get.find<SessionService>();
      await sessionService.checkActiveSession();

      if (AppConstants.enableLogging) {
        print('🔄 Dashboard refreshed successfully');
      }
    } catch (e) {
      _handleError('Dashboard yenilenirken hata', e);
    } finally {
      isRefreshing.value = false;
    }
  }

  /// Kullanıcı bilgilerini yükle
  Future<void> _loadCurrentUser() async {
    try {
      final user = await _getCurrentUserUseCase(const NoParams());
      currentUser.value = user;
    } catch (e) {
      if (AppConstants.enableLogging) {
        print('🔥 Load current user error: $e');
      }
    }
  }

  /// Dashboard istatistiklerini yükle
  Future<void> _loadDashboardStats() async {
    try {
      final params = DashboardParams(userId: userId!);
      final stats = await _getDashboardStatsUseCase.call(params);
      dashboardStats.value = stats;
    } catch (e) {
      if (AppConstants.enableLogging) {
        print('🔥 Load dashboard stats error: $e');
      }
    }
  }

  /// Mevcut paketleri yükle
  Future<void> _loadAvailablePackages() async {
    try {
      final packages = await _getAllPackagesUseCase(const PackageParams());
      availablePackages.assignAll(packages.where((p) => p.isAvailable).toList());
    } catch (e) {
      if (AppConstants.enableLogging) {
        print('🔥 Load packages error: $e');
      }
    }
  }

  /// Kullanıcı tercihlerini yükle
  Future<void> _loadUserPreferences() async {
    try {
      final preferences = await _getUserPreferencesUseCase(userId!);
      breakEvenPoint.value = preferences?.dailyTarget ?? 0.0;
    } catch (e) {
      if (AppConstants.enableLogging) {
        print('🔥 Load user preferences error: $e');
      }
    }
  }

  /// Varsayılan aracı getir
  Future<VehicleModel?> getDefaultVehicle() async {
    try {
      var defaultVehicle = await _getDefaultVehicleUseCase(const vehicle_usecases.VehicleParams());

      if (defaultVehicle == null) {
        final vehicles = await _getAllVehiclesUseCase(const vehicle_usecases.VehicleParams());
        if (vehicles.isNotEmpty) {
          defaultVehicle = vehicles.first;
          if (AppConstants.enableLogging) {
            print('🚗 Using first vehicle as default: ${defaultVehicle.brand} ${defaultVehicle.model}');
          }
        }
      }

      return defaultVehicle;
    } catch (e) {
      if (AppConstants.enableLogging) {
        print('🔥 Get default vehicle error: $e');
      }
      return null;
    }
  }

  /// Real-time güncellemeleri başlat
  void _startRealtimeUpdates() {
    if (userId == null) return;

    try {
      _watchDashboardStatsUseCase.call(DashboardParams(userId: userId!)).then((stream) {
        stream.listen(
          (stats) {
            dashboardStats.value = stats;
            if (AppConstants.enableLogging) {
              print('📊 Real-time dashboard update: ${stats.toString()}');
            }
          },
          onError: (error) {
            if (AppConstants.enableLogging) {
              print('🔥 Real-time dashboard error: $error');
            }
          },
        );
      });
    } catch (e) {
      if (AppConstants.enableLogging) {
        print('🔥 Start realtime updates error: $e');
      }
    }
  }

  /// Başabaş noktasını güncelle
  Future<void> updateBreakEvenPoint(double newBreakEven) async {
    if (userId == null) return;

    try {
      // Veritabanına kaydet
      await _updateDailyTargetUseCase(UpdateDailyTargetParams(
        userId: userId!,
        dailyTarget: newBreakEven,
      ));

      // Local state'i güncelle
      breakEvenPoint.value = newBreakEven;

      if (AppConstants.enableLogging) {
        print('🎯 Break-even point updated: ₺${newBreakEven.toStringAsFixed(0)}');
      }
    } catch (e) {
      _handleError('Hedef güncellenirken hata', e);
    }
  }

  /// Hata yönetimi
  void _handleError(String title, dynamic error) {
    _errorHandler.logError(title, error);
    _errorHandler.handleAndNotify(
      error,
      fallbackMessage: _errorHandler.getErrorMessage(error),
      fallbackTitle: title,
      duration: const Duration(seconds: 3),
    );
  }
}
