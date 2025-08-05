import 'package:get/get.dart';

import '../../core/utils/app_constants.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../domain/services/database_service.dart';
import '../../domain/services/auth_service.dart';
import '../../domain/services/error_handler_service.dart';
import '../models/dashboard_stats_model.dart';

/// Dashboard Repository Implementation (Clean Architecture)
/// SOLID: Dependency Inversion - DashboardRepository interface'ini implement eder
/// SOLID: Single Responsibility - Sadece dashboard data operations
/// Data Logic vs Business Logic: Bu class sadece data operations yapar, business logic Domain layer'da
class DashboardRepositoryImpl implements DashboardRepository {
  late final DatabaseService _databaseService;
  late final AuthService _authService;
  late final ErrorHandlerService _errorHandler;

  DashboardRepositoryImpl() {
    _databaseService = Get.find<DatabaseService>();
    _authService = Get.find<AuthService>();
    _errorHandler = Get.find<ErrorHandlerService>();
  }

  // Cache duration (5 minutes)
  static const Duration _cacheValidDuration = Duration(minutes: 5);

  // Middleware kontrolü yaptığı için ! operatörü güvenli
  late final String userId = _authService.currentUserId!;

  // ============================================================================
  // BASIC STATISTICS OPERATIONS (Data Layer Only)
  // ============================================================================

