import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/training_session.dart';
import '../../domain/entities/training_type.dart';

const _typeColors = {
  TrainingType.pattern: AppColors.itfRed,
  TrainingType.sparring: Color(0xFF1976D2),
  TrainingType.kicks: Color(0xFF388E3C),
  TrainingType.punches: Color(0xFFF57C00),
  TrainingType.fitness: Color(0xFF7B1FA2),
  TrainingType.other: AppColors.textSecondary,
};

class TypeDistributionChart extends StatelessWidget {
  const TypeDistributionChart({super.key, required this.sessions});

  final List<TrainingSession> sessions;

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) return const SizedBox.shrink();

    final counts = <TrainingType, int>{};
    for (final s in sessions) {
      counts[s.type] = (counts[s.type] ?? 0) + 1;
    }

    final total = sessions.length;
    final sections = counts.entries.map((e) {
      final pct = e.value / total;
      return PieChartSectionData(
        value: e.value.toDouble(),
        color: _typeColors[e.key] ?? AppColors.textSecondary,
        radius: 44,
        title: pct >= 0.08 ? '${(pct * 100).round()}%' : '',
        titleStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Row(
      children: [
        SizedBox(
          height: 140,
          width: 140,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 30,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: counts.entries.map((e) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _typeColors[e.key],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      e.key.i18nKey.tr(),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const Spacer(),
                    Text(
                      '${e.value}${'stats.sessionsSuffix'.tr()}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
