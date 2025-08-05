import '../../data/models/ride_model.dart';
import '../repositories/ride_repository.dart';

// Base Use Case Interface (Clean Architecture)
abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}

// Ride Use Case Parameters
class RideParams {
  final String? rideId;
  final String? sessionId;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? date;
  final String? query;
  final int? limit;
  final String? orderBy;
  final bool? isProfitable;
  final double? minDistance;
  final double? maxDistance;
  final double? minEarnings;
  final double? maxEarnings;
  final double? minProfit;
  final double? maxProfit;
  final Map<String, dynamic>? filters;
  final RideModel? ride;
  final int? days;
  final int? year;

  const RideParams({
    this.rideId,
    this.sessionId,
    this.startDate,
    this.endDate,
    this.date,
    this.query,
    this.limit,
    this.orderBy,
    this.isProfitable,
    this.minDistance,
    this.maxDistance,
    this.minEarnings,
    this.maxEarnings,
    this.minProfit,
    this.maxProfit,
    this.filters,
    this.ride,
    this.days,
    this.year,
  });
}

// ============================================================================
// BASIC RIDE OPERATIONS
// ============================================================================

/// Tüm ride'ları getir Use Case
class GetAllRidesUseCase implements UseCase<List<RideModel>, RideParams> {
  final RideRepository repository;

  GetAllRidesUseCase(this.repository);

  @override
  Future<List<RideModel>> call(RideParams params) async {
    return await repository.getAllRides();
  }
}

/// Tarih aralığına göre ride'ları getir Use Case
class GetRidesByDateRangeUseCase
    implements UseCase<List<RideModel>, RideParams> {
  final RideRepository repository;

  GetRidesByDateRangeUseCase(this.repository);

  @override
  Future<List<RideModel>> call(RideParams params) async {
    if (params.startDate == null || params.endDate == null) {
      throw ArgumentError('Start date ve end date gerekli');
    }
    return await repository.getRidesByDateRange(
        params.startDate!, params.endDate!);
  }
}

/// Kârlılığa göre ride'ları getir Use Case
class GetRidesByProfitabilityUseCase
    implements UseCase<List<RideModel>, RideParams> {
  final RideRepository repository;

  GetRidesByProfitabilityUseCase(this.repository);

  @override
  Future<List<RideModel>> call(RideParams params) async {
    if (params.isProfitable == null) {
      throw ArgumentError('Profitability flag gerekli');
    }
    return await repository.getRidesByProfitability(params.isProfitable!);
  }
}

/// En iyi ride'ları getir Use Case
class GetTopRidesUseCase implements UseCase<List<RideModel>, RideParams> {
  final RideRepository repository;

  GetTopRidesUseCase(this.repository);

  @override
  Future<List<RideModel>> call(RideParams params) async {
    final limit = params.limit ?? 10;
    final orderBy = params.orderBy ?? 'netProfit';
    return await repository.getTopRides(limit, orderBy: orderBy);
  }
}

// ============================================================================
// SEARCH & FILTER OPERATIONS
// ============================================================================

/// Ride arama Use Case
class SearchRidesUseCase implements UseCase<List<RideModel>, RideParams> {
  final RideRepository repository;

  SearchRidesUseCase(this.repository);

  @override
  Future<List<RideModel>> call(RideParams params) async {
    if (params.query == null || params.query!.isEmpty) {
      throw ArgumentError('Arama sorgusu gerekli');
    }
    return await repository.searchRides(params.query!);
  }
}

/// Ride filtreleme Use Case
class FilterRidesUseCase implements UseCase<List<RideModel>, RideParams> {
  final RideRepository repository;

  FilterRidesUseCase(this.repository);