  @override
  Future<DashboardStatsModel> getDashboardStats() async {
    try {
      final doc = await _databaseService.getDocumentById(
        '${DatabaseConstants.usersCollection}/$userId/dashboard_stats/current',
      );

      if (doc.exists && doc.data() != null) {
        return DashboardStatsModel.fromJson(
          doc.data()! as Map<String, dynamic>,
        );
      } else {
        // Eğer cache yoksa, real-time hesapla ve kaydet
        return await calculateRealTimeStats();
      }
    } catch (e) {
      _errorHandler.logError('Get dashboard stats', e);
      throw Exception('Dashboard istatistikleri yüklenirken hata oluştu: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  @override
  Stream<DashboardStatsModel> watchDashboardStats() {
    try {
      return _databaseService
          .watchDocument('${DatabaseConstants.usersCollection}/$userId/dashboard_stats/current')
          .map((doc) {
        if (doc.exists && doc.data() != null) {
          return DashboardStatsModel.fromJson(
            doc.data()! as Map<String, dynamic>,
          );
        } else {
          return DashboardStatsModel.empty();
        }
      });
    } catch (e) {
      _errorHandler.logError('Watch dashboard stats', e);
      throw Exception('Dashboard izleme hatası: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  @override
  Future<void> updateDashboardStats(DashboardStatsModel stats) async {
    try {
      final updatedStats = stats.copyWith(lastUpdated: DateTime.now());

      await _databaseService.setDocument(
        '${DatabaseConstants.usersCollection}/$userId/dashboard_stats/current',
        updatedStats.toJson(),
        merge: true,
      );

      if (AppConstants.enableLogging) {
        print('📊 Dashboard stats updated for user: $userId');
      }
    } catch (e) {
      _errorHandler.logError('Update dashboard stats', e);
      throw Exception('Dashboard istatistikleri güncellenirken hata oluştu: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  // ============================================================================
  // REAL-TIME CALCULATIONS (Business Logic + Data Access)
  // ============================================================================

  @override
  Future<DashboardStatsModel> calculateRealTimeStats() async {
    try {
      final now = DateTime.now();

      // Parallel calculations for better performance
      final results = await Future.wait([
        calculateTodayEarnings(),
        calculateWeeklyEarnings(),
        calculateMonthlyEarnings(),
        _calculateTotalEarnings(),
        calculateTodayRides(),
        calculateWeeklyRides(),
        calculateMonthlyRides(),
        _calculateTotalRides(),
        calculateTodayExpenses(),
        calculateWeeklyExpenses(),
        calculateMonthlyExpenses(),
        _getLastRideDate(),
      ]);

      final stats = DashboardStatsModel(
        todayEarnings: results[0] as double,
        weeklyEarnings: results[1] as double,
        monthlyEarnings: results[2] as double,
        totalEarnings: results[3] as double,
        todayRides: results[4] as int,
        weeklyRides: results[5] as int,
        monthlyRides: results[6] as int,
        totalRides: results[7] as int,
        todayExpenses: results[8] as double,
        weeklyExpenses: results[9] as double,
        monthlyExpenses: results[10] as double,
        todayProfit: (results[0] as double) - (results[8] as double),
        weeklyProfit: (results[1] as double) - (results[9] as double),
        monthlyProfit: (results[2] as double) - (results[10] as double),
        lastRideDate: results[11] as DateTime,
        lastUpdated: now,
      );

      // Cache the calculated stats
      await updateDashboardStats(stats);

      return stats;
    } catch (e) {
      _errorHandler.logError('Calculate real-time stats', e);
      throw Exception('İstatistik hesaplama hatası: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  @override
  Future<double> calculateTodayEarnings() async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final querySnapshot = await _databaseService.getDocumentsWhereRange(
        '${DatabaseConstants.usersCollection}/$userId/${DatabaseConstants.ridesCollection}',
        'date',
        startOfDay.toIso8601String(),
        endOfDay.toIso8601String(),
      );

      double total = 0.0;
      for (final doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        total += (data['totalAmount'] as num?)?.toDouble() ?? 0.0;
      }

      return total;
    } catch (e) {
      _errorHandler.logError('Calculate today earnings', e);
      return 0.0; // Return 0 instead of throwing error for graceful degradation
    }
  }

  @override
  Future<double> calculateWeeklyEarnings() async {
    try {
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final startOfWeekDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

      final querySnapshot = await _databaseService.getDocumentsWhere(
        '${DatabaseConstants.usersCollection}/$userId/${DatabaseConstants.ridesCollection}',
        'date',
        startOfWeekDate.toIso8601String(),
      );

      double total = 0.0;
      for (final doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        total += (data['totalAmount'] as num?)?.toDouble() ?? 0.0;
      }

      return total;
    } catch (e) {
      _errorHandler.logError('Calculate weekly earnings', e);
      return 0.0;
    }
  }

  @override
  Future<double> calculateMonthlyEarnings() async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);

      final querySnapshot = await _databaseService.getDocumentsWhere(
        '${DatabaseConstants.usersCollection}/$userId/${DatabaseConstants.ridesCollection}',
        'date',
        startOfMonth.toIso8601String(),
      );

      double total = 0.0;
      for (final doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        total += (data['totalAmount'] as num?)?.toDouble() ?? 0.0;
      }

      return total;
    } catch (e) {
      _errorHandler.logError('Calculate monthly earnings', e);
      return 0.0;
    }
  }

  Future<double> _calculateTotalEarnings() async {
    try {
      final querySnapshot = await _databaseService.getDocuments(
        '${DatabaseConstants.usersCollection}/$userId/${DatabaseConstants.ridesCollection}',
      );

      double total = 0.0;
      for (final doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        total += (data['totalAmount'] as num?)?.toDouble() ?? 0.0;
      }

      return total;
    } catch (e) {
      _errorHandler.logError('Calculate total earnings', e);
      return 0.0;
    }
  }

  @override
  Future<int> calculateTodayRides() async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final querySnapshot = await _databaseService.getDocumentsWhereRange(
        '${DatabaseConstants.usersCollection}/$userId/${DatabaseConstants.ridesCollection}',
        'date',
        startOfDay.toIso8601String(),
        endOfDay.toIso8601String(),
      );

      return querySnapshot.docs.length;
    } catch (e) {
      _errorHandler.logError('Calculate today rides', e);
      return 0;
    }
  }

  @override
  Future<int> calculateWeeklyRides() async {
    try {
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final startOfWeekDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

      final querySnapshot = await _databaseService.getDocumentsWhere(
        '${DatabaseConstants.usersCollection}/$userId/${DatabaseConstants.ridesCollection}',
        'date',
        startOfWeekDate.toIso8601String(),
      );

      return querySnapshot.docs.length;
    } catch (e) {
      _errorHandler.logError('Calculate weekly rides', e);
      return 0;
    }
  }

  @override
  Future<int> calculateMonthlyRides() async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);

      final querySnapshot = await _databaseService.getDocumentsWhere(
        '${DatabaseConstants.usersCollection}/$userId/${DatabaseConstants.ridesCollection}',
        'date',
        startOfMonth.toIso8601String(),
      );

      return querySnapshot.docs.length;
    } catch (e) {
      _errorHandler.logError('Calculate monthly rides', e);
      return 0;
    }
  }

  Future<int> _calculateTotalRides() async {
    try {
      final querySnapshot = await _databaseService.getDocuments(
        '${DatabaseConstants.usersCollection}/$userId/${DatabaseConstants.ridesCollection}',
      );

      return querySnapshot.docs.length;
    } catch (e) {
      _errorHandler.logError('Calculate total rides', e);
      return 0;
    }
  }

  @override
  Future<double> calculateTodayExpenses() async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final querySnapshot = await _databaseService.getDocumentsWhereRange(
        '${DatabaseConstants.usersCollection}/$userId/${DatabaseConstants.expensesCollection}',
        'createdAt',
        startOfDay.toIso8601String(),
        endOfDay.toIso8601String(),
      );

      double total = 0.0;
      for (final doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final expenseType = data['type'] as String? ?? 'general';

        // Sadece genel giderleri dahil et (session giderleri dahil değil)
        if (expenseType == 'general') {
          total += (data['amount'] as num?)?.toDouble() ?? 0.0;
        }
      }

      if (AppConstants.enableLogging) {
        print('💸 Today general expenses calculated: ₺$total');
      }

      return total;
    } catch (e) {
      _errorHandler.logError('Calculate today expenses', e);
      return 0.0;
    }
  }

