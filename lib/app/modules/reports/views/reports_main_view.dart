import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_constants.dart';
import '../controllers/reports_controller.dart';
import '../widgets/chart_widgets/earnings_chart.dart';
import '../widgets/report_widgets/kpi_card.dart';
import '../widgets/report_widgets/report_summary_card.dart';
import '../widgets/filters/date_range_picker.dart';

/// Reports Main View - Basitleştirilmiş
/// Analiz/raporlama modülünün ana sayfası
class ReportsMainView extends GetView<ReportsController> {
  const ReportsMainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  /// App Bar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Raporlar & Analiz',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
      ),
      backgroundColor: AppColors.surface,
      elevation: 0,
      actions: [
        Obx(() => IconButton(
              icon: const Icon(Icons.filter_list, color: AppColors.onSurface),
              onPressed: controller.isBusy ? null : () => _showFilterDialog(),
            )),
      ],
    );
  }

  /// Ana Body
  Widget _buildBody() {
    return Obx(() {
      if (controller.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuickActions(),
            const SizedBox(height: 24),
            _buildTabBar(),
            const SizedBox(height: 16),
            _buildTabContent(),
          ],
        ),
      );
    });
  }

  /// Hızlı Eylemler
  Widget _buildQuickActions() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hızlı Raporlar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    'Bugün',
                    Icons.today,
                    () => controller.generateTodayReport(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildQuickActionButton(
                    'Bu Hafta',
                    Icons.view_week,
                    () => controller.generateThisWeekReport(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildQuickActionButton(
                    'Bu Ay',
                    Icons.calendar_month,
                    () => controller.generateThisMonthReport(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Hızlı Eylem Butonu
  Widget _buildQuickActionButton(String title, IconData icon, VoidCallback? onTap) {
    return Obx(() {
      final isDisabled = controller.isBusy;
      return InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color: isDisabled ? AppColors.outline.withOpacity(0.3) : AppColors.outline,
            ),
            borderRadius: BorderRadius.circular(8),
            color: isDisabled ? AppColors.surface.withOpacity(0.5) : Colors.transparent,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isDisabled ? AppColors.onSurfaceVariant : AppColors.primary,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDisabled ? AppColors.onSurfaceVariant : AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  /// Tab Bar
  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildTabButton('Özet', 'summary'),
          _buildTabButton('Trendler', 'trends'),
        ],
      ),
    );
  }

  /// Tab Button
  Widget _buildTabButton(String title, String tab) {
    return Expanded(
      child: Obx(() {
        final isSelected = controller.selectedTab == tab;
        final isDisabled = controller.isBusy;
        return InkWell(
          onTap: isDisabled ? null : () => controller.selectTab(tab),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color:
                    isDisabled ? AppColors.onSurfaceVariant : (isSelected ? AppColors.onPrimary : AppColors.onSurface),
              ),
            ),
          ),
        );
      }),
    );
  }

  /// Tab Content
  Widget _buildTabContent() {
    return Obx(() {
      switch (controller.selectedTab) {
        case 'summary':
          return _buildSummaryTab();
        case 'trends':
          return _buildTrendsTab();
        default:
          return _buildSummaryTab();
      }
    });
  }

  /// Summary Tab
  Widget _buildSummaryTab() {
    return Column(
      children: [
        _buildReportSummary(),
        const SizedBox(height: 16),
        _buildKPICards(),
      ],
    );
  }

  /// Trends Tab
  Widget _buildTrendsTab() {
    return Column(
      children: [
        _buildEarningsChart(),
        const SizedBox(height: 16),
        _buildTrendAnalysis(),
      ],
    );
  }

  /// Report Summary
  Widget _buildReportSummary() {
    return Obx(() {
      final report = controller.currentReport;
      if (report.isEmpty) {
        return const Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Henüz rapor oluşturulmadı'),
          ),
        );
      }
      return ReportSummaryCard(report: report);
    });
  }

  /// KPI Cards
  Widget _buildKPICards() {
    return Obx(() {
      final report = controller.currentReport;
      if (report.isEmpty) {
        return const SizedBox.shrink();
      }

      final summary = report['summary'] as Map<String, dynamic>? ?? {};

      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: KPICard(
                  title: 'Toplam Kazanç',
                  value: '₺${summary['totalEarnings']?.toStringAsFixed(2) ?? '0.00'}',
                  icon: Icons.attach_money,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: KPICard(
                  title: 'Toplam Yolculuk',
                  value: '${summary['totalRides'] ?? 0}',
                  icon: Icons.directions_car,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: KPICard(
                  title: 'Toplam Mesafe',
                  value: '${summary['totalDistance']?.toStringAsFixed(1) ?? '0.0'} km',
                  icon: Icons.route,
                  color: AppColors.info,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: KPICard(
                  title: 'Toplam Kâr',
                  value: '₺${summary['totalProfit']?.toStringAsFixed(2) ?? '0.00'}',
                  icon: Icons.trending_up,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  /// Earnings Chart
  Widget _buildEarningsChart() {
    return Obx(() {
      final trend = controller.earningsTrend;
      if (trend.isEmpty) {
        return const Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Trend verisi bulunamadı'),
          ),
        );
      }
      return EarningsChart(data: trend);
    });
  }

  /// Trend Analysis
  Widget _buildTrendAnalysis() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Trend analizi burada gösterilecek'),
      ),
    );
  }

  /// Filter Dialog
  void _showFilterDialog() {
    showDialog(
      context: Get.context!,
      builder: (context) => const CustomDateRangePickerDialog(),
    );
  }

  /// Floating Action Button
  Widget _buildFloatingActionButton() {
    return Obx(() => FloatingActionButton.extended(
          onPressed: controller.isBusy ? null : () => _showCustomReportDialog(),
          backgroundColor: controller.isBusy ? AppColors.onSurfaceVariant : AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          icon: const Icon(Icons.add_chart),
          label: const Text('Özel Rapor'),
        ));
  }

  /// Custom Report Dialog
  void _showCustomReportDialog() {
    // Custom report dialog implementation
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: const Text('Özel Rapor'),
        content: const Text('Özel rapor özelliği yakında eklenecek'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }
}
