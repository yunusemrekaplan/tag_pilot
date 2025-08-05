import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/form_validator.dart';
import '../../../core/utils/notification_helper.dart';
import '../controllers/ride_form_controller.dart';
import '../../dashboard/controllers/dashboard_controller.dart';

/// Modern Yolculuk Ekleme Formu
/// Material 3 tasarım ile aktif session'a yolculuk ekleme
class RideAddView extends GetView<RideFormController> {
  const RideAddView({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final distanceController = TextEditingController();
    final earningsController = TextEditingController();
    final notesController = TextEditingController();

    // Dashboard controller'dan aktif session bilgisi
    final dashboardController = Get.find<DashboardController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Yolculuk Ekle'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Obx(() {
        // Aktif session kontrolü
        if (!dashboardController.hasActiveSession) {
          return _buildNoActiveSessionMessage();
        }

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Aktif Session Bilgisi
                _buildActiveSessionInfo(dashboardController),
                const SizedBox(height: 24),

                // Form
                Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Yolculuk Bilgileri',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.onBackground,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 20),

                      // Mesafe Input
                      _buildDistanceField(distanceController),
                      const SizedBox(height: 20),

                      // Kazanç Input
                      _buildEarningsField(earningsController),
                      const SizedBox(height: 20),

                      // Notlar Input
                      _buildNotesField(notesController),
                      const SizedBox(height: 32),

                      // Kaydet Button
                      _buildSaveButton(
                        formKey,
                        distanceController,
                        earningsController,
                        notesController,
                        dashboardController,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNoActiveSessionMessage() {
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
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.warning_rounded,
                color: AppColors.warning,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Aktif Sefer Bulunamadı',
              style: Get.textTheme.titleLarge?.copyWith(
                color: AppColors.onBackground,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Yolculuk eklemek için önce bir sefer başlatmanız gerekiyor.',
              style: Get.textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Get.back();
              },
              icon: const Icon(Icons.arrow_back, color: AppColors.onPrimary),
              label: const Text('Dashboard\'a Dön'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveSessionInfo(DashboardController dashboardController) {
    final package = dashboardController.activePackage;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.directions_car_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Aktif Sefer',
                style: Get.textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (package != null)
            Row(
              children: [
                Icon(Icons.card_membership, color: AppColors.onPrimaryContainer, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Paket: ${package.name}',
                  style: Get.textTheme.bodyMedium?.copyWith(
                    color: AppColors.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.timer, color: AppColors.onPrimaryContainer, size: 16),
              const SizedBox(width: 6),
              Text(
                'Süre: ${dashboardController.sessionDuration}',
                style: Get.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDistanceField(TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mesafe (km)',
          style: Get.textTheme.titleMedium?.copyWith(
            color: AppColors.onBackground,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          decoration: InputDecoration(
            hintText: 'Örn: 15.5',
            prefixIcon: const Icon(Icons.route_outlined),
            suffixText: 'km',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.outline.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          validator: (value) => FormValidator.validateDistance(value),
        ),
      ],
    );
  }

  Widget _buildEarningsField(TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kazanç (₺)',
          style: Get.textTheme.titleMedium?.copyWith(
            color: AppColors.onBackground,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          decoration: InputDecoration(
            hintText: 'Örn: 45.00',
            prefixIcon: const Icon(Icons.monetization_on_outlined),
            suffixText: '₺',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.outline.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          validator: (value) => FormValidator.validateEarnings(value),
        ),
      ],
    );
  }

  Widget _buildNotesField(TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notlar (İsteğe Bağlı)',
          style: Get.textTheme.titleMedium?.copyWith(
            color: AppColors.onBackground,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Yolculuk hakkında özel notlar...',
            prefixIcon: const Icon(Icons.note_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.outline.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(
    GlobalKey<FormState> formKey,
    TextEditingController distanceController,
    TextEditingController earningsController,
    TextEditingController notesController,
    DashboardController dashboardController,
  ) {
    return SizedBox(
      width: double.infinity,
      child: Obx(() => ElevatedButton(
            onPressed: controller.isBusy
                ? null
                : () => _handleSave(
                      formKey,
                      distanceController,
                      earningsController,
                      notesController,
                      dashboardController,
                    ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: controller.isBusy
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.onPrimary),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.save, size: 20, color: AppColors.onPrimary),
                      const SizedBox(width: 8),
                      Text(
                        'Yolculuk Kaydet',
                        style: Get.textTheme.titleMedium?.copyWith(
                          color: AppColors.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          )),
    );
  }

  Future<void> _handleSave(
    GlobalKey<FormState> formKey,
    TextEditingController distanceController,
    TextEditingController earningsController,
    TextEditingController notesController,
    DashboardController dashboardController,
  ) async {
    // Button spam protection - çift kontrol
    if (controller.isBusy) {
      print('🚫 HandleSave blocked - controller is busy');
      return;
    }

    if (!formKey.currentState!.validate()) return;

    final distance = double.tryParse(distanceController.text);
    final earnings = double.tryParse(earningsController.text);
    final notes = notesController.text.trim();

    if (distance == null || distance <= 0) {
      NotificationHelper.showError('Geçerli bir mesafe girin');
      return;
    }

    if (earnings == null || earnings < 0) {
      NotificationHelper.showError('Geçerli bir kazanç miktarı girin');
      return;
    }

    // Aktif session kontrolü (UI validation)
    if (!dashboardController.hasActiveSession) {
      NotificationHelper.showError('Aktif sefer bulunamadı');
      return;
    }

    // Vehicle bilgilerini al (dashboard'dan)
    var selectedVehicle = dashboardController.selectedVehicle;
    if (selectedVehicle == null) {
      // Eğer selected vehicle null ise, default vehicle'ı almaya çalış
      try {
        selectedVehicle = await dashboardController.getDefaultVehicle();
        if (selectedVehicle == null) {
          NotificationHelper.showError('Araç bilgisi bulunamadı. Lütfen araç sayfasını kontrol edin.');
          return;
        }
      } catch (e) {
        NotificationHelper.showError('Araç bilgisi yüklenirken hata oluştu');
        return;
      }
    }

    // SOLID: Business Logic'i RideController'a taşıdık
    final success = await controller.addRide(
      distanceKm: distance,
      earnings: earnings,
      fuelRate: selectedVehicle.fuelConsumptionPer100Km,
      fuelPrice: selectedVehicle.defaultFuelPricePerLitre,
      notes: notes.isNotEmpty ? notes : null,
    );

    if (success) {
      // İşlem başarılı - hemen sayfadan çık
      Get.back(); // Form sayfasını kapat

      // NOT: Dashboard refresh gerekli değil - session stats zaten güncellendi
    }
  }
}
