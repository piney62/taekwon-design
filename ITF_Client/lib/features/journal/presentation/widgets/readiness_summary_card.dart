import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../features/auth/application/providers.dart';
import '../../../../features/settings/application/providers.dart';
import '../../application/readiness_provider.dart';
import '../../application/weakness_provider.dart';
import '../../domain/entities/readiness_data.dart';
import '../../domain/entities/training_session.dart';

class ReadinessSummaryCard extends ConsumerWidget {
  const ReadinessSummaryCard({
    super.key,
    required this.sessions,
    this.onTap,
  });

  final List<TrainingSession> sessions;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final readinessAsync = ref.watch(readinessProvider);
    final weaknessAsync = ref.watch(weaknessPatternsProvider);
    final settingsAsync = ref.watch(settingsControllerProvider);

    final beltLevel = settingsAsync.valueOrNull?.beltLevel.name ?? 'white';
    final joinedAt = authState.joinedAt;
    final isDojo = authState.dojoConnected;

    return readinessAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (readiness) {
        final weaknesses = weaknessAsync.valueOrNull ?? [];
        final pct = _calcPct(
          isDojo: isDojo,
          readiness: readiness,
          sessions: sessions,
          joinedAt: joinedAt,
          weaknessCount: weaknesses.length,
        );
        final nextPattern = _nextPatternLabel(context, beltLevel);
        final pctColor = isDojo
            ? (pct >= 80 ? AppColors.success : AppColors.itfRed)
            : AppColors.itfRed;

        return Card(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 12, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.trending_up,
                          size: 16, color: AppColors.info),
                      const SizedBox(width: 6),
                      Text(
                        'journal.readinessTitle'.tr(),
                        style:
                            Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const Spacer(),
                      Text(
                        'journal.tapForDetail'.tr(),
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                      ),
                      const Icon(Icons.chevron_right,
                          size: 16, color: AppColors.textSecondary),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 원형 퍼센트
                      SizedBox(
                        width: 56,
                        height: 56,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CustomPaint(
                              size: const Size(56, 56),
                              painter: _CirclePainter(
                                pct: pct / 100,
                                color: pctColor,
                              ),
                            ),
                            Text(
                              '$pct%',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: pctColor,
                                    fontSize: 13,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nextPattern,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            _MiniChecklist(
                              readiness: readiness,
                              sessions: sessions,
                              isDojo: isDojo,
                              joinedAt: joinedAt,
                              weaknessCount: weaknesses.length,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (isDojo && !readiness.sparringCheck) ...[
                    const SizedBox(height: 8),
                    Text(
                      'journal.instructorEvalPending'.tr(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static int _calcPct({
    required bool isDojo,
    required ReadinessData readiness,
    required List<TrainingSession> sessions,
    required DateTime? joinedAt,
    required int weaknessCount,
  }) {
    final daysSince = joinedAt != null
        ? DateTime.now().difference(joinedAt).inDays
        : 0;
    final totalSessions = sessions.length;
    final autoSaved = sessions.where((s) => s.isAutoSaved).length;
    final avgScore = sessions.isEmpty
        ? 0.0
        : sessions.fold(0, (s, e) => s + e.score) / sessions.length;

    if (isDojo) {
      // 도장 모드: 4항목 × 25%
      // 수련 기간 (25%)
      final p1 = daysSince >= 28 ? 25 : (daysSince * 25 ~/ 28);
      // 품새 분석 횟수 (25%)
      final p2 = autoSaved >= 10 ? 25 : (autoSaved * 25 ~/ 10);
      // 품새 품질 (25% - 약점수에 따라 감소)
      final p3 = weaknessCount == 0
          ? 25
          : math.max(0, 25 - weaknessCount * 5).clamp(0, 25);
      // 겨루기·격파 사범 평가 (25%)
      final p4 = (readiness.sparringCheck ? 12 : 0) +
          (readiness.breakingCheck ? 13 : 0);
      return (p1 + p2 + p3 + p4).clamp(0, 100);
    } else {
      // 자습 모드: 4항목 × 25%
      final p1 = daysSince >= 28 ? 25 : (daysSince * 25 ~/ 28);
      final p2 = totalSessions >= 10 ? 25 : (totalSessions * 25 ~/ 10);
      final p3 = avgScore >= 3.5 ? 25 : 0;
      final p4 = (readiness.sparringCheck ? 12 : 0) +
          (readiness.breakingCheck ? 13 : 0);
      return (p1 + p2 + p3 + p4).clamp(0, 100);
    }
  }

  static String _nextPatternLabel(BuildContext context, String beltLevel) {
    final pattern = switch (beltLevel) {
      'white' => '천지',
      'yellow' => '단군',
      'green' => '도산',
      'blue' => '원효',
      'red' => '화랑',
      _ => null,
    };
    return pattern != null
        ? 'journal.readinessNextPatternFmt'.tr(namedArgs: {'pattern': pattern})
        : 'journal.readinessNextPattern'.tr();
  }
}

// 미니 체크리스트 (3개만 표시)
class _MiniChecklist extends StatelessWidget {
  const _MiniChecklist({
    required this.readiness,
    required this.sessions,
    required this.isDojo,
    required this.joinedAt,
    required this.weaknessCount,
  });

  final ReadinessData readiness;
  final List<TrainingSession> sessions;
  final bool isDojo;
  final DateTime? joinedAt;
  final int weaknessCount;

  @override
  Widget build(BuildContext context) {
    final daysSince = joinedAt != null
        ? DateTime.now().difference(joinedAt!).inDays
        : 0;
    final autoSaved = sessions.where((s) => s.isAutoSaved).length;
    final avgScore = sessions.isEmpty
        ? 0.0
        : sessions.fold(0, (s, e) => s + e.score) / sessions.length;

    final items = isDojo
        ? [
            (daysSince >= 28, 'journal.readinessCheckPeriod'.tr()),
            (autoSaved >= 10, 'journal.readinessCheckAnalysisFmt'.tr(namedArgs: {'count': autoSaved.toString()})),
            (weaknessCount == 0, 'journal.readinessCheckWeaknessFmt'.tr(namedArgs: {'count': weaknessCount.toString()})),
          ]
        : [
            (daysSince >= 28, 'journal.readinessCheckPeriod'.tr()),
            (sessions.length >= 10, 'journal.readinessCheckSessionsFmt'.tr(namedArgs: {'count': sessions.length.toString()})),
            (avgScore >= 3.5, 'journal.readinessCheckAvgScoreFmt'.tr(namedArgs: {'score': avgScore.toStringAsFixed(1)})),
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map((item) => _MiniItem(ok: item.$1, label: item.$2))
          .toList(),
    );
  }
}

class _MiniItem extends StatelessWidget {
  const _MiniItem({required this.ok, required this.label});
  final bool ok;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          ok ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 13,
          color: ok ? AppColors.success : AppColors.textDisabled,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: ok ? null : AppColors.textSecondary,
                fontSize: 11,
              ),
        ),
      ],
    );
  }
}

// 원형 진행 커스텀 페인터
class _CirclePainter extends CustomPainter {
  _CirclePainter({required this.pct, required this.color});
  final double pct;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = math.min(cx, cy) - 4;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);
    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(Offset(cx, cy), r, bgPaint);
    canvas.drawArc(
        rect, -math.pi / 2, 2 * math.pi * pct, false, fgPaint);
  }

  @override
  bool shouldRepaint(_CirclePainter old) =>
      old.pct != pct || old.color != color;
}
