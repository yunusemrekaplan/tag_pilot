import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../../domain/usecases/expense_usecases.dart';
import '../../../domain/services/auth_service.dart';
import '../../../domain/services/error_handler_service.dart';
import '../../../data/models/expense_model.dart';
import '../../../data/enums/expense_enums.dart';
import '../../../core/controllers/base_controller.dart';
import '../../../core/utils/notification_helper.dart';
import '../../../core/utils/app_constants.dart';
import '../../../domain/usecases/session_usecases.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../../dashboard/controllers/session_service.dart';

/// Expense Controller (Clean Architecture)
/// SOLID: Single Responsibility - Sadece expense UI state management
/// SOLID: Dependency Inversion - Use case'lere bağımlı, implementation'a değil
/// BaseController: Standardized loading states ve execution patterns kullanır
class ExpenseController extends BaseController {
  // Dependencies (injected via GetX)
  late final AuthService _authService;
  late final ErrorHandlerService _errorHandler;
  late final ExpenseUseCases _expenseUseCases;
  late final GetActiveSessionUseCase _getActiveSessionUseCase;
  late final DashboardController _dashboardController;

  @override
  void onInit() {
    super.onInit();
    _authService = Get.find<AuthService>();
    _errorHandler = Get.find<ErrorHandlerService>();
    _expenseUseCases = Get.find<ExpenseUseCases>();
    _getActiveSessionUseCase = Get.find<GetActiveSessionUseCase>();
    _dashboardController = Get.find<DashboardController>();

    // Initial load
    refreshExpenses();
  }

  // =====================================================
  // REACTIVE STATE VARIABLES
  // =====================================================

  /// Tüm kullanıcı giderleri
  final RxList<ExpenseModel> _allExpenses = <ExpenseModel>[].obs;
  List<ExpenseModel> get allExpenses => _allExpenses;

  /// Filtrelenmiş giderler (UI'da görünen)
  final RxList<ExpenseModel> _filteredExpenses = <ExpenseModel>[].obs;
  List<ExpenseModel> get filteredExpenses => _filteredExpenses;

  /// Seçili tarih aralığı
  final Rx<DateTimeRange?> _selectedDateRange = Rx<DateTimeRange?>(null);
  DateTimeRange? get selectedDateRange => _selectedDateRange.value;

  /// Seçili kategori filtresi
  final Rx<ExpenseCategory?> _selectedCategory = Rx<ExpenseCategory?>(null);
  ExpenseCategory? get selectedCategory => _selectedCategory.value;

  /// Seçili tip filtresi
  final Rx<ExpenseType?> _selectedType = Rx<ExpenseType?>(null);
  ExpenseType? get selectedType => _selectedType.value;

  /// Aktif seans bilgisi
  final Rx<String?> _activeSessionId = Rx<String?>(null);
  String? get activeSessionId => _activeSessionId.value;

  /// Gider ekleme formu için state
  final RxBool _isAddingExpense = false.obs;
  bool get isAddingExpense => _isAddingExpense.value;

  /// Form için seçili tip (Gider Ekleme)
  final Rx<ExpenseType> _selectedFormType = ExpenseType.session.obs;
  ExpenseType get selectedFormType => _selectedFormType.value;

  /// Form için seçili kategori
  final Rx<ExpenseCategory> _selectedFormCategory = ExpenseCategory.yemek.obs;
  ExpenseCategory get selectedFormCategory => _selectedFormCategory.value;

  /// Form için recurrence bilgisi
  final Rx<RecurrenceInfo?> _formRecurrence = Rx<RecurrenceInfo?>(null);
  RecurrenceInfo? get formRecurrence => _formRecurrence.value;

  /// Tek seferlik/Periyodik toggle
  final RxBool _isRecurring = false.obs;
  bool get isRecurring => _isRecurring.value;

  // =====================================================
  // CORE BUSINESS METHODS
  // =====================================================

  /// Tüm giderleri yenile
  Future<void> refreshExpenses() async {
    await executeWithLoading(() async {
      // Middleware userId kontrolü yaptığı için burada gerekli değil
      final userId = _authService.currentUserId!;

      final expenses = await _expenseUseCases.getUserExpenses(userId);
      _allExpenses.assignAll(expenses);
      _applyFilters();

      // Aktif seans ID'sini güncelle
      await _updateActiveSession();
    });
  }

  /// Aktif seans bilgisini güncelle
  Future<void> _updateActiveSession() async {
    try {
      // Middleware userId kontrolü yaptığı için burada gerekli değil
      final userId = _authService.currentUserId!;
      final params = SessionParams(userId: userId);
      final activeSession = await _getActiveSessionUseCase.call(params);
      _activeSessionId.value = activeSession?.id;
    } catch (e) {
      _activeSessionId.value = null;
    }
  }

