import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/ride_model.dart';
import '../controllers/ride_controller.dart';

/// Ride Management View
/// Advanced ride analytics, filtering ve management
class RideManagementView extends StatelessWidget {
  const RideManagementView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RideController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sefer Yönetimi'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context, controller),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refreshData(),
          ),
        ],
      ),
      body: _buildBody(controller),
    );
  }

  Widget _buildBody(RideController controller) {
    return Column(
      children: [
        _buildSearchBar(controller),
        _buildQuickStats(controller),
        Expanded(
          child: Obx(() {
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final rides = controller.displayedRides;

            if (rides.isEmpty) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              onRefresh: () => controller.refreshData(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: rides.length,
                itemBuilder: (context, index) {
                  final ride = rides[index];
                  return _buildRideCard(ride);
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSearchBar(RideController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Sefer ara (not, session ID)',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: Obx(() => controller.searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => controller.clearSearch(),
                )
              : const SizedBox.shrink()),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: (value) => controller.searchRides(value),
      ),
    );
  }

  Widget _buildQuickStats(RideController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surfaceVariant,
      child: Obx(() => Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Toplam Sefer',
                  controller.totalRides.toString(),
                  Icons.directions_car,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Toplam Kazanç',
                  '₺${controller.totalEarnings.toStringAsFixed(0)}',
                  Icons.monetization_on,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Kârlılık',
                  '${controller.profitabilityPercentage.toStringAsFixed(0)}%',
                  Icons.trending_up,
                ),
              ),
            ],
          )),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildRideCard(RideModel ride) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  ride.isProfitable ? Icons.trending_up : Icons.trending_down,
                  color: ride.isProfitable ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  ride.profitStatus,
                  style: TextStyle(
                    color: ride.isProfitable ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  ride.createdAt?.toString().substring(0, 16) ?? 'Tarih yok',
                  style: TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildRideDetail('Mesafe', '${ride.distanceKm} km'),
                ),
                Expanded(
                  child: _buildRideDetail('Kazanç', '₺${ride.earnings}'),
                ),
                Expanded(
                  child: _buildRideDetail(
                      'Net Kâr', '₺${ride.netProfit.toStringAsFixed(2)}'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildRideDetail(
                      'Yakıt Maliyeti', '₺${ride.fuelCost.toStringAsFixed(2)}'),
                ),
                Expanded(
                  child: _buildRideDetail(
                      'Kâr Marjı', '${ride.profitMargin.toStringAsFixed(1)}%'),
                ),
                Expanded(
                  child: _buildRideDetail(
                      'Km Başı', '₺${ride.earningsPerKm.toStringAsFixed(2)}'),
                ),
              ],
            ),
            if (ride.notes != null && ride.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Not: ${ride.notes}',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRideDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_car_outlined,
            size: 64,
            color: AppColors.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Sefer bulunamadı',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Henüz hiç sefer eklenmemiş veya\nfiltrelere uygun sefer yok',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context, RideController controller) {
    final minEarningsController = TextEditingController();
    final maxEarningsController = TextEditingController();
    bool? isProfitable;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrele'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: minEarningsController,
              decoration: const InputDecoration(
                labelText: 'Minimum Kazanç (₺)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: maxEarningsController,
              decoration: const InputDecoration(
                labelText: 'Maksimum Kazanç (₺)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<bool?>(
              value: isProfitable,
              decoration: const InputDecoration(
                labelText: 'Kârlılık Durumu',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('Tümü')),
                DropdownMenuItem(value: true, child: Text('Sadece Kârlı')),
                DropdownMenuItem(value: false, child: Text('Sadece Zararlı')),
              ],
              onChanged: (value) => isProfitable = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              controller.clearFilters();
              Get.back();
            },
            child: const Text('Temizle'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.applyFilters(
                minEarnings: double.tryParse(minEarningsController.text),
                maxEarnings: double.tryParse(maxEarningsController.text),
                isProfitable: isProfitable,
              );
              Get.back();
            },
            child: const Text('Uygula'),
          ),
        ],
      ),
    );
  }
}
