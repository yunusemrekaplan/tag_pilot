import '../../core/utils/app_constants.dart';
import '../../domain/repositories/ride_repository.dart';
import '../../domain/services/database_service.dart';
import '../../domain/services/auth_service.dart';
import '../../domain/services/error_handler_service.dart';
import '../models/ride_model.dart';

/// Ride Repository Implementation
/// SOLID: Single Responsibility - Ride data management
/// SOLID: Dependency Inversion - Depends on abstract services
class RideRepositoryImpl implements RideRepository {
  final DatabaseService _databaseService;
  final AuthService _authService;
  final ErrorHandlerService _errorHandler;

  RideRepositoryImpl(
    this._databaseService,
    this._authService,
    this._errorHandler,
  );

  // Middleware kontrolü yaptığı için ! operatörü güvenli
  String get _userId => _authService.currentUserId!;

  // ============================================================================
  // ADVANCED READ OPERATIONS
  // ============================================================================

  @override
  Future<List<RideModel>> getAllRides() async {
    try {
      final allRides = <RideModel>[];

      // Tüm session'ları getir
      final sessionsSnapshot = await _databaseService.getDocuments(
        '${DatabaseConstants.usersCollection}/$_userId/${DatabaseConstants.sessionsCollection}',
      );

      // Her session için ride'ları topla
      for (final sessionDoc in sessionsSnapshot.docs) {
        final sessionId = sessionDoc.id;
        final ridesSnapshot = await _databaseService.getDocuments(
          '${DatabaseConstants.usersCollection}/$_userId/${DatabaseConstants.sessionsCollection}/$sessionId/${DatabaseConstants.ridesCollection}',
        );

        final sessionRides = ridesSnapshot.docs
            .map((doc) => RideModel.fromJson({
                  'id': doc.id,
                  ...doc.data() as Map<String, dynamic>,
                }))
            .toList();

        allRides.addAll(sessionRides);
      }

      // Tarihe göre sırala (en yeni önce)
      allRides.sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));

      if (AppConstants.enableLogging) {
        print('🚗 ${allRides.length} ride loaded successfully');
      }

