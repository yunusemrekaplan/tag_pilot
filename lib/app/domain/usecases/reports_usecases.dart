import '../repositories/reports_repository.dart';

/// Base Use Case
abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}

/// Reports Parameters
class ReportsParams {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? reportType; // 'daily', 'weekly', 'monthly', 'custom'
  final List<String>? metrics; // ['earnings', 'profit', 'distance', 'expenses']
  final String? userId;

  const ReportsParams({
    this.startDate,
    this.endDate,
    this.reportType,
    this.metrics,
    this.userId,
  });
}

// ============================================================================
// BASIC REPORTS USE CASES
// ============================================================================

/// Günlük rapor oluştur Use Case
class GenerateDailyReportUseCase implements UseCase<Map<String, dynamic>, ReportsParams> {
  final ReportsRepository repository;

  GenerateDailyReportUseCase(this.repository);

  @override
  Future<Map<String, dynamic>> call(ReportsParams params) async {
    if (params.startDate == null) {
      throw ArgumentError('Start date gerekli');
    }
    return await repository.generateDailyReport(params.startDate!);
  }
}

/// Haftalık rapor oluştur Use Case
class GenerateWeeklyReportUseCase implements UseCase<Map<String, dynamic>, ReportsParams> {
  final ReportsRepository repository;

  GenerateWeeklyReportUseCase(this.repository);

  @override
  Future<Map<String, dynamic>> call(ReportsParams params) async {
    if (params.startDate == null) {
      throw ArgumentError('Start date gerekli');
    }
    return await repository.generateWeeklyReport(params.startDate!);
  }
}

/// Aylık rapor oluştur Use Case
class GenerateMonthlyReportUseCase implements UseCase<Map<String, dynamic>, ReportsParams> {
  final ReportsRepository repository;

  GenerateMonthlyReportUseCase(this.repository);

  @override
  Future<Map<String, dynamic>> call(ReportsParams params) async {
    if (params.startDate == null) {
      throw ArgumentError('Start date gerekli');
    }
    return await repository.generateMonthlyReport(params.startDate!);
  }
}

/// Özel rapor oluştur Use Case
class GenerateCustomReportUseCase implements UseCase<Map<String, dynamic>, ReportsParams> {
  final ReportsRepository repository;

  GenerateCustomReportUseCase(this.repository);

  @override
  Future<Map<String, dynamic>> call(ReportsParams params) async {
    if (params.startDate == null || params.endDate == null) {
      throw ArgumentError('Start date ve end date gerekli');
    }
    return await repository.generateCustomReport(
      startDate: params.startDate!,
      endDate: params.endDate!,
    );
  }
}

// ============================================================================
// ANALYTICS USE CASES
// ============================================================================

/// Kazanç trend analizi Use Case
class GetEarningsTrendUseCase implements UseCase<List<Map<String, dynamic>>, ReportsParams> {
  final ReportsRepository repository;

  GetEarningsTrendUseCase(this.repository);

  @override
  Future<List<Map<String, dynamic>>> call(ReportsParams params) async {
    final days = _calculateDays(params.startDate, params.endDate);
    return await repository.getEarningsTrend(days);
  }

  int _calculateDays(DateTime? start, DateTime? end) {
    if (start == null || end == null) return 7;
    return end.difference(start).inDays + 1;
  }
}

/// Kâr trend analizi Use Case
class GetProfitTrendUseCase implements UseCase<List<Map<String, dynamic>>, ReportsParams> {
  final ReportsRepository repository;

  GetProfitTrendUseCase(this.repository);

  @override
  Future<List<Map<String, dynamic>>> call(ReportsParams params) async {
    final days = _calculateDays(params.startDate, params.endDate);
    return await repository.getProfitTrend(days);
  }

  int _calculateDays(DateTime? start, DateTime? end) {
    if (start == null || end == null) return 7;
    return end.difference(start).inDays + 1;
  }
}

/// Mesafe trend analizi Use Case
class GetDistanceTrendUseCase implements UseCase<List<Map<String, dynamic>>, ReportsParams> {
  final ReportsRepository repository;

  GetDistanceTrendUseCase(this.repository);

  @override
  Future<List<Map<String, dynamic>>> call(ReportsParams params) async {
    final days = _calculateDays(params.startDate, params.endDate);
    return await repository.getDistanceTrend(days);
  }

  int _calculateDays(DateTime? start, DateTime? end) {
    if (start == null || end == null) return 7;
    return end.difference(start).inDays + 1;
  }
}

/// Harcama kategorileri analizi Use Case
class GetExpenseCategoryAnalysisUseCase implements UseCase<Map<String, dynamic>, ReportsParams> {
  final ReportsRepository repository;

  GetExpenseCategoryAnalysisUseCase(this.repository);

  @override
  Future<Map<String, dynamic>> call(ReportsParams params) async {
    if (params.startDate == null || params.endDate == null) {
      throw ArgumentError('Start date ve end date gerekli');
    }
    return await repository.getExpenseCategoryAnalysis(params.startDate!, params.endDate!);
  }
}

// ============================================================================
// COMPARISON USE CASES
// ============================================================================

/// Dönem karşılaştırma Use Case
class ComparePeriodsUseCase implements UseCase<Map<String, dynamic>, ReportsParams> {
  final ReportsRepository repository;

  ComparePeriodsUseCase(this.repository);

  @override
  Future<Map<String, dynamic>> call(ReportsParams params) async {
    if (params.startDate == null || params.endDate == null) {
      throw ArgumentError('Start date ve end date gerekli');
    }
    return await repository.comparePeriods(params.startDate!, params.endDate!);
  }
}

/// Performans karşılaştırma Use Case
class ComparePerformanceUseCase implements UseCase<Map<String, dynamic>, ReportsParams> {
  final ReportsRepository repository;

  ComparePerformanceUseCase(this.repository);

  @override
  Future<Map<String, dynamic>> call(ReportsParams params) async {
    return await repository.comparePerformance();
  }
}

// ============================================================================
// INSIGHTS USE CASES
// ============================================================================

/// Performans önerileri Use Case
class GetPerformanceInsightsUseCase implements UseCase<List<String>, ReportsParams> {
  final ReportsRepository repository;

  GetPerformanceInsightsUseCase(this.repository);

  @override
  Future<List<String>> call(ReportsParams params) async {
    return await repository.getPerformanceInsights();
  }
}

/// Optimizasyon önerileri Use Case
class GetOptimizationSuggestionsUseCase implements UseCase<Map<String, dynamic>, ReportsParams> {
  final ReportsRepository repository;

  GetOptimizationSuggestionsUseCase(this.repository);

  @override
  Future<Map<String, dynamic>> call(ReportsParams params) async {
    return await repository.getOptimizationSuggestions();
  }
}

/// Hedef analizi Use Case
class GetGoalAnalysisUseCase implements UseCase<Map<String, dynamic>, ReportsParams> {
  final ReportsRepository repository;

  GetGoalAnalysisUseCase(this.repository);

  @override
  Future<Map<String, dynamic>> call(ReportsParams params) async {
    return await repository.getGoalAnalysis();
  }
}
