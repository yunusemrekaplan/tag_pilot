import 'package:get/get.dart';

import '../../domain/repositories/reports_repository.dart';
import '../../domain/repositories/ride_repository.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../domain/repositories/session_repository.dart';
import '../../domain/services/auth_service.dart';
import '../../domain/services/error_handler_service.dart';

/// Reports Repository Implementation (Clean Architecture)
/// SOLID: Dependency Inversion - ReportsRepository interface'ini implement eder
/// SOLID: Single Responsibility - Sadece reports data operations
/// Data Logic vs Business Logic: Bu class sadece data operations yapar, business logic Domain layer'da
class ReportsRepositoryImpl implements ReportsRepository {
  late final AuthService _authService;
  late final ErrorHandlerService _errorHandler;
  late final RideRepository _rideRepository;
  late final ExpenseRepository _expenseRepository;
  late final SessionRepository _sessionRepository;

  ReportsRepositoryImpl() {
    _authService = Get.find<AuthService>();
    _errorHandler = Get.find<ErrorHandlerService>();
    _rideRepository = Get.find<RideRepository>();
    _expenseRepository = Get.find<ExpenseRepository>();
    _sessionRepository = Get.find<SessionRepository>();
  }

  // Middleware kontrolü yaptığı için ! operatörü güvenli
  late final String userId = _authService.currentUserId!;

  // ============================================================================
  // BASIC REPORT GENERATION
  // ============================================================================

