import '../../data/models/dashboard_stats_model.dart';
import '../repositories/dashboard_repository.dart';

/// Base Use Case
/// SOLID: Single Responsibility - Sadece bir işlevi yerine getirir
abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}

/// Parameters için base class
class DashboardParams {
  final String? userId; // Optional for backward compatibility
  final DashboardStatsModel? stats;
  final String? rideId;
  final String? expenseId;

  const DashboardParams({
    this.userId,
    this.stats,
    this.rideId,
    this.expenseId,
  });
}

// ============================================================================
// DASHBOARD STATISTICS USE CASES
// ============================================================================

/// Dashboard istatistiklerini getir Use Case
/// SOLID: Single Responsibility - Sadece dashboard stats alma business logic'i
class GetDashboardStatsUseCase
    implements UseCase<DashboardStatsModel, DashboardParams> {
  final DashboardRepository repository;

  GetDashboardStatsUseCase(this.repository);

  @override
  Future<DashboardStatsModel> call(DashboardParams params) async {
    try {
      return await repository.getDashboardStats();
    } catch (e) {
      // Eğer cache'de veri yoksa, real-time hesapla
      return await repository.calculateRealTimeStats();
    }
  }
}

/// Dashboard istatistiklerini izle Use Case
class WatchDashboardStatsUseCase
    implements UseCase<Stream<DashboardStatsModel>, DashboardParams> {
  final DashboardRepository repository;

  WatchDashboardStatsUseCase(this.repository);

  @override
  Future<Stream<DashboardStatsModel>> call(DashboardParams params) async {
    return repository.watchDashboardStats();
  }
}

/// Dashboard istatistiklerini güncelle Use Case
class UpdateDashboardStatsUseCase implements UseCase<void, DashboardParams> {
  final DashboardRepository repository;

  UpdateDashboardStatsUseCase(this.repository);

  @override
  Future<void> call(DashboardParams params) async {
    if (params.stats == null) {
      throw ArgumentError('Dashboard stats gerekli');
    }
    await repository.updateDashboardStats(params.stats!);
  }
}

/// Real-time dashboard istatistiklerini hesapla Use Case
class CalculateRealTimeStatsUseCase
    implements UseCase<DashboardStatsModel, DashboardParams> {
  final DashboardRepository repository;

  CalculateRealTimeStatsUseCase(this.repository);

  @override
  Future<DashboardStatsModel> call(DashboardParams params) async {
    return await repository.calculateRealTimeStats();
  }
}

// ============================================================================
// SPECIFIC CALCULATION USE CASES
// ============================================================================

/// Bugünkü kazancı hesapla Use Case
class CalculateTodayEarningsUseCase
    implements UseCase<double, DashboardParams> {
  final DashboardRepository repository;

  CalculateTodayEarningsUseCase(this.repository);

  @override
  Future<double> call(DashboardParams params) async {
    return await repository.calculateTodayEarnings();
  }
}

/// Haftalık kazancı hesapla Use Case
class CalculateWeeklyEarningsUseCase
    implements UseCase<double, DashboardParams> {
  final DashboardRepository repository;

  CalculateWeeklyEarningsUseCase(this.repository);

  @override
  Future<double> call(DashboardParams params) async {
    return await repository.calculateWeeklyEarnings();
  }
}

/// Aylık kazancı hesapla Use Case
class CalculateMonthlyEarningsUseCase
    implements UseCase<double, DashboardParams> {
  final DashboardRepository repository;

  CalculateMonthlyEarningsUseCase(this.repository);

  @override
  Future<double> call(DashboardParams params) async {
    return await repository.calculateMonthlyEarnings();
  }
}

/// Bugünkü sefer sayısını hesapla Use Case
class CalculateTodayRidesUseCase implements UseCase<int, DashboardParams> {
  final DashboardRepository repository;

  CalculateTodayRidesUseCase(this.repository);

  @override
  Future<int> call(DashboardParams params) async {
    return await repository.calculateTodayRides();
  }
}

