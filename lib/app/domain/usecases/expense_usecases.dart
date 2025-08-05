import 'package:get/get.dart';

import '../repositories/expense_repository.dart';
import '../../data/models/expense_model.dart';
import '../../data/enums/expense_enums.dart';

/// Expense Use Cases
/// SOLID: Single Responsibility - Sadece expense business logic
class ExpenseUseCases {
  final ExpenseRepository _expenseRepository = Get.find<ExpenseRepository>();

  // =====================================================
  // SEANS GİDERLERİ
  // =====================================================

  /// Seans gideri ekle
  /// Validasyonlar:
  /// - SessionId geçerli olmalı
  /// - Amount pozitif olmalı
  /// - Category geçerli olmalı
  Future<void> addSessionExpense({
    required String sessionId,
    required ExpenseCategory category,
    required double amount,
    String? description,
  }) async {
    // Input validation
    if (sessionId.isEmpty) {
      throw ArgumentError('Session ID cannot be empty');
    }

    if (amount <= 0) {
      throw ArgumentError('Amount must be positive');
    }

    await _expenseRepository.addSessionExpense(
      sessionId: sessionId,
      category: category,
      amount: amount,
      description: description,
    );
  }

  /// Belirli seans için toplam giderleri getir
  Future<double> getSessionTotalExpenses(String sessionId) async {
    if (sessionId.isEmpty) {
      throw ArgumentError('Session ID cannot be empty');
    }

    return await _expenseRepository.getSessionTotalExpenses(sessionId);
  }

  /// Belirli seans için gider listesi getir
  Future<List<ExpenseModel>> getSessionExpenses(String sessionId) async {
    if (sessionId.isEmpty) {
      throw ArgumentError('Session ID cannot be empty');
    }

    return await _expenseRepository.getSessionExpenses(sessionId);
  }

  // =====================================================
  // GENEL GİDERLER
  // =====================================================

  /// Genel gider ekle (tek seferlik veya periyodik)
  /// Validasyonlar:
  /// - Amount pozitif olmalı
  /// - Category geçerli olmalı
  /// - Recurrence bilgisi tutarlı olmalı
  Future<void> addGeneralExpense({
    required ExpenseCategory category,
    required double amount,
    RecurrenceInfo? recurrence,
    String? description,
  }) async {
    // Input validation
    if (amount <= 0) {
      throw ArgumentError('Amount must be positive');
    }

    // Recurrence validation
    if (recurrence != null) {
      if (recurrence.type != RecurrenceType.none) {
        if (recurrence.startDate
            .isAfter(DateTime.now().add(Duration(days: 1)))) {
          throw ArgumentError(
              'Start date cannot be in the future (more than 1 day)');
        }

        if (recurrence.endDate != null &&
            recurrence.endDate!.isBefore(recurrence.startDate)) {
          throw ArgumentError('End date cannot be before start date');
        }

        if (recurrence.durationCount != null &&
            recurrence.durationCount! <= 0) {
          throw ArgumentError('Duration count must be positive');
        }
      }
    }

    await _expenseRepository.addGeneralExpense(
      category: category,
      amount: amount,
      recurrence: recurrence,
      description: description,
    );
  }

  /// Periyodik giderleri getir
  Future<List<ExpenseModel>> getRecurringExpenses(String userId) async {
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }

