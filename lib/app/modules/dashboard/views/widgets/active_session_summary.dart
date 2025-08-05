import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tag_pilot/app/core/theme/app_colors.dart';
import 'package:tag_pilot/app/modules/dashboard/controllers/dashboard_controller.dart';

/// Active Session Summary - Sade Modern Grid
class ActiveSessionSummary extends GetView<DashboardController> {
  const ActiveSessionSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.hasActiveSession) {
        return const SizedBox.shrink();
      }

      // Net kar = Aktif session kazanç - yakıt maliyeti (günlük giderler dahil değil)
      final profit = controller.activeSessionEarnings - controller.activeSessionFuelCost;
      final summaryItems = [
        GridSummaryBox(
          icon: Icons.timer_outlined,
          label: 'Süre',
          value: controller.sessionDuration,
          iconColor: AppColors.info,
        ),
        GridSummaryBox(
          icon: Icons.route_outlined,
          label: 'KM',
          value: controller.activeSessionDistance.toStringAsFixed(1),
          iconColor: AppColors.primary,
        ),
        GridSummaryBox(
          icon: Icons.monetization_on_outlined,
          label: 'Kazanç',
          value: '₺${controller.activeSessionEarnings.toStringAsFixed(0)}',
          iconColor: AppColors.success,
        ),
        GridSummaryBox(
          icon: Icons.local_gas_station_outlined,
          label: 'Yakıt',
          value: '₺${controller.activeSessionFuelCost.toStringAsFixed(0)}',
          iconColor: AppColors.warning,
        ),
        GridSummaryBox(
          icon: Icons.receipt_long_outlined,
          label: 'Gider',
          value: '₺${controller.activeSessionExpenses.toStringAsFixed(0)}',
          iconColor: AppColors.error,
        ),
        GridSummaryBox(
          icon: Icons.trending_up_outlined,
          label: 'Net Kar',
          value: '₺${(profit - controller.activeSessionExpenses).toStringAsFixed(0)}',
          iconColor: profit - controller.activeSessionExpenses >= 0 ? AppColors.success : AppColors.error,
        ),
      ];

      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outline.withOpacity(0.22), width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.outline.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.directions_car_rounded, color: AppColors.primary, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Aktif Sefer Özeti',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.onBackground,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: summaryItems,
            ),
          ],
        ),
      );
    });
  }
}

class GridSummaryBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

  const GridSummaryBox({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline.withOpacity(0.28), width: 1.2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.onBackground,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}
