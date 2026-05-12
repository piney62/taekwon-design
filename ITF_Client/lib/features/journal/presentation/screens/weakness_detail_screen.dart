import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_shell.dart';
import '../../../../shared/widgets/grad_header_text.dart';
import '../../../../shared/widgets/tul_card.dart';
import '../../application/weakness_provider.dart';
import '../../domain/entities/weakness_pattern.dart';

const _pageSize = 7;

class WeaknessDetailScreen extends ConsumerStatefulWidget {
  const WeaknessDetailScreen({super.key});

  @override
  ConsumerState<WeaknessDetailScreen> createState() =>
      _WeaknessDetailScreenState();
}

class _WeaknessDetailScreenState extends ConsumerState<WeaknessDetailScreen> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(weaknessPatternsProvider);

    return Scaffold(
      appBar: AppBar(
        title: GradHeaderText('journal.weaknessScreenTitle'.tr(), fontSize: 20),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(weaknessPatternsProvider);
              setState(() => _currentPage = 0);
            },
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${'common.error'.tr()}: $e')),
        data: (patterns) {
          if (patterns.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_outline,
                      color: AppColors.success, size: 56),
                  const SizedBox(height: 16),
                  Text(
                    'journal.weaknessNone'.tr(),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'journal.weaknessHint'.tr(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final totalCount = patterns.length;
          final totalPages = (totalCount / _pageSize).ceil().clamp(1, 999);

          if (_currentPage >= totalPages) {
            _currentPage = (totalPages - 1).clamp(0, 999);
          }

          final pageStart = _currentPage * _pageSize;
          final pageEnd = (pageStart + _pageSize).clamp(0, totalCount);
          final pageItems = patterns.sublist(pageStart, pageEnd);

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, kAppShellContentBottomInset),
            children: [
              // ── 안내 배너 ──────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppColors.warning.withValues(alpha: 0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline,
                        color: AppColors.warning, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'journal.weaknessInfo'.tr(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.warning,
                            ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── 약점 목록 ──────────────────────────────────────────────
              ...pageItems.asMap().entries.map((entry) {
                final rank = pageStart + entry.key + 1;
                final p = entry.value;
                return _WeaknessCard(rank: rank, pattern: p);
              }),

              const SizedBox(height: 12),

              // ── 페이지네이션 ───────────────────────────────────────────
              if (totalPages > 1)
                _PaginationBar(
                  currentPage: _currentPage,
                  totalPages: totalPages,
                  pageStart: pageStart,
                  pageEnd: pageEnd,
                  totalCount: totalCount,
                  onPrev: _currentPage > 0
                      ? () => setState(() => _currentPage--)
                      : null,
                  onNext: _currentPage < totalPages - 1
                      ? () => setState(() => _currentPage++)
                      : null,
                ),
            ],
          );
        },
      ),
    );
  }
}

// ── Pagination bar ─────────────────────────────────────────────────────────

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({
    required this.currentPage,
    required this.totalPages,
    required this.pageStart,
    required this.pageEnd,
    required this.totalCount,
    required this.onPrev,
    required this.onNext,
  });

  final int currentPage;
  final int totalPages;
  final int pageStart;
  final int pageEnd;
  final int totalCount;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: onPrev,
          color: onPrev != null ? AppColors.primary : AppColors.textDisabled,
        ),
        const SizedBox(width: 8),
        Column(
          children: [
            Text(
              '${currentPage + 1} / $totalPages',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              '${pageStart + 1}–$pageEnd / $totalCount',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: onNext,
          color: onNext != null ? AppColors.primary : AppColors.textDisabled,
        ),
      ],
    );
  }
}

// ── Weakness card ──────────────────────────────────────────────────────────

class _WeaknessCard extends StatelessWidget {
  const _WeaknessCard({required this.rank, required this.pattern});

  final int rank;
  final WeaknessPattern pattern;

  Color get _rankColor {
    if (rank == 1) return AppColors.itfRed;
    if (rank == 2) return AppColors.warning;
    return AppColors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('yyyy.MM.dd').format(pattern.detectedAt);
    final count = pattern.consecutiveCount;
    final urgency = count >= 5
        ? 'journal.urgencyHigh'.tr()
        : count >= 3
            ? 'journal.urgencyMid'.tr()
            : 'journal.urgencyLow'.tr();
    final urgencyColor = count >= 5
        ? AppColors.itfRed
        : count >= 3
            ? AppColors.warning
            : AppColors.info;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TulCard.compact(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: _rankColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: TextStyle(
                    color: _rankColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pattern.movementName,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _Chip(
                        label: 'journal.consecutiveCountFmt'.tr(
                            namedArgs: {'count': count.toString()}),
                        color: _rankColor,
                      ),
                      const SizedBox(width: 8),
                      _Chip(label: urgency, color: urgencyColor),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'journal.firstDetectedFmt'
                        .tr(namedArgs: {'date': dateStr}),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
