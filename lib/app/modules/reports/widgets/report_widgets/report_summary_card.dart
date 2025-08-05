import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';

/// Report Summary Card Widget
/// Rapor özetini gösteren kart
class ReportSummaryCard extends StatelessWidget {
  final Map<String, dynamic> report;

  const ReportSummaryCard({
    super.key,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    final summary = report['summary'] as Map<String, dynamic>? ?? {};
    final reportType = report['reportType'] as String? ?? 'custom';
    final generatedAt = report['generatedAt'] as String?;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(reportType, generatedAt),
            const SizedBox(height: 16),
            _buildSummaryGrid(summary),
            if (report['details'] != null) ...[
              const SizedBox(height: 16),
              _buildDetailsSection(report['details']),
            ],
          ],
        ),
      ),
    );
  }

  /// Header
  Widget _buildHeader(String reportType, String? generatedAt) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            _getReportTypeText(reportType),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
        const Spacer(),
        if (generatedAt != null)
          Text(
            'Oluşturulma: ${DateFormat('dd.MM.yyyy HH:mm').format(DateTime.parse(generatedAt).add(const Duration(hours: 3)))}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.onSurfaceVariant,
            ),
          ),
      ],
    );
  }

  /// Summary Grid
  Widget _buildSummaryGrid(Map<String, dynamic> summary) {
    final items = [
      _SummaryItem('Toplam Yolculuk', '${summary['totalRides'] ?? 0}', Icons.route),
      _SummaryItem('Tamamlanan Sefer', '${summary['totalCompletedSessions'] ?? 0}', Icons.timer),
      _SummaryItem('Toplam Kazanç', '₺${_formatCurrency(summary['totalEarnings'] ?? 0.0)}', Icons.attach_money),
      _SummaryItem(
          'Toplam Yakıt Maliyeti', '₺${_formatCurrency(summary['totalFuelCost'] ?? 0.0)}', Icons.local_gas_station),
      _SummaryItem('Toplam Harcama', '₺${_formatCurrency(summary['totalExpenses'] ?? 0.0)}', Icons.payments),
      _SummaryItem(
          'Toplam Paket Ücreti', '₺${_formatCurrency(summary['totalPackageCost'] ?? 0.0)}', Icons.card_membership),
      _SummaryItem('Toplam Kâr', '₺${_formatCurrency(summary['totalProfit'] ?? 0.0)}', Icons.trending_up),
      _SummaryItem('Toplam Mesafe', '${_formatDistance(summary['totalDistance'] ?? 0.0)} km', Icons.directions_car),
      _SummaryItem('Kâr Marjı', '%${_formatPercentage(summary['profitMargin'] ?? 0.0)}', Icons.analytics),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.5,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildSummaryItem(item);
      },
    );
  }

  /// Summary Item
  Widget _buildSummaryItem(_SummaryItem item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outline.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(
                item.icon,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            item.value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  /// Details Section
  Widget _buildDetailsSection(Map<String, dynamic> details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detaylar',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        if (details['rides'] != null) ...[
          _buildDetailItem('Seferler', '${(details['rides'] as List).length} sefer'),
        ],
        if (details['expenses'] != null) ...[
          _buildDetailItem('Harcamalar', '${(details['expenses'] as List).length} harcama'),
        ],
        if (details['sessions'] != null) ...[
          _buildDetailItem('Seanslar', '${(details['sessions'] as List).length} seans'),
        ],
      ],
    );
  }

  /// Detail Item
  Widget _buildDetailItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$title:',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  String _getReportTypeText(String reportType) {
    switch (reportType) {
      case 'daily':
        return 'Günlük Rapor';
      case 'weekly':
        return 'Haftalık Rapor';
      case 'monthly':
        return 'Aylık Rapor';
      case 'custom':
        return 'Özel Rapor';
      default:
        return 'Rapor';
    }
  }

  String _formatCurrency(double value) {
    return NumberFormat('#,##0.00', 'tr_TR').format(value);
  }

  String _formatDistance(double value) {
    return NumberFormat('#,##0.0', 'tr_TR').format(value);
  }

  String _formatPercentage(double value) {
    return NumberFormat('#,##0.0', 'tr_TR').format(value);
  }
}

/// Summary Item Helper Class
class _SummaryItem {
  final String title;
  final String value;
  final IconData icon;

  _SummaryItem(this.title, this.value, this.icon);
}
