import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/pattern.dart';
import '../screens/pattern_detail_screen.dart';

class PatternsPage extends StatelessWidget {
  const PatternsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('learn.patterns'.tr())),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: itfPatterns.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final p = itfPatterns[i];
          return _PatternCard(
            pattern: p,
            index: i + 1,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    PatternDetailScreen(pattern: p, index: i + 1),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PatternCard extends StatelessWidget {
  const _PatternCard({
    required this.pattern,
    required this.index,
    required this.onTap,
  });

  final ItfPattern pattern;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final meaning = locale == 'ko' ? pattern.meaningKo : pattern.meaningEn;
    final belt = locale == 'ko' ? pattern.beltKo : pattern.beltEn;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.itfRed.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.itfRed,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          pattern.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          pattern.korean,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                        const Spacer(),
                        const Icon(Icons.chevron_right,
                            size: 18, color: AppColors.textDisabled),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      meaning,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _Tag(
                          label: 'learn.movesCount'.tr(namedArgs: {'count': pattern.moves.toString()}),
                          color: AppColors.info,
                        ),
                        const SizedBox(width: 6),
                        _Tag(label: belt, color: AppColors.success),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}
