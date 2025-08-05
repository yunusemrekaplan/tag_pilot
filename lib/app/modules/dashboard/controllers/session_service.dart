import 'package:get/get.dart';

import '../../../core/utils/app_constants.dart';
import '../../../core/utils/notification_helper.dart';
import '../../../data/enums/session_status.dart';
import '../../../data/models/package_model.dart';
import '../../../data/models/session_model.dart';
import '../../../data/models/vehicle_model.dart';
import '../../../domain/services/auth_service.dart';
import '../../../domain/services/error_handler_service.dart';
import '../../../domain/usecases/session_usecases.dart';
import '../../../domain/usecases/vehicle_usecases.dart' as vehicle_usecases;
import '../../../domain/usecases/expense_usecases.dart' as expense_usecases;
import 'dashboard_service.dart';

/// Session Management Service
/// Tüm session işlemleri burada merkezi olarak yönetilir
class SessionService extends GetxService {
  // Dependencies
  late final AuthService _authService;
  late final ErrorHandlerService _errorHandler;
  late final DashboardService _dashboardService;

  // Use Cases
  late final StartSessionUseCase _startSessionUseCase;
  late final GetActiveSessionUseCase _getActiveSessionUseCase;
  late final PauseSessionUseCase _pauseSessionUseCase;
  late final ResumeSessionUseCase _resumeSessionUseCase;
  late final CompleteSessionUseCase _completeSessionUseCase;
  late final CalculateSessionEarningsUseCase _calculateSessionEarningsUseCase;
  late final CalculateSessionFuelCostUseCase _calculateSessionFuelCostUseCase;
  late final vehicle_usecases.GetVehicleByIdUseCase _getVehicleByIdUseCase;
  late final CalculateTotalDistanceUseCase _calculateTotalDistanceUseCase;
  late final expense_usecases.ExpenseUseCases _expenseUseCases;

  // State
  final RxBool hasActiveSession = false.obs;
  final RxString activeSessionId = ''.obs;
  final Rx<DateTime?> sessionStartTime = Rx<DateTime?>(null);
  final Rx<SessionModel?> currentActiveSession = Rx<SessionModel?>(null);
  final Rx<PackageModel?> activePackage = Rx<PackageModel?>(null);
  final Rx<VehicleModel?> selectedVehicle = Rx<VehicleModel?>(null);
  final RxBool isSessionProcessing = false.obs;

  // Active Session Statistics
  final RxDouble activeSessionDistance = 0.0.obs;
  final RxDouble activeSessionFuelCost = 0.0.obs;
  final RxDouble activeSessionEarnings = 0.0.obs;
  final RxDouble activeSessionExpenses = 0.0.obs;

  // Getters
  String? get userId => _authService.currentUserId;

  String get currentSessionStatus {
    if (!hasActiveSession.value) return 'inactive';
    final session = currentActiveSession.value;
    if (session == null) return 'inactive';

    switch (session.status) {
      case SessionStatus.active:
        return 'active';
      case SessionStatus.paused:
        return 'paused';
      case SessionStatus.completed:
        return 'completed';
    }
  }

  String get sessionDuration {
    final session = currentActiveSession.value;
    if (session == null || sessionStartTime.value == null) return '00:00';

    final now = DateTime.now();
    final duration = now.difference(sessionStartTime.value!);
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;

    if (days > 0) {
      return '${days}g ${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
    } else {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
    }
  }

  @override
  void onInit() {
    super.onInit();
    _initializeDependencies();
  }

  void _initializeDependencies() {
    _authService = Get.find<AuthService>();
    _errorHandler = Get.find<ErrorHandlerService>();
    _dashboardService = Get.find<DashboardService>();
    _startSessionUseCase = Get.find<StartSessionUseCase>();
    _getActiveSessionUseCase = Get.find<GetActiveSessionUseCase>();
    _pauseSessionUseCase = Get.find<PauseSessionUseCase>();
    _resumeSessionUseCase = Get.find<ResumeSessionUseCase>();
    _completeSessionUseCase = Get.find<CompleteSessionUseCase>();
    _calculateSessionEarningsUseCase = Get.find<CalculateSessionEarningsUseCase>();
    _calculateSessionFuelCostUseCase = Get.find<CalculateSessionFuelCostUseCase>();
    _getVehicleByIdUseCase = Get.find<vehicle_usecases.GetVehicleByIdUseCase>();
    _calculateTotalDistanceUseCase = Get.find<CalculateTotalDistanceUseCase>();
    _expenseUseCases = Get.find<expense_usecases.ExpenseUseCases>();
  }

