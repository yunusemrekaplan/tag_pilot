import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_constants.dart';
import '../../../routes/app_routes.dart';
import '../controllers/vehicle_controller.dart';
import '../../../data/models/vehicle_model.dart';
import '../../../data/enums/fuel_type.dart';

/// Vehicle List View
/// Araçları listeler ve yönetim işlemlerini sağlar
class VehicleListView extends GetView<VehicleController> {
  const VehicleListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Araçlarım'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => controller.refreshVehicles(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!controller.hasVehicles) {
          return _buildEmptyState();
        }

        return _buildVehicleList();
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.vehicleForm),
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.onSecondary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.directions_car_outlined,
                size: 80,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Henüz araç eklememişsiniz',
              style: Get.textTheme.headlineSmall?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'İlk aracınızı ekleyerek başlayın.\nAraç bilgilerinizi takip edebilir ve sefer maliyetlerinizi hesaplayabilirsiniz.',
              style: Get.textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Get.toNamed(AppRoutes.vehicleForm),
              icon: const Icon(Icons.add),
              label: const Text('İlk Aracını Ekle'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: AppColors.onSecondary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleList() {
    return RefreshIndicator(
      onRefresh: () => controller.refreshVehicles(),
      child: ListView.builder(
        padding: const EdgeInsets.all(UIConstants.defaultPadding),
        itemCount: controller.vehicles.length,
        itemBuilder: (context, index) {
          final vehicle = controller.vehicles[index];
          return _buildVehicleCard(vehicle);
        },
      ),
    );
  }

  Widget _buildVehicleCard(VehicleModel vehicle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => Get.toNamed(
          AppRoutes.vehicleDetail,
          arguments: vehicle,
        ),
        borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Vehicle info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              vehicle.displayName,
                              style: Get.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurface,
                              ),
                            ),
                            if (vehicle.isDefault) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'VARSAYILAN',
                                  style: Get.textTheme.labelSmall?.copyWith(
                                    color: AppColors.onSecondary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Plaka: ${vehicle.plate}',
                          style: Get.textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Actions
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleMenuAction(value, vehicle),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Düzenle'),
                          ],
                        ),
                      ),
                      if (!vehicle.isDefault)
                        const PopupMenuItem(
                          value: 'setDefault',
                          child: Row(
                            children: [
                              Icon(Icons.star, size: 20),
                              SizedBox(width: 8),
                              Text('Varsayılan Yap'),
                            ],
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Sil', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Vehicle details
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      icon: Icons.local_gas_station,
                      label: 'Yakıt Türü',
                      value: vehicle.fuelType.displayName,
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      icon: Icons.speed,
                      label: 'Ortalama Tüketim',
                      value:
                          '${vehicle.fuelConsumptionPer100Km.toStringAsFixed(2)} L/100km',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      icon: Icons.attach_money,
                      label: 'Yakıt Fiyatı',
                      value:
                          '${CurrencyConstants.currencySymbol}${vehicle.defaultFuelPricePerLitre.toStringAsFixed(2)}/L',
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      icon: Icons.calculate,
                      label: '100km Maliyeti',
                      value:
                          '${CurrencyConstants.currencySymbol}${vehicle.calculateFuelCost(100).toStringAsFixed(2)}',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Get.textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
              Text(
                value,
                style: Get.textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleMenuAction(String action, VehicleModel vehicle) {
    switch (action) {
      case 'edit':
        Get.toNamed(
          AppRoutes.vehicleForm,
          arguments: vehicle,
        );
        break;
      case 'setDefault':
        _showSetDefaultDialog(vehicle);
        break;
      case 'delete':
        _showDeleteDialog(vehicle);
        break;
    }
  }

  void _showSetDefaultDialog(VehicleModel vehicle) {
    Get.dialog(
      AlertDialog(
        title: const Text('Varsayılan Araç'),
        content: Text(
          '${vehicle.displayName} aracını varsayılan araç olarak ayarlamak istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.setDefaultVehicle(vehicle.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: AppColors.onSecondary,
            ),
            child: const Text('Ayarla'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(VehicleModel vehicle) {
    Get.dialog(
      AlertDialog(
        title: const Text('Aracı Sil'),
        content: Text(
          '${vehicle.displayName} aracını silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteVehicle(vehicle.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.onError,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}