  @override
  Future<List<RideModel>> call(RideParams params) async {
    return await repository.filterRides(
      minDistance: params.minDistance,
      maxDistance: params.maxDistance,
      minEarnings: params.minEarnings,
      maxEarnings: params.maxEarnings,
      minProfit: params.minProfit,
      maxProfit: params.maxProfit,
      fromDate: params.startDate,
      toDate: params.endDate,
      isProfitable: params.isProfitable,
    );
  }
}

/// Ride'ları izle Use Case
class WatchAllRidesUseCase
    implements UseCase<Stream<List<RideModel>>, RideParams> {
  final RideRepository repository;

  WatchAllRidesUseCase(this.repository);

  @override
  Future<Stream<List<RideModel>>> call(RideParams params) async {
    return repository.watchAllRides();
  }
}

// ============================================================================
// ANALYTICS USE CASES
// ============================================================================

/// Ride analytics getir Use Case
class GetRideAnalyticsUseCase
    implements UseCase<Map<String, dynamic>, RideParams> {
  final RideRepository repository;

  GetRideAnalyticsUseCase(this.repository);

  @override
  Future<Map<String, dynamic>> call(RideParams params) async {
    return await repository.getRideAnalytics();
  }
}

/// Performance metrics getir Use Case
class GetPerformanceMetricsUseCase
    implements UseCase<Map<String, dynamic>, RideParams> {
  final RideRepository repository;

  GetPerformanceMetricsUseCase(this.repository);

  @override
  Future<Map<String, dynamic>> call(RideParams params) async {
    return await repository.getPerformanceMetrics();
  }
}

/// Kârlılık analizi getir Use Case
class GetProfitabilityAnalysisUseCase
    implements UseCase<Map<String, dynamic>, RideParams> {
  final RideRepository repository;

  GetProfitabilityAnalysisUseCase(this.repository);

  @override
  Future<Map<String, dynamic>> call(RideParams params) async {
    return await repository.getProfitabilityAnalysis();
  }
}

/// Günlük ride istatistikleri Use Case
class GetDailyRideStatsUseCase
    implements UseCase<Map<String, dynamic>, RideParams> {
  final RideRepository repository;

  GetDailyRideStatsUseCase(this.repository);

  @override
  Future<Map<String, dynamic>> call(RideParams params) async {
    if (params.date == null) {
      throw ArgumentError('Date gerekli');
    }
    return await repository.getDailyRideStats(params.date!);
  }
}

/// Haftalık ride istatistikleri Use Case
class GetWeeklyRideStatsUseCase
    implements UseCase<Map<String, dynamic>, RideParams> {
  final RideRepository repository;

  GetWeeklyRideStatsUseCase(this.repository);

  @override
  Future<Map<String, dynamic>> call(RideParams params) async {
    if (params.date == null) {
      throw ArgumentError('Start of week date gerekli');
    }
    return await repository.getWeeklyRideStats(params.date!);
  }
}

/// Aylık ride istatistikleri Use Case
class GetMonthlyRideStatsUseCase
    implements UseCase<Map<String, dynamic>, RideParams> {
  final RideRepository repository;

  GetMonthlyRideStatsUseCase(this.repository);

  @override
  Future<Map<String, dynamic>> call(RideParams params) async {
    if (params.date == null) {
      throw ArgumentError('Start of month date gerekli');
    }
    return await repository.getMonthlyRideStats(params.date!);
  }
}

// ============================================================================
// ADVANCED METRICS USE CASES
// ============================================================================

/// Ortalama ride kazancı Use Case
class GetAverageRideEarningsUseCase implements UseCase<double, RideParams> {
  final RideRepository repository;

  GetAverageRideEarningsUseCase(this.repository);

  @override
  Future<double> call(RideParams params) async {
    return await repository.getAverageRideEarnings();
  }
}

/// Ortalama ride mesafesi Use Case
class GetAverageRideDistanceUseCase implements UseCase<double, RideParams> {
  final RideRepository repository;

  GetAverageRideDistanceUseCase(this.repository);

