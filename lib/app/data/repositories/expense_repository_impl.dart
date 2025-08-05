import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:tag_pilot/app/domain/services/auth_service.dart';

import '../../core/utils/app_constants.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../domain/services/database_service.dart';
import '../../domain/services/error_handler_service.dart';
import '../models/expense_model.dart';
import '../enums/expense_enums.dart';

/// Expense Repository Implementation
/// SOLID: Single Responsibility - Sadece expense data operations
class ExpenseRepositoryImpl implements ExpenseRepository {
  late final DatabaseService _databaseService;
  late final AuthService _authService;
  late final ErrorHandlerService _errorHandler;

  ExpenseRepositoryImpl() {
    _databaseService = Get.find<DatabaseService>();
    _authService = Get.find<AuthService>();
    _errorHandler = Get.find<ErrorHandlerService>();
  }

  // Middleware kontrolü yaptığı için ! operatörü güvenli
  String get _currentUserId => _authService.currentUser!.uid;

  CollectionReference get _expensesCollection => _databaseService
      .getCollection('${DatabaseConstants.usersCollection}/$_currentUserId/${DatabaseConstants.expensesCollection}');

  @override
  Future<void> addSessionExpense({
    required String sessionId,
    required ExpenseCategory category,
    required double amount,
    String? description,
  }) async {
    try {
      final docRef = _expensesCollection.doc();
      final expense = ExpenseModel(
        id: docRef.id,
        userId: _currentUserId,
        type: ExpenseType.session,
        category: category,
        amount: amount,
        createdAt: DateTime.now(),
        sessionId: sessionId,
        description: description,
      );

      await docRef.set(expense.toJson());
    } catch (e) {
      _errorHandler.logError('Failed to add session expense', e);
      throw Exception('Failed to add session expense: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  @override
  Future<void> addGeneralExpense({
    required ExpenseCategory category,
    required double amount,
    RecurrenceInfo? recurrence,
    String? description,
  }) async {
    try {
      final docRef = _expensesCollection.doc();
      final expense = ExpenseModel(
        id: docRef.id,
        userId: _currentUserId,
        type: ExpenseType.general,
        category: category,
        amount: amount,
        createdAt: DateTime.now(),
        recurrence: recurrence,
        description: description,
      );

      await docRef.set(expense.toJson());
    } catch (e) {
      _errorHandler.logError('Failed to add general expense', e);
      throw Exception('Failed to add general expense: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  @override
  Future<List<ExpenseModel>> getSessionExpenses(String sessionId) async {
    try {
      final querySnapshot = await _expensesCollection
          .where('userId', isEqualTo: _currentUserId)
          .where('sessionId', isEqualTo: sessionId)
          .where('type', isEqualTo: ExpenseType.session.name)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ExpenseModel.fromJson({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              }))
          .toList();
    } catch (e) {
      _errorHandler.logError('Failed to get session expenses', e);
      throw Exception('Failed to get session expenses: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  @override
  Future<List<ExpenseModel>> getUserExpenses(String userId) async {
    try {
      final querySnapshot =
          await _expensesCollection.where('userId', isEqualTo: userId).orderBy('createdAt', descending: true).get();

      return querySnapshot.docs
          .map((doc) => ExpenseModel.fromJson({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              }))
          .toList();
    } catch (e) {
      _errorHandler.logError('Failed to get user expenses', e);
      throw Exception('Failed to get user expenses: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  @override
  Future<List<ExpenseModel>> getExpensesInRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final querySnapshot = await _expensesCollection
          .where('userId', isEqualTo: userId)
          .where('createdAt', isGreaterThanOrEqualTo: startDate.toIso8601String())
          .where('createdAt', isLessThanOrEqualTo: endDate.toIso8601String())
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ExpenseModel.fromJson({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              }))
          .toList();
    } catch (e) {
      _errorHandler.logError('Failed to get expenses in range', e);
      throw Exception('Failed to get expenses in range: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  @override
  Future<List<ExpenseModel>> getExpensesByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final querySnapshot = await _expensesCollection
          .where('userId', isEqualTo: _currentUserId)
          .where('createdAt', isGreaterThanOrEqualTo: startDate.toIso8601String())
          .where('createdAt', isLessThanOrEqualTo: endDate.toIso8601String())
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ExpenseModel.fromJson({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              }))
          .toList();
    } catch (e) {
      _errorHandler.logError('Failed to get expenses by date range', e);
      throw Exception('Failed to get expenses by date range: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  @override
  Future<List<ExpenseModel>> getExpensesByCategory({
    required String userId,
    required ExpenseCategory category,
  }) async {
    try {
      final querySnapshot = await _expensesCollection
          .where('userId', isEqualTo: userId)
          .where('category', isEqualTo: category.name)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ExpenseModel.fromJson({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              }))
          .toList();
    } catch (e) {
      _errorHandler.logError('Failed to get expenses by category', e);
      throw Exception('Failed to get expenses by category: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  @override
  Future<List<ExpenseModel>> getExpensesByType({
    required String userId,
    required ExpenseType type,
  }) async {
    try {
      final querySnapshot = await _expensesCollection
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: type.name)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ExpenseModel.fromJson({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              }))
          .toList();
    } catch (e) {
      _errorHandler.logError('Failed to get expenses by type', e);
      throw Exception('Failed to get expenses by type: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  @override
  Future<void> updateExpense(ExpenseModel expense) async {
    try {
      final updatedExpense = expense.copyWith(updatedAt: DateTime.now());
      await _expensesCollection.doc(expense.id).update(updatedExpense.toJson());
    } catch (e) {
      _errorHandler.logError('Failed to update expense', e);
      throw Exception('Failed to update expense: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    try {
      await _expensesCollection.doc(expenseId).delete();
    } catch (e) {
      _errorHandler.logError('Failed to delete expense', e);
      throw Exception('Failed to delete expense: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  @override
  Future<double> getTotalExpensesInRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    ExpenseType? type,
  }) async {
    try {
      // Tüm user'ın giderlerini al (recurrence hesaplamaları için)
      final allExpenses = await getUserExpenses(userId);

      // Filter by type if specified
      final filteredExpenses = type != null ? allExpenses.where((e) => e.type == type).toList() : allExpenses;

      double total = 0.0;

      for (final expense in filteredExpenses) {
        total += expense.getAmountForDateRange(
          rangeStart: startDate,
          rangeEnd: endDate,
        );
      }

      return total;
    } catch (e) {
      _errorHandler.logError('Failed to calculate total expenses in range', e);
      throw Exception('Failed to calculate total expenses in range: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  @override
  Future<double> getSessionTotalExpenses(String sessionId) async {
    try {
      final sessionExpenses = await getSessionExpenses(sessionId);
      return sessionExpenses.fold<double>(0.0, (sum, expense) => sum + expense.amount);
    } catch (e) {
      _errorHandler.logError('Failed to calculate session total expenses', e);
      throw Exception('Failed to calculate session total expenses: ${_errorHandler.getErrorMessage(e)}');
    }
  }

  @override
  Future<List<ExpenseModel>> getRecurringExpenses(String userId) async {
    try {
      final querySnapshot = await _expensesCollection
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: ExpenseType.general.name)
          .orderBy('createdAt', descending: true)
          .get();

      final allGeneralExpenses = querySnapshot.docs
          .map((doc) => ExpenseModel.fromJson({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              }))
          .toList();

      // Filter recurring expenses
      return allGeneralExpenses.where((expense) => expense.isRecurring).toList();
    } catch (e) {
      _errorHandler.logError('Failed to get recurring expenses', e);
      throw Exception('Failed to get recurring expenses: ${_errorHandler.getErrorMessage(e)}');
    }
  }
}
