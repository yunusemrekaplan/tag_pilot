import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';

/// Distance Chart Widget
/// Mesafe trend grafiği
class DistanceChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const DistanceChart({
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
    final totalDistance = data.fold<double>(0.0, (sum, item) => sum + (item['distance'] ?? 0.0));
    final averageDistance = data.isNotEmpty ? totalDistance / data.length : 0.0;

    return Row(
      children: [
        const Icon(Icons.directions_car, color: AppColors.info, size: 24),
        const SizedBox(width: 8),
        const Text(
          'Mesafe Trendi',
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
              '${_formatDistance(totalDistance)} km',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.info,
              ),
            ),
            Text(
              'Ort: ${_formatDistance(averageDistance)} km',
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
      final distance = item['distance'] ?? 0.0;
      return FlSpot(index.toDouble(), distance);
    }).toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _getMaxValue(),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final date = DateTime.parse(data[group.x.toInt()]['date']);
              return BarTooltipItem(
                '${DateFormat('dd.MM').format(date)}\n${_formatDistance(rod.toY)} km',
                const TextStyle(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
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
              interval: _getMaxValue() / 5,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${_formatDistance(value)} km',
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
        barGroups: spots.map((spot) {
          return BarChartGroupData(
            x: spot.x.toInt(),
            barRods: [
              BarChartRodData(
                toY: spot.y,
                color: AppColors.info,
                width: 16,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
        gridData: FlGridData(
          show: true,
          horizontalInterval: _getMaxValue() / 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.outline.withOpacity(0.3),
              strokeWidth: 1,
            );
          },
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
                Icons.directions_car,
                size: 48,
                color: AppColors.onSurfaceVariant,
              ),
              SizedBox(height: 8),
              Text(
                'Mesafe verisi bulunamadı',
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
    final maxDistance = data.fold<double>(0.0, (max, item) {
      final distance = item['distance'] ?? 0.0;
      return distance > max ? distance : max;
    });
    return maxDistance > 0 ? maxDistance * 1.2 : 100;
  }

  double _getInterval() {
    if (data.length <= 7) return 1;
    if (data.length <= 14) return 2;
    return 3;
  }

  String _formatDistance(double value) {
    return NumberFormat('#,##0.0', 'tr_TR').format(value);
  }
}