    return await _expenseRepository.getRecurringExpenses(userId);
  }

  // =====================================================
  // GENEL OPERASYONLAR
  // =====================================================

  /// User'ın tüm giderlerini getir
  Future<List<ExpenseModel>> getUserExpenses(String userId) async {
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }

    return await _expenseRepository.getUserExpenses(userId);
  }

  /// Tarih aralığındaki giderleri getir
  Future<List<ExpenseModel>> getExpensesInRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // Input validation
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }

    if (endDate.isBefore(startDate)) {
      throw ArgumentError('End date cannot be before start date');
    }

    return await _expenseRepository.getExpensesInRange(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Tarih aralığındaki toplam gider miktarını hesapla
  /// (Recurrence paylarını da dahil eder)
  Future<double> getTotalExpensesInRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    ExpenseType? type,
  }) async {
    // Input validation
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }

    if (endDate.isBefore(startDate)) {
      throw ArgumentError('End date cannot be before start date');
    }

    return await _expenseRepository.getTotalExpensesInRange(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
      type: type,
    );
  }

  /// Kategori bazında giderleri getir
  Future<List<ExpenseModel>> getExpensesByCategory({
    required String userId,
    required ExpenseCategory category,
  }) async {
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }

    return await _expenseRepository.getExpensesByCategory(
      userId: userId,
      category: category,
    );
  }

  /// Tip bazında giderleri getir (session/general)
  Future<List<ExpenseModel>> getExpensesByType({
    required String userId,
    required ExpenseType type,
  }) async {
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }

    return await _expenseRepository.getExpensesByType(
      userId: userId,
      type: type,
    );
  }

  /// Gider güncelle
  Future<void> updateExpense(ExpenseModel expense) async {
    // Business rule: Seans gideri sadece aynı seans içinde güncellenebilir
    if (expense.type == ExpenseType.session && expense.sessionId == null) {
      throw ArgumentError('Session expense must have a session ID');
    }

    // Amount validation
    if (expense.amount <= 0) {
      throw ArgumentError('Amount must be positive');
    }

    await _expenseRepository.updateExpense(expense);
  }

  /// Gider sil
  Future<void> deleteExpense(String expenseId) async {
    if (expenseId.isEmpty) {
      throw ArgumentError('Expense ID cannot be empty');
    }

    await _expenseRepository.deleteExpense(expenseId);
  }

  // =====================================================
  // İSTATİSTİK ve ANALİTİK METODLAR
  // =====================================================

  /// Aylık gider analizi
  Future<Map<ExpenseCategory, double>> getMonthlyExpensesByCategory({
    required String userId,
    required DateTime month,
  }) async {
    final startDate = DateTime(month.year, month.month, 1);
    final endDate = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    final expenses = await getExpensesInRange(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );

    final Map<ExpenseCategory, double> categoryTotals = {};

    for (final expense in expenses) {
      final amount = expense.getAmountForDateRange(
        rangeStart: startDate,
        rangeEnd: endDate,
      );

      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0.0) + amount;
    }

    return categoryTotals;
  }

  /// Haftalık gider trendi
  Future<List<double>> getWeeklyExpenseTrend({
    required String userId,
    required int weekCount,
  }) async {
    final List<double> weeklyTotals = [];
    final now = DateTime.now();

    for (int i = weekCount - 1; i >= 0; i--) {
      final weekStart = now.subtract(Duration(days: (i * 7) + now.weekday - 1));
      final weekEnd = weekStart
          .add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

      final weekTotal = await getTotalExpensesInRange(
        userId: userId,
        startDate: weekStart,
        endDate: weekEnd,
      );

      weeklyTotals.add(weekTotal);
    }

    return weeklyTotals;
  }

  /// En fazla harcanan kategoriler (top 5)
  Future<List<MapEntry<ExpenseCategory, double>>> getTopExpenseCategories({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    int limit = 5,
  }) async {
    final categoryTotals = <ExpenseCategory, double>{};
    final expenses = await getExpensesInRange(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );

    for (final expense in expenses) {
      final amount = expense.getAmountForDateRange(
        rangeStart: startDate,
        rangeEnd: endDate,
      );

      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0.0) + amount;
    }

    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedEntries.take(limit).toList();
  }

  /// Günlük ortalama gider hesapla
  Future<double> getDailyAverageExpense({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final total = await getTotalExpensesInRange(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );

    final dayCount = endDate.difference(startDate).inDays + 1;
    return dayCount > 0 ? total / dayCount : 0.0;
  }
}