  /// Sefer başlat
  Future<void> startSession({
    required String vehicleId,
    required String packageId,
    required String packageType,
    required double packagePrice,
    required double? currentFuelPrice,
  }) async {
    if (userId == null) return;

    isSessionProcessing.value = true;
    try {
      await _startSessionUseCase(
        userId: userId!,
        vehicleId: vehicleId,
        packageId: packageId,
        packageType: packageType,
        packagePrice: packagePrice,
        currentFuelPrice: currentFuelPrice,
      );

      await checkActiveSession();

      // Sefer başlatıldığında selected vehicle'ı güncelle
      await _updateSelectedVehicleAfterSessionStart(vehicleId);

      // Başabaş noktasını güncelle (sefer başlatıldığında)
      await _updateBreakEvenPointAfterSessionStart(packagePrice);

      NotificationHelper.showSuccess(
        'Sefer başarıyla başlatıldı',
        title: 'Başarılı',
        duration: const Duration(seconds: 3),
      );

      if (AppConstants.enableLogging) {
        print('🚀 Session started successfully');
      }
    } catch (e) {
      _handleError('Sefer başlatılırken hata oluştu', e);
    } finally {
      isSessionProcessing.value = false;
    }
  }

  /// Aktif seferi kontrol et
  Future<void> checkActiveSession() async {
    if (userId == null) return;

    try {
      final session = await _getActiveSessionUseCase(const SessionParams());

      if (session != null) {
        hasActiveSession.value = true;
        activeSessionId.value = session.id;
        sessionStartTime.value = session.startTime;
        currentActiveSession.value = session;

        await _calculateActiveSessionMetrics(session);

        if (AppConstants.enableLogging) {
          print('✅ Active session found: ${session.id}');
        }
      } else {
        _clearActiveSession();
        if (AppConstants.enableLogging) {
          print('ℹ️ No active session found');
        }
      }
    } catch (e) {
      if (AppConstants.enableLogging) {
        print('🔥 Check active session error: $e');
      }
    }
  }

  /// Aktif seferi molaya al
  Future<void> pauseActiveSession() async {
    if (!hasActiveSession.value || isSessionProcessing.value) return;

    isSessionProcessing.value = true;
    try {
      final session = currentActiveSession.value;
      if (session == null) {
        NotificationHelper.showWarning(
          'Aktif sefer bulunamadı!',
          title: 'Uyarı',
          duration: const Duration(seconds: 3),
        );
        return;
      }

      await _pauseSessionUseCase(SessionParams(sessionId: session.id));

      NotificationHelper.showSuccess(
        'Sefer molaya alındı',
        title: 'Başarılı',
        duration: const Duration(seconds: 3),
      );

      await checkActiveSession();

      if (AppConstants.enableLogging) {
        print('⏸️ Session paused successfully');
      }
    } catch (e) {
      _handleError('Sefer molaya alınırken hata oluştu', e);
    } finally {
      isSessionProcessing.value = false;
    }
  }

  /// Molada olan seferi devam ettir
  Future<void> resumeActiveSession() async {
    if (!hasActiveSession.value || isSessionProcessing.value) return;

    isSessionProcessing.value = true;
    try {
      final session = currentActiveSession.value;
      if (session == null) {
        NotificationHelper.showWarning(
          'Aktif sefer bulunamadı!',
          title: 'Uyarı',
          duration: const Duration(seconds: 3),
        );
        return;
      }

      await _resumeSessionUseCase(SessionParams(sessionId: session.id));

      NotificationHelper.showSuccess(
        'Sefer devam ettiriliyor',
        title: 'Başarılı',
        duration: const Duration(seconds: 3),
      );

      await checkActiveSession();

      if (AppConstants.enableLogging) {
        print('▶️ Session resumed successfully');
      }
    } catch (e) {
      _handleError('Sefer devam ettirilirken hata oluştu', e);
    } finally {
      isSessionProcessing.value = false;
    }
  }

  /// Aktif seferi sonlandır
  Future<void> endActiveSession() async {
    if (!hasActiveSession.value || isSessionProcessing.value) return;

    isSessionProcessing.value = true;
    try {
      final session = currentActiveSession.value;
      if (session == null) {
        NotificationHelper.showWarning(
          'Aktif sefer bulunamadı!',
          title: 'Uyarı',
          duration: const Duration(seconds: 3),
        );
        return;
      }

      await _completeSessionUseCase(SessionParams(sessionId: session.id));

      NotificationHelper.showSuccess(
        'Sefer başarıyla sonlandırıldı',
        title: 'Başarılı',
        duration: const Duration(seconds: 3),
      );

      _clearActiveSession();

      // Sefer bitirildiğinde başabaş noktasını sıfırla
      await _resetBreakEvenPointAfterSessionEnd();

      if (AppConstants.enableLogging) {
        print('🏁 Session ended successfully');
      }
    } catch (e) {
      _handleError('Sefer sonlandırılırken hata oluştu', e);
    } finally {
      isSessionProcessing.value = false;
    }
  }

