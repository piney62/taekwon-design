import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_shell.dart';
import '../../../../shared/widgets/tul_buttons.dart';
import '../../../../shared/widgets/tul_card.dart';
import '../../../auth/application/providers.dart';
import '../../../settings/application/providers.dart';
import '../../application/readiness_provider.dart';
import '../../application/weakness_provider.dart';
import '../../domain/entities/readiness_data.dart';
import '../../domain/entities/training_session.dart';
import 'theory_test_sheet.dart';

class ReadinessDetailScreen extends ConsumerWidget {
  const ReadinessDetailScreen({
    super.key,
    required this.sessions,
  });

  final List<TrainingSession> sessions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final readinessAsync = ref.watch(readinessProvider);
    final weaknessAsync = ref.watch(weaknessPatternsProvider);
    final settingsAsync = ref.watch(settingsControllerProvider);

    final beltLevel = settingsAsync.valueOrNull?.beltLevel.name ?? 'white';
    final isDojo = authState.dojoConnected;
    final joinedAt = authState.joinedAt;
    final nextBelt = _nextBeltLabel(beltLevel);

    return Scaffold(
      body: readinessAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (readiness) {
          final weaknesses = weaknessAsync.valueOrNull ?? [];
          final items = _buildItems(
            isDojo: isDojo,
            readiness: readiness,
            sessions: sessions,
            joinedAt: joinedAt,
            weaknessCount: weaknesses.length,
          );
          final pct = _calcPct(items);
          final incomplete =
              items.where((i) => !i.passed && !i.optional).length;

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              // ── TopBar
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Icon(Icons.chevron_left_rounded,
                              color: AppColors.text, size: 20),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'journal.readinessDetail'.tr(),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, kAppShellContentBottomInset),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Gradient ring + next belt
                    Center(
                      child: Column(
                        children: [
                          _GradientRing(pct: pct),
                          const SizedBox(height: 14),
                          Text(
                            'TO',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted,
                              letterSpacing: 0.12,
                            ),
                          ),
                          const SizedBox(height: 6),
                          ShaderMask(
                            shaderCallback: (b) =>
                                AppColors.gradMain.createShader(b),
                            child: Text(
                              nextBelt,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Checklist section title
                    Text(
                      'journal.readinessChecklist'.tr(),
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),

                    // ── Items
                    ...items.map((item) => _CheckCard(
                          item: item,
                          onToggle: item.toggleable
                              ? (val) =>
                                  _toggle(ref, readiness, item.key, val)
                              : null,
                        )),

                    const SizedBox(height: 8),

                    // ── Status card
                    _StatusCard(pct: pct, incomplete: incomplete),
                    const SizedBox(height: 16),

                    // ── Theory test button
                    _GradientTheoryButton(
                      label: readiness.theoryTestPassed
                          ? 'journal.theoryTestRetry'.tr()
                          : 'journal.theoryTestBtn'.tr(),
                      onTap: () => showTheoryTestSheet(
                        context, ref, beltLevel,
                        onPassed: (score) async {
                          await ref
                              .read(readinessProvider.notifier)
                              .save(readiness.copyWith(theoryTestPassed: true));
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Data builders ──────────────────────────────────────────────────────────

  List<_CheckItem> _buildItems({
    required bool isDojo,
    required ReadinessData readiness,
    required List<TrainingSession> sessions,
    required DateTime? joinedAt,
    required int weaknessCount,
  }) {
    final daysSince = joinedAt != null
        ? DateTime.now().difference(joinedAt).inDays
        : 0;
    final autoSaved = sessions.where((s) => s.isAutoSaved).length;
    final avgScore = sessions.isEmpty
        ? 0.0
        : sessions.fold(0, (s, e) => s + e.score) / sessions.length;

    // Theory test item — shared by both branches
    final theoryItem = _CheckItem(
      key: '',
      label: 'journal.checkTheoryTest'.tr(),
      desc: readiness.theoryTestPassed
          ? 'journal.checkTheoryTestPassed'.tr()
          : 'journal.checkTheoryTestPending'.tr(),
      passed: readiness.theoryTestPassed,
      toggleable: false,
      optional: false,
      pctContrib: 20,
      icon: Icons.bolt_rounded,
      iconColor: AppColors.accent,
    );

    if (isDojo) {
      return [
        _CheckItem(
          key: '',
          label: 'journal.checkPeriod'.tr(),
          desc: daysSince >= 28
              ? 'journal.checkPeriodOk'
                  .tr(namedArgs: {'days': daysSince.toString()})
              : 'journal.checkPeriodFail'
                  .tr(namedArgs: {'days': daysSince.toString()}),
          passed: daysSince >= 28,
          toggleable: false,
          optional: false,
          pctContrib: 20,
          icon: Icons.local_fire_department_rounded,
          iconColor: AppColors.primary,
        ),
        _CheckItem(
          key: '',
          label: 'journal.checkAnalysisCount'.tr(),
          desc: 'journal.checkAnalysisCountDesc'
              .tr(namedArgs: {'count': autoSaved.toString()}),
          passed: autoSaved >= 10,
          toggleable: false,
          optional: false,
          pctContrib: 20,
          icon: Icons.analytics_outlined,
          iconColor: AppColors.secondary,
        ),
        _CheckItem(
          key: '',
          label: 'journal.checkQuality'.tr(),
          desc: weaknessCount == 0
              ? 'journal.checkQualityOk'.tr()
              : 'journal.checkQualityFail'
                  .tr(namedArgs: {'count': weaknessCount.toString()}),
          passed: weaknessCount == 0,
          toggleable: false,
          optional: false,
          pctContrib: 20,
          icon: Icons.star_outline_rounded,
          iconColor: AppColors.accent,
        ),
        _CheckItem(
          key: 'sparring',
          label: 'journal.checkSparringInstructor'.tr(),
          desc: readiness.sparringCheck
              ? 'journal.checkSparringApproved'.tr()
              : 'journal.checkSparringPending'.tr(),
          passed: readiness.sparringCheck,
          toggleable: true,
          optional: false,
          pctContrib: 10,
          icon: Icons.more_horiz_rounded,
          iconColor: AppColors.textMuted,
        ),
        _CheckItem(
          key: 'breaking',
          label: 'journal.checkBreakingInstructor'.tr(),
          desc: readiness.breakingCheck
              ? 'journal.checkBreakingApproved'.tr()
              : 'journal.checkBreakingPending'.tr(),
          passed: readiness.breakingCheck,
          toggleable: true,
          optional: true,
          pctContrib: 10,
          icon: Icons.help_outline_rounded,
          iconColor: AppColors.textMuted,
        ),
        theoryItem,
      ];
    } else {
      return [
        _CheckItem(
          key: '',
          label: 'journal.checkPeriod'.tr(),
          desc: daysSince >= 28
              ? 'journal.checkPeriodOk'
                  .tr(namedArgs: {'days': daysSince.toString()})
              : 'journal.checkPeriodFail'
                  .tr(namedArgs: {'days': daysSince.toString()}),
          passed: daysSince >= 28,
          toggleable: false,
          optional: false,
          pctContrib: 20,
          icon: Icons.local_fire_department_rounded,
          iconColor: AppColors.primary,
        ),
        _CheckItem(
          key: '',
          label: 'journal.checkSessionCount'.tr(),
          desc: 'journal.checkSessionCountDesc'
              .tr(namedArgs: {'count': sessions.length.toString()}),
          passed: sessions.length >= 10,
          toggleable: false,
          optional: false,
          pctContrib: 20,
          icon: Icons.fitness_center_rounded,
          iconColor: AppColors.secondary,
        ),
        _CheckItem(
          key: '',
          label: 'journal.checkAvgScore'.tr(),
          desc: 'journal.checkAvgScoreDesc'
              .tr(namedArgs: {'score': avgScore.toStringAsFixed(1)}),
          passed: avgScore >= 3.5,
          toggleable: false,
          optional: false,
          pctContrib: 20,
          icon: Icons.trending_up_rounded,
          iconColor: AppColors.accent,
        ),
        _CheckItem(
          key: 'sparring',
          label: 'journal.checkSparringSelf'.tr(),
          desc: 'journal.checkSparringSelfDesc'.tr(),
          passed: readiness.sparringCheck,
          toggleable: true,
          optional: false,
          pctContrib: 10,
          icon: Icons.more_horiz_rounded,
          iconColor: AppColors.textMuted,
        ),
        _CheckItem(
          key: 'breaking',
          label: 'journal.checkBreakingSelf'.tr(),
          desc: 'journal.checkBreakingSelfDesc'.tr(),
          passed: readiness.breakingCheck,
          toggleable: true,
          optional: true,
          pctContrib: 10,
          icon: Icons.help_outline_rounded,
          iconColor: AppColors.textMuted,
        ),
        theoryItem,
      ];
    }
  }

  int _calcPct(List<_CheckItem> items) =>
      items.fold(0, (sum, i) => sum + (i.passed ? i.pctContrib : 0));

  Future<void> _toggle(
    WidgetRef ref,
    ReadinessData current,
    String key,
    bool val,
  ) async {
    final updated = switch (key) {
      'sparring' => current.copyWith(sparringCheck: val),
      'breaking' => current.copyWith(breakingCheck: val),
      _ => current,
    };
    await ref.read(readinessProvider.notifier).save(updated);
  }

  static String _nextBeltLabel(String beltLevel) {
    return switch (beltLevel) {
      'white'  => 'Yellow Belt (노란띠)',
      'yellow' => 'Green Belt (초록띠)',
      'green'  => 'Blue Belt (파란띠)',
      'blue'   => 'Red Belt (빨간띠)',
      'red'    => 'Black Belt (검정띠)',
      _        => 'Next Belt',
    };
  }
}

// ── Data model ─────────────────────────────────────────────────────────────

class _CheckItem {
  const _CheckItem({
    required this.key,
    required this.label,
    required this.desc,
    required this.passed,
    required this.toggleable,
    required this.optional,
    required this.pctContrib,
    required this.icon,
    required this.iconColor,
  });

  final String key;
  final String label;
  final String desc;
  final bool passed;
  final bool toggleable;
  final bool optional;
  final int pctContrib;
  final IconData icon;
  final Color iconColor;
}

// ── Gradient ring ──────────────────────────────────────────────────────────

class _GradientRing extends StatelessWidget {
  const _GradientRing({required this.pct});
  final int pct;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(160, 160),
            painter: _GradientRingPainter(pct: pct / 100),
          ),
          Text(
            '$pct%',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientRingPainter extends CustomPainter {
  const _GradientRingPainter({required this.pct});
  final double pct;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    const strokeW = 12.0;
    final r = math.min(cx, cy) - strokeW / 2;
    final center = Offset(cx, cy);
    final rect = Rect.fromCircle(center: center, radius: r);

    // Background track
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW,
    );

    // Gradient arc
    final shader = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [AppColors.primary, AppColors.secondary],
    ).createShader(rect);

    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * pct,
      false,
      Paint()
        ..shader = shader
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_GradientRingPainter old) => old.pct != pct;
}

// ── Checklist card ─────────────────────────────────────────────────────────

class _CheckCard extends StatelessWidget {
  const _CheckCard({required this.item, this.onToggle});

  final _CheckItem item;
  final void Function(bool)? onToggle;

  @override
  Widget build(BuildContext context) {
    final Widget iconWidget;
    if (item.passed) {
      iconWidget = Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.check_rounded,
            color: AppColors.success, size: 22),
      );
    } else if (item.optional) {
      iconWidget = Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.muted,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.help_outline_rounded,
            color: AppColors.textMuted, size: 20),
      );
    } else {
      iconWidget = Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: item.iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(item.icon, color: item.iconColor, size: 20),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TulCard.compact(
      child: Row(
        children: [
          iconWidget,
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.label,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                    if (item.optional)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.muted,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'journal.optional'.tr(),
                          style: TextStyle(
                              fontSize: 10, color: AppColors.textMuted),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  item.desc,
                  style: TextStyle(
                      fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          if (item.toggleable && onToggle != null) ...[
            const SizedBox(width: 4),
            Switch(
              value: item.passed,
              onChanged: onToggle,
              activeThumbColor: AppColors.primary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ],
      ),
      ),
    );
  }
}

// ── Status card ────────────────────────────────────────────────────────────

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.pct, required this.incomplete});
  final int pct;
  final int incomplete;

  @override
  Widget build(BuildContext context) {
    if (pct >= 100) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppColors.gradSoft,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: AppColors.success.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.emoji_events_rounded,
                  color: AppColors.success, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'journal.readyForPromotion'.tr(),
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.success),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'journal.readyForPromotionDesc'.tr(),
                    style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final String title = pct < 33
        ? 'journal.readinessEarly'.tr()
        : pct < 66
            ? 'journal.readinessMid'.tr()
            : 'journal.almostThere'.tr();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.gradSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.bolt_rounded,
                color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 12, height: 1.5),
                children: [
                  TextSpan(
                    text: '$title ',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                  TextSpan(
                    text: 'journal.almostThereDesc'
                        .tr(namedArgs: {'count': '$incomplete'}),
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Theory test gradient button ────────────────────────────────────────────

class _GradientTheoryButton extends StatelessWidget {
  const _GradientTheoryButton(
      {required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TulPrimaryButton(
      label: label,
      icon: Icons.bolt_rounded,
      onPressed: onTap,
    );
  }
}