  @override
  Future<double> call(RideParams params) async {
    return await repository.getAverageRideDistance();
  }
}

/// Ortalama ride kârı Use Case
class GetAverageRideProfitUseCase implements UseCase<double, RideParams> {
  final RideRepository repository;

  GetAverageRideProfitUseCase(this.repository);

  @override
  Future<double> call(RideParams params) async {
    return await repository.getAverageRideProfit();
  }
}

/// En iyi performans gösteren ride Use Case
class GetBestPerformingRideUseCase implements UseCase<RideModel?, RideParams> {
  final RideRepository repository;

  GetBestPerformingRideUseCase(this.repository);

  @override
  Future<RideModel?> call(RideParams params) async {
    return await repository.getBestPerformingRide();
  }
}

/// En kötü performans gösteren ride Use Case
class GetWorstPerformingRideUseCase implements UseCase<RideModel?, RideParams> {
  final RideRepository repository;

  GetWorstPerformingRideUseCase(this.repository);

  @override
  Future<RideModel?> call(RideParams params) async {
    return await repository.getWorstPerformingRide();
  }
}

// ============================================================================
// TREND ANALYSIS USE CASES
// ============================================================================

/// Kazanç trend analizi Use Case
class GetEarningsTrendUseCase
    implements UseCase<List<Map<String, dynamic>>, RideParams> {
  final RideRepository repository;

  GetEarningsTrendUseCase(this.repository);

  @override
  Future<List<Map<String, dynamic>>> call(RideParams params) async {
    final days = params.days ?? 7; // Default 7 gün
    return await repository.getEarningsTrend(days);
  }
}

/// Kârlılık trend analizi Use Case
class GetProfitabilityTrendUseCase
    implements UseCase<List<Map<String, dynamic>>, RideParams> {
  final RideRepository repository;

  GetProfitabilityTrendUseCase(this.repository);

  @override
  Future<List<Map<String, dynamic>>> call(RideParams params) async {
    final days = params.days ?? 7; // Default 7 gün
    return await repository.getProfitabilityTrend(days);
  }
}

/// Mesafe trend analizi Use Case
class GetDistanceTrendUseCase
    implements UseCase<List<Map<String, dynamic>>, RideParams> {
  final RideRepository repository;

  GetDistanceTrendUseCase(this.repository);

  @override
  Future<List<Map<String, dynamic>>> call(RideParams params) async {
    final days = params.days ?? 7; // Default 7 gün
    return await repository.getDistanceTrend(days);
  }
}

// ============================================================================
// REPORTING USE CASES
// ============================================================================

/// Günlük rapor Use Case
class GenerateDailyReportUseCase
    implements UseCase<Map<String, dynamic>, RideParams> {
  final RideRepository repository;

  GenerateDailyReportUseCase(this.repository);

  @override
  Future<Map<String, dynamic>> call(RideParams params) async {
    if (params.date == null) {
      throw ArgumentError('Date gerekli');
    }
    return await repository.generateDailyReport(params.date!);
  }
}

/// Haftalık rapor Use Case
class GenerateWeeklyReportUseCase
    implements UseCase<Map<String, dynamic>, RideParams> {
  final RideRepository repository;

  GenerateWeeklyReportUseCase(this.repository);

  @override
  Future<Map<String, dynamic>> call(RideParams params) async {
    if (params.date == null) {
      throw ArgumentError('Start of week date gerekli');
    }
    return await repository.generateWeeklyReport(params.date!);
  }
}

/// Aylık rapor Use Case
class GenerateMonthlyReportUseCase
    implements UseCase<Map<String, dynamic>, RideParams> {
  final RideRepository repository;

  GenerateMonthlyReportUseCase(this.repository);

  @override
  Future<Map<String, dynamic>> call(RideParams params) async {
    if (params.date == null) {
      throw ArgumentError('Start of month date gerekli');
    }
    return await repository.generateMonthlyReport(params.date!);
  }
}
