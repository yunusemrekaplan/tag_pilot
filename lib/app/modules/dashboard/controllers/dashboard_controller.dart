import 'package:get/get.dart';

import '../../../core/controllers/base_controller.dart';
import '../../../core/utils/notification_helper.dart';
import '../../../data/enums/package_type.dart';
import '../../../data/models/dashboard_stats_model.dart';
import '../../../data/models/package_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/vehicle_model.dart';
import '../../../routes/app_routes.dart';
import 'dashboard_dialog_helper.dart';
import 'dashboard_service.dart';
import 'session_service.dart';

/// Dashboard Controller - Clean Architecture
/// Sadece UI orchestration yapar, business logic servisler içinde
class DashboardController extends BaseController {
  // Services
  late final DashboardService _dashboardService;
  late final SessionService _sessionService;

  // UI State
  final RxInt selectedIndex = 0.obs;

  // Getters - Services'den proxy
  UserModel? get currentUser => _dashboardService.currentUser.value;
  DashboardStatsModel get dashboardStats => _dashboardService.dashboardStats.value;
  List<PackageModel> get availablePackages => _dashboardService.availablePackages;
  VehicleModel? get selectedVehicle => _sessionService.selectedVehicle.value;

  // Dashboard Stats Getters
  double get todayEarnings => _dashboardService.todayEarnings;
  double get weeklyEarnings => _dashboardService.weeklyEarnings;
  double get monthlyEarnings => _dashboardService.monthlyEarnings;
  double get totalEarnings => _dashboardService.totalEarnings;
  int get todayRides => _dashboardService.todayRides;
  int get weeklyRides => _dashboardService.weeklyRides;
  int get monthlyRides => _dashboardService.monthlyRides;
  int get totalRides => _dashboardService.totalRides;
  double get todayExpenses => _dashboardService.todayExpenses;
  double get weeklyExpenses => _dashboardService.weeklyExpenses;
  double get monthlyExpenses => _dashboardService.monthlyExpenses;
  double get todayProfit => _dashboardService.todayProfit;
  double get weeklyProfit => _dashboardService.weeklyProfit;
  double get monthlyProfit => _dashboardService.monthlyProfit;

  // Session Getters
  bool get hasActiveSession => _sessionService.hasActiveSession.value;
  String get activeSessionId => _sessionService.activeSessionId.value;
  DateTime? get sessionStartTime => _sessionService.sessionStartTime.value;
  String get currentSessionStatus => _sessionService.currentSessionStatus;
  String get sessionDuration => _sessionService.sessionDuration;
  bool get isSessionProcessing => _sessionService.isSessionProcessing.value;

  // Active Session Stats
  double get activeSessionDistance => _sessionService.activeSessionDistance.value;
  double get activeSessionFuelCost => _sessionService.activeSessionFuelCost.value;
  double get activeSessionEarnings => _sessionService.activeSessionEarnings.value;
  double get activeSessionExpenses => _sessionService.activeSessionExpenses.value;
  PackageModel? get activePackage => _sessionService.activePackage.value;

  // Break Even
  double get breakEvenPoint => _dashboardService.breakEvenPoint.value;
  double get breakEvenProgressPercentage {
    if (breakEvenPoint <= 0) return 0.0;

    // Aktif session varsa: Net kar = Kazanç - Yakıt Maliyeti - Giderler
    // Aktif session yoksa: Günlük net kar
    final currentNetProfit =
        hasActiveSession ? activeSessionEarnings - activeSessionFuelCost - activeSessionExpenses : todayProfit;

    return (currentNetProfit / breakEvenPoint * 100).clamp(0.0, 100.0);
  }

  // Loading States
  bool get isLoading => _dashboardService.isLoading.value;
  bool get isRefreshing => _dashboardService.isRefreshing.value;

  @override
  void onInit() {
    super.onInit();
    _initializeServices();
    _initializeDashboard();
  }

  void _initializeServices() {
    _dashboardService = Get.find<DashboardService>();
    _sessionService = Get.find<SessionService>();
  }

  Future<void> _initializeDashboard() async {
    await executeWithLoading(() async {
      await Future.wait([
        _dashboardService.initialize(),
        _sessionService.checkActiveSession(),
      ]);
    });
  }