  /// Seans gideri ekle
  Future<void> addSessionExpense({
    required String sessionId,
    required ExpenseCategory category,
    required double amount,
    String? description,
  }) async {
    await executeWithLoading(() async {
      await _expenseUseCases.addSessionExpense(
        sessionId: sessionId,
        category: category,
        amount: amount,
        description: description,
      );

      Get.back();
      NotificationHelper.showSuccess('Seans gideri başarıyla eklendi');
      await refreshExpenses();

      // Session istatistiklerini güncelle (dashboard refresh yerine)
      await _updateSessionStatsAfterExpense();
    });
  }

  /// Genel gider ekle
  Future<void> addGeneralExpense({
    required ExpenseCategory category,
    required double amount,
    RecurrenceInfo? recurrence,
    String? description,
  }) async {
    await executeWithLoading(() async {
      await _expenseUseCases.addGeneralExpense(
        category: category,
        amount: amount,
        recurrence: recurrence,
        description: description,
      );

      Get.back();
      NotificationHelper.showSuccess('Genel gider başarıyla eklendi');
      await refreshExpenses();
      await _dashboardController.refreshDashboard();
    });
  }

  /// Gider sil
  Future<void> deleteExpense(String expenseId) async {
    await executeWithLoading(() async {
      await _expenseUseCases.deleteExpense(expenseId);

      Get.back();
      NotificationHelper.showSuccess('Gider başarıyla silindi');
      await refreshExpenses();
      await _dashboardController.refreshDashboard();
    });
  }

  /// Gider güncelle
  Future<void> updateExpense(ExpenseModel expense) async {
    await executeWithLoading(() async {
      await _expenseUseCases.updateExpense(expense);

      Get.back();
      NotificationHelper.showSuccess('Gider başarıyla güncellendi');
      await refreshExpenses();
      await _dashboardController.refreshDashboard();
    });
  }

  // =====================================================
  // FILTER & SEARCH METHODS
  // =====================================================

  /// Tarih aralığı filtresini uygula
  void setDateRange(DateTimeRange? range) {
    _selectedDateRange.value = range;
    _applyFilters();
  }

  /// Kategori filtresini uygula
  void setCategory(ExpenseCategory? category) {
    _selectedCategory.value = category;
    _applyFilters();
  }

  /// Tip filtresini uygula
  void setType(ExpenseType? type) {
    _selectedType.value = type;
    _applyFilters();
  }

  /// Tüm filtreleri temizle
  void clearFilters() {
    _selectedDateRange.value = null;
    _selectedCategory.value = null;
    _selectedType.value = null;
    _applyFilters();
  }

  /// Filtreleri uygula
  void _applyFilters() {
    var filtered = _allExpenses.toList();

    // Tarih aralığı filtresi
    if (_selectedDateRange.value != null) {
      final range = _selectedDateRange.value!;
      filtered = filtered.where((expense) {
        return expense.createdAt.isAfter(range.start.subtract(const Duration(days: 1))) &&
            expense.createdAt.isBefore(range.end.add(const Duration(days: 1)));
      }).toList();
    }

    // Kategori filtresi
    if (_selectedCategory.value != null) {
      filtered = filtered.where((expense) {
        return expense.category == _selectedCategory.value;
      }).toList();
    }

    // Tip filtresi
    if (_selectedType.value != null) {
      filtered = filtered.where((expense) {
        return expense.type == _selectedType.value;
      }).toList();
    }

    _filteredExpenses.assignAll(filtered);
  }

  // =====================================================
  // FORM STATE MANAGEMENT
  // =====================================================

  /// Gider ekleme formunu aç
  void openAddExpenseForm() async {
    _isAddingExpense.value = true;

    // Önce aktif seans bilgisini güncelle
    await _updateActiveSession();

    // Debug: Aktif seans kontrolü
    print('DEBUG: Active session ID: ${_activeSessionId.value}');

    // Form state'ini temizle
    _selectedFormCategory.value = ExpenseCategory.yemek;
    _formRecurrence.value = null;
    _isRecurring.value = false;

    // Aktif seans durumuna göre tip belirle
    if (_activeSessionId.value != null) {
      _selectedFormType.value = ExpenseType.session;
      print('DEBUG: Selected type: SESSION');
    } else {
      _selectedFormType.value = ExpenseType.general;
      print('DEBUG: Selected type: GENERAL');
    }

    // UI'ın güncellenmesi için reactive değişkenleri trigger et
    _selectedFormType.refresh();
    _selectedFormCategory.refresh();
  }

  /// Gider ekleme formunu kapat
  void closeAddExpenseForm() {
    _isAddingExpense.value = false;
    _resetFormState();
  }

  /// Form state'ini sıfırla
  void _resetFormState() {
    // Aktif seans durumuna göre tip seç
    final hasActiveSession = _activeSessionId.value != null;
    _selectedFormType.value = hasActiveSession ? ExpenseType.session : ExpenseType.general;
    _selectedFormCategory.value = ExpenseCategory.yemek;
    _formRecurrence.value = null;
    _isRecurring.value = false;
  }

