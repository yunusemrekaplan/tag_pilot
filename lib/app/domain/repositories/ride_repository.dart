import '../../data/models/ride_model.dart';

/// Ride Repository Interface
/// SOLID: Dependency Inversion - High-level modules buna bağımlı, implementation'a değil
/// SOLID: Interface Segregation - Sadece advanced ride operations
abstract class RideRepository {
  // ============================================================================
  // ADVANCED READ OPERATIONS
  // ============================================================================

  // Cross-Session Ride Operations
  Future<List<RideModel>> getAllRides();
  Future<List<RideModel>> getRidesByDateRange(DateTime startDate, DateTime endDate);
  Future<List<RideModel>> getRidesByProfitability(bool profitable);
  Future<List<RideModel>> getTopRides(int limit, {String orderBy = 'netProfit'});

  // Search & Filter Operations
  Future<List<RideModel>> searchRides(String query);
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
  });

  // Real-time Operations
  Stream<List<RideModel>> watchAllRides();
  Stream<List<RideModel>> watchRidesWithFilter(Map<String, dynamic> filters);

  // ============================================================================
  // ANALYTICS OPERATIONS
  // ============================================================================

  // Basic Analytics
  Future<Map<String, dynamic>> getRideAnalytics();
  Future<Map<String, dynamic>> getPerformanceMetrics();
  Future<Map<String, dynamic>> getProfitabilityAnalysis();

  // Time-based Analytics
  Future<Map<String, dynamic>> getDailyRideStats(DateTime date);
  Future<Map<String, dynamic>> getWeeklyRideStats(DateTime startOfWeek);
  Future<Map<String, dynamic>> getMonthlyRideStats(DateTime startOfMonth);
  Future<Map<String, dynamic>> getYearlyRideStats(int year);

  // Comparison Analytics
  Future<Map<String, dynamic>> compareRidePerformance(
    DateTime period1Start,
    DateTime period1End,
    DateTime period2Start,
    DateTime period2End,
  );

  // Advanced Metrics
  Future<double> getAverageRideEarnings();
  Future<double> getAverageRideDistance();
  Future<double> getAverageRideProfit();
  Future<double> getAverageProfitMargin();
  Future<double> getBestRideEarnings();
  Future<double> getWorstRideEarnings();
  Future<RideModel?> getBestPerformingRide();
  Future<RideModel?> getWorstPerformingRide();

  // ============================================================================
  // BUSINESS INTELLIGENCE
  // ============================================================================

  // Trend Analysis
  Future<List<Map<String, dynamic>>> getEarningsTrend(int days);
  Future<List<Map<String, dynamic>>> getProfitabilityTrend(int days);
  Future<List<Map<String, dynamic>>> getDistanceTrend(int days);

  // Efficiency Metrics
  Future<double> calculateFuelEfficiency();
  Future<double> calculateTimeEfficiency();
  Future<Map<String, dynamic>> getEfficiencyMetrics();

  // Goals & Targets
  Future<double> calculateDailyTarget();
  Future<bool> isDailyTargetMet(DateTime date);
  Future<double> getProgressTowardTarget(DateTime date);

  // Recommendations
  Future<List<String>> getPerformanceRecommendations();
  Future<Map<String, dynamic>> getOptimizationSuggestions();

  // ============================================================================
  // REPORTING OPERATIONS
  // ============================================================================

  // Report Generation
  Future<Map<String, dynamic>> generateDailyReport(DateTime date);
  Future<Map<String, dynamic>> generateWeeklyReport(DateTime startOfWeek);
  Future<Map<String, dynamic>> generateMonthlyReport(DateTime startOfMonth);
  Future<Map<String, dynamic>> generateCustomReport(
    DateTime startDate,
    DateTime endDate,
    List<String> metrics,
  );

  // Data Export
  Future<List<Map<String, dynamic>>> exportRideData({
    DateTime? startDate,
    DateTime? endDate,
    List<String>? fields,
  });

  // ============================================================================
  // ADVANCED BUSINESS LOGIC
  // ============================================================================

  // Performance Analysis
  Future<bool> isPerformingAboveAverage(RideModel ride);
  Future<int> getRideRanking(String rideId);
  Future<List<RideModel>> getSimilarRides(RideModel ride);

  // Prediction & Forecasting
  Future<double> predictNextRideEarnings();
  Future<Map<String, dynamic>> getForecast(int days);

  // Anomaly Detection
  Future<List<RideModel>> detectAnomalousRides();
  Future<bool> isRideAnomalous(RideModel ride);
}
