import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tag_pilot/app/core/theme/app_colors.dart';
import 'package:tag_pilot/app/modules/dashboard/controllers/dashboard_controller.dart';

/// Insights Section
class InsightsSection extends GetView<DashboardController> {
  const InsightsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Analiz & İçgörüler',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.onBackground,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Spacer(),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // TODO: Navigate to detailed insights
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    'Tümünü Gör',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(() {
          final insights = _generateInsights();

          if (insights.isEmpty) {
            return _buildEmptyInsights(context);
          }

          return Column(
            children: insights.take(3).map((insight) => ModernInsightCard(insight: insight)).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildEmptyInsights(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.outline.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.insights_rounded,
              color: AppColors.onPrimary,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Henüz analiz yok',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Daha fazla sefer yaparak kişiselleştirilmiş analiz ve öneriler alabilirsiniz',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => controller.startSessionWithPackage(),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: AppColors.successGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'İlk Seferi Başlat',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _generateInsights() {
    final insights = <Map<String, dynamic>>[];

    // Performance insight
    if (controller.todayEarnings > 0) {
      final avgPerRide = controller.todayRides > 0 ? controller.todayEarnings / controller.todayRides : 0;
      insights.add({
        'title': 'Günlük Performans',
        'description': 'Sefer başına ortalama ₺${avgPerRide.toStringAsFixed(2)} kazanç',
        'icon': Icons.trending_up_rounded,
        'color': AppColors.success,
        'type': 'performance',
      });
    }

    // Profit insight
    if (controller.todayProfit != 0) {
      insights.add({
        'title': controller.todayProfit > 0 ? 'Karlı Gün!' : 'Dikkat',
        'description': controller.todayProfit > 0
            ? 'Bugün ₺${controller.todayProfit.toStringAsFixed(2)} kar elde ettiniz'
            : 'Bugün ₺${controller.todayProfit.abs().toStringAsFixed(2)} zarar var',
        'icon': controller.todayProfit > 0 ? Icons.celebration_rounded : Icons.warning_rounded,
        'color': controller.todayProfit > 0 ? AppColors.success : AppColors.warning,
        'type': 'profit',
      });
    }

    // Goal insight
    if (controller.breakEvenProgressPercentage >= 50) {
      insights.add({
        'title': 'Hedef Takibi',
        'description':
            'Günlük hedefinizin %${controller.breakEvenProgressPercentage.toStringAsFixed(0)}\'ini tamamladınız',
        'icon': Icons.flag_rounded,
        'color': AppColors.info,
        'type': 'goal',
      });
    }

    return insights;
  }
}

/// Modern Insight Card
class ModernInsightCard extends StatelessWidget {
  final Map<String, dynamic> insight;

  const ModernInsightCard({super.key, required this.insight});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: Show detailed insight
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: (insight['color'] as Color).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: (insight['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    insight['icon'] as IconData,
                    color: insight['color'] as Color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        insight['title'] as String,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        insight['description'] as String,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.onSurfaceVariant,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
