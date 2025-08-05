import 'package:get/get.dart';

import '../../../domain/usecases/session_usecases.dart';
import '../../../core/utils/app_constants.dart';
import '../../../core/utils/notification_helper.dart';
import '../../../core/controllers/base_controller.dart';
import '../../dashboard/controllers/session_service.dart';

/// Ride Form Controller
/// SOLID: Single Responsibility - Sadece ride ekleme formu için
/// Clean Architecture: Presentation Layer - Sadece form UI state management
class RideFormController extends BaseController {
  // ============================================================================
  // DEPENDENCIES (Use Cases)
  // ============================================================================

  // Session Integration - Session modülüyle etkileşim için
  late final GetActiveSessionUseCase _getActiveSessionUseCase;
  late final AddRideToSessionUseCase _addRideToSessionUseCase;

  // ============================================================================
  // LIFECYCLE
  // ============================================================================

  @override
  void onInit() {
    super.onInit();
    _initializeDependencies();
    // NOT: Burada veri yüklenmez, sadece dependencies initialize edilir
  }

  void _initializeDependencies() {
    // Sadece form için gerekli use case'ler
    _getActiveSessionUseCase = Get.find<GetActiveSessionUseCase>();
    _addRideToSessionUseCase = Get.find<AddRideToSessionUseCase>();
  }

  // ============================================================================
  // RIDE FORM OPERATIONS
  // ============================================================================

  /// Aktif session'a ride ekle
  /// SOLID: Single Responsibility - Sadece ride ekleme işlemi
  /// Clean Architecture: Use Case'ler üzerinden session modülü ile etkileşim
  Future<bool> addRide({
    required double distanceKm,
    required double earnings,
    required double fuelRate,
    required double fuelPrice,
    String? notes,
  }) async {
    if (AppConstants.enableLogging) {
      print('🚗 AddRide called - isBusy: $isBusy, isCreating: $isCreating');
    }

    // Duplicate call protection - tüm busy state'leri kontrol et
    if (isBusy) {
      if (AppConstants.enableLogging) {
        print('🚫 AddRide blocked - controller is busy (isBusy: $isBusy)');
      }
      return false;
    }

    try {
      // 1. Aktif session kontrolü
      final activeSession = await _getActiveSessionUseCase(const SessionParams());
      if (activeSession == null) {
        NotificationHelper.showError('Aktif sefer bulunamadı');
        return false;
      }

      // 2. Session modülü üzerinden ride ekleme (Clean Architecture)
      await executeWithCreating(() async {
        if (AppConstants.enableLogging) {
          print('🔄 Executing addRideToSession...');
        }
        await _addRideToSessionUseCase(SessionParams(
          sessionId: activeSession.id,
          distanceKm: distanceKm,
          earnings: earnings,
          fuelRate: fuelRate,
          fuelPrice: fuelPrice,
          notes: notes,
        ));
      });

      if (AppConstants.enableLogging) {
        print('✅ AddRide completed successfully');
      }

      // Session istatistiklerini güncelle
      await _updateSessionStatsAfterRide();

      NotificationHelper.showSuccess('Yolculuk başarıyla eklendi');
      return true;
    } catch (e) {
      if (AppConstants.enableLogging) {
        print('❌ AddRide failed: $e');
      }
      NotificationHelper.showError('Yolculuk eklenirken hata oluştu: $e');
      return false;
    }
  }

  /// Session istatistiklerini güncelle
  Future<void> _updateSessionStatsAfterRide() async {
    try {
      // SessionService'den session istatistiklerini güncelle
      final sessionService = Get.find<SessionService>();
      await sessionService.updateSessionStatsAfterRide();

      if (AppConstants.enableLogging) {
        print('📊 Session stats updated after ride');
      }
    } catch (e) {
      if (AppConstants.enableLogging) {
        print('🔥 Update session stats error: $e');
      }
    }
  }
}
