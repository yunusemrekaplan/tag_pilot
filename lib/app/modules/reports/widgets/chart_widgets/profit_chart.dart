import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';

/// Profit Chart Widget
/// Kâr trend grafiği
class ProfitChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const ProfitChart({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return _buildEmptyState();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _buildChart(),
            ),
          ],
        ),
      ),
    );
  }

  /// Header
  Widget _buildHeader() {
    final totalProfit = data.fold<double>(0.0, (sum, item) => sum + (item['profit'] ?? 0.0));
    final averageProfit = data.isNotEmpty ? totalProfit / data.length : 0.0;
    final isPositive = totalProfit >= 0;

    return Row(
      children: [
        Icon(
          Icons.trending_up,
          color: isPositive ? AppColors.success : AppColors.error,
          size: 24,
        ),
        const SizedBox(width: 8),
        const Text(
          'Kâr Trendi',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₺${_formatCurrency(totalProfit)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isPositive ? AppColors.success : AppColors.error,
              ),
            ),
            Text(
              'Ort: ₺${_formatCurrency(averageProfit)}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Chart
  Widget _buildChart() {
    final spots = data.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final profit = item['profit'] ?? 0.0;
      return FlSpot(index.toDouble(), profit);
    }).toList();

    final maxValue = _getMaxValue();
    final minValue = _getMinValue();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: (maxValue - minValue) / 5,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.outline.withOpacity(0.3),
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: AppColors.outline.withOpacity(0.3),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: _getInterval(),
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < data.length) {
                  final date = DateTime.parse(data[value.toInt()]['date']);
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat('dd/MM').format(date),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: (maxValue - minValue) / 5,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                return Text(
                  '₺${_formatCurrency(value)}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onSurfaceVariant,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: AppColors.outline.withOpacity(0.3)),
        ),
        minX: 0,
        maxX: (data.length - 1).toDouble(),
        minY: minValue,
        maxY: maxValue,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            gradient: LinearGradient(
              colors: [
                _getProfitColor(spots.first.y),
                _getProfitColor(spots.last.y),
              ],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: _getProfitColor(spot.y),
                  strokeWidth: 2,
                  strokeColor: AppColors.surface,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  _getProfitColor(spots.first.y).withOpacity(0.3),
                  _getProfitColor(spots.last.y).withOpacity(0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: 0,
              color: AppColors.outline,
              strokeWidth: 2,
              dashArray: [5, 5],
            ),
          ],
        ),
      ),
    );
  }

  /// Empty State
  Widget _buildEmptyState() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: const Padding(
        padding: EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.trending_up,
                size: 48,
                color: AppColors.onSurfaceVariant,
              ),
              SizedBox(height: 8),
              Text(
                'Kâr verisi bulunamadı',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _getMaxValue() {
    if (data.isEmpty) return 100;
    final maxProfit = data.fold<double>(0.0, (max, item) {
      final profit = item['profit'] ?? 0.0;
      return profit > max ? profit : max;
    });
    return maxProfit > 0 ? maxProfit * 1.2 : 100;
  }

  double _getMinValue() {
    if (data.isEmpty) return 0;
    final minProfit = data.fold<double>(0.0, (min, item) {
      final profit = item['profit'] ?? 0.0;
      return profit < min ? profit : min;
    });
    return minProfit < 0 ? minProfit * 1.2 : 0;
  }

  double _getInterval() {
    if (data.length <= 7) return 1;
    if (data.length <= 14) return 2;
    return 3;
  }

  Color _getProfitColor(double value) {
    return value >= 0 ? AppColors.success : AppColors.error;
  }

  String _formatCurrency(double value) {
    return NumberFormat('#,##0', 'tr_TR').format(value);
  }
}