  /// Form tip seçimini değiştir
  void setFormType(ExpenseType type) {
    _selectedFormType.value = type;
    // Session seçilirse recurring'i kapat
    if (type == ExpenseType.session) {
      _isRecurring.value = false;
      _formRecurrence.value = null;
    }
  }

  /// Form kategori seçimini değiştir
  void setFormCategory(ExpenseCategory category) {
    _selectedFormCategory.value = category;
  }

  /// Recurring toggle'ı değiştir
  void setRecurring(bool isRecurring) {
    _isRecurring.value = isRecurring;
    if (!isRecurring) {
      _formRecurrence.value = null;
    }
  }

  /// Recurrence bilgisini ayarla
  void setRecurrence(RecurrenceInfo? recurrence) {
    _formRecurrence.value = recurrence;
    _isRecurring.value = recurrence != null && recurrence.type != RecurrenceType.none;
  }

  /// Form ile gider ekle
  Future<void> submitExpenseForm({
    required double amount,
    String? description,
  }) async {
    if (_selectedFormType.value == ExpenseType.session) {
      // Seans gideri
      if (_activeSessionId.value == null) {
        NotificationHelper.showError('Aktif seans bulunamadı');
        return;
      }

      await addSessionExpense(
        sessionId: _activeSessionId.value!,
        category: _selectedFormCategory.value,
        amount: amount,
        description: description,
      );
    } else {
      // Genel gider
      await addGeneralExpense(
        category: _selectedFormCategory.value,
        amount: amount,
        recurrence: _formRecurrence.value,
        description: description,
      );
    }

    closeAddExpenseForm();
  }

  // =====================================================
  // STATISTICS & ANALYTICS
  // =====================================================

  /// Toplam gider miktarı (filtrelenmiş)
  double get totalFilteredAmount {
    return _filteredExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  /// Kategori bazında gider dağılımı
  Map<ExpenseCategory, double> get categoryBreakdown {
    final Map<ExpenseCategory, double> breakdown = {};

    for (final expense in _filteredExpenses) {
      breakdown[expense.category] = (breakdown[expense.category] ?? 0.0) + expense.amount;
    }

    return breakdown;
  }

  /// Tip bazında gider dağılımı
  Map<ExpenseType, double> get typeBreakdown {
    final Map<ExpenseType, double> breakdown = {};

    for (final expense in _filteredExpenses) {
      breakdown[expense.type] = (breakdown[expense.type] ?? 0.0) + expense.amount;
    }

    return breakdown;
  }

  /// Bugünkü toplam gider
  double get todayTotal {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _allExpenses
        .where((expense) => expense.createdAt.isAfter(startOfDay) && expense.createdAt.isBefore(endOfDay))
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  /// Bu ayki toplam gider
  double get monthlyTotal {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    return _allExpenses
        .where((expense) => expense.createdAt.isAfter(startOfMonth) && expense.createdAt.isBefore(endOfMonth))
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  /// Periyodik giderlerin sayısı
  int get recurringExpensesCount {
    return _allExpenses.where((expense) => expense.isRecurring).length;
  }

  // =====================================================
  // UI HELPER METHODS
  // =====================================================

  /// Form tip seçimi için UI validation
  bool get canSelectSession => _activeSessionId.value != null;

  /// Form submit butonunun aktif olup olmadığını kontrol et
  bool isSubmitButtonEnabled(double amount) {
    // Tutar kontrolü
    if (amount <= 0) return false;

    // Tip seçimi kontrolü
    if (_selectedFormType.value == ExpenseType.session) {
      // Seans gideri için aktif seans gerekli
      return _activeSessionId.value != null;
    }

    // Genel gider için ek koşul yok
    return true;
  }

  /// Form submit validation
  bool canSubmitForm(double amount) {
    if (amount <= 0) return false;

    if (_selectedFormType.value == ExpenseType.session) {
      return _activeSessionId.value != null;
    }

    return true; // Genel gider için ek validation yok
  }

  /// Kategori için icon al
  String getCategoryIcon(ExpenseCategory category) {
    return category.icon;
  }

  /// Kategori için display name al
  String getCategoryDisplayName(ExpenseCategory category) {
    return category.displayName;
  }

  /// Tip için display name al
  String getTypeDisplayName(ExpenseType type) {
    return type.displayName;
  }

  /// Session istatistiklerini güncelle
  Future<void> _updateSessionStatsAfterExpense() async {
    try {
      // SessionService'den session istatistiklerini güncelle
      final sessionService = Get.find<SessionService>();
      await sessionService.updateSessionStatsAfterExpense();

      if (AppConstants.enableLogging) {
        print('📊 Session stats updated after expense');
      }
    } catch (e) {
      if (AppConstants.enableLogging) {
        print('🔥 Update session stats error: $e');
      }
    }
  }
}
