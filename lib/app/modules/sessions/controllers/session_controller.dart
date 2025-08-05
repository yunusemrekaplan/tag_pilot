import 'dart:async';
import 'package:get/get.dart';
import 'package:tag_pilot/app/data/enums/package_type.dart';

import '../../../domain/usecases/session_usecases.dart';
import '../../../domain/services/auth_service.dart';
import '../../../domain/services/error_handler_service.dart';
import '../../../data/models/session_model.dart';
import '../../../data/models/ride_model.dart';
import '../../../core/utils/notification_helper.dart';
import '../../../core/controllers/base_controller.dart';
import '../../../core/extensions/datetime_extensions.dart';
import '../../dashboard/views/dialogs/package_selection_dialog.dart';
import '../../dashboard/views/dialogs/fuel_price_dialog.dart';
import '../../../domain/usecases/vehicle_usecases.dart' as vehicle_usecases;
import '../../../domain/usecases/package_usecases.dart';
import '../../../data/models/vehicle_model.dart';
import '../../../data/models/package_model.dart';
import 'package:flutter/material.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../../../data/enums/session_status.dart';

/// Session Controller (Clean Architecture)
/// SOLID: Single Responsibility - Sadece session UI state management
/// SOLID: Dependency Inversion - Use case'lere bağımlı, implementation'a değil
/// BaseController: Standardized loading states ve execution patterns kullanır
class SessionController extends BaseController {
  // Dependencies (injected via GetX)
  late final AuthService _authService;
  late final ErrorHandlerService _errorHandler;

  // Use Cases
  late final StartSessionUseCase _startSessionUseCase;
  late final GetAllSessionsUseCase _getAllSessionsUseCase;
  late final GetActiveSessionUseCase _getActiveSessionUseCase;
  late final CompleteSessionUseCase _completeSessionUseCase;
  late final DeleteSessionUseCase _deleteSessionUseCase;

  // YENİ: Session State Management Use Cases
  late final PauseSessionUseCase _pauseSessionUseCase;
  late final ResumeSessionUseCase _resumeSessionUseCase;
  late final RestartSessionUseCase _restartSessionUseCase;

  // Ride Use Cases
  late final GetRidesBySessionUseCase _getRidesBySessionUseCase;
  late final DeleteRideUseCase _deleteRideUseCase;

  // Business Logic Use Cases
  late final GetSessionStatisticsUseCase _getSessionStatisticsUseCase;

  // Reactive State Variables
  final RxList<SessionModel> _sessions = <SessionModel>[].obs;
  final Rx<SessionModel?> _activeSession = Rx<SessionModel?>(null);
  final RxList<RideModel> _currentSessionRides = <RideModel>[].obs;

  // Business State
  final RxBool _hasActiveSession = false.obs;
  final Rx<Duration> _activeDuration = Duration.zero.obs;
  final RxMap<String, dynamic> _sessionStats = <String, dynamic>{}.obs;

  // Filter State
  final Rx<DateTime?> _filterStartDate = Rx<DateTime?>(null);
  final Rx<DateTime?> _filterEndDate = Rx<DateTime?>(null);
  final Rx<SessionStatus?> _filterStatus = Rx<SessionStatus?>(null);
  final Rx<PackageType?> _filterPackageType = Rx<PackageType?>(null);
  final RxBool _hasActiveFilters = false.obs;

  // Timer for duration updates
  Timer? _durationTimer;

  // Current User
  // Middleware kontrolü yaptığı için ! operatörü güvenli
  String get _currentUserId => _authService.currentUserId!;

  // Getters (Public Interface)
  List<SessionModel> get sessions => _sessions;
  SessionModel? get activeSession => _activeSession.value;
  List<RideModel> get currentSessionRides => _currentSessionRides;

  // Loading states BaseController'dan geliyor: isLoading, isCreating, isUpdating, isDeleting
  // Session-specific operations için mapping
  bool get isStarting => isCreating; // Session başlatma için
  bool get isCompleting => isUpdating; // Session tamamlama için
  bool get isAddingRide => isCreating; // Ride ekleme için

  bool get hasActiveSession => _hasActiveSession.value;
  Duration get activeDuration => _activeDuration.value;
  Map<String, dynamic> get sessionStats => _sessionStats;

  // Computed Properties
  List<SessionModel> get completedSessions => sessions.where((s) => s.isCompleted).toList();

