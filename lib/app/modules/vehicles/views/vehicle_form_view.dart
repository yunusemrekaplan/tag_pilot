import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/navigation_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_constants.dart';
import '../../../core/utils/form_validator.dart';
import '../../../data/enums/fuel_type.dart';
import '../../../data/models/vehicle_model.dart';
import '../controllers/vehicle_controller.dart';

class VehicleFormView extends GetView<VehicleController> {
  const VehicleFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final brandController = TextEditingController();
    final modelController = TextEditingController();
    final plateController = TextEditingController();
    final fuelConsumptionController = TextEditingController();
    final fuelPriceController = TextEditingController();

    final selectedFuelType = Rx<FuelType>(FuelType.petrol);
    final isFirstVehicle = !controller.hasVehicles;

    // Eğer düzenleme modundaysa mevcut verileri doldur
    final VehicleModel? editingVehicle = Get.arguments as VehicleModel?;
    if (editingVehicle != null) {
      brandController.text = editingVehicle.brand;
      modelController.text = editingVehicle.model;
      plateController.text = editingVehicle.plate;
      fuelConsumptionController.text = editingVehicle.fuelConsumptionPer100Km.toString();
      fuelPriceController.text = editingVehicle.defaultFuelPricePerLitre.toString();
      selectedFuelType.value = editingVehicle.fuelType;
    } else {
      // Varsayılan değerler
      fuelConsumptionController.text = '8.0';
      fuelPriceController.text = '25.0';
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(editingVehicle != null ? 'Araç Düzenle' : 'Araç Ekle'),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                // Form Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(UIConstants.defaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        if (isFirstVehicle) _buildWelcomeHeader(),

                        if (isFirstVehicle) const SizedBox(height: 32),

                        // Vehicle Information Section
                        _buildSectionTitle('Araç Bilgileri'),
                        const SizedBox(height: 16),

                        _buildVehicleInfoSection(
                          brandController,
                          modelController,
                          plateController,
                          selectedFuelType,
                        ),

                        const SizedBox(height: 24),

                        // Fuel Information Section
                        _buildSectionTitle('Yakıt Bilgileri'),
                        const SizedBox(height: 16),

                        _buildFuelInfoSection(
                          fuelConsumptionController,
                          fuelPriceController,
                        ),

                        const SizedBox(height: 24),

                        // Help Text
                        _buildHelpText(),
                      ],
                    ),
                  ),
                ),

                // Save Button
                Container(
                  padding: const EdgeInsets.all(UIConstants.defaultPadding),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border(
                      top: BorderSide(
                        color: AppColors.outline.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Obx(() => _buildSaveButton(
                        formKey,
                        editingVehicle,
                        brandController,
                        modelController,
                        plateController,
                        selectedFuelType,
                        fuelConsumptionController,
                        fuelPriceController,
                        isFirstVehicle,
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.secondary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.directions_car,
              color: AppColors.onSecondary,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Hoş Geldiniz!',
            style: Get.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'İlk aracınızı ekleyerek TAG-Pilot deneyiminizi başlatın. Araç bilgilerinizi doğru girmeniz, gelir-gider hesaplamalarınızın hassasiyetini artıracaktır.',
            style: Get.textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Get.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildVehicleInfoSection(
    TextEditingController brandController,
    TextEditingController modelController,
    TextEditingController plateController,
    Rx<FuelType> selectedFuelType,
  ) {
    return Column(
      children: [
        // Brand & Model Row
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: brandController,
                decoration: const InputDecoration(
                  labelText: 'Marka',
                  hintText: 'Örn: Toyota',
                  prefixIcon: Icon(Icons.branding_watermark),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) => FormValidator.validateRequired(value, 'Marka'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: modelController,
                decoration: const InputDecoration(
                  labelText: 'Model',
                  hintText: 'Örn: Corolla',
                  prefixIcon: Icon(Icons.directions_car),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) => FormValidator.validateRequired(value, 'Model'),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Plate
        TextFormField(
          controller: plateController,
          decoration: const InputDecoration(
            labelText: 'Plaka',
            hintText: '34 ABC 123',
            prefixIcon: Icon(Icons.pin),
          ),
          textCapitalization: TextCapitalization.characters,
          validator: (value) => FormValidator.validateVehiclePlate(value),
        ),

        const SizedBox(height: 16),

        // Fuel Type
        Obx(() => DropdownButtonFormField<FuelType>(
              value: selectedFuelType.value,
              decoration: const InputDecoration(
                labelText: 'Yakıt Türü',
                prefixIcon: Icon(Icons.local_gas_station),
              ),
              items: FuelType.values
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.displayName),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  selectedFuelType.value = value;
                }
              },
              validator: (value) => value == null ? 'Yakıt türü seçiniz' : null,
            )),
      ],
    );
  }

  Widget _buildFuelInfoSection(
    TextEditingController fuelConsumptionController,
    TextEditingController fuelPriceController,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: fuelConsumptionController,
                decoration: const InputDecoration(
                  labelText: 'Ortalama Tüketim',
                  hintText: '8.0',
                  suffixText: 'L/100km',
                  prefixIcon: Icon(Icons.speed),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => FormValidator.validateFuelRate(value),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: fuelPriceController,
                decoration: const InputDecoration(
                  labelText: 'Varsayılan Yakıt Fiyatı',
                  hintText: '25.0',
                  suffixText: '₺/L',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => FormValidator.validateFuelPrice(value),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHelpText() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'İpuçları',
                style: Get.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• Ortalama tüketim: Aracınızın 100 km\'de ne kadar yakıt tükettiğini belirtir\n'
            '• Varsayılan yakıt fiyatı: Sefer başlatırken otomatik olarak kullanılacak fiyattır\n'
            '• Bu bilgileri daha sonra düzenleyebilirsiniz',
            style: Get.textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(
    GlobalKey<FormState> formKey,
    VehicleModel? editingVehicle,
    TextEditingController brandController,
    TextEditingController modelController,
    TextEditingController plateController,
    Rx<FuelType> selectedFuelType,
    TextEditingController fuelConsumptionController,
    TextEditingController fuelPriceController,
    bool isFirstVehicle,
  ) {
    final isLoading = editingVehicle != null ? controller.isUpdating : controller.isCreating;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () => _handleSave(
                  formKey,
                  editingVehicle,
                  brandController,
                  modelController,
                  plateController,
                  selectedFuelType,
                  fuelConsumptionController,
                  fuelPriceController,
                  isFirstVehicle,
                ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.onSecondary,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.onSecondary),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(editingVehicle != null ? Icons.save : Icons.add),
                  const SizedBox(width: 8),
                  Text(
                    editingVehicle != null ? 'Kaydet' : 'Araç Ekle',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _handleSave(
    GlobalKey<FormState> formKey,
    VehicleModel? editingVehicle,
    TextEditingController brandController,
    TextEditingController modelController,
    TextEditingController plateController,
    Rx<FuelType> selectedFuelType,
    TextEditingController fuelConsumptionController,
    TextEditingController fuelPriceController,
    bool isFirstVehicle,
  ) async {
    if (!formKey.currentState!.validate()) return;

    final brand = brandController.text.trim();
    final model = modelController.text.trim();
    final plate = plateController.text.trim().toUpperCase();
    final fuelType = selectedFuelType.value;
    final fuelConsumption = double.tryParse(fuelConsumptionController.text) ?? 8.0;
    final fuelPrice = double.tryParse(fuelPriceController.text) ?? 25.0;

    // Plaka benzersizlik kontrolü
    final isPlateUnique = await controller.isPlateUnique(
      plate,
      excludeVehicleId: editingVehicle?.id,
    );

    if (!isPlateUnique) {
      Get.snackbar(
        'Plaka Hatası',
        'Bu plaka zaten kayıtlı. Lütfen farklı bir plaka girin.',
        backgroundColor: AppColors.error,
        colorText: AppColors.onError,
      );
      return;
    }

    bool success;
    if (editingVehicle != null) {
      // Güncelleme
      success = await controller.updateVehicle(
        vehicleId: editingVehicle.id,
        brand: brand,
        model: model,
        plate: plate,
        fuelType: fuelType,
        fuelConsumptionPer100Km: fuelConsumption,
        defaultFuelPricePerLitre: fuelPrice,
      );
    } else {
      // Yeni ekleme
      success = await controller.createVehicle(
        brand: brand,
        model: model,
        plate: plate,
        fuelType: fuelType,
        fuelConsumptionPer100Km: fuelConsumption,
        defaultFuelPricePerLitre: fuelPrice,
      );
    }

    if (success) {
      if (isFirstVehicle) {
        // İlk araç kaydından sonra dashboard'a git
        Get.find<NavigationService>().navigateToMainApp();
      } else {
        // Normal düzenleme/ekleme sonrası geri dön
        Get.back();
      }
    }
  }
}