/// Haftalık sefer sayısını hesapla Use Case
class CalculateWeeklyRidesUseCase implements UseCase<int, DashboardParams> {
  final DashboardRepository repository;

  CalculateWeeklyRidesUseCase(this.repository);

  @override
  Future<int> call(DashboardParams params) async {
    return await repository.calculateWeeklyRides();
  }
}

/// Aylık sefer sayısını hesapla Use Case
class CalculateMonthlyRidesUseCase implements UseCase<int, DashboardParams> {
  final DashboardRepository repository;

  CalculateMonthlyRidesUseCase(this.repository);

  @override
  Future<int> call(DashboardParams params) async {
    return await repository.calculateMonthlyRides();
  }
}

/// Bugünkü giderleri hesapla Use Case
class CalculateTodayExpensesUseCase
    implements UseCase<double, DashboardParams> {
  final DashboardRepository repository;

  CalculateTodayExpensesUseCase(this.repository);

  @override
  Future<double> call(DashboardParams params) async {
    return await repository.calculateTodayExpenses();
  }
}

/// Haftalık giderleri hesapla Use Case
class CalculateWeeklyExpensesUseCase
    implements UseCase<double, DashboardParams> {
  final DashboardRepository repository;

  CalculateWeeklyExpensesUseCase(this.repository);

  @override
  Future<double> call(DashboardParams params) async {
    return await repository.calculateWeeklyExpenses();
  }
}

/// Aylık giderleri hesapla Use Case
class CalculateMonthlyExpensesUseCase
    implements UseCase<double, DashboardParams> {
  final DashboardRepository repository;

  CalculateMonthlyExpensesUseCase(this.repository);

  @override
  Future<double> call(DashboardParams params) async {
    return await repository.calculateMonthlyExpenses();
  }
}

// ============================================================================
// CACHE MANAGEMENT USE CASES
// ============================================================================

/// Dashboard cache'ini yenile Use Case
class RefreshDashboardCacheUseCase implements UseCase<void, DashboardParams> {
  final DashboardRepository repository;

  RefreshDashboardCacheUseCase(this.repository);

  @override
  Future<void> call(DashboardParams params) async {
    await repository.refreshDashboardCache();
  }
}

/// Dashboard cache validliğini kontrol et Use Case
class IsDashboardCacheValidUseCase implements UseCase<bool, DashboardParams> {
  final DashboardRepository repository;

  IsDashboardCacheValidUseCase(this.repository);

  @override
  Future<bool> call(DashboardParams params) async {
    return await repository.isDashboardCacheValid();
  }
}

// ============================================================================
// BACKGROUND UPDATE USE CASES
// ============================================================================

/// Dashboard istatistiklerini initialize et Use Case
class InitializeDashboardStatsUseCase
    implements UseCase<void, DashboardParams> {
  final DashboardRepository repository;

  InitializeDashboardStatsUseCase(this.repository);

  @override
  Future<void> call(DashboardParams params) async {
    await repository.initializeDashboardStats();
  }
}

/// Sefer sonrası dashboard güncelle Use Case
class UpdateStatsAfterRideUseCase implements UseCase<void, DashboardParams> {
  final DashboardRepository repository;

  UpdateStatsAfterRideUseCase(this.repository);

  @override
  Future<void> call(DashboardParams params) async {
    if (params.rideId == null) {
      throw ArgumentError('Ride ID gerekli');
    }
    await repository.updateStatsAfterRide(params.rideId!);
  }
}

/// Gider sonrası dashboard güncelle Use Case
class UpdateStatsAfterExpenseUseCase implements UseCase<void, DashboardParams> {
  final DashboardRepository repository;

  UpdateStatsAfterExpenseUseCase(this.repository);

  @override
  Future<void> call(DashboardParams params) async {
    if (params.expenseId == null) {
      throw ArgumentError('Expense ID gerekli');
    }
    await repository.updateStatsAfterExpense(params.expenseId!);
  }
}