  /// Aktif session istatistiklerini hesapla
  Future<void> _calculateActiveSessionMetrics(SessionModel session) async {
    try {
      final sessionParams = SessionParams(sessionId: session.id);

      final results = await Future.wait([
        _calculateSessionEarningsUseCase(sessionParams),
        _calculateSessionFuelCostUseCase(sessionParams),
        _calculateTotalDistanceUseCase(sessionParams),
        _expenseUseCases.getSessionTotalExpenses(session.id),
      ]);

      activeSessionEarnings.value = results[0];
      activeSessionFuelCost.value = results[1];
      activeSessionDistance.value = results[2];
      activeSessionExpenses.value = results[3];

      if (AppConstants.enableLogging) {
        print('📊 Active session metrics calculated - Expenses: ₺${results[3].toStringAsFixed(2)}');
      }
    } catch (e) {
      if (AppConstants.enableLogging) {
        print('🔥 Calculate session metrics error: $e');
      }
    }
  }

  /// Yolculuk eklendiğinde session istatistiklerini güncelle
  Future<void> updateSessionStatsAfterRide() async {
    try {
      if (hasActiveSession.value && currentActiveSession.value != null) {
        // Session istatistiklerini yeniden hesapla
        await _calculateActiveSessionMetrics(currentActiveSession.value!);

        if (AppConstants.enableLogging) {
          print('📊 Session stats updated after ride');
        }
      }
    } catch (e) {
      if (AppConstants.enableLogging) {
        print('🔥 Update session stats error: $e');
      }
    }
  }

  /// Gider eklendiğinde session istatistiklerini güncelle
  Future<void> updateSessionStatsAfterExpense() async {
    try {
      if (hasActiveSession.value && currentActiveSession.value != null) {
        // Session istatistiklerini yeniden hesapla
        await _calculateActiveSessionMetrics(currentActiveSession.value!);

        // Başabaş noktası ilerlemesini güncelle (dashboard'da otomatik hesaplanır)
        if (AppConstants.enableLogging) {
          print('📊 Session stats updated after expense');
        }
      }
    } catch (e) {
      if (AppConstants.enableLogging) {
        print('🔥 Update session stats error: $e');
      }
    }
  }

  /// Aktif session bilgilerini temizle
  void _clearActiveSession() {
    hasActiveSession.value = false;
    activeSessionId.value = '';
    sessionStartTime.value = null;
    currentActiveSession.value = null;
    activePackage.value = null;
    selectedVehicle.value = null;
    activeSessionDistance.value = 0.0;
    activeSessionFuelCost.value = 0.0;
    activeSessionEarnings.value = 0.0;
    activeSessionExpenses.value = 0.0;
  }

  /// Sefer başlatıldığında selected vehicle'ı güncelle
  Future<void> _updateSelectedVehicleAfterSessionStart(String vehicleId) async {
    try {
      // Vehicle bilgisini getir ve selected vehicle'a ata
      final vehicle = await _getVehicleByIdUseCase(
        vehicle_usecases.VehicleParams(vehicleId: vehicleId),
      );

      if (vehicle != null) {
        selectedVehicle.value = vehicle;

        if (AppConstants.enableLogging) {
          print('🚗 Selected vehicle updated: ${vehicle.displayName}');
        }
      }
    } catch (e) {
      if (AppConstants.enableLogging) {
        print('🔥 Update selected vehicle error: $e');
      }
    }
  }

  /// Sefer başlatıldığında başabaş noktasını güncelle
  Future<void> _updateBreakEvenPointAfterSessionStart(double packagePrice) async {
    try {
      // Eğer başabaş noktası 0 ise, paket fiyatını başabaş noktası olarak ayarla
      if (_dashboardService.breakEvenPoint.value <= 0) {
        await _dashboardService.updateBreakEvenPoint(packagePrice);

        if (AppConstants.enableLogging) {
          print('🎯 Break-even point set to package price: ₺${packagePrice.toStringAsFixed(0)}');
        }
      }
    } catch (e) {
      if (AppConstants.enableLogging) {
        print('🔥 Update break-even point error: $e');
      }
    }
  }

  /// Sefer bitirildiğinde başabaş noktasını sıfırla
  Future<void> _resetBreakEvenPointAfterSessionEnd() async {
    try {
      // Başabaş noktasını 0'a sıfırla
      await _dashboardService.updateBreakEvenPoint(0.0);

      if (AppConstants.enableLogging) {
        print('🔄 Break-even point reset to 0 after session end');
      }
    } catch (e) {
      if (AppConstants.enableLogging) {
        print('🔥 Reset break-even point error: $e');
      }
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
