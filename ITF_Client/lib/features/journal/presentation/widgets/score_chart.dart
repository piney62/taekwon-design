import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/training_session.dart';

class ScoreChart extends StatelessWidget {
  const ScoreChart({super.key, required this.sessions});

  final List<TrainingSession> sessions;

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return SizedBox(
        height: 140,
        child: Center(
          child: Text(
            'journal.chartPlaceholder'.tr(),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    // Show last 10 sessions in chronological order
    final data = sessions.reversed.take(10).toList();

    final spots = List.generate(
      data.length,
      (i) => FlSpot(i.toDouble(), data[i].score.toDouble()),
    );

    return SizedBox(
      height: 140,
      child: LineChart(
        LineChartData(
          minY: 1,
          maxY: 5,
          gridData: FlGridData(
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (_) => const FlLine(
              color: AppColors.surfaceVariant,
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                reservedSize: 24,
                getTitlesWidget: (v, _) => Text(
                  v.toInt().toString(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 20,
                getTitlesWidget: (v, _) {
                  final idx = v.toInt();
                  if (idx < 0 || idx >= data.length) return const SizedBox();
                  final date = data[idx].date;
                  return Text(
                    '${date.month}/${date.day}',
                    style: const TextStyle(
                      fontSize: 9,
                      color: AppColors.textSecondary,
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.itfRed,
              barWidth: 2.5,
              dotData: FlDotData(
                getDotPainter: (p0, p1, p2, p3) => FlDotCirclePainter(
                  radius: 4,
                  color: AppColors.itfRed,
                  strokeWidth: 0,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.itfRed.withValues(alpha: 0.12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
