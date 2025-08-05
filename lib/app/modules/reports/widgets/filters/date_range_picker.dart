import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../controllers/reports_controller.dart';

/// Custom Date Range Picker Dialog
/// Tarih aralığı seçici dialog
class CustomDateRangePickerDialog extends StatefulWidget {
  const CustomDateRangePickerDialog({super.key});

  @override
  State<CustomDateRangePickerDialog> createState() => _CustomDateRangePickerDialogState();
}

class _CustomDateRangePickerDialogState extends State<CustomDateRangePickerDialog> {
  DateTime? startDate;
  DateTime? endDate;
  late ReportsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ReportsController>();
    startDate = controller.startDate;
    endDate = controller.endDate;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildDatePickers(),
            const SizedBox(height: 24),
            _buildQuickSelections(),
            const SizedBox(height: 24),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  /// Header
  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Icons.date_range, color: AppColors.primary, size: 24),
        const SizedBox(width: 12),
        const Text(
          'Tarih Aralığı Seç',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
      ],
    );
  }

  /// Date Pickers
  Widget _buildDatePickers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDateField(
          'Başlangıç Tarihi',
          startDate,
          (date) => setState(() => startDate = date),
          Icons.calendar_today,
        ),
        const SizedBox(height: 16),
        _buildDateField(
          'Bitiş Tarihi',
          endDate,
          (date) => setState(() => endDate = date),
          Icons.calendar_month,
        ),
      ],
    );
  }

  /// Date Field
  Widget _buildDateField(
    String label,
    DateTime? date,
    Function(DateTime?) onChanged,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
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
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: AppColors.primary,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (selectedDate != null) {
              onChanged(selectedDate);
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.outline),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    date != null ? DateFormat('dd.MM.yyyy').format(date) : 'Tarih seçin',
                    style: TextStyle(
                      fontSize: 14,
                      color: date != null ? AppColors.onSurface : AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: AppColors.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Quick Selections
  Widget _buildQuickSelections() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hızlı Seçimler',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildQuickButton('Bugün', () => _setQuickDate(0)),
            _buildQuickButton('Son 7 Gün', () => _setQuickDate(7)),
            _buildQuickButton('Son 30 Gün', () => _setQuickDate(30)),
            _buildQuickButton('Bu Ay', () => _setThisMonth()),
            _buildQuickButton('Geçen Ay', () => _setLastMonth()),
          ],
        ),
      ],
    );
  }

  /// Quick Button
  Widget _buildQuickButton(String label, VoidCallback onTap) {
    return Obx(() {
      final isDisabled = controller.isBusy;
      return InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(
              color: isDisabled ? AppColors.outline.withOpacity(0.3) : AppColors.outline,
            ),
            borderRadius: BorderRadius.circular(16),
            color: isDisabled ? AppColors.surface.withOpacity(0.5) : Colors.transparent,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDisabled ? AppColors.onSurfaceVariant : AppColors.onSurface,
            ),
          ),
        ),
      );
    });
  }

  /// Actions
  Widget _buildActions() {
    return Obx(() {
      final isDisabled = controller.isBusy;
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: isDisabled ? null : () => Get.back(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('İptal'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: (isDisabled || !_isValidSelection()) ? null : _applySelection,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Uygula'),
            ),
          ),
        ],
      );
    });
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  void _setQuickDate(int days) {
    final end = DateTime.now();
    final start = end.subtract(Duration(days: days));
    setState(() {
      startDate = start;
      endDate = end;
    });
  }

  void _setThisMonth() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 1).subtract(const Duration(days: 1));
    setState(() {
      startDate = start;
      endDate = end;
    });
  }

  void _setLastMonth() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month - 1, 1);
    final end = DateTime(now.year, now.month, 1).subtract(const Duration(days: 1));
    setState(() {
      startDate = start;
      endDate = end;
    });
  }

  bool _isValidSelection() {
    return startDate != null && endDate != null && startDate!.isBefore(endDate!);
  }

  void _applySelection() async {
    if (_isValidSelection()) {
      try {
        await controller.setStartDate(startDate!);
        await controller.setEndDate(endDate!);
        Get.back();
      } catch (e) {
        // Error already handled by controller
      }
    }
  }
}
