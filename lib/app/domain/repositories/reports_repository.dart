/// Reports Repository Interface
/// SOLID: Dependency Inversion - High-level modules buna bağımlı, implementation'a değil
/// SOLID: Interface Segregation - Sadece reports operasyonları
abstract class ReportsRepository {
  // ============================================================================
  // BASIC REPORT GENERATION
  // ============================================================================

  /// Günlük rapor oluştur
  Future<Map<String, dynamic>> generateDailyReport(DateTime date);

  /// Haftalık rapor oluştur
  Future<Map<String, dynamic>> generateWeeklyReport(DateTime startOfWeek);

  /// Aylık rapor oluştur
  Future<Map<String, dynamic>> generateMonthlyReport(DateTime startOfMonth);

  /// Özel rapor oluştur
  Future<Map<String, dynamic>> generateCustomReport({
    required DateTime startDate,
    required DateTime endDate,
  });

  // ============================================================================
  // TREND ANALYSIS
  // ============================================================================

  /// Kazanç trend analizi
  Future<List<Map<String, dynamic>>> getEarningsTrend(int days);

  /// Kâr trend analizi
  Future<List<Map<String, dynamic>>> getProfitTrend(int days);

  /// Mesafe trend analizi
  Future<List<Map<String, dynamic>>> getDistanceTrend(int days);

  /// Harcama trend analizi
  Future<List<Map<String, dynamic>>> getExpenseTrend(int days);

  // ============================================================================
  // CATEGORY ANALYSIS
  // ============================================================================

  /// Harcama kategorileri analizi
  Future<Map<String, dynamic>> getExpenseCategoryAnalysis(DateTime startDate, DateTime endDate);

  /// Kazanç kategorileri analizi (paket bazlı)
  Future<Map<String, dynamic>> getEarningsCategoryAnalysis(DateTime startDate, DateTime endDate);

  /// Performans kategorileri analizi
  Future<Map<String, dynamic>> getPerformanceCategoryAnalysis(DateTime startDate, DateTime endDate);

  // ============================================================================
  // COMPARISON ANALYSIS
  // ============================================================================

  /// Dönem karşılaştırma
  Future<Map<String, dynamic>> comparePeriods(DateTime startDate, DateTime endDate);

  /// Performans karşılaştırma (haftalık/aylık)
  Future<Map<String, dynamic>> comparePerformance();

  /// Hedef vs gerçekleşen karşılaştırma
  Future<Map<String, dynamic>> compareTargets(DateTime startDate, DateTime endDate);

  // ============================================================================
  // INSIGHTS & RECOMMENDATIONS
  // ============================================================================

  /// Performans önerileri
  Future<List<String>> getPerformanceInsights();

  /// Optimizasyon önerileri
  Future<Map<String, dynamic>> getOptimizationSuggestions();

  /// Hedef analizi
  Future<Map<String, dynamic>> getGoalAnalysis();

  /// Kârlılık analizi
  Future<Map<String, dynamic>> getProfitabilityAnalysis();

  // ============================================================================
  // ADVANCED METRICS
  // ============================================================================

  /// Verimlilik metrikleri
  Future<Map<String, dynamic>> getEfficiencyMetrics(DateTime startDate, DateTime endDate);

  /// Risk analizi
  Future<Map<String, dynamic>> getRiskAnalysis(DateTime startDate, DateTime endDate);

  /// Tahmin analizi
  Future<Map<String, dynamic>> getForecastAnalysis(int days);

  // ============================================================================
  // EXPORT & SHARING
  // ============================================================================

  /// PDF rapor oluştur
  Future<String> generatePdfReport(Map<String, dynamic> reportData);

  /// Excel rapor oluştur
  Future<String> generateExcelReport(Map<String, dynamic> reportData);

  /// Rapor paylaş
  Future<bool> shareReport(String reportPath, String shareType);
}
