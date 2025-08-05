import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tag_pilot/app/routes/app_routes.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/expense_model.dart';
import '../../../data/enums/expense_enums.dart';
import '../controllers/expense_controller.dart';
import '../../../core/extensions/datetime_extensions.dart';

/// Expense List View
/// Tüm giderlerin görüntülendiği ve yönetildiği ana sayfa
/// SOLID: Single Responsibility - Sadece expenses listesi UI'ı
/// Clean Architecture: Controller üzerinden business logic'e erişim
/// GetView pattern ile reactive state management
class ExpenseListView extends GetView<ExpenseController> {
  const ExpenseListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Giderlerim',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        actions: [
          Obx(() => Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: _showFilterDialog,
                  ),
                  if (_hasActiveFilters())
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              )),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Column(
          children: [
            // Aktif Filtreler
            if (_hasActiveFilters()) _buildActiveFilters(),

            // Gider Listesi
            Expanded(
              child: controller.filteredExpenses.isEmpty ? _buildEmptyState() : _buildExpensesList(),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.expenseAdd),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        icon: const Icon(Icons.add),
        label: const Text(
          'Yeni Gider',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // İstatistik kartı kaldırıldı - filtre sistemi kullanılıyor

  // İstatistik item metodu kaldırıldı

  bool _hasActiveFilters() {
    return controller.selectedDateRange != null ||
        controller.selectedCategory != null ||
        controller.selectedType != null;
  }

  Widget _buildActiveFilters() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        color: Colors.blue.shade50,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.filter_list, color: Colors.blue.shade700, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Aktif Filtreler',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: controller.clearFilters,
                    child: Text(
                      'Temizle',
                      style: TextStyle(color: Colors.blue.shade700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  if (controller.selectedDateRange != null)
                    _buildFilterChip(
                      'Tarih: ${_formatDateRange(controller.selectedDateRange!)}',
                      () => controller.setDateRange(null),
                    ),
                  if (controller.selectedCategory != null)
                    _buildFilterChip(
                      '${controller.getCategoryIcon(controller.selectedCategory!)} ${controller.getCategoryDisplayName(controller.selectedCategory!)}',
                      () => controller.setCategory(null),
                    ),
                  if (controller.selectedType != null)
                    _buildFilterChip(
                      controller.getTypeDisplayName(controller.selectedType!),
                      () => controller.setType(null),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: onRemove,
      backgroundColor: Colors.blue.shade100,
      deleteIconColor: Colors.blue.shade700,
    );
  }

  Widget _buildEmptyState() {
    String message;
    String subtitle;
    IconData icon;

    // Filtre sistemi kullanıldığı için genel mesaj
    if (_hasActiveFilters()) {
      message = 'Filtre kriterlerine uygun gider bulunamadı';
      subtitle = 'Filtreleri değiştirerek farklı sonuçlar arayabilirsiniz';
      icon = Icons.filter_list_outlined;
    } else {
      message = 'Henüz gider bulunamadı';
      subtitle = 'İlk giderinizi eklemek için + butonuna dokunun';
      icon = Icons.receipt_long_outlined;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                size: 40,
                color: AppColors.primary.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpensesList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: controller.filteredExpenses.length,
      itemBuilder: (context, index) {
        final expense = controller.filteredExpenses[index];
        return _buildExpenseCard(expense);
      },
    );
  }

  Widget _buildExpenseCard(ExpenseModel expense) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showExpenseDetails(expense),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Kategori Icon ve Başlık
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getExpenseTypeColor(expense.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      expense.categoryIcon,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          expense.categoryDisplayName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          expense.typeDisplayName,
                          style: TextStyle(
                            fontSize: 12,
                            color: _getExpenseTypeColor(expense.type),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Tutar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        expense.formattedAmount,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _getExpenseTypeColor(expense.type),
                        ),
                      ),
                      Text(
                        expense.createdAt.toRelativeTime,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              if (expense.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  expense.description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],

              // Recurrence bilgisi
              if (expense.isRecurring) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.purple.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.repeat,
                        size: 14,
                        color: Colors.purple.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        expense.recurrenceDisplayName,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.purple.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Session bilgisi
              if (expense.sessionId != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.work_outline,
                        size: 14,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Seans Gideri',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getExpenseTypeColor(ExpenseType type) {
    switch (type) {
      case ExpenseType.session:
        return Colors.blue;
      case ExpenseType.general:
        return Colors.orange;
    }
  }

  void _showExpenseDetails(ExpenseModel expense) {
    showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      builder: (context) => _ExpenseDetailsBottomSheet(expense: expense),
    );
  }

  void _showFilterDialog() {
    Get.dialog(
      ExpenseFilterDialog(
        controller: controller,
        onFiltersApplied: () {
          // Filtreler uygulandığında controller'ı refresh et
          controller.refreshExpenses();
        },
      ),
      barrierDismissible: true,
    );
  }

  String _formatDateRange(DateTimeRange range) {
    final start = '${range.start.day}/${range.start.month}';
    final end = '${range.end.day}/${range.end.month}';
    return '$start - $end';
  }
}

// Gider Detayları Bottom Sheet
class _ExpenseDetailsBottomSheet extends StatelessWidget {
  final ExpenseModel expense;

  const _ExpenseDetailsBottomSheet({required this.expense});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ExpenseController>();

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Row(
            children: [
              Text(
                expense.categoryIcon,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.categoryDisplayName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      expense.typeDisplayName,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                expense.formattedAmount,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Detaylar
          _buildDetailRow('Tarih', expense.createdAt.toTurkishDateTime),

          if (expense.description != null) _buildDetailRow('Açıklama', expense.description!),

          if (expense.isRecurring) _buildDetailRow('Tekrarlama', expense.recurrenceDisplayName),

          if (expense.sessionId != null) _buildDetailRow('Seans', 'Seans Gideri'),

          const SizedBox(height: 24),

          // Aksiyon Butonları
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Get.back();
                    controller.deleteExpense(expense.id);
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text('Sil', style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.back();
                    // TODO: Düzenleme sayfasına git
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Düzenle'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

/// Expense Filter Dialog
/// Gider filtreleme için dialog widget'ı
class ExpenseFilterDialog extends StatefulWidget {
  final ExpenseController controller;
  final VoidCallback onFiltersApplied;

  const ExpenseFilterDialog({
    super.key,
    required this.controller,
    required this.onFiltersApplied,
  });

  @override
  State<ExpenseFilterDialog> createState() => _ExpenseFilterDialogState();
}

class _ExpenseFilterDialogState extends State<ExpenseFilterDialog> {
  DateTime? _startDate;
  DateTime? _endDate;
  ExpenseCategory? _selectedCategory;
  ExpenseType? _selectedType;

  @override
  void initState() {
    super.initState();
    // Mevcut filtreleri yükle
    _startDate = widget.controller.selectedDateRange?.start;
    _endDate = widget.controller.selectedDateRange?.end;
    _selectedCategory = widget.controller.selectedCategory;
    _selectedType = widget.controller.selectedType;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDateRangeFilter(),
                    const SizedBox(height: 20),
                    _buildTypeFilter(),
                    const SizedBox(height: 20),
                    _buildCategoryFilter(),
                    const SizedBox(height: 24),
                    _buildActions(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.filter_list,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Gider Filtreleri',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          if (_hasActiveFilters())
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Aktif',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.close, color: Colors.white),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tarih Aralığı',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                'Başlangıç',
                _startDate,
                (date) => setState(() => _startDate = date),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDateField(
                'Bitiş',
                _endDate,
                (date) => setState(() => _endDate = date),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateField(String label, DateTime? date, Function(DateTime?) onDateSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final selectedDate = await showDatePicker(
              context: context,
              initialDate: date ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (selectedDate != null) {
              onDateSelected(selectedDate);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.outline.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    date != null ? date.toTurkishDate : 'Tarih Seç',
                    style: TextStyle(
                      fontSize: 14,
                      color: date != null ? AppColors.onSurface : AppColors.onSurface.withOpacity(0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gider Türü',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildFilterChip(
              'Tümü',
              null,
              _selectedType,
              (type) => setState(() => _selectedType = type),
            ),
            ...ExpenseType.values.map((type) => _buildFilterChip(
                  widget.controller.getTypeDisplayName(type),
                  type,
                  _selectedType,
                  (selectedType) => setState(() => _selectedType = selectedType),
                )),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategori',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildFilterChip(
              'Tümü',
              null,
              _selectedCategory,
              (category) => setState(() => _selectedCategory = category),
            ),
            ...ExpenseCategory.values.map((category) => _buildFilterChip(
                  '${widget.controller.getCategoryIcon(category)} ${widget.controller.getCategoryDisplayName(category)}',
                  category,
                  _selectedCategory,
                  (selectedCategory) => setState(() => _selectedCategory = selectedCategory),
                )),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip<T>(
    String label,
    T? value,
    T? selectedValue,
    Function(T?) onSelected,
  ) {
    final isSelected = value == selectedValue;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isSelected ? AppColors.onPrimary : AppColors.onSurface,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        onSelected(selected ? value : null);
      },
      backgroundColor: AppColors.background,
      selectedColor: AppColors.primary,
      checkmarkColor: AppColors.onPrimary,
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.outline.withOpacity(0.2),
        width: 1,
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              widget.controller.clearFilters();
              widget.onFiltersApplied();
              Get.back();
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Temizle'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // Başlangıç ve bitiş tarihlerini DateTimeRange'e çevir
              DateTimeRange? dateRange;
              if (_startDate != null || _endDate != null) {
                final start = _startDate ?? DateTime.now().subtract(const Duration(days: 30));
                final end = _endDate ?? DateTime.now();
                dateRange = DateTimeRange(start: start, end: end);
              }

              widget.controller.setDateRange(dateRange);
              widget.controller.setCategory(_selectedCategory);
              widget.controller.setType(_selectedType);
              widget.onFiltersApplied();
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Uygula'),
          ),
        ),
      ],
    );
  }

  bool _hasActiveFilters() {
    return _startDate != null || _endDate != null || _selectedCategory != null || _selectedType != null;
  }
}
