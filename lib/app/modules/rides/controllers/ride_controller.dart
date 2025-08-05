import 'package:get/get.dart';
import '../../../domain/usecases/ride_usecases.dart';

import '../../../data/models/ride_model.dart';
import '../../../core/utils/app_constants.dart';
import '../../../core/utils/notification_helper.dart';
import '../../../core/controllers/base_controller.dart';

/// Ride List Controller
/// SOLID: Single Responsibility - Ride listesi ve management için
/// Clean Architecture: Presentation Layer - Ride listesi UI state management
/// BaseController: Standardized loading states ve execution patterns kullanır
class RideController extends BaseController {
  // ============================================================================
  // DEPENDENCIES (Use Cases)
  // ============================================================================

  // Basic Operations
  late final GetAllRidesUseCase _getAllRidesUseCase;
  late final GetRidesByDateRangeUseCase _getRidesByDateRangeUseCase;

  // Search & Filter
  late final SearchRidesUseCase _searchRidesUseCase;
  late final FilterRidesUseCase _filterRidesUseCase;

  // Analytics
  late final GetRideAnalyticsUseCase _getRideAnalyticsUseCase;
  late final GetPerformanceMetricsUseCase _getPerformanceMetricsUseCase;
  late final GetProfitabilityAnalysisUseCase _getProfitabilityAnalysisUseCase;

  // Reports
  late final GenerateDailyReportUseCase _generateDailyReportUseCase;

  late final GenerateWeeklyReportUseCase _generateWeeklyReportUseCase;
  late final GenerateMonthlyReportUseCase _generateMonthlyReportUseCase;

  // ============================================================================
  // REACTIVE STATE VARIABLES
  // ============================================================================

  // Ride Data
  final RxList<RideModel> _allRides = <RideModel>[].obs;
  final RxList<RideModel> _filteredRides = <RideModel>[].obs;
  final RxList<RideModel> _searchResults = <RideModel>[].obs;

  // Loading States - BaseController'dan geliyor: isLoading, isCreating, isUpdating, isDeleting

  // Analytics Data
  final RxMap<String, dynamic> _analytics = <String, dynamic>{}.obs;
  final RxMap<String, dynamic> _performanceMetrics = <String, dynamic>{}.obs;
  final RxMap<String, dynamic> _profitabilityAnalysis = <String, dynamic>{}.obs;

  // Filter & Search State
  final RxString _searchQuery = ''.obs;
  final RxMap<String, dynamic> _activeFilters = <String, dynamic>{}.obs;
  final RxString _sortBy = 'netProfit'.obs;
  final RxBool _sortAscending = false.obs;

  // Date Range State
  final Rx<DateTime?> _fromDate = Rx<DateTime?>(null);
  final Rx<DateTime?> _toDate = Rx<DateTime?>(null);

  // View State
  final RxString _selectedTab = 'list'.obs; // list, analytics, trends
  final RxInt _selectedTimeframe = 0.obs; // 0: daily, 1: weekly, 2: monthly

  // ============================================================================
  // GETTERS (Public Interface)
  // ============================================================================

  // Data Getters
  List<RideModel> get allRides => _allRides;
  List<RideModel> get filteredRides => _filteredRides;
  List<RideModel> get searchResults => _searchResults;
  List<RideModel> get displayedRides =>
      _searchQuery.value.isNotEmpty ? _searchResults : _filteredRides;

  // Loading State Getters - BaseController'dan geliyor
  // isLoading BaseController'dan geliyor
  bool get isLoadingAnalytics =>
      isLoading; // Analytics loading için main loading kullanılacak
  bool get isSearching => isLoading; // Search için main loading kullanılacak
  bool get isFiltering => isLoading; // Filter için main loading kullanılacak
  bool get isGeneratingReport =>
      isCreating; // Report generation için creating kullanılacak

