import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/enums/expense_enums.dart';
import '../controllers/expense_controller.dart';

class ExpenseAddView extends GetView<ExpenseController> {
  const ExpenseAddView({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();

    // Controller'a listener ekle - tutar değiştiğinde UI'ı güncelle
    amountController.addListener(() {
      controller.update(); // GetX controller'ını güncelle
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Gider Ekle'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gider Tipi Seçimi
                _buildExpenseTypeSection(),
                const SizedBox(height: 24),

                // Aktif Seans Bilgisi (eğer varsa)
                if (controller.canSelectSession) _buildActiveSessionInfo(),
                if (controller.canSelectSession) const SizedBox(height: 24),

                // Kategori Seçimi
                _buildCategorySection(),
                const SizedBox(height: 24),

                // Periyodik Gider Ayarları (sadece genel gider için)
                if (controller.selectedFormType == ExpenseType.general) _buildRecurrenceSection(),

                if (controller.selectedFormType == ExpenseType.general && controller.isRecurring) ...[
                  const SizedBox(height: 24),
                  _buildRecurrenceDetailsSection(),
                ],

                const SizedBox(height: 24),

                // Tutar Girişi
                _buildAmountSection(amountController),
                const SizedBox(height: 24),

                // Açıklama (Opsiyonel)
                _buildDescriptionSection(descriptionController),
                const SizedBox(height: 32),

                // Kaydet Butonu
                _buildSubmitButton(formKey, amountController, descriptionController),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildExpenseTypeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gider Türü',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTypeRadio(
                    ExpenseType.session,
                    'Seans Gideri',
                    'Aktif seansa ait gider',
                    enabled: controller.canSelectSession,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTypeRadio(
                    ExpenseType.general,
                    'Genel Gider',
                    'Seanslardan bağımsız gider',
                  ),
                ),
              ],
            ),
            if (!controller.canSelectSession)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Seans gideri eklemek için aktif bir seans olmalı',
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeRadio(
    ExpenseType type,
    String title,
    String subtitle, {
    bool enabled = true,
  }) {
    final isSelected = controller.selectedFormType == type;

    return InkWell(
      onTap: enabled ? () => controller.setFormType(type) : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color:
              enabled ? (isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent) : Colors.grey.shade100,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Radio<ExpenseType>(
                  value: type,
                  groupValue: controller.selectedFormType,
                  onChanged: enabled ? (value) => controller.setFormType(value!) : null,
                  activeColor: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: enabled ? Colors.black87 : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: enabled ? Colors.grey.shade600 : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveSessionInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.play_circle_outline, color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Aktif Seans Bulundu',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Seans gideri ekleyebilirsiniz',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Aktif',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kategori',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ExpenseCategory.values.map((category) {
                final isSelected = controller.selectedFormCategory == category;
                return InkWell(
                  onTap: () => controller.setFormCategory(category),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          controller.getCategoryIcon(category),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          controller.getCategoryDisplayName(category),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecurrenceSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tekrarlama',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Periyodik Gider'),
              subtitle: Text(
                controller.isRecurring ? 'Bu gider düzenli olarak tekrarlanacak' : 'Bu gider tek seferlik olacak',
              ),
              value: controller.isRecurring,
              onChanged: (value) => controller.setRecurring(value),
              activeColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecurrenceDetailsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tekrarlama Detayları',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Periyot Seçimi
            const Text(
              'Periyot',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                RecurrenceType.weekly,
                RecurrenceType.monthly,
                RecurrenceType.yearly,
              ].map((type) {
                final isSelected = controller.formRecurrence?.type == type;
                return InkWell(
                  onTap: () => _selectRecurrenceType(type),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      type.displayName,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Başlangıç Tarihi
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Başlangıç Tarihi',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _selectStartDate,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                controller.formRecurrence?.startDate != null
                                    ? _formatDate(controller.formRecurrence!.startDate)
                                    : 'Tarih Seç',
                                style: TextStyle(
                                  color: controller.formRecurrence?.startDate != null
                                      ? Colors.black87
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountSection(TextEditingController amountController) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tutar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              decoration: InputDecoration(
                labelText: 'Gider Tutarı',
                hintText: '0.00',
                prefixText: '₺ ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: const Icon(Icons.attach_money),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Tutar gerekli';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Geçerli bir tutar girin';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionSection(TextEditingController descriptionController) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Açıklama (Opsiyonel)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Gider Açıklaması',
                hintText: 'Giderle ilgili detay açıklama...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(GlobalKey<FormState> formKey, TextEditingController amountController,
      TextEditingController descriptionController) {
    return GetBuilder<ExpenseController>(
      builder: (controller) {
        final amount = double.tryParse(amountController.text) ?? 0.0;
        final isEnabled =
            amount > 0 && (controller.selectedFormType == ExpenseType.general || controller.canSelectSession);

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isEnabled && !controller.isLoading
                ? () async {
                    if (formKey.currentState!.validate()) {
                      await controller.submitExpenseForm(
                        amount: amount,
                        description: descriptionController.text.isEmpty ? null : descriptionController.text,
                      );
                    }
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: controller.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Gider Ekle',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        );
      },
    );
  }

  // Helper Methods
  void _selectRecurrenceType(RecurrenceType type) {
    final currentRecurrence = controller.formRecurrence;
    final newRecurrence = RecurrenceInfo(
      type: type,
      startDate: currentRecurrence?.startDate ?? DateTime.now(),
      endDate: currentRecurrence?.endDate,
      durationCount: currentRecurrence?.durationCount,
    );
    controller.setRecurrence(newRecurrence);
  }

  void _selectStartDate() async {
    final selectedDate = await showDatePicker(
      context: Get.context!,
      initialDate: controller.formRecurrence?.startDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      final currentRecurrence = controller.formRecurrence;
      final newRecurrence = RecurrenceInfo(
        type: currentRecurrence?.type ?? RecurrenceType.monthly,
        startDate: selectedDate,
        endDate: currentRecurrence?.endDate,
        durationCount: currentRecurrence?.durationCount,
      );
      controller.setRecurrence(newRecurrence);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
