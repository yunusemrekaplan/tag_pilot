import '../../data/models/dashboard_stats_model.dart';

/// Dashboard Repository Interface
/// SOLID: Dependency Inversion - High-level modules buna bağımlı, implementation'a değil
/// SOLID: Interface Segregation - Sadece dashboard operasyonları
abstract class DashboardRepository {
  // Statistics Operations
  Future<DashboardStatsModel> getDashboardStats();
  Stream<DashboardStatsModel> watchDashboardStats();
  Future<void> updateDashboardStats(DashboardStatsModel stats);

  // Real-time calculations (Business Logic in Domain)
  Future<DashboardStatsModel> calculateRealTimeStats();
  Future<double> calculateTodayEarnings();
  Future<double> calculateWeeklyEarnings();
  Future<double> calculateMonthlyEarnings();
  Future<int> calculateTodayRides();
  Future<int> calculateWeeklyRides();
  Future<int> calculateMonthlyRides();
  Future<double> calculateTodayExpenses();
  Future<double> calculateWeeklyExpenses();
  Future<double> calculateMonthlyExpenses();

  // Cache Management
  Future<void> refreshDashboardCache();
  Future<bool> isDashboardCacheValid();

  // Background Updates
  Future<void> initializeDashboardStats();
  Future<void> updateStatsAfterRide(String rideId);
  Future<void> updateStatsAfterExpense(String expenseId);
}