  // Analytics Getters
  Map<String, dynamic> get analytics => _analytics;
  Map<String, dynamic> get performanceMetrics => _performanceMetrics;
  Map<String, dynamic> get profitabilityAnalysis => _profitabilityAnalysis;

  // Filter & Search Getters
  String get searchQuery => _searchQuery.value;
  Map<String, dynamic> get activeFilters => _activeFilters;
  String get sortBy => _sortBy.value;
  bool get sortAscending => _sortAscending.value;

  // Date Range Getters
  DateTime? get fromDate => _fromDate.value;
  DateTime? get toDate => _toDate.value;

  // View State Getters
  String get selectedTab => _selectedTab.value;
  int get selectedTimeframe => _selectedTimeframe.value;

  // Computed Properties
  bool get hasActiveFilters =>
      _activeFilters.isNotEmpty ||
      _fromDate.value != null ||
      _toDate.value != null;

  int get totalRides => _allRides.length;
  int get profitableRides =>
      _allRides.where((ride) => ride.isProfitable).length;
  int get unprofitableRides => totalRides - profitableRides;

  double get totalEarnings =>
      _allRides.fold<double>(0.0, (sum, ride) => sum + ride.earnings);
  double get totalProfit =>
      _allRides.fold<double>(0.0, (sum, ride) => sum + ride.netProfit);
  double get totalDistance =>
      _allRides.fold<double>(0.0, (sum, ride) => sum + ride.distanceKm);

  double get averageEarnings =>
      totalRides > 0 ? totalEarnings / totalRides : 0.0;
  double get averageProfit => totalRides > 0 ? totalProfit / totalRides : 0.0;
  double get profitabilityPercentage =>
      totalRides > 0 ? (profitableRides / totalRides) * 100 : 0.0;

  // Today's Data
  List<RideModel> get todayRides {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _allRides.where((ride) {
      if (ride.createdAt == null) return false;
      return ride.createdAt!.isAfter(startOfDay) &&
          ride.createdAt!.isBefore(endOfDay);
    }).toList();
  }

  // ============================================================================
  // LIFECYCLE
  // ============================================================================

  @override
  void onInit() {
    super.onInit();
    _initializeDependencies();
    _loadInitialData();
  }

  void _initializeDependencies() {
    // Basic Operations
    _getAllRidesUseCase = Get.find<GetAllRidesUseCase>();
    _getRidesByDateRangeUseCase = Get.find<GetRidesByDateRangeUseCase>();

    // Search & Filter
    _searchRidesUseCase = Get.find<SearchRidesUseCase>();
    _filterRidesUseCase = Get.find<FilterRidesUseCase>();

    // Analytics
    _getRideAnalyticsUseCase = Get.find<GetRideAnalyticsUseCase>();
    _getPerformanceMetricsUseCase = Get.find<GetPerformanceMetricsUseCase>();
    _getProfitabilityAnalysisUseCase =
        Get.find<GetProfitabilityAnalysisUseCase>();

    // Time-based Stats

    // Reports
    _generateDailyReportUseCase = Get.find<GenerateDailyReportUseCase>();
    _generateWeeklyReportUseCase = Get.find<GenerateWeeklyReportUseCase>();
    _generateMonthlyReportUseCase = Get.find<GenerateMonthlyReportUseCase>();
  }

  Future<void> _loadInitialData() async {
    await loadAllRides();
    await loadAnalytics();
  }

  // ============================================================================
  // DATA LOADING OPERATIONS
  // ============================================================================

  Future<void> loadAllRides() async {
    await executeWithLoading(() async {
      final rides = await _getAllRidesUseCase(const RideParams());
      _allRides.assignAll(rides);
      _filteredRides.assignAll(rides);

      if (AppConstants.enableLogging) {
        print('🚗 Loaded ${rides.length} rides');
      }
    });
  }