      return allRides;
    } catch (e) {
      _errorHandler.logError('Get all rides', e);
      throw Exception('Ride\'lar yüklenirken hata oluştu: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  @override
  Future<List<RideModel>> getRidesByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final allRides = await getAllRides();

      return allRides.where((ride) {
        if (ride.createdAt == null) return false;
        final rideDate = ride.createdAt!;
        return rideDate.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
            rideDate.isBefore(endDate.add(const Duration(seconds: 1)));
      }).toList();
    } catch (e) {
      _errorHandler.logError('Get rides by date range', e);
      throw Exception('Tarih aralığına göre ride\'lar getirilemedi: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  @override
  Future<List<RideModel>> getRidesByProfitability(bool profitable) async {
    try {
      final allRides = await getAllRides();

      return allRides.where((ride) => ride.isProfitable == profitable).toList();
    } catch (e) {
      _errorHandler.logError('Get rides by profitability', e);
      throw Exception('Kârlılığa göre ride\'lar getirilemedi: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  @override
  Future<List<RideModel>> getTopRides(int limit, {String orderBy = 'netProfit'}) async {
    try {
      final allRides = await getAllRides();

      // Sıralama mantığı
      allRides.sort((a, b) {
        switch (orderBy) {
          case 'netProfit':
            return b.netProfit.compareTo(a.netProfit);
          case 'earnings':
            return b.earnings.compareTo(a.earnings);
          case 'distanceKm':
            return b.distanceKm.compareTo(a.distanceKm);
          case 'profitMargin':
            return b.profitMargin.compareTo(a.profitMargin);
          default:
            return b.netProfit.compareTo(a.netProfit);
        }
      });

      return allRides.take(limit).toList();
    } catch (e) {
      _errorHandler.logError('Get top rides', e);
      throw Exception('En iyi ride\'lar getirilemedi: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  @override
  Future<List<RideModel>> searchRides(String query) async {
    try {
      final allRides = await getAllRides();
      final lowerQuery = query.toLowerCase();

      return allRides.where((ride) {
        // Notes içinde arama
        if (ride.notes != null && ride.notes!.toLowerCase().contains(lowerQuery)) {
          return true;
        }

        // Session ID'de arama
        if (ride.sessionId.toLowerCase().contains(lowerQuery)) {
          return true;
        }

        // Profit status'ta arama
        if (ride.profitStatus.toLowerCase().contains(lowerQuery)) {
          return true;
        }

        return false;
      }).toList();
    } catch (e) {
      _errorHandler.logError('Search rides', e);
      throw Exception('Ride arama başarısız: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  @override
  Future<List<RideModel>> filterRides({
    double? minDistance,
    double? maxDistance,
    double? minEarnings,
    double? maxEarnings,
    double? minProfit,
    double? maxProfit,
    DateTime? fromDate,
    DateTime? toDate,
    bool? isProfitable,
  }) async {
    try {
      final allRides = await getAllRides();

      return allRides.where((ride) {
        // Mesafe filtresi
        if (minDistance != null && ride.distanceKm < minDistance) return false;
        if (maxDistance != null && ride.distanceKm > maxDistance) return false;

        // Kazanç filtresi
        if (minEarnings != null && ride.earnings < minEarnings) return false;
        if (maxEarnings != null && ride.earnings > maxEarnings) return false;

        // Kâr filtresi
        if (minProfit != null && ride.netProfit < minProfit) return false;
        if (maxProfit != null && ride.netProfit > maxProfit) return false;

        // Tarih filtresi
        if (fromDate != null && ride.createdAt != null) {
          if (ride.createdAt!.isBefore(fromDate)) return false;
        }
        if (toDate != null && ride.createdAt != null) {
          if (ride.createdAt!.isAfter(toDate)) return false;
        }

        // Kârlılık filtresi
        if (isProfitable != null && ride.isProfitable != isProfitable) return false;

        return true;
      }).toList();
    } catch (e) {
      _errorHandler.logError('Filter rides', e);
      throw Exception('Ride filtreleme başarısız: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  @override
  Stream<List<RideModel>> watchAllRides() {
    try {
      // Basit implementation - sadece poll yaparak
      // Gerçek implementation'da collection group query kullanılabilir
      return Stream.periodic(const Duration(seconds: 5)).asyncMap((_) => getAllRides()).handleError((error) {
        _errorHandler.logError('Watch all rides', error);
        return <RideModel>[];
      });
    } catch (e) {
      _errorHandler.logError('Watch all rides', e);
      return Stream.value(<RideModel>[]);
    }
  }

  @override
  Stream<List<RideModel>> watchRidesWithFilter(Map<String, dynamic> filters) {
    // Stub implementation
    return watchAllRides();
  }

  // ============================================================================
  // ANALYTICS OPERATIONS
  // ============================================================================

  @override
  Future<Map<String, dynamic>> getRideAnalytics() async {
    try {
      final allRides = await getAllRides();

      if (allRides.isEmpty) {
        return {
          'totalRides': 0,
          'totalEarnings': 0.0,
          'totalDistance': 0.0,
          'totalProfit': 0.0,
          'averageEarnings': 0.0,
          'averageDistance': 0.0,
          'averageProfit': 0.0,
          'profitableRides': 0,
          'unprofitableRides': 0,
          'profitabilityPercentage': 0.0,
        };
      }

      final totalRides = allRides.length;
      final totalEarnings = allRides.fold<double>(0.0, (sum, ride) => sum + ride.earnings);
      final totalDistance = allRides.fold<double>(0.0, (sum, ride) => sum + ride.distanceKm);
      final totalProfit = allRides.fold<double>(0.0, (sum, ride) => sum + ride.netProfit);
      final profitableRides = allRides.where((ride) => ride.isProfitable).length;
      final unprofitableRides = totalRides - profitableRides;

      return {
        'totalRides': totalRides,
        'totalEarnings': totalEarnings,
        'totalDistance': totalDistance,
        'totalProfit': totalProfit,
        'averageEarnings': totalEarnings / totalRides,
        'averageDistance': totalDistance / totalRides,
        'averageProfit': totalProfit / totalRides,
        'profitableRides': profitableRides,
        'unprofitableRides': unprofitableRides,
        'profitabilityPercentage': (profitableRides / totalRides) * 100,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      _errorHandler.logError('Get ride analytics', e);
      throw Exception('Ride analytics hesaplanamadı: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  @override
  Future<Map<String, dynamic>> getPerformanceMetrics() async {
    try {
      final allRides = await getAllRides();

      if (allRides.isEmpty) {
        return {
          'bestRide': null,
          'worstRide': null,
          'averageProfitMargin': 0.0,
          'bestProfitMargin': 0.0,
          'worstProfitMargin': 0.0,
          'consistencyScore': 0.0,
        };
      }

      // En iyi ve en kötü ride'ları bul
      final sortedByProfit = [...allRides]..sort((a, b) => b.netProfit.compareTo(a.netProfit));
      final bestRide = sortedByProfit.first;
      final worstRide = sortedByProfit.last;

      // Profit margin istatistikleri
      final profitMargins = allRides.map((ride) => ride.profitMargin).toList();
      final averageProfitMargin = profitMargins.fold<double>(0.0, (sum, margin) => sum + margin) / profitMargins.length;
      final bestProfitMargin = profitMargins.reduce((a, b) => a > b ? a : b);
      final worstProfitMargin = profitMargins.reduce((a, b) => a < b ? a : b);

      // Tutarlılık skoru (profit variance'ın tersi)
      final variance = _calculateVariance(allRides.map((r) => r.netProfit).toList());
      final consistencyScore = variance > 0 ? (1 / (1 + variance)) * 100 : 100.0;

      return {
        'bestRide': bestRide.toJson(),
        'worstRide': worstRide.toJson(),
        'averageProfitMargin': averageProfitMargin,
        'bestProfitMargin': bestProfitMargin,
        'worstProfitMargin': worstProfitMargin,
        'consistencyScore': consistencyScore,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      _errorHandler.logError('Get performance metrics', e);
      throw Exception('Performance metrics hesaplanamadı: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  @override
  Future<Map<String, dynamic>> getProfitabilityAnalysis() async {
    try {
      final allRides = await getAllRides();

      if (allRides.isEmpty) {
        return {
          'totalProfitableRides': 0,
          'totalUnprofitableRides': 0,
          'profitabilityRate': 0.0,
          'averageProfitableEarnings': 0.0,
          'averageUnprofitableEarnings': 0.0,
          'profitLoss': 0.0,
        };
      }

      final profitableRides = allRides.where((ride) => ride.isProfitable).toList();
      final unprofitableRides = allRides.where((ride) => !ride.isProfitable).toList();

      final profitableEarnings = profitableRides.isEmpty
          ? 0.0
          : profitableRides.fold<double>(0.0, (sum, ride) => sum + ride.earnings) / profitableRides.length;

      final unprofitableEarnings = unprofitableRides.isEmpty
          ? 0.0
          : unprofitableRides.fold<double>(0.0, (sum, ride) => sum + ride.earnings) / unprofitableRides.length;

      final totalProfit = allRides.fold<double>(0.0, (sum, ride) => sum + ride.netProfit);

      return {
        'totalProfitableRides': profitableRides.length,
        'totalUnprofitableRides': unprofitableRides.length,
        'profitabilityRate': (profitableRides.length / allRides.length) * 100,
        'averageProfitableEarnings': profitableEarnings,
        'averageUnprofitableEarnings': unprofitableEarnings,
        'profitLoss': totalProfit,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      _errorHandler.logError('Get profitability analysis', e);
      throw Exception('Profitability analysis hesaplanamadı: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  @override
  Future<Map<String, dynamic>> getDailyRideStats(DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      final dayRides = await getRidesByDateRange(startOfDay, endOfDay);

      if (dayRides.isEmpty) {
        return {
          'date': date.toIso8601String(),
          'totalRides': 0,
          'totalEarnings': 0.0,
          'totalDistance': 0.0,
          'totalProfit': 0.0,
          'averageEarnings': 0.0,
          'profitableRides': 0,
        };
      }

      return {
        'date': date.toIso8601String(),
        'totalRides': dayRides.length,
        'totalEarnings': dayRides.fold<double>(0.0, (sum, ride) => sum + ride.earnings),
        'totalDistance': dayRides.fold<double>(0.0, (sum, ride) => sum + ride.distanceKm),
        'totalProfit': dayRides.fold<double>(0.0, (sum, ride) => sum + ride.netProfit),
        'averageEarnings': dayRides.fold<double>(0.0, (sum, ride) => sum + ride.earnings) / dayRides.length,
        'profitableRides': dayRides.where((ride) => ride.isProfitable).length,
      };
    } catch (e) {
      _errorHandler.logError('Get daily ride stats', e);
      throw Exception('Günlük ride istatistikleri hesaplanamadı: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  // ============================================================================
  // STUB IMPLEMENTATIONS (İleride implement edilecek)
  // ============================================================================

  @override
  Future<Map<String, dynamic>> getWeeklyRideStats(DateTime startOfWeek) async {
    // Stub - basit implementation
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    final weekRides = await getRidesByDateRange(startOfWeek, endOfWeek);

    return {
      'period': 'week',
      'startDate': startOfWeek.toIso8601String(),
      'endDate': endOfWeek.toIso8601String(),
      'totalRides': weekRides.length,
      'totalEarnings': weekRides.fold<double>(0.0, (sum, ride) => sum + ride.earnings),
    };
  }

  @override
  Future<Map<String, dynamic>> getMonthlyRideStats(DateTime startOfMonth) async {
    // Stub - basit implementation
    final endOfMonth = DateTime(startOfMonth.year, startOfMonth.month + 1, 1);
    final monthRides = await getRidesByDateRange(startOfMonth, endOfMonth);

    return {
      'period': 'month',
      'startDate': startOfMonth.toIso8601String(),
      'endDate': endOfMonth.toIso8601String(),
      'totalRides': monthRides.length,
      'totalEarnings': monthRides.fold<double>(0.0, (sum, ride) => sum + ride.earnings),
    };
  }

  @override
  Future<Map<String, dynamic>> getYearlyRideStats(int year) async {
    // Stub implementation
    return {'year': year, 'status': 'Not implemented yet'};
  }

  @override
  Future<Map<String, dynamic>> compareRidePerformance(
    DateTime period1Start,
    DateTime period1End,
    DateTime period2Start,
    DateTime period2End,
  ) async {
    // Stub implementation
    return {'status': 'Not implemented yet'};
  }

  @override
  Future<double> getAverageRideEarnings() async {
    final analytics = await getRideAnalytics();
    return analytics['averageEarnings'] ?? 0.0;
  }

  @override
  Future<double> getAverageRideDistance() async {
    final analytics = await getRideAnalytics();
    return analytics['averageDistance'] ?? 0.0;
  }

  @override
  Future<double> getAverageRideProfit() async {
    final analytics = await getRideAnalytics();
    return analytics['averageProfit'] ?? 0.0;
  }

  @override
  Future<double> getAverageProfitMargin() async {
    final metrics = await getPerformanceMetrics();
    return metrics['averageProfitMargin'] ?? 0.0;
  }

  @override
  Future<double> getBestRideEarnings() async {
    final allRides = await getAllRides();
    if (allRides.isEmpty) return 0.0;
    return allRides.map((r) => r.earnings).reduce((a, b) => a > b ? a : b);
  }

  @override
  Future<double> getWorstRideEarnings() async {
    final allRides = await getAllRides();
    if (allRides.isEmpty) return 0.0;
    return allRides.map((r) => r.earnings).reduce((a, b) => a < b ? a : b);
  }

  @override
  Future<RideModel?> getBestPerformingRide() async {
    final allRides = await getAllRides();
    if (allRides.isEmpty) return null;
    allRides.sort((a, b) => b.netProfit.compareTo(a.netProfit));
    return allRides.first;
  }

  @override
  Future<RideModel?> getWorstPerformingRide() async {
    final allRides = await getAllRides();
    if (allRides.isEmpty) return null;
    allRides.sort((a, b) => a.netProfit.compareTo(b.netProfit));
    return allRides.first;
  }

  // ============================================================================
  // STUB IMPLEMENTATIONS - Tüm diğer interface metodları
  // ============================================================================

  @override
  Future<List<Map<String, dynamic>>> getEarningsTrend(int days) async => [];

  @override
  Future<List<Map<String, dynamic>>> getProfitabilityTrend(int days) async => [];

  @override
  Future<List<Map<String, dynamic>>> getDistanceTrend(int days) async => [];

  @override
  Future<double> calculateFuelEfficiency() async => 0.0;

  @override
  Future<double> calculateTimeEfficiency() async => 0.0;

  @override
  Future<Map<String, dynamic>> getEfficiencyMetrics() async => {};

  @override
  Future<double> calculateDailyTarget() async => 0.0;

  @override
  Future<bool> isDailyTargetMet(DateTime date) async => false;

  @override
  Future<double> getProgressTowardTarget(DateTime date) async => 0.0;

  @override
  Future<List<String>> getPerformanceRecommendations() async => [];

  @override
  Future<Map<String, dynamic>> getOptimizationSuggestions() async => {};

  @override
  Future<Map<String, dynamic>> generateDailyReport(DateTime date) async => {};

  @override
  Future<Map<String, dynamic>> generateWeeklyReport(DateTime startOfWeek) async => {};

  @override
  Future<Map<String, dynamic>> generateMonthlyReport(DateTime startOfMonth) async => {};

  @override
  Future<Map<String, dynamic>> generateCustomReport(DateTime startDate, DateTime endDate, List<String> metrics) async =>
      {};

  @override
  Future<List<Map<String, dynamic>>> exportRideData(
          {DateTime? startDate, DateTime? endDate, List<String>? fields}) async =>
      [];

  @override
  Future<bool> isPerformingAboveAverage(RideModel ride) async => false;

  @override
  Future<int> getRideRanking(String rideId) async => 0;

  @override
  Future<List<RideModel>> getSimilarRides(RideModel ride) async => [];

  @override
  Future<double> predictNextRideEarnings() async => 0.0;

  @override
  Future<Map<String, dynamic>> getForecast(int days) async => {};

  @override
  Future<List<RideModel>> detectAnomalousRides() async => [];

  @override
  Future<bool> isRideAnomalous(RideModel ride) async => false;

  // ============================================================================
  // PRIVATE HELPER METHODS
  // ============================================================================

  double _calculateVariance(List<double> values) {
    if (values.isEmpty) return 0.0;

    final mean = values.fold<double>(0.0, (sum, value) => sum + value) / values.length;
    final squaredDifferences = values.map((value) => (value - mean) * (value - mean));
    return squaredDifferences.fold<double>(0.0, (sum, value) => sum + value) / values.length;
  }
}