  @override
  Future<Map<String, dynamic>> generateDailyReport(DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      // Parallel data fetching for better performance
      final results = await Future.wait([
        _rideRepository.getRidesByDateRange(startOfDay, endOfDay),
        _expenseRepository.getExpensesByDateRange(startOfDay, endOfDay),
        _sessionRepository.getSessionsByDateRange(startOfDay, endOfDay),
      ]);

      final rides = results[0] as List;
      final expenses = results[1] as List;
      final sessions = results[2] as List;

      // Doğru hesaplamalar
      final totalEarnings = rides.fold<double>(0.0, (sum, ride) => sum + ride.earnings);
      final totalFuelCost = rides.fold<double>(0.0, (sum, ride) => sum + ride.fuelCost);
      final totalExpenses = expenses.fold<double>(0.0, (sum, expense) => sum + expense.amount);
      final totalDistance = rides.fold<double>(0.0, (sum, ride) => sum + ride.distanceKm);

      // Paket ücretlerini hesapla
      final totalPackageCost = _calculateTotalPackageCost(sessions);

      // Doğru kâr hesaplaması: Kazanç - Yakıt Maliyeti - Harcamalar - Paket Ücretleri
      final totalProfit = totalEarnings - totalFuelCost - totalExpenses - totalPackageCost;

      return {
        'reportType': 'daily',
        'date': date.toIso8601String(),
        'summary': {
          'totalRides': rides.length,
          'totalCompletedSessions': sessions.length,
          'totalEarnings': totalEarnings,
          'totalFuelCost': totalFuelCost,
          'totalExpenses': totalExpenses,
          'totalPackageCost': totalPackageCost,
          'totalProfit': totalProfit,
          'totalDistance': totalDistance,
          'averageEarningsPerRide': rides.isNotEmpty ? totalEarnings / rides.length : 0.0,
          'averageDistancePerRide': rides.isNotEmpty ? totalDistance / rides.length : 0.0,
          'profitMargin': totalEarnings > 0 ? (totalProfit / totalEarnings) * 100 : 0.0,
        },
        'details': {
          'rides': rides.map((ride) => ride.toJson()).toList(),
          'expenses': expenses.map((expense) => expense.toJson()).toList(),
          'sessions': sessions.map((session) => session.toJson()).toList(),
        },
        'generatedAt': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      _errorHandler.logError('Generate daily report', e);
      throw Exception('Günlük rapor oluşturulurken hata oluştu: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  @override
  Future<Map<String, dynamic>> generateWeeklyReport(DateTime startOfWeek) async {
    try {
      final endOfWeek = startOfWeek.add(const Duration(days: 7));

      // Parallel data fetching
      final results = await Future.wait([
        _rideRepository.getRidesByDateRange(startOfWeek, endOfWeek),
        _expenseRepository.getExpensesByDateRange(startOfWeek, endOfWeek),
        _sessionRepository.getSessionsByDateRange(startOfWeek, endOfWeek),
      ]);

      final rides = results[0] as List;
      final expenses = results[1] as List;
      final sessions = results[2] as List;

      // Doğru hesaplamalar
      final totalEarnings = rides.fold<double>(0.0, (sum, ride) => sum + ride.earnings);
      final totalFuelCost = rides.fold<double>(0.0, (sum, ride) => sum + ride.fuelCost);
      final totalExpenses = expenses.fold<double>(0.0, (sum, expense) => sum + expense.amount);
      final totalDistance = rides.fold<double>(0.0, (sum, ride) => sum + ride.distanceKm);

      // Paket ücretlerini hesapla
      final totalPackageCost = _calculateTotalPackageCost(sessions);

      // Doğru kâr hesaplaması: Kazanç - Yakıt Maliyeti - Harcamalar - Paket Ücretleri
      final totalProfit = totalEarnings - totalFuelCost - totalExpenses - totalPackageCost;

      // Daily breakdown
      final dailyBreakdown = <Map<String, dynamic>>[];
      for (int i = 0; i < 7; i++) {
        final day = startOfWeek.add(Duration(days: i));
        final dayRides = rides
            .where((ride) => ride.createdAt.isAfter(day) && ride.createdAt.isBefore(day.add(const Duration(days: 1))))
            .toList();

        final dayEarnings = dayRides.fold<double>(0.0, (sum, ride) => sum + ride.earnings);
        final dayFuelCost = dayRides.fold<double>(0.0, (sum, ride) => sum + ride.fuelCost);
        final dayDistance = dayRides.fold<double>(0.0, (sum, ride) => sum + ride.distanceKm);

        dailyBreakdown.add({
          'date': day.toIso8601String(),
          'dayName': _getDayName(day.weekday),
          'rides': dayRides.length,
          'earnings': dayEarnings,
          'fuelCost': dayFuelCost,
          'distance': dayDistance,
        });
      }

      return {
        'reportType': 'weekly',
        'startDate': startOfWeek.toIso8601String(),
        'endDate': endOfWeek.toIso8601String(),
        'summary': {
          'totalRides': rides.length,
          'totalCompletedSessions': sessions.length,
          'totalEarnings': totalEarnings,
          'totalFuelCost': totalFuelCost,
          'totalExpenses': totalExpenses,
          'totalPackageCost': totalPackageCost,
          'totalProfit': totalProfit,
          'totalDistance': totalDistance,
          'averageEarningsPerRide': rides.isNotEmpty ? totalEarnings / rides.length : 0.0,
          'averageDistancePerRide': rides.isNotEmpty ? totalDistance / rides.length : 0.0,
          'profitMargin': totalEarnings > 0 ? (totalProfit / totalEarnings) * 100 : 0.0,
        },
        'dailyBreakdown': dailyBreakdown,
        'details': {
          'rides': rides.map((ride) => ride.toJson()).toList(),
          'expenses': expenses.map((expense) => expense.toJson()).toList(),
          'sessions': sessions.map((session) => session.toJson()).toList(),
        },
        'generatedAt': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      _errorHandler.logError('Generate weekly report', e);
      throw Exception('Haftalık rapor oluşturulurken hata oluştu: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  @override
  Future<Map<String, dynamic>> generateMonthlyReport(DateTime startOfMonth) async {
    try {
      final endOfMonth = DateTime(startOfMonth.year, startOfMonth.month + 1, 1).subtract(const Duration(days: 1));

      // Parallel data fetching
      final results = await Future.wait([
        _rideRepository.getRidesByDateRange(startOfMonth, endOfMonth),
        _expenseRepository.getExpensesByDateRange(startOfMonth, endOfMonth),
        _sessionRepository.getSessionsByDateRange(startOfMonth, endOfMonth),
      ]);

      final rides = results[0] as List;
      final expenses = results[1] as List;
      final sessions = results[2] as List;

      // Doğru hesaplamalar
      final totalEarnings = rides.fold<double>(0.0, (sum, ride) => sum + ride.earnings);
      final totalFuelCost = rides.fold<double>(0.0, (sum, ride) => sum + ride.fuelCost);
      final totalExpenses = expenses.fold<double>(0.0, (sum, expense) => sum + expense.amount);
      final totalDistance = rides.fold<double>(0.0, (sum, ride) => sum + ride.distanceKm);

      // Paket ücretlerini hesapla
      final totalPackageCost = _calculateTotalPackageCost(sessions);

      // Doğru kâr hesaplaması: Kazanç - Yakıt Maliyeti - Harcamalar - Paket Ücretleri
      final totalProfit = totalEarnings - totalFuelCost - totalExpenses - totalPackageCost;

      return {
        'reportType': 'monthly',
        'startDate': startOfMonth.toIso8601String(),
        'endDate': endOfMonth.toIso8601String(),
        'summary': {
          'totalRides': rides.length,
          'totalCompletedSessions': sessions.length,
          'totalEarnings': totalEarnings,
          'totalFuelCost': totalFuelCost,
          'totalExpenses': totalExpenses,
          'totalPackageCost': totalPackageCost,
          'totalProfit': totalProfit,
          'totalDistance': totalDistance,
          'averageEarningsPerRide': rides.isNotEmpty ? totalEarnings / rides.length : 0.0,
          'averageDistancePerRide': rides.isNotEmpty ? totalDistance / rides.length : 0.0,
          'profitMargin': totalEarnings > 0 ? (totalProfit / totalEarnings) * 100 : 0.0,
        },
        'details': {
          'rides': rides.map((ride) => ride.toJson()).toList(),
          'expenses': expenses.map((expense) => expense.toJson()).toList(),
          'sessions': sessions.map((session) => session.toJson()).toList(),
        },
        'generatedAt': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      _errorHandler.logError('Generate monthly report', e);
      throw Exception('Aylık rapor oluşturulurken hata oluştu: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  @override
  Future<Map<String, dynamic>> generateCustomReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Parallel data fetching
      final results = await Future.wait([
        _rideRepository.getRidesByDateRange(startDate, endDate),
        _expenseRepository.getExpensesByDateRange(startDate, endDate),
        _sessionRepository.getSessionsByDateRange(startDate, endDate),
      ]);

      final rides = results[0] as List;
      final expenses = results[1] as List;
      final sessions = results[2] as List;

      // Doğru hesaplamalar
      final totalEarnings = rides.fold<double>(0.0, (sum, ride) => sum + ride.earnings);
      final totalFuelCost = rides.fold<double>(0.0, (sum, ride) => sum + ride.fuelCost);
      final totalExpenses = expenses.fold<double>(0.0, (sum, expense) => sum + expense.amount);
      final totalDistance = rides.fold<double>(0.0, (sum, ride) => sum + ride.distanceKm);

      // Paket ücretlerini hesapla
      final totalPackageCost = _calculateTotalPackageCost(sessions);

      // Doğru kâr hesaplaması: Kazanç - Yakıt Maliyeti - Harcamalar - Paket Ücretleri
      final totalProfit = totalEarnings - totalFuelCost - totalExpenses - totalPackageCost;

      return {
        'reportType': 'custom',
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'summary': {
          'totalRides': rides.length,
          'totalCompletedSessions': sessions.length,
          'totalEarnings': totalEarnings,
          'totalFuelCost': totalFuelCost,
          'totalExpenses': totalExpenses,
          'totalPackageCost': totalPackageCost,
          'totalProfit': totalProfit,
          'totalDistance': totalDistance,
          'averageEarningsPerRide': rides.isNotEmpty ? totalEarnings / rides.length : 0.0,
          'averageDistancePerRide': rides.isNotEmpty ? totalDistance / rides.length : 0.0,
          'profitMargin': totalEarnings > 0 ? (totalProfit / totalEarnings) * 100 : 0.0,
        },
        'details': {
          'rides': rides.map((ride) => ride.toJson()).toList(),
          'expenses': expenses.map((expense) => expense.toJson()).toList(),
          'sessions': sessions.map((session) => session.toJson()).toList(),
        },
        'generatedAt': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      _errorHandler.logError('Generate custom report', e);
      throw Exception('Özel rapor oluşturulurken hata oluştu: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  // ============================================================================
  // TREND ANALYSIS
  // ============================================================================

  @override
  Future<List<Map<String, dynamic>>> getEarningsTrend(int days) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days));

      final rides = await _rideRepository.getRidesByDateRange(startDate, endDate);

      // Günlük kazanç trendi
      final trend = <Map<String, dynamic>>[];
      for (int i = 0; i < days; i++) {
        final date = endDate.subtract(Duration(days: i));
        final dayRides = rides
            .where((ride) =>
                ride.createdAt != null &&
                ride.createdAt!.isAfter(DateTime(date.year, date.month, date.day)) &&
                ride.createdAt!.isBefore(DateTime(date.year, date.month, date.day + 1)))
            .toList();

        final dayEarnings = dayRides.fold<double>(0.0, (sum, ride) => sum + ride.earnings);

        trend.add({
          'date': date.toIso8601String(),
          'dayName': _getDayName(date.weekday),
          'earnings': dayEarnings,
          'rideCount': dayRides.length,
        });
      }

      return trend.reversed.toList();
    } catch (e) {
      _errorHandler.logError('Get earnings trend', e);
      throw Exception('Kazanç trend verisi alınırken hata oluştu: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getProfitTrend(int days) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days));

      final rides = await _rideRepository.getRidesByDateRange(startDate, endDate);
      final expenses = await _expenseRepository.getExpensesByDateRange(startDate, endDate);

      final trendData = <Map<String, dynamic>>[];
      for (int i = 0; i < days; i++) {
        final date = startDate.add(Duration(days: i));
        final dayRides = rides
            .where((ride) =>
                ride.createdAt != null &&
                ride.createdAt!.isAfter(date) &&
                ride.createdAt!.isBefore(date.add(const Duration(days: 1))))
            .toList();

        final dayExpenses = expenses
            .where((expense) =>
                expense.createdAt.isAfter(date) && expense.createdAt.isBefore(date.add(const Duration(days: 1))))
            .toList();

        final dayEarnings = dayRides.fold<double>(0.0, (sum, ride) => sum + ride.earnings);
        final dayExpenseAmount = dayExpenses.fold<double>(0.0, (sum, expense) => sum + expense.amount);
        final dayProfit = dayEarnings - dayExpenseAmount;

        trendData.add({
          'date': date.toIso8601String(),
          'profit': dayProfit,
          'earnings': dayEarnings,
          'expenses': dayExpenseAmount,
        });
      }

      return trendData;
    } catch (e) {
      _errorHandler.logError('Get profit trend', e);
      throw Exception('Kâr trend analizi yapılırken hata oluştu: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getDistanceTrend(int days) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days));

      final rides = await _rideRepository.getRidesByDateRange(startDate, endDate);

      final trendData = <Map<String, dynamic>>[];
      for (int i = 0; i < days; i++) {
        final date = startDate.add(Duration(days: i));
        final dayRides = rides
            .where((ride) =>
                ride.createdAt != null &&
                ride.createdAt!.isAfter(date) &&
                ride.createdAt!.isBefore(date.add(const Duration(days: 1))))
            .toList();

        final dayDistance = dayRides.fold<double>(0.0, (sum, ride) => sum + ride.distanceKm);
        trendData.add({
          'date': date.toIso8601String(),
          'distance': dayDistance,
          'rideCount': dayRides.length,
        });
      }

      return trendData;
    } catch (e) {
      _errorHandler.logError('Get distance trend', e);
      throw Exception('Mesafe trend analizi yapılırken hata oluştu: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getExpenseTrend(int days) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days));

      final expenses = await _expenseRepository.getExpensesByDateRange(startDate, endDate);

      final trendData = <Map<String, dynamic>>[];
      for (int i = 0; i < days; i++) {
        final date = startDate.add(Duration(days: i));
        final dayExpenses = expenses
            .where((expense) =>
                expense.createdAt.isAfter(date) && expense.createdAt.isBefore(date.add(const Duration(days: 1))))
            .toList();

        final dayExpenseAmount = dayExpenses.fold<double>(0.0, (sum, expense) => sum + expense.amount);
        trendData.add({
          'date': date.toIso8601String(),
          'expenses': dayExpenseAmount,
          'expenseCount': dayExpenses.length,
        });
      }

      return trendData;
    } catch (e) {
      _errorHandler.logError('Get expense trend', e);
      throw Exception('Harcama trend analizi yapılırken hata oluştu: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  // ============================================================================
  // CATEGORY ANALYSIS
  // ============================================================================

  @override
  Future<Map<String, dynamic>> getExpenseCategoryAnalysis(DateTime startDate, DateTime endDate) async {
    try {
      final expenses = await _expenseRepository.getExpensesByDateRange(startDate, endDate);

      final categoryMap = <String, double>{};
      for (final expense in expenses) {
        final category = expense.category.name;
        categoryMap[category] = (categoryMap[category] ?? 0.0) + expense.amount;
      }

      final totalExpenses = categoryMap.values.fold<double>(0.0, (sum, amount) => sum + amount);
      final categoryPercentages = <String, double>{};

      for (final entry in categoryMap.entries) {
        categoryPercentages[entry.key] = (entry.value / totalExpenses) * 100;
      }

      return {
        'categories': categoryMap,
        'percentages': categoryPercentages,
        'totalExpenses': totalExpenses,
        'categoryCount': categoryMap.length,
      };
    } catch (e) {
      _errorHandler.logError('Get expense category analysis', e);
      throw Exception('Harcama kategorisi analizi yapılırken hata oluştu: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  @override
  Future<Map<String, dynamic>> getEarningsCategoryAnalysis(DateTime startDate, DateTime endDate) async {
    // Stub implementation
    return {'status': 'Not implemented yet'};
  }

  @override
  Future<Map<String, dynamic>> getPerformanceCategoryAnalysis(DateTime startDate, DateTime endDate) async {
    // Stub implementation
    return {'status': 'Not implemented yet'};
  }

  // ============================================================================
  // COMPARISON ANALYSIS
  // ============================================================================

  @override
  Future<Map<String, dynamic>> comparePeriods(DateTime startDate, DateTime endDate) async {
    // Stub implementation
    return {'status': 'Not implemented yet'};
  }

  @override
  Future<Map<String, dynamic>> comparePerformance() async {
    // Stub implementation
    return {'status': 'Not implemented yet'};
  }

  @override
  Future<Map<String, dynamic>> compareTargets(DateTime startDate, DateTime endDate) async {
    // Stub implementation
    return {'status': 'Not implemented yet'};
  }

  // ============================================================================
  // INSIGHTS & RECOMMENDATIONS
  // ============================================================================

  @override
  Future<List<String>> getPerformanceInsights() async {
    // Stub implementation
    return ['Performans önerileri yakında eklenecek'];
  }

  @override
  Future<Map<String, dynamic>> getOptimizationSuggestions() async {
    // Stub implementation
    return {'status': 'Not implemented yet'};
  }

  @override
  Future<Map<String, dynamic>> getGoalAnalysis() async {
    // Stub implementation
    return {'status': 'Not implemented yet'};
  }

  @override
  Future<Map<String, dynamic>> getProfitabilityAnalysis() async {
    // Stub implementation
    return {'status': 'Not implemented yet'};
  }

  // ============================================================================
  // ADVANCED METRICS
  // ============================================================================

  @override
  Future<Map<String, dynamic>> getEfficiencyMetrics(DateTime startDate, DateTime endDate) async {
    // Stub implementation
    return {'status': 'Not implemented yet'};
  }

  @override
  Future<Map<String, dynamic>> getRiskAnalysis(DateTime startDate, DateTime endDate) async {
    // Stub implementation
    return {'status': 'Not implemented yet'};
  }

  @override
  Future<Map<String, dynamic>> getForecastAnalysis(int days) async {
    // Stub implementation
    return {'status': 'Not implemented yet'};
  }

  @override
  Future<String> generatePdfReport(Map<String, dynamic> reportData) async {
    // Stub implementation
    return 'PDF rapor oluşturma yakında eklenecek';
  }

  @override
  Future<String> generateExcelReport(Map<String, dynamic> reportData) async {
    // Stub implementation
    return 'Excel rapor oluşturma yakında eklenecek';
  }

  @override
  Future<bool> shareReport(String reportPath, String shareType) async {
    // Stub implementation
    return false;
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Pazartesi';
      case 2:
        return 'Salı';
      case 3:
        return 'Çarşamba';
      case 4:
        return 'Perşembe';
      case 5:
        return 'Cuma';
      case 6:
        return 'Cumartesi';
      case 7:
        return 'Pazar';
      default:
        return 'Bilinmeyen';
    }
  }

  /// Toplam paket ücretini hesapla
  double _calculateTotalPackageCost(List sessions) {
    return sessions.fold<double>(0.0, (sum, session) {
      // Session'da packagePrice varsa ekle
      if (session.packagePrice != null && session.packagePrice > 0) {
        return sum + session.packagePrice;
      }
      return sum;
    });
  }
}