  List<SessionModel> get todaySessions => sessions.where((s) => s.startTime.isToday).toList();

  // Filter Getters
  DateTime? get filterStartDate => _filterStartDate.value;
  DateTime? get filterEndDate => _filterEndDate.value;
  SessionStatus? get filterStatus => _filterStatus.value;
  PackageType? get filterPackageType => _filterPackageType.value;
  bool get hasActiveFilters => _hasActiveFilters.value;

  String get activeDurationFormatted {
    if (!hasActiveSession) return '00:00';
    final hours = activeDuration.inHours;
    final minutes = activeDuration.inMinutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  @override
  void onInit() {
    super.onInit();
    _initializeDependencies();
    _loadInitialData();
    _startDurationTimer();
  }

  void _initializeDependencies() {
    _authService = Get.find<AuthService>();
    _errorHandler = Get.find<ErrorHandlerService>();

    // Session Use Cases
    _startSessionUseCase = Get.find<StartSessionUseCase>();
    _getAllSessionsUseCase = Get.find<GetAllSessionsUseCase>();
    _getActiveSessionUseCase = Get.find<GetActiveSessionUseCase>();
    _completeSessionUseCase = Get.find<CompleteSessionUseCase>();
    _deleteSessionUseCase = Get.find<DeleteSessionUseCase>();

    // YENİ: Session State Management Use Cases
    _pauseSessionUseCase = Get.find<PauseSessionUseCase>();
    _resumeSessionUseCase = Get.find<ResumeSessionUseCase>();
    _restartSessionUseCase = Get.find<RestartSessionUseCase>();

    // Ride Use Cases
    _getRidesBySessionUseCase = Get.find<GetRidesBySessionUseCase>();
    _deleteRideUseCase = Get.find<DeleteRideUseCase>();

    // Business Logic Use Cases
    _getSessionStatisticsUseCase = Get.find<GetSessionStatisticsUseCase>();
  }

  Future<void> _loadInitialData() async {
    await loadSessions();
    await loadActiveSession();
  }

  void _startDurationTimer() {
    _durationTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (hasActiveSession) {
        _updateActiveDuration();
      }
    });
  }

  void _updateActiveDuration() {
    if (activeSession != null) {
      _activeDuration.value = activeSession!.activeDuration;
    }
  }

  // ============================================================================
  // DATA LOADING OPERATIONS
  // ============================================================================

  Future<void> loadSessions() async {
    await executeWithLoading(() async {
      final sessions = await _getAllSessionsUseCase(const SessionParams());
      _sessions.assignAll(sessions);
    });
  }

  Future<void> loadActiveSession() async {
    try {
      final activeSession = await _getActiveSessionUseCase(const SessionParams());
      _activeSession.value = activeSession;
      _hasActiveSession.value = activeSession != null;

      if (activeSession != null) {
        await loadCurrentSessionRides(activeSession.id);
        await loadSessionStatistics(activeSession.id);
        _updateActiveDuration();
      }
    } catch (e) {
      _errorHandler.logError('Load active session', e);
    }
  }

  Future<void> loadCurrentSessionRides(String sessionId) async {
    try {
      final rides = await _getRidesBySessionUseCase(
        SessionParams(sessionId: sessionId),
      );
      _currentSessionRides.assignAll(rides);
    } catch (e) {
      _errorHandler.logError('Load current session rides', e);
    }
  }

  Future<void> loadSessionStatistics(String sessionId) async {
    try {
      final stats = await _getSessionStatisticsUseCase(
        SessionParams(sessionId: sessionId),
      );
      _sessionStats.assignAll(stats);
    } catch (e) {
      _errorHandler.logError('Load session statistics', e);
    }
  }

  // ============================================================================
  // SESSION OPERATIONS
  // ============================================================================

  Future<bool> startSession(String vehicleId,
      {required String packageId,
      required String packageType,
      required double packagePrice,
      required double currentFuelPrice}) async {
    if (packageId.isEmpty) {
      NotificationHelper.showError('Paket seçimi gerekli');
      return false;
    }

    return await executeWithCreating(() async {
      final session = await _startSessionUseCase(
        userId: _currentUserId,
        vehicleId: vehicleId,
        packageId: packageId,
        packageType: packageType,
        packagePrice: packagePrice,
        currentFuelPrice: currentFuelPrice,
      );

      _activeSession.value = session;
      _hasActiveSession.value = true;
      await loadCurrentSessionRides(session.id);
      await loadSessionStatistics(session.id);
      _updateActiveDuration();

      NotificationHelper.showSuccess('Çalışma seansı başlatıldı');
      await _loadInitialData();
      return true;
    }, errorMessage: 'Session başlatılırken hata oluştu');
  }

  Future<bool> completeSession() async {
    if (activeSession == null) {
      NotificationHelper.showError('Aktif session bulunamadı');
      return false;
    }

    return await executeWithUpdating(() async {
      await _completeSessionUseCase(
        SessionParams(sessionId: activeSession!.id),
      );

      NotificationHelper.showSuccess('Çalışma seansı tamamlandı');
      await _loadInitialData();
      return true;
    }, errorMessage: 'Session tamamlanırken hata oluştu');
  }

  Future<bool> deleteSession(String sessionId) async {
    return await executeWithDeleting(() async {
      await _deleteSessionUseCase(
        SessionParams(sessionId: sessionId),
      );

      NotificationHelper.showSuccess('Session başarıyla silindi');
      loadSessions();
      return true;
    }, errorMessage: 'Session silinirken hata oluştu');
  }

  // ============================================================================
  // RIDE OPERATIONS
  // ============================================================================

  /// Ride ekleme işlemi artık RideController'da yapılıyor
  /// SOLID: Module Separation - Her modül kendi sorumluluğu ile sınırlı

  Future<bool> deleteRide(String rideId) async {
    return await executeWithDeleting(() async {
      await _deleteRideUseCase(
        SessionParams(rideId: rideId),
      );

      NotificationHelper.showSuccess('Sefer başarıyla silindi');
      if (activeSession != null) {
        await loadCurrentSessionRides(activeSession!.id);
        await loadSessionStatistics(activeSession!.id);
      }
      return true;
    }, errorMessage: 'Sefer silinirken hata oluştu');
  }

  // ============================================================================
  // SESSION STATE MANAGEMENT OPERATIONS (YENİ)
  // ============================================================================

  /// Aktif session'ı molaya al
  Future<bool> pauseActiveSession() async {
    if (activeSession == null) {
      NotificationHelper.showError('Aktif session bulunamadı');
      return false;
    }

    if (!activeSession!.isActive) {
      NotificationHelper.showWarning('Sadece aktif session\'lar molaya alınabilir');
      return false;
    }

    return await executeWithUpdating(() async {
      final pausedSession = await _pauseSessionUseCase(
        SessionParams(sessionId: activeSession!.id),
      );

      // Local state'i güncelle
      _activeSession.value = pausedSession;

      // Sessions listesini güncelle
      final sessionIndex = _sessions.indexWhere((s) => s.id == pausedSession.id);
      if (sessionIndex != -1) {
        _sessions[sessionIndex] = pausedSession;
      }

      NotificationHelper.showSuccess('Sefer molaya alındı');
      return true;
    }, errorMessage: 'Sefer molaya alınırken hata oluştu');
  }

  /// Molada olan session'ı devam ettir
  Future<bool> resumeActiveSession() async {
    if (activeSession == null) {
      NotificationHelper.showError('Aktif session bulunamadı');
      return false;
    }

    if (!activeSession!.isPaused) {
      NotificationHelper.showWarning('Sadece molada olan session\'lar devam ettirilebilir');
      return false;
    }

    return await executeWithUpdating(() async {
      final resumedSession = await _resumeSessionUseCase(
        SessionParams(sessionId: activeSession!.id),
      );

      // Local state'i güncelle
      _activeSession.value = resumedSession;

      // Sessions listesini güncelle
      final sessionIndex = _sessions.indexWhere((s) => s.id == resumedSession.id);
      if (sessionIndex != -1) {
        _sessions[sessionIndex] = resumedSession;
      }

      NotificationHelper.showSuccess('Sefer devam ettiriliyor');
      return true;
    }, errorMessage: 'Sefer devam ettirilirken hata oluştu');
  }

  /// Session'ı tamamen bitir
  Future<bool> completeActiveSession() async {
    if (activeSession == null) {
      NotificationHelper.showError('Aktif session bulunamadı');
      return false;
    }

    if (activeSession!.isCompleted) {
      NotificationHelper.showWarning('Session zaten tamamlanmış');
      return false;
    }

    return await executeWithUpdating(() async {
      await _completeSessionUseCase(
        SessionParams(sessionId: activeSession!.id),
      );

      // Local state'i temizle
      _activeSession.value = null;
      _hasActiveSession.value = false;
      _currentSessionRides.clear();
      _activeDuration.value = Duration.zero;

      // Sessions listesini yenile
      await loadSessions();

      NotificationHelper.showSuccess('Sefer başarıyla tamamlandı');
      return true;
    }, errorMessage: 'Sefer tamamlanırken hata oluştu');
  }

  Future<void> restartSession(SessionModel session) async {
    if (session.status != SessionStatus.completed) {
      NotificationHelper.showWarning('Sadece tamamlanmış seferler tekrar başlatılabilir');
      return;
    }
    try {
      await executeWithUpdating(() async {
        final restarted = await _restartSessionUseCase(SessionParams(sessionId: session.id));
        // Local state'i güncelle
        final index = _sessions.indexWhere((s) => s.id == session.id);
        if (index != -1) {
          _sessions[index] = restarted;
        }
        await loadActiveSession();
        NotificationHelper.showSuccess('Sefer tekrar başlatıldı');
      });
    } catch (e) {
      NotificationHelper.showError('Sefer tekrar başlatılırken hata oluştu');
    }
  }

  // ============================================================================
  // UI HELPER METHODS
  // ============================================================================

  Future<void> refreshSessions() async {
    await loadSessions();
    await loadActiveSession();
  }

  // ============================================================================
  // UI FILTERING & SEARCH OPERATIONS
  // ============================================================================

  // Search & Filter States
  final RxString _searchQuery = ''.obs;
  final RxString _selectedFilter = 'all'.obs;
  final Rx<DateTime?> _selectedDate = Rx<DateTime?>(null);

  // Getters for UI
  String get searchQuery => _searchQuery.value;
  String get selectedFilter => _selectedFilter.value;
  DateTime? get selectedDate => _selectedDate.value;

  // Search sessions
  void searchSessions(String query) {
    _searchQuery.value = query.toLowerCase();
  }

  void clearSearch() {
    _searchQuery.value = '';
  }

  // Filter sessions by type
  void setFilter(String filter) {
    _selectedFilter.value = filter;
  }

  // Filter sessions by date
  void setDateFilter(DateTime? date) {
    _selectedDate.value = date;
  }

  // Get filtered sessions based on current filters
  List<SessionModel> getFilteredSessions(String tabFilter) {
    List<SessionModel> filteredSessions = List.from(sessions);

    // Apply tab filter
    switch (tabFilter) {
      case 'active':
        filteredSessions = filteredSessions.where((s) => s.isActive || s.isPaused).toList();
        break;
      case 'completed':
        filteredSessions = filteredSessions.where((s) => s.isCompleted).toList();
        break;
      case 'today':
        filteredSessions = filteredSessions.where((s) => s.startTime.isToday).toList();
        break;
      case 'all':
      default:
        // No additional filter
        break;
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filteredSessions = filteredSessions.where((s) {
        return s.id.toLowerCase().contains(_searchQuery.value) ||
            (s.packageType?.name.toLowerCase().contains(_searchQuery.value) ?? false) ||
            s.startTime.toString().toLowerCase().contains(_searchQuery.value);
      }).toList();
    }

    // Apply date filter
    if (_selectedDate.value != null) {
      filteredSessions = filteredSessions.where((s) {
        return s.startTime.day == _selectedDate.value!.day &&
            s.startTime.month == _selectedDate.value!.month &&
            s.startTime.year == _selectedDate.value!.year;
      }).toList();
    }

    // Apply advanced filters
    if (hasActiveFilters) {
      if (_filterStartDate.value != null) {
        filteredSessions = filteredSessions.where((s) => s.startTime.isAfter(_filterStartDate.value!)).toList();
      }

      if (_filterEndDate.value != null) {
        filteredSessions = filteredSessions
            .where((s) => s.startTime.isBefore(_filterEndDate.value!.add(const Duration(days: 1))))
            .toList();
      }

      if (_filterStatus.value != null) {
        filteredSessions = filteredSessions.where((s) => s.status == _filterStatus.value).toList();
      }

      if (_filterPackageType.value != null) {
        filteredSessions = filteredSessions.where((s) => s.packageType == _filterPackageType.value).toList();
      }
    }

    // Sort by start time (newest first)
    filteredSessions.sort((a, b) => b.startTime.compareTo(a.startTime));

    return filteredSessions;
  }

  // Get quick stats for sessions
  Map<String, dynamic> getQuickStats() {
    final activeSessions = sessions.where((s) => s.isActive).length;
    final completedToday = sessions.where((s) => s.isCompleted && s.startTime.isToday).length;
    // TODO: Total earnings should be calculated from rides
    // This requires session-specific calculations from use cases
    final totalEarnings = 0.0; // Placeholder for now

    return {
      'activeSessions': activeSessions,
      'completedToday': completedToday,
      'totalEarnings': totalEarnings,
    };
  }

  /// UI'dan çağrılır: Tüm sefer başlatma mantığı burada
  Future<void> startSessionWithDialog(BuildContext context) async {
    if (hasActiveSession) {
      NotificationHelper.showWarning('Zaten aktif bir seferiniz var!');
      return;
    }

    // Araç seçimi (varsayılan veya ilk araç)
    VehicleModel? defaultVehicle;
    try {
      defaultVehicle = await Get.find<vehicle_usecases.GetDefaultVehicleUseCase>()(
        const vehicle_usecases.VehicleParams(),
      );
      if (defaultVehicle == null) {
        final vehicles = await Get.find<vehicle_usecases.GetAllVehiclesUseCase>()(
          const vehicle_usecases.VehicleParams(),
        );
        if (vehicles.isNotEmpty) {
          defaultVehicle = vehicles.first;
        } else {
          NotificationHelper.showWarning('Henüz kayıtlı araç bulunmuyor. Sefer başlatmak için önce araç ekleyin.');
          Get.toNamed('/vehicles');
          return;
        }
      }
    } catch (e) {
      NotificationHelper.showError('Araç bilgileri yüklenirken hata oluştu. Lütfen araç sayfasını kontrol edin.');
      Get.toNamed('/vehicles');
      return;
    }

    // Paket seçimi
    final packages = await Get.find<GetAllPackagesUseCase>()(const PackageParams());
    final availablePackages = packages.where((p) => p.isAvailable).toList();
    if (availablePackages.isEmpty) {
      NotificationHelper.showError('Mevcut paket bulunmuyor');
      return;
    }
    PackageModel? selectedPackage;
    await Get.dialog<PackageModel>(
      PackageSelectionDialog(
        availablePackages: availablePackages,
        onPackageSelected: (package) {
          selectedPackage = package;
        },
      ),
      barrierDismissible: false,
    );
    if (selectedPackage == null) return;

    // Yakıt fiyatı seçimi
    final fuelPrice = await Get.dialog<double?>(
      FuelPriceDialog(defaultVehicle: defaultVehicle),
      barrierDismissible: false,
    );
    if (fuelPrice == null) return;

    // Session başlat
    final success = await startSession(
      defaultVehicle.id,
      packageId: selectedPackage!.id,
      packageType: selectedPackage!.type.value,
      packagePrice: selectedPackage!.price,
      currentFuelPrice: fuelPrice,
    );
    if (success) {
      NotificationHelper.showSuccess('Sefer başarıyla başlatıldı');
      await refreshSessions();
      final dashboardController = Get.find<DashboardController>();
      await dashboardController.refreshDashboard();
    }
  }

  // ============================================================================
  // FILTER METHODS
  // ============================================================================

  /// Filtreleri uygula
  void applyFilters({
    DateTime? startDate,
    DateTime? endDate,
    SessionStatus? status,
    PackageType? packageType,
  }) {
    _filterStartDate.value = startDate;
    _filterEndDate.value = endDate;
    _filterStatus.value = status;
    _filterPackageType.value = packageType;
    _updateActiveFiltersState();
  }

  /// Filtreleri temizle
  void clearFilters() {
    _filterStartDate.value = null;
    _filterEndDate.value = null;
    _filterStatus.value = null;
    _filterPackageType.value = null;
    _updateActiveFiltersState();
  }

  /// Aktif filtre durumunu güncelle
  void _updateActiveFiltersState() {
    _hasActiveFilters.value = _filterStartDate.value != null ||
        _filterEndDate.value != null ||
        _filterStatus.value != null ||
        _filterPackageType.value != null;
  }

  // Bu metod zaten yukarıda güncellendi

  // ============================================================================
  // PRIVATE HELPER METHODS
  // ============================================================================
  // Custom execution methods artık gerekli değil - BaseController'dan geliyor

  @override
  void onClose() {
    _durationTimer?.cancel();
    super.onClose();
  }
}