  @override
  Future<double> calculateWeeklyExpenses() async {
    try {
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final startOfWeekDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

      final querySnapshot = await _databaseService.getDocumentsWhere(
        '${DatabaseConstants.usersCollection}/$userId/${DatabaseConstants.expensesCollection}',
        'createdAt',
        startOfWeekDate.toIso8601String(),
      );

      double total = 0.0;
      for (final doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final expenseType = data['type'] as String? ?? 'general';

        // Sadece genel giderleri dahil et (session giderleri dahil değil)
        if (expenseType == 'general') {
          total += (data['amount'] as num?)?.toDouble() ?? 0.0;
        }
      }

      return total;
    } catch (e) {
      _errorHandler.logError('Calculate weekly expenses', e);
      return 0.0;
    }
  }

  @override
  Future<double> calculateMonthlyExpenses() async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);

      final querySnapshot = await _databaseService.getDocumentsWhere(
        '${DatabaseConstants.usersCollection}/$userId/${DatabaseConstants.expensesCollection}',
        'createdAt',
        startOfMonth.toIso8601String(),
      );

      double total = 0.0;
      for (final doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final expenseType = data['type'] as String? ?? 'general';

        // Sadece genel giderleri dahil et (session giderleri dahil değil)
        if (expenseType == 'general') {
          total += (data['amount'] as num?)?.toDouble() ?? 0.0;
        }
      }

      return total;
    } catch (e) {
      _errorHandler.logError('Calculate monthly expenses', e);
      return 0.0;
    }
  }

  Future<DateTime> _getLastRideDate() async {
    try {
      final querySnapshot = await _databaseService.getDocuments(
        '${DatabaseConstants.usersCollection}/$userId/${DatabaseConstants.ridesCollection}',
      );

      if (querySnapshot.docs.isEmpty) {
        return DateTime.now();
      }

      // Find the latest date
      DateTime latestDate = DateTime.now().subtract(const Duration(days: 365));

      for (final doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final dateStr = data['date'] as String?;
        if (dateStr != null) {
          final date = DateTime.parse(dateStr);
          if (date.isAfter(latestDate)) {
            latestDate = date;
          }
        }
      }

      return latestDate;
    } catch (e) {
      _errorHandler.logError('Get last ride date', e);
      return DateTime.now();
    }
  }

  // ============================================================================
  // CACHE MANAGEMENT
  // ============================================================================

  @override
  Future<bool> isCacheValid() async {
    try {
      final doc = await _databaseService.getDocumentById(
        '${DatabaseConstants.usersCollection}/$userId/dashboard_stats/current',
      );

      if (!doc.exists || doc.data() == null) return false;

      final data = doc.data() as Map<String, dynamic>;
      final lastUpdatedStr = data['lastUpdated'] as String?;

      if (lastUpdatedStr == null) return false;

      final lastUpdated = DateTime.parse(lastUpdatedStr);
      final difference = DateTime.now().difference(lastUpdated);

      return difference.inMinutes < _cacheValidDuration.inMinutes;
    } catch (e) {
      _errorHandler.logError('Check cache validity', e);
      return false;
    }
  }

  @override
  Future<void> invalidateCache() async {
    try {
      await _databaseService.deleteDocument(
        '${DatabaseConstants.usersCollection}/$userId/dashboard_stats/current',
      );

      if (AppConstants.enableLogging) {
        print('🗑️ Dashboard cache invalidated for user: $userId');
      }
    } catch (e) {
      _errorHandler.logError('Invalidate cache', e);
      // Don't throw error, cache invalidation is not critical
    }
  }

  @override
  Future<void> refreshCacheInBackground() async {
    try {
      // Run in background without blocking UI
      calculateRealTimeStats();

      if (AppConstants.enableLogging) {
        print('🔄 Background cache refresh initiated for user: $userId');
      }
    } catch (e) {
      _errorHandler.logError('Background cache refresh', e);
      // Don't throw error, background refresh is not critical
    }
  }

  // ============================================================================
  // REQUIRED INTERFACE METHODS
  // ============================================================================

  @override
  Future<void> refreshDashboardCache() async {
    try {
      final newStats = await calculateRealTimeStats();
      await updateDashboardStats(newStats);

      if (AppConstants.enableLogging) {
        print('🔄 Dashboard cache refreshed for user: $userId');
      }
    } catch (e) {
      _errorHandler.logError('Refresh dashboard cache', e);
      throw Exception('Dashboard cache yenileme hatası: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  @override
  Future<bool> isDashboardCacheValid() async {
    try {
      return await isCacheValid();
    } catch (e) {
      _errorHandler.logError('Check dashboard cache validity', e);
      return false;
    }
  }

  @override
  Future<void> initializeDashboardStats() async {
    try {
      final stats = await calculateRealTimeStats();
      await updateDashboardStats(stats);

      if (AppConstants.enableLogging) {
        print('🚀 Dashboard stats initialized for user: $userId');
      }
    } catch (e) {
      _errorHandler.logError('Initialize dashboard stats', e);
      throw Exception('Dashboard istatistik başlatma hatası: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  @override
  Future<void> updateStatsAfterRide(String rideId) async {
    try {
      await refreshDashboardCache();

      if (AppConstants.enableLogging) {
        print('📊 Dashboard updated after ride: $rideId');
      }
    } catch (e) {
      _errorHandler.logError('Update stats after ride', e);
      // Bu critical değil, sessizce fail edebilir
    }
  }

  @override
  Future<void> updateStatsAfterExpense(String expenseId) async {
    try {
      await refreshDashboardCache();

      if (AppConstants.enableLogging) {
        print('💰 Dashboard updated after expense: $expenseId');
      }
    } catch (e) {
      _errorHandler.logError('Update stats after expense', e);
      // Bu critical değil, sessizce fail edebilir
    }
  }
}
