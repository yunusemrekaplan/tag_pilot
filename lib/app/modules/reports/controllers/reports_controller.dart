import 'package:get/get.dart';

import '../../../domain/usecases/reports_usecases.dart';
import '../../../core/utils/app_constants.dart';
import '../../../core/utils/notification_helper.dart';
import '../../../core/controllers/base_controller.dart';

/// Reports Controller - Basitleştirilmiş ve odaklanmış
/// SOLID: Single Responsibility - Sadece temel rapor işlemleri
/// Clean Architecture: Presentation Layer - Reports UI state management
class ReportsController extends BaseController {
  // ============================================================================
  // DEPENDENCIES (Sadece temel use cases)
  // ============================================================================

  late final GenerateDailyReportUseCase _generateDailyReportUseCase;
  late final GenerateWeeklyReportUseCase _generateWeeklyReportUseCase;
  late final GenerateMonthlyReportUseCase _generateMonthlyReportUseCase;
  late final GenerateCustomReportUseCase _generateCustomReportUseCase;
  late final GetEarningsTrendUseCase _getEarningsTrendUseCase;

  // ============================================================================
  // REACTIVE STATE VARIABLES (Basitleştirilmiş)
  // ============================================================================

  // Report Data
  final RxMap<String, dynamic> _currentReport = <String, dynamic>{}.obs;
  final RxList<Map<String, dynamic>> _earningsTrend = <Map<String, dynamic>>[].obs;

  // Filter & Date State
  final Rx<DateTime?> _startDate = Rx<DateTime?>(null);
  final Rx<DateTime?> _endDate = Rx<DateTime?>(null);
  final RxString _selectedTab = 'summary'.obs;

  // ============================================================================
  // GETTERS (Public Interface)
  // ============================================================================

  // Data Getters
  Map<String, dynamic> get currentReport => _currentReport;
  List<Map<String, dynamic>> get earningsTrend => _earningsTrend;

  // Filter & Date Getters
  DateTime? get startDate => _startDate.value;
  DateTime? get endDate => _endDate.value;
  String get selectedTab => _selectedTab.value;

  // Computed Properties
  bool get hasActiveFilters => _startDate.value != null || _endDate.value != null;

  // ============================================================================
  // LIFECYCLE
  // ============================================================================

  @override
  void onInit() {
    super.onInit();
    _initializeDependencies();
    _initializeDefaultDates();
    _loadInitialData();
  }

  void _initializeDependencies() {
    try {
      _generateDailyReportUseCase = Get.find<GenerateDailyReportUseCase>();
      _generateWeeklyReportUseCase = Get.find<GenerateWeeklyReportUseCase>();
      _generateMonthlyReportUseCase = Get.find<GenerateMonthlyReportUseCase>();
      _generateCustomReportUseCase = Get.find<GenerateCustomReportUseCase>();
      _getEarningsTrendUseCase = Get.find<GetEarningsTrendUseCase>();
    } catch (e) {
      print('🔥 Dependency initialization error in ReportsController: $e');
      NotificationHelper.showError('Rapor servisleri başlatılamadı');
    }
  }

  void _initializeDefaultDates() {
    final now = DateTime.now();
    _startDate.value = DateTime(now.year, now.month, now.day - 7);
    _endDate.value = now;
  }

  Future<void> _loadInitialData() async {
    await executeSafelyVoid(() async {
      await loadEarningsTrend();
    });
  }

  // ============================================================================
  // REPORT GENERATION OPERATIONS
  // ============================================================================

  Future<Map<String, dynamic>?> generateDailyReport(DateTime date) async {
    return await executeWithCreating(() async {
      final report = await _generateDailyReportUseCase(ReportsParams(startDate: date));
      _currentReport.assignAll(report);
      NotificationHelper.showSuccess('Günlük rapor oluşturuldu');
      return report;
    }, errorMessage: 'Günlük rapor oluşturulurken hata oluştu');
  }

  Future<Map<String, dynamic>?> generateWeeklyReport(DateTime startOfWeek) async {
    return await executeWithCreating(() async {
      final report = await _generateWeeklyReportUseCase(ReportsParams(startDate: startOfWeek));
      _currentReport.assignAll(report);
      NotificationHelper.showSuccess('Haftalık rapor oluşturuldu');
      return report;
    }, errorMessage: 'Haftalık rapor oluşturulurken hata oluştu');
  }

  Future<Map<String, dynamic>?> generateMonthlyReport(DateTime startOfMonth) async {
    return await executeWithCreating(() async {
      final report = await _generateMonthlyReportUseCase(ReportsParams(startDate: startOfMonth));
      _currentReport.assignAll(report);
      NotificationHelper.showSuccess('Aylık rapor oluşturuldu');
      return report;
    }, errorMessage: 'Aylık rapor oluşturulurken hata oluştu');
  }

  Future<Map<String, dynamic>?> generateCustomReport() async {
    if (_startDate.value == null || _endDate.value == null) {
      NotificationHelper.showError('Başlangıç ve bitiş tarihi seçin');
      return null;
    }

    return await executeWithCreating(() async {
      final report = await _generateCustomReportUseCase(ReportsParams(
        startDate: _startDate.value,
        endDate: _endDate.value,
      ));
      _currentReport.assignAll(report);
      NotificationHelper.showSuccess('Özel rapor oluşturuldu');
      return report;
    }, errorMessage: 'Özel rapor oluşturulurken hata oluştu');
  }

  // ============================================================================
  // TREND ANALYSIS OPERATIONS
  // ============================================================================

  Future<void> loadEarningsTrend() async {
    await executeWithUpdating(() async {
      final trend = await _getEarningsTrendUseCase(ReportsParams(
        startDate: _startDate.value,
        endDate: _endDate.value,
      ));
      _earningsTrend.assignAll(trend);
    }, errorMessage: 'Kazanç trend verisi yüklenirken hata oluştu');
  }

  // ============================================================================
  // FILTER & DATE OPERATIONS
  // ============================================================================

  Future<void> setStartDate(DateTime date) async {
    await executeSafelyVoid(() async {
      _startDate.value = date;
      await _refreshData();
    });
  }

  Future<void> setEndDate(DateTime date) async {
    await executeSafelyVoid(() async {
      _endDate.value = date;
      await _refreshData();
    });
  }

  // ============================================================================
  // VIEW STATE OPERATIONS
  // ============================================================================

  Future<void> selectTab(String tab) async {
    await executeSafelyVoid(() async {
      _selectedTab.value = tab;
      await _refreshData();
    });
  }

  Future<void> refreshData() async {
    await executeWithRefreshing(() async {
      await _refreshData();
    }, errorMessage: 'Veriler yenilenirken hata oluştu');
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  Future<void> _refreshData() async {
    if (_selectedTab.value == 'trends') {
      await loadEarningsTrend();
    }
  }

  // Quick report generation methods
  Future<void> generateTodayReport() async {
    await executeSafelyVoid(() async {
      await generateDailyReport(DateTime.now());
    });
  }

  Future<void> generateThisWeekReport() async {
    await executeSafelyVoid(() async {
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      await generateWeeklyReport(startOfWeek);
    });
  }

  Future<void> generateThisMonthReport() async {
    await executeSafelyVoid(() async {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      await generateMonthlyReport(startOfMonth);
    });
  }
}