  Future<void> loadAnalytics() async {
    await executeWithLoading(() async {
      final analytics = await _getRideAnalyticsUseCase(const RideParams());
      final performance =
          await _getPerformanceMetricsUseCase(const RideParams());
      final profitability =
          await _getProfitabilityAnalysisUseCase(const RideParams());

      _analytics.assignAll(analytics);
      _performanceMetrics.assignAll(performance);
      _profitabilityAnalysis.assignAll(profitability);
    });
  }

  Future<void> loadRidesByDateRange(
      DateTime startDate, DateTime endDate) async {
    await executeWithLoading(() async {
      final rides = await _getRidesByDateRangeUseCase(
        RideParams(startDate: startDate, endDate: endDate),
      );
      _filteredRides.assignAll(rides);
    });
  }

  // ============================================================================
  // SEARCH OPERATIONS
  // ============================================================================

  Future<void> searchRides(String query) async {
    _searchQuery.value = query;

    if (query.isEmpty) {
      _searchResults.clear();
      return;
    }

    await executeWithLoading(() async {
      final results = await _searchRidesUseCase(RideParams(query: query));
      _searchResults.assignAll(results);
    });
  }

  void clearSearch() {
    _searchQuery.value = '';
    _searchResults.clear();
  }

  // ============================================================================
  // FILTER OPERATIONS
  // ============================================================================

  Future<void> applyFilters({
    double? minDistance,
    double? maxDistance,
    double? minEarnings,
    double? maxEarnings,
    double? minProfit,
    double? maxProfit,
    bool? isProfitable,
  }) async {
    await executeWithLoading(() async {
      // Update active filters
      final filters = <String, dynamic>{};
      if (minDistance != null) filters['minDistance'] = minDistance;
      if (maxDistance != null) filters['maxDistance'] = maxDistance;
      if (minEarnings != null) filters['minEarnings'] = minEarnings;
      if (maxEarnings != null) filters['maxEarnings'] = maxEarnings;
      if (minProfit != null) filters['minProfit'] = minProfit;
      if (maxProfit != null) filters['maxProfit'] = maxProfit;
      if (isProfitable != null) filters['isProfitable'] = isProfitable;

      _activeFilters.assignAll(filters);

      final filteredRides = await _filterRidesUseCase(RideParams(
        minDistance: minDistance,
        maxDistance: maxDistance,
        minEarnings: minEarnings,
        maxEarnings: maxEarnings,
        minProfit: minProfit,
        maxProfit: maxProfit,
        startDate: _fromDate.value,
        endDate: _toDate.value,
        isProfitable: isProfitable,
      ));

      _filteredRides.assignAll(filteredRides);
    });
  }

  void clearFilters() {
    _activeFilters.clear();
    _fromDate.value = null;
    _toDate.value = null;
    _filteredRides.assignAll(_allRides);
  }

  void setDateRange(DateTime? from, DateTime? to) {
    _fromDate.value = from;
    _toDate.value = to;
    _applyCurrentFilters();
  }

  Future<void> _applyCurrentFilters() async {
    if (!hasActiveFilters) {
      _filteredRides.assignAll(_allRides);
      return;
    }

    await applyFilters(
      minDistance: _activeFilters['minDistance'],
      maxDistance: _activeFilters['maxDistance'],
      minEarnings: _activeFilters['minEarnings'],
      maxEarnings: _activeFilters['maxEarnings'],
      minProfit: _activeFilters['minProfit'],
      maxProfit: _activeFilters['maxProfit'],
      isProfitable: _activeFilters['isProfitable'],
    );
  }

  // ============================================================================
  // SORTING OPERATIONS
  // ============================================================================

  void setSorting(String sortBy, {bool ascending = false}) {
    _sortBy.value = sortBy;
    _sortAscending.value = ascending;
    _applySorting();
  }

  void toggleSortDirection() {
    _sortAscending.value = !_sortAscending.value;
    _applySorting();
  }

