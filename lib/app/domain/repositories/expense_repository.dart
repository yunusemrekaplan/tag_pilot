import '../../data/models/expense_model.dart';
import '../../data/enums/expense_enums.dart';

/// Expense Repository Interface
/// SOLID: Dependency Inversion - Abstract repository interface
abstract class ExpenseRepository {
  /// Seans gideri ekle
  Future<void> addSessionExpense({
    required String sessionId,
    required ExpenseCategory category,
    required double amount,
    String? description,
  });

  /// Genel gider ekle
  Future<void> addGeneralExpense({
    required ExpenseCategory category,
    required double amount,
    RecurrenceInfo? recurrence,
    String? description,
  });

  /// Belirli bir seans için tüm giderleri getir
  Future<List<ExpenseModel>> getSessionExpenses(String sessionId);

  /// User'ın tüm giderlerini getir
  Future<List<ExpenseModel>> getUserExpenses(String userId);

  /// Tarih aralığındaki giderleri getir (hem session hem general)
  Future<List<ExpenseModel>> getExpensesInRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Tarih aralığındaki giderleri getir (current user için)
  Future<List<ExpenseModel>> getExpensesByDateRange(DateTime startDate, DateTime endDate);

  /// Belirli kategorideki giderleri getir
  Future<List<ExpenseModel>> getExpensesByCategory({
    required String userId,
    required ExpenseCategory category,
  });

  /// Belirli tipte giderleri getir (session/general)
  Future<List<ExpenseModel>> getExpensesByType({
    required String userId,
    required ExpenseType type,
  });

  /// Gider güncelle
  Future<void> updateExpense(ExpenseModel expense);

  /// Gider sil
  Future<void> deleteExpense(String expenseId);

  /// Belirli tarih aralığındaki toplam gider miktarını hesapla
  /// (Recurrence paylarını da dahil eder)
  Future<double> getTotalExpensesInRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    ExpenseType? type, // Opsiyonel: sadece belirli tip
  });

  /// Seans için toplam giderleri hesapla
  Future<double> getSessionTotalExpenses(String sessionId);

  /// Periyodik giderleri getir
  Future<List<ExpenseModel>> getRecurringExpenses(String userId);
}
