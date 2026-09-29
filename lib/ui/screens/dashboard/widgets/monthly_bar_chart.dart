import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';

class MonthlyBarChart extends StatelessWidget {
  const MonthlyBarChart({
    super.key,
    required this.monthlyData,
    required this.currencySymbol,
  });

  final Map<DateTime, double> monthlyData;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final entries = monthlyData.entries.toList();

    double maxSpending = 100.0;
    for (final e in entries) {
      if (e.value > maxSpending) maxSpending = e.value;
    }
    // Add 15% ceiling for nice chart headroom
    maxSpending *= 1.15;

    final barGroups = <BarChartGroupData>[];
    for (int i = 0; i < entries.length; i++) {
      final isCurrent = i == entries.length - 1;
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: entries[i].value,
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: isCurrent
                    ? [AppColors.primary, AppColors.primaryLight]
                    : [
                        isDark ? AppColors.surfaceVariantDark : Colors.grey.shade400,
                        isDark ? Colors.grey.shade600 : Colors.grey.shade500,
                      ],
              ),
              width: 16,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 190,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxSpending,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => isDark ? AppColors.surfaceDark : Colors.black87,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final date = entries[group.x.toInt()].key;
                    final monthName = DateFormat('MMM yyyy').format(date);
                    return BarTooltipItem(
                      '$monthName\n',
                      const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      children: [
                        TextSpan(
                          text: CurrencyFormatter.format(rod.toY, symbol: currencySymbol),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= entries.length) {
                        return const SizedBox.shrink();
                      }
                      final monthName =
                          DateFormat('MMM').format(entries[index].key);
                      final isCurrent = index == entries.length - 1;
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(
                          monthName,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight:
                                isCurrent ? FontWeight.w700 : FontWeight.w500,
                            color: isCurrent
                                ? AppColors.primary
                                : (isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: maxSpending / 4,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  strokeWidth: 1,
                  dashArray: [4, 4],
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: barGroups,
            ),
          ),
        ),
      ],
    );
  }
}