  /// UI Actions - Tab Navigation
  void changeTabIndex(int index) {
    selectedIndex.value = index;
  }

  /// UI Actions - Dashboard
  Future<void> refreshDashboard() async {
    await _dashboardService.refreshDashboard();
  }

  /// UI Actions - Session Management
  Future<void> startSessionWithPackage() async {
    if (isSessionProcessing) return;

    try {
      // 1. Araç bilgisini al
      final defaultVehicle = await _dashboardService.getDefaultVehicle();
      if (defaultVehicle == null) {
        NotificationHelper.showWarning(
          'Henüz kayıtlı araç bulunmuyor. Sefer başlatmak için önce araç ekleyin.',
          title: 'Uyarı',
          duration: const Duration(seconds: 3),
        );
        Get.toNamed('/vehicles');
        return;
      }

      // 2. Paket seçimi
      final selectedPackage = await DashboardDialogHelper.showPackageSelectionDialog(availablePackages);
      if (selectedPackage == null) return;

      // 3. Yakıt fiyatı
      final fuelPrice = await DashboardDialogHelper.showFuelPriceDialog(defaultVehicle);
      if (fuelPrice == null) return;

      // 4. Session başlat
      await _sessionService.startSession(
        vehicleId: defaultVehicle.id,
        packageId: selectedPackage.id,
        packageType: selectedPackage.type.value,
        packagePrice: selectedPackage.price,
        currentFuelPrice: fuelPrice,
      );

      // 5. Başabaş noktasını kontrol et ve güncelle
      await _checkAndUpdateBreakEvenPoint(selectedPackage.price);
    } catch (e) {
      NotificationHelper.showError(
        'Sefer başlatılırken hata oluştu',
        title: 'Hata',
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> pauseActiveSession() async {
    await _sessionService.pauseActiveSession();
  }

  Future<void> resumeActiveSession() async {
    await _sessionService.resumeActiveSession();
  }

  Future<void> endActiveSession() async {
    await _sessionService.endActiveSession();

    // Sefer bitirildiğinde başabaş noktasını sıfırla
    await _resetBreakEvenPointAfterSessionEnd();
  }

  /// UI Actions - Quick Actions
  void addExpense() {
    Get.toNamed(AppRoutes.expenseAdd);
  }

  void addRide() {
    Get.toNamed(AppRoutes.rideAdd);
  }

  void viewReports() {
    NotificationHelper.showInfo(
      'Rapor görüntüleme özelliği yakında eklenecek!',
      title: 'Bilgi',
      duration: const Duration(seconds: 3),
    );
  }

  void openSettings() {
    NotificationHelper.showInfo(
      'Ayarlar sayfası yakında eklenecek!',
      title: 'Bilgi',
      duration: const Duration(seconds: 3),
    );
  }

  /// UI Actions - Break Even
  Future<void> updateBreakEvenPoint(double newBreakEven) async {
    await _dashboardService.updateBreakEvenPoint(newBreakEven);
  }

  /// Vehicle bilgilerini getir (public method)
  Future<VehicleModel?> getDefaultVehicle() async {
    return await _dashboardService.getDefaultVehicle();
  }

  /// Sefer başlatıldığında başabaş noktasını kontrol et ve güncelle
  Future<void> _checkAndUpdateBreakEvenPoint(double packagePrice) async {
    try {
      // Eğer başabaş noktası 0 ise, paket fiyatını başabaş noktası olarak ayarla
      if (breakEvenPoint <= 0) {
        await _dashboardService.updateBreakEvenPoint(packagePrice);

        NotificationHelper.showInfo(
          'Başabaş noktası paket fiyatına göre ayarlandı: ₺${packagePrice.toStringAsFixed(0)}',
          title: 'Bilgi',
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      // Hata durumunda sessizce devam et
    }
  }

  /// Sefer bitirildiğinde başabaş noktasını sıfırla
  Future<void> _resetBreakEvenPointAfterSessionEnd() async {
    try {
      // Başabaş noktasını 0'a sıfırla
      await _dashboardService.updateBreakEvenPoint(0.0);
    } catch (e) {
      // Hata durumunda sessizce devam et
    }
  }
}