  void _applySorting() {
    final rides = [...displayedRides];

    rides.sort((a, b) {
      int comparison = 0;

      switch (_sortBy.value) {
        case 'netProfit':
          comparison = a.netProfit.compareTo(b.netProfit);
          break;
        case 'earnings':
          comparison = a.earnings.compareTo(b.earnings);
          break;
        case 'distanceKm':
          comparison = a.distanceKm.compareTo(b.distanceKm);
          break;
        case 'profitMargin':
          comparison = a.profitMargin.compareTo(b.profitMargin);
          break;
        case 'createdAt':
          comparison = (a.createdAt ?? DateTime.now())
              .compareTo(b.createdAt ?? DateTime.now());
          break;
        default:
          comparison = a.netProfit.compareTo(b.netProfit);
      }

      return _sortAscending.value ? comparison : -comparison;
    });

    if (_searchQuery.value.isNotEmpty) {
      _searchResults.assignAll(rides);
    } else {
      _filteredRides.assignAll(rides);
    }
  }

  // ============================================================================
  // VIEW STATE OPERATIONS
  // ============================================================================

  void selectTab(String tab) {
    _selectedTab.value = tab;

    if (tab == 'analytics' && _analytics.isEmpty) {
      loadAnalytics();
    }
  }

  void selectTimeframe(int timeframe) {
    _selectedTimeframe.value = timeframe;
    // Reload data based on timeframe if needed
  }

  // ============================================================================
  // REPORT OPERATIONS
  // ============================================================================

  Future<Map<String, dynamic>?> generateDailyReport(DateTime date) async {
    return await executeWithCreating(() async {
      final report = await _generateDailyReportUseCase(RideParams(date: date));
      NotificationHelper.showSuccess('Günlük rapor oluşturuldu');
      return report;
    }, errorMessage: 'Günlük rapor oluşturulurken hata oluştu');
  }

  Future<Map<String, dynamic>?> generateWeeklyReport(
      DateTime startOfWeek) async {
    return await executeWithCreating(() async {
      final report =
          await _generateWeeklyReportUseCase(RideParams(date: startOfWeek));
      NotificationHelper.showSuccess('Haftalık rapor oluşturuldu');
      return report;
    }, errorMessage: 'Haftalık rapor oluşturulurken hata oluştu');
  }

  Future<Map<String, dynamic>?> generateMonthlyReport(
      DateTime startOfMonth) async {
    return await executeWithCreating(() async {
      final report =
          await _generateMonthlyReportUseCase(RideParams(date: startOfMonth));
      NotificationHelper.showSuccess('Aylık rapor oluşturuldu');
      return report;
    }, errorMessage: 'Aylık rapor oluşturulurken hata oluştu');
  }

  // ============================================================================
  // UI HELPER METHODS
  // ============================================================================

  Future<void> refreshData() async {
    await loadAllRides();
    await loadAnalytics();
  }

  String getFilterSummary() {
    if (!hasActiveFilters) return 'Filtre yok';

    final parts = <String>[];

    if (_activeFilters['minDistance'] != null) {
      parts.add('Min mesafe: ${_activeFilters['minDistance']} km');
    }
    if (_activeFilters['maxDistance'] != null) {
      parts.add('Max mesafe: ${_activeFilters['maxDistance']} km');
    }
    if (_activeFilters['minEarnings'] != null) {
      parts.add('Min kazanç: ₺${_activeFilters['minEarnings']}');
    }
    if (_activeFilters['maxEarnings'] != null) {
      parts.add('Max kazanç: ₺${_activeFilters['maxEarnings']}');
    }
    if (_activeFilters['isProfitable'] != null) {
      parts.add(
          _activeFilters['isProfitable'] ? 'Sadece kârlı' : 'Sadece zararlı');
    }
    if (_fromDate.value != null || _toDate.value != null) {
      parts.add('Tarih filtresi aktif');
    }

    return parts.join(', ');
  }

  // ============================================================================
  // REFRESH OPERATIONS
  // ============================================================================

  // ============================================================================
  // PRIVATE HELPER METHODS
  // ============================================================================
  // Custom execution methods artık gerekli değil - BaseController'dan geliyor
}
