import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tag_pilot/app/core/theme/app_colors.dart';
import 'package:tag_pilot/app/core/utils/notification_helper.dart';
import 'package:tag_pilot/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:tag_pilot/app/modules/dashboard/views/dialogs/break_even_dialog.dart';

/// Modern Progress Card
class BreakEvenProgressCard extends GetView<DashboardController> {
  const BreakEvenProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.22), width: 1.3),
        boxShadow: [
          BoxShadow(
            color: AppColors.outline.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.analytics_outlined,
                  color: AppColors.onPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Başabaş Noktası',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.onBackground,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showBreakEvenDialog(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress Value
          Obx(() {
            if (controller.breakEvenPoint <= 0) {
              return Text(
                'Sefer başlatın',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
              );
            }

            // Aktif session varsa net kar göster, yoksa günlük net kar göster
            final currentNetProfit = controller.hasActiveSession
                ? controller.activeSessionEarnings - controller.activeSessionFuelCost - controller.activeSessionExpenses
                : controller.todayProfit;

            return RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '₺${currentNetProfit.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  TextSpan(
                    text: ' / ₺${controller.breakEvenPoint.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 14),

          // Progress Bar
          Obx(() {
            if (controller.breakEvenPoint <= 0) {
              return Container(
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.onSurfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }

            final progress = controller.breakEvenProgressPercentage / 100;
            final isCompleted = progress >= 1.0;

            return Container(
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(6),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: isCompleted ? AppColors.successGradient : AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: (isCompleted ? AppColors.success : AppColors.primary).withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 12),

          // Progress Details
          Obx(() {
            if (controller.breakEvenPoint <= 0) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Başabaş noktası belirlenmedi',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Sefer başlatın',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              );
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  '%${controller.breakEvenProgressPercentage.toStringAsFixed(1)} tamamlandı',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  void _showBreakEvenDialog(BuildContext context) {
    final dashboardController = Get.find<DashboardController>();

    if (dashboardController.hasActiveSession) {
      Get.dialog(
        BreakEvenDialog(controller: dashboardController),
        barrierDismissible: false,
      );
    } else {
      NotificationHelper.showInfo('Başabaş noktası belirlemek için aktif sefer başlatın');
    }
  }
}
