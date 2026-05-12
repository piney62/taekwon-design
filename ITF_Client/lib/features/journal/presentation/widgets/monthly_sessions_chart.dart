import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/training_session.dart';

class MonthlySessionsChart extends StatelessWidget {
  const MonthlySessionsChart({super.key, required this.sessions});

  final List<TrainingSession> sessions;

  @override
  Widget build(BuildContext context) {
    // Build last 6 months data
    final now = DateTime.now();
    final months = List.generate(6, (i) {
      final m = DateTime(now.year, now.month - (5 - i));
      return m;
    });

    final counts = {
      for (final m in months)
        '${m.year}-${m.month}': sessions
            .where((s) => s.date.year == m.year && s.date.month == m.month)
            .length,
    };

    final maxY = (counts.values.fold(0, (a, b) => a > b ? a : b) + 1)
        .clamp(4, 999)
        .toDouble();

    final bars = months.asMap().entries.map((e) {
      final key = '${e.value.year}-${e.value.month}';
      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: counts[key]!.toDouble(),
            color: AppColors.itfRed,
            width: 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();

    final langCode = Localizations.localeOf(context).languageCode;
    final monthLabels = months.map((m) => DateFormat('MMM', langCode).format(m)).toList();

    return SizedBox(
      height: 160,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          gridData: FlGridData(
            drawVerticalLine: false,
            horizontalInterval: (maxY / 4).ceilToDouble().clamp(1, 999),
            getDrawingHorizontalLine: (_) => const FlLine(
              color: AppColors.surfaceVariant,
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: bars,
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                getTitlesWidget: (v, _) {
                  final idx = v.toInt();
                  if (idx < 0 || idx >= monthLabels.length) {
                    return const SizedBox();
                  }
                  return Text(
                    monthLabels[idx],
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                interval: (maxY / 4).ceilToDouble().clamp(1, 999),
                getTitlesWidget: (v, _) => Text(
                  v.toInt().toString(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
        ),
      ),
    );
  }
}
