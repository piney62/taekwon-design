import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/backend_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/tul_text_styles.dart';
import '../../../shared/widgets/app_shell.dart' show kAppShellContentBottomInset;
import '../../../shared/widgets/badge.dart';
import '../../../shared/widgets/grad_header_text.dart';
import '../../../shared/widgets/list_row.dart';
import '../../../shared/widgets/stat_card.dart';
import '../../../shared/widgets/tul_buttons.dart';
import '../../../shared/widgets/tul_card.dart';
import '../../../shared/widgets/tul_modal_sheet.dart';
import '../../auth/application/providers.dart';
import '../../settings/application/providers.dart';
import '../../settings/domain/entities/belt_level.dart';
import '../application/providers.dart';
import '../application/readiness_provider.dart';
import '../application/weakness_provider.dart';
import '../application/weekly_goal_provider.dart';
import '../domain/entities/readiness_data.dart';
import '../domain/entities/training_session.dart';
import '../domain/entities/training_type.dart';
import 'screens/all_sessions_screen.dart';
import 'screens/readiness_detail_screen.dart';
import 'screens/weakness_detail_screen.dart';
import 'widgets/add_session_sheet.dart';
import 'widgets/homework_banner.dart';
import 'widgets/training_calendar.dart';

class JournalScreen extends ConsumerWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(journalControllerProvider);
    final authState = ref.watch(authControllerProvider);
    final beltLevel =
        ref.watch(settingsControllerProvider).valueOrNull?.beltLevel ??
            BeltLevel.white;
    final isDojo = authState.dojoConnected;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(journalControllerProvider);
                ref.invalidate(readinessProvider);
                ref.invalidate(weaknessPatternsProvider);
              },
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Header ──────────────────────────────────
                            _Header(
                              isDojo: isDojo,
                              instructorName: authState.instructorName,
                            ),
                            const SizedBox(height: 20),

                            // ── Stats strip ──────────────────────────────
                            _StatsStrip(
                              sessions: state.sessions,
                              isDojo: isDojo,
                            ),
                            const SizedBox(height: 16),

                            // ── Streak milestone ─────────────────────────
                            _StreakBanner(sessions: state.sessions),

                            // ── Weekly goal (non-dojo students only) ─────
                            if (!isDojo && !authState.isInstructor)
                              const _WeeklyGoalCard(),

                            // ── Homework ─────────────────────────────────
                            if (isDojo)
                              _HomeworkCard(
                                instructorName: authState.instructorName,
                              ),

                            // ── Belt Progress ─────────────────────────────
                            _BeltProgressCard(
                              sessions: state.sessions,
                              beltLevel: beltLevel,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (_) => ReadinessDetailScreen(
                                    sessions: state.sessions,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // ── Weak Points ───────────────────────────────
                            const _WeakPointsCard(),
                            const SizedBox(height: 16),

                            // ── Calendar ─────────────────────────────────
                            _CalendarCard(
                              sessions: state.sessions,
                              onDayTap: (date) => _showDaySessions(
                                  context, ref, date, state.sessions),
                            ),
                            const SizedBox(height: 16),

                            // ── Add training button ──────────────────────
                            _AddTrainingButton(
                              onTap: () => _addSession(context, ref),
                            ),
                            const SizedBox(height: 24),

                            // ── Recent records header ────────────────────
                            _SectionHeader(
                              title: 'journal.recentRecords'.tr(),
                              onViewAll: () => Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (_) => const AllSessionsScreen(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── Recent record list ────────────────────────────────
                  if (state.sessions.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _EmptyCard(
                          onTap: () => _addSession(context, ref),
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                          child: _RecordCard(session: state.sessions[i]),
                        ),
                        childCount: state.sessions.take(3).length,
                      ),
                    ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: kAppShellContentBottomInset),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _addSession(BuildContext context, WidgetRef ref) async {
    final session = await showModalBottomSheet<TrainingSession>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const AddSessionSheet(),
    );
    if (session != null) {
      await ref.read(journalControllerProvider.notifier).addSession(session);
    }
  }

  void _showDaySessions(BuildContext context, WidgetRef ref, DateTime date,
      List<TrainingSession> allSessions) {
    final daySessions =
        allSessions.where((s) => DateUtils.isSameDay(s.date, date)).toList();
    if (daySessions.isEmpty) return;

    final langCode = Localizations.localeOf(context).languageCode;
    final dateFmt = DateFormat.MMMd(langCode).format(date);
    final title = 'journal.daySessionsTitle'.tr(
        namedArgs: {'date': dateFmt, 'count': daySessions.length.toString()});

    TulModalSheet.show<void>(
      context: context,
      title: title,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.55,
        ),
        child: ListView(
          padding: const EdgeInsets.only(top: 4, bottom: 8),
          children: daySessions
              .map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _RecordCard(session: s),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

// ── Header ─────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.isDojo, required this.instructorName});

  final bool isDojo;
  final String instructorName;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GradHeaderText(
                '${'journal.titlePrefix'.tr()} ${'journal.titleAccent'.tr()}',
              ),
              const SizedBox(height: 4),
              Text(
                'journal.trackProgress'.tr(),
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        if (isDojo && instructorName.isNotEmpty)
          TulBadge(
            label: instructorName,
            color: TulBadgeColor.blue,
            icon: Icons.school_rounded,
          ),
      ],
    );
  }
}

// ── Stats strip ───────────────────────────────────────────────────────────

class _StatsStrip extends ConsumerWidget {
  const _StatsStrip({required this.sessions, required this.isDojo});

  final List<TrainingSession> sessions;
  final bool isDojo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = _calcStreak(sessions);
    final monthCount = _monthCount(sessions);
    final pendingCount = isDojo
        ? ref.watch(myHomeworkProvider).maybeWhen(
              data: (list) => list.length,
              orElse: () => 0,
            )
        : 0;

    return Row(
      children: [
        Expanded(
          child: StatCard(
            icon: Icons.local_fire_department_rounded,
            value: '$streak',
            label: 'journal.streak'.tr(),
            color: StatCardColor.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: StatCard(
            icon: Icons.trending_up_rounded,
            value: '$monthCount',
            label: 'journal.thisMonth'.tr(),
            color: StatCardColor.secondary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: StatCard(
            icon: Icons.task_alt_rounded,
            value: isDojo ? '$pendingCount' : '-',
            label: 'journal.pendingHomework'.tr(),
            color: StatCardColor.accent,
          ),
        ),
      ],
    );
  }

  int _calcStreak(List<TrainingSession> s) {
    if (s.isEmpty) return 0;
    final dates = s.map((x) => DateUtils.dateOnly(x.date)).toSet().toList()
      ..sort();
    final today = DateUtils.dateOnly(DateTime.now());
    final yesterday = today.subtract(const Duration(days: 1));
    DateTime cursor;
    if (dates.contains(today)) {
      cursor = today;
    } else if (dates.contains(yesterday)) {
      cursor = yesterday;
    } else {
      return 0;
    }
    int streak = 1;
    cursor = cursor.subtract(const Duration(days: 1));
    while (dates.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  int _monthCount(List<TrainingSession> s) {
    final now = DateTime.now();
    return s.where((x) => x.date.year == now.year && x.date.month == now.month)
        .length;
  }
}

// ── Streak milestone ──────────────────────────────────────────────────────

class _StreakBanner extends StatelessWidget {
  const _StreakBanner({required this.sessions});
  final List<TrainingSession> sessions;

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) return const SizedBox.shrink();
    final dates = sessions
        .map((s) => DateUtils.dateOnly(s.date))
        .toSet()
        .toList()
      ..sort();
    final today = DateUtils.dateOnly(DateTime.now());
    final yesterday = today.subtract(const Duration(days: 1));
    if (!dates.contains(today) && !dates.contains(yesterday)) {
      return const SizedBox.shrink();
    }
    DateTime cursor = dates.contains(today) ? today : yesterday;
    int streak = 1;
    cursor = cursor.subtract(const Duration(days: 1));
    while (dates.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    String? message;
    if (streak == 30 || streak == 60 || streak == 100) {
      message = 'journal.milestoneStreakGold'
          .tr(namedArgs: {'streak': streak.toString()});
    } else if (streak == 7 || streak == 14) {
      message = 'journal.milestoneStreakFire'
          .tr(namedArgs: {'streak': streak.toString()});
    }
    if (message == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: AppColors.gradMain,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          message,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

// ── Homework card ─────────────────────────────────────────────────────────

class _HomeworkCard extends ConsumerWidget {
  const _HomeworkCard({required this.instructorName});
  final String instructorName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeworkAsync = ref.watch(myHomeworkProvider);
    return homeworkAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (e, st) => const SizedBox.shrink(),
      data: (list) {
        if (list.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: TulCard.compact(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'journal.sabumHomework'.tr(),
                      style: TulTextStyles.cardHeader(color: AppColors.text),
                    ),
                    const Spacer(),
                    TulBadge(
                      label: 'journal.tasksCountFmt'
                          .tr(namedArgs: {'count': list.length.toString()}),
                      color: TulBadgeColor.muted,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...list.map((hw) => _HomeworkRow(
                      hw: hw,
                      onComplete: () async {
                        await ref
                            .read(backendClientProvider)
                            .completeHomework(hw['id'] as int);
                        ref.invalidate(myHomeworkProvider);
                      },
                    )),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ignore: must_be_immutable
class _HomeworkRow extends StatefulWidget {
  const _HomeworkRow({required this.hw, required this.onComplete});
  final Map<String, dynamic> hw;
  final Future<void> Function() onComplete;

  @override
  State<_HomeworkRow> createState() => _HomeworkRowState();
}

class _HomeworkRowState extends State<_HomeworkRow> {
  bool _done = false;

  String _dueLabel(String? raw) {
    if (raw == null) return '';
    final dt = DateTime.tryParse(raw);
    if (dt == null) return '';
    final days = dt.difference(DateTime.now()).inDays;
    if (days < 0) return 'journal.overdueHw'.tr();
    if (days == 0) return 'journal.dueToday'.tr();
    return 'journal.dueInDaysFmt'.tr(namedArgs: {'days': days.toString()});
  }

  @override
  Widget build(BuildContext context) {
    final content = widget.hw['content'] as String? ?? '';
    final dueLabel = _dueLabel(widget.hw['due_date'] as String?);

    return GestureDetector(
      onTap: () async {
        if (_done) return;
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            title: Text('journal.hwSubmitTitle'.tr(),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            content: Text('journal.hwSubmitBody'.tr(),
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text('journal.hwSubmitCancel'.tr(),
                    style: TextStyle(color: AppColors.textMuted)),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text('journal.hwSubmitConfirm'.tr(),
                    style: TextStyle(
                        color: AppColors.primary, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        );
        if (confirmed != true) return;
        setState(() => _done = true);
        try {
          await widget.onComplete();
        } catch (_) {
          if (mounted) setState(() => _done = false);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 18,
              height: 18,
              margin: const EdgeInsets.only(top: 1),
              decoration: BoxDecoration(
                color: _done
                    ? AppColors.success.withValues(alpha: 0.2)
                    : Colors.transparent,
                border: Border.all(
                  color: _done ? AppColors.success : AppColors.border,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: _done
                  ? Icon(Icons.check_rounded,
                      size: 12, color: AppColors.success)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _done ? AppColors.textMuted : AppColors.text,
                      decoration: _done ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (dueLabel.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      dueLabel,
                      style: TextStyle(
                        fontSize: 11,
                        color: dueLabel == 'journal.overdueHw'.tr()
                            ? AppColors.primary
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Belt Progress card ─────────────────────────────────────────────────────

class _BeltProgressCard extends ConsumerWidget {
  const _BeltProgressCard({
    required this.sessions,
    required this.beltLevel,
    required this.onTap,
  });

  final List<TrainingSession> sessions;
  final BeltLevel beltLevel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readinessAsync = ref.watch(readinessProvider);
    final weaknessAsync = ref.watch(weaknessPatternsProvider);
    final authState = ref.watch(authControllerProvider);

    return readinessAsync.when(
      loading: () => _buildCard(context, pct: 0, passed: 0, total: 6),
      error: (e, st) => const SizedBox.shrink(),
      data: (readiness) {
        final weaknesses = weaknessAsync.valueOrNull ?? [];
        final result = _computeReadiness(
          isDojo: authState.dojoConnected,
          readiness: readiness,
          sessions: sessions,
          joinedAt: authState.joinedAt,
          weaknessCount: weaknesses.length,
        );
        return _buildCard(context,
            pct: result.pct, passed: result.passed, total: result.total);
      },
    );
  }

  Widget _buildCard(BuildContext context,
      {required int pct, required int passed, required int total}) {
    final nextBeltStr = _nextBeltLabel(beltLevel);

    return TulCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(80, 80),
                  painter: _MiniRingPainter(pct: pct / 100),
                ),
                Text(
                  '$pct%',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'journal.nextBelt'.tr(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                ShaderMask(
                  shaderCallback: (b) =>
                      AppColors.gradMain.createShader(b),
                  child: Text(
                    '${beltLevel.i18nKey.tr()} → $nextBeltStr',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'journal.criteriaMetFmt'.tr(namedArgs: {
                    'passed': '$passed',
                    'total': '$total',
                  }),
                  style: TextStyle(
                      fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              color: AppColors.textMuted, size: 20),
        ],
      ),
    );
  }

  static ({int pct, int passed, int total}) _computeReadiness({
    required bool isDojo,
    required ReadinessData readiness,
    required List<TrainingSession> sessions,
    required DateTime? joinedAt,
    required int weaknessCount,
  }) {
    final daysSince =
        joinedAt != null ? DateTime.now().difference(joinedAt).inDays : 0;
    final autoSaved = sessions.where((s) => s.isAutoSaved).length;
    final avgScore = sessions.isEmpty
        ? 0.0
        : sessions.fold(0, (s, e) => s + e.score) / sessions.length;

    final periodOk = daysSince >= 28;
    final trainingOk = isDojo ? autoSaved >= 10 : sessions.length >= 10;
    final qualityOk = isDojo ? weaknessCount == 0 : avgScore >= 3.5;
    final sparringOk = readiness.sparringCheck;
    final breakingOk = readiness.breakingCheck;
    final theoryOk = readiness.theoryTestPassed;

    final passed = [periodOk, trainingOk, qualityOk, sparringOk, breakingOk, theoryOk]
        .where((b) => b)
        .length;

    int pct = 0;
    pct += periodOk ? 20 : (daysSince * 20 ~/ 28).clamp(0, 20);
    final trainCount = isDojo ? autoSaved : sessions.length;
    pct += trainingOk ? 20 : (trainCount * 20 ~/ 10).clamp(0, 20);
    if (isDojo) {
      pct += math.max(0, 20 - weaknessCount * 4).clamp(0, 20);
    } else {
      pct += qualityOk ? 20 : 0;
    }
    pct += sparringOk ? 10 : 0;
    pct += breakingOk ? 10 : 0;
    pct += theoryOk ? 20 : 0;

    return (pct: pct.clamp(0, 100), passed: passed, total: 6);
  }

  static String _nextBeltLabel(BeltLevel level) {
    return switch (level) {
      BeltLevel.white  => 'belt.yellow'.tr(),
      BeltLevel.yellow => 'belt.green'.tr(),
      BeltLevel.green  => 'belt.blue'.tr(),
      BeltLevel.blue   => 'belt.red'.tr(),
      BeltLevel.red    => 'belt.black'.tr(),
      BeltLevel.black  => 'belt.black'.tr(),
    };
  }
}

class _MiniRingPainter extends CustomPainter {
  const _MiniRingPainter({required this.pct});
  final double pct;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    const strokeW = 8.0;
    final r = math.min(cx, cy) - strokeW / 2;
    final center = Offset(cx, cy);
    final rect = Rect.fromCircle(center: center, radius: r);

    canvas.drawCircle(
      center,
      r,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW,
    );

    if (pct > 0) {
      final shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: 3 * math.pi / 2,
        colors: const [
          Color(0xFFEF4444),
          Color(0xFFEC4899),
          Color(0xFF3B82F6),
        ],
        stops: const [0.0, 0.5, 1.0],
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
  }

  @override
  bool shouldRepaint(_MiniRingPainter old) => old.pct != pct;
}

// ── Weak Points card ──────────────────────────────────────────────────────

class _WeakPointsCard extends ConsumerWidget {
  const _WeakPointsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weaknessAsync = ref.watch(weaknessPatternsProvider);
    return weaknessAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (e, st) => const SizedBox.shrink(),
      data: (list) {
        final top = list.take(3).toList();
        return TulCard(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => const WeaknessDetailScreen(),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'journal.weakPoints'.tr(),
                    style: TulTextStyles.cardHeader(color: AppColors.text),
                  ),
                  const Spacer(),
                  Icon(Icons.chevron_right_rounded,
                      color: AppColors.textMuted, size: 18),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.document_scanner_outlined,
                      size: 11, color: AppColors.secondary),
                  const SizedBox(width: 4),
                  Text(
                    'journal.weakPointsSource'.tr(),
                    style: TextStyle(
                        fontSize: 10,
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (top.isEmpty)
                Text(
                  'journal.noWeaknessYet'.tr(),
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                )
              else
                ...top.map((w) {
                  final color = _badgeColor(w.consecutiveCount);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '×${w.consecutiveCount}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: color,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            w.movementName,
                            style: const TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  static Color _badgeColor(int count) {
    if (count >= 4) return AppColors.primary;
    if (count >= 3) return const Color(0xFFD97706);
    return AppColors.secondary;
  }
}

// ── Calendar card ─────────────────────────────────────────────────────────

class _CalendarCard extends StatelessWidget {
  const _CalendarCard({required this.sessions, required this.onDayTap});

  final List<TrainingSession> sessions;
  final void Function(DateTime) onDayTap;

  @override
  Widget build(BuildContext context) {
    return TulCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      child: TrainingCalendar(
        sessions: sessions,
        showNavigation: true,
        onDayTap: onDayTap,
      ),
    );
  }
}

// ── Add training button ───────────────────────────────────────────────────

class _AddTrainingButton extends StatelessWidget {
  const _AddTrainingButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TulSecondaryButton(
      label: 'journal.addSession'.tr(),
      icon: Icons.add_rounded,
      onPressed: onTap,
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onViewAll});

  final String title;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TulTextStyles.cardHeader(color: AppColors.text)),
        TulGhostButton(
          label: 'journal.viewAll'.tr(),
          onPressed: onViewAll,
          color: AppColors.primary,
        ),
      ],
    );
  }
}

// ── Record card ───────────────────────────────────────────────────────────

class _RecordCard extends StatelessWidget {
  const _RecordCard({required this.session});
  final TrainingSession session;

  @override
  Widget build(BuildContext context) {
    final color = _typeColor(session.type);
    final score = (session.score * 20).clamp(0, 100);

    final title = session.patternName.isNotEmpty
        ? session.patternName
        : session.type.i18nKey.tr();

    String subtitle = '${session.durationMinutes} min';
    if (session.selectedMovements.isNotEmpty) {
      subtitle += ' · ${session.selectedMovements.length} '
          '${'journal.movementsFmt'.tr(namedArgs: {'count': ''}).trim()}';
    }

    return TulCard(
      padding: EdgeInsets.zero,
      child: ListRow(
        icon: _typeIcon(session.type),
        iconColor: _typeListRowColor(session.type),
        title: title,
        sub: subtitle,
        trailing: Text(
          '$score%',
          style: TulTextStyles.bodyStrong(color: color),
        ),
      ),
    );
  }

  static Color _typeColor(TrainingType t) => switch (t) {
        TrainingType.pattern  => AppColors.primary,
        TrainingType.sparring => AppColors.secondary,
        TrainingType.kicks    => AppColors.accent,
        TrainingType.punches  => AppColors.primary,
        TrainingType.fitness  => AppColors.secondary,
        TrainingType.other    => AppColors.accent,
      };

  static ListRowColor _typeListRowColor(TrainingType t) => switch (t) {
        TrainingType.pattern  => ListRowColor.primary,
        TrainingType.sparring => ListRowColor.secondary,
        TrainingType.kicks    => ListRowColor.accent,
        TrainingType.punches  => ListRowColor.primary,
        TrainingType.fitness  => ListRowColor.secondary,
        TrainingType.other    => ListRowColor.accent,
      };

  static IconData _typeIcon(TrainingType t) => switch (t) {
        TrainingType.pattern  => Icons.track_changes_rounded,
        TrainingType.sparring => Icons.sports_martial_arts_rounded,
        TrainingType.kicks    => Icons.arrow_upward_rounded,
        TrainingType.punches  => Icons.sports_kabaddi_rounded,
        TrainingType.fitness  => Icons.fitness_center_rounded,
        TrainingType.other    => Icons.more_horiz_rounded,
      };
}

// ── Empty card ────────────────────────────────────────────────────────────

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TulCard(
      padding: const EdgeInsets.all(28),
      onTap: onTap,
      child: Column(
        children: [
          Icon(Icons.book_outlined, color: AppColors.textMuted, size: 36),
          const SizedBox(height: 10),
          Text(
            'journal.noSessionsYet'.tr(),
            style: TextStyle(fontSize: 14, color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Weekly Goal Card ──────────────────────────────────────────────────────────

class _WeeklyGoalCard extends ConsumerWidget {
  const _WeeklyGoalCard();

  static const _itfPatterns = [
    'Saju Jirugi', 'Saju Makgi',
    'Chon-Ji', 'Dan-Gun', 'Do-San', 'Won-Hyo', 'Yul-Gok',
    'Joong-Gun', 'Toi-Gye', 'Hwa-Rang', 'Choong-Moo',
    'Kwang-Gae', 'Po-Eun', 'Ge-Baek', 'Eui-Am', 'Choong-Jang',
    'Juche', 'Sam-Il', 'Yoo-Sin', 'Choi-Yong', 'Yon-Gae',
    'Ul-Ji', 'Moon-Moo', 'So-San', 'Se-Jong', 'Tong-Il',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(weeklyProgressProvider);

    final progressColor = progress.goalMet
        ? AppColors.success
        : progress.progressRatio >= 0.5
            ? AppColors.warning
            : AppColors.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TulCard.compact(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row ──────────────────────────────────────────────
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: progressColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.flag_rounded, color: progressColor, size: 17),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'journal.weeklyGoalTitle'.tr(),
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                GestureDetector(
                  onTap: () => _openSetup(context, ref, progress),
                  child: Row(
                    children: [
                      Text(
                        'journal.weeklyGoalSet'.tr(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const Icon(Icons.chevron_right_rounded,
                          color: AppColors.primary, size: 16),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ── Count + progress bar ─────────────────────────────────────
            Row(
              children: [
                Text(
                  '${progress.thisWeekCount} / ${progress.target}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: progressColor,
                      ),
                ),
                const SizedBox(width: 8),
                Text(
                  'journal.weeklyGoalUnit'.tr(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.progressRatio,
                minHeight: 6,
                backgroundColor: AppColors.muted,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
            const SizedBox(height: 10),

            // ── Streak + days left ───────────────────────────────────────
            Row(
              children: [
                if (progress.streak > 0) ...[
                  const Text('🔥', style: TextStyle(fontSize: 13)),
                  const SizedBox(width: 3),
                  Text(
                    'journal.weeklyGoalStreak'
                        .tr(namedArgs: {'n': progress.streak.toString()}),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(width: 12),
                ],
                Icon(Icons.schedule_rounded,
                    size: 13, color: AppColors.textSecondary),
                const SizedBox(width: 3),
                Text(
                  'journal.weeklyGoalDaysLeft'
                      .tr(namedArgs: {'n': progress.daysLeft.toString()}),
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.textSecondary),
                ),
                if (progress.goalMet) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'journal.weeklyGoalDone'.tr(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ],
            ),

            // ── Focus pattern ────────────────────────────────────────────
            if (progress.focusPattern != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.sports_martial_arts_rounded,
                      size: 13, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    'journal.weeklyGoalFocus'.tr(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: (progress.focusPatternCompleted
                              ? AppColors.success
                              : AppColors.accent)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      progress.focusPattern!,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: progress.focusPatternCompleted
                                ? AppColors.success
                                : AppColors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    progress.focusPatternCompleted
                        ? 'journal.weeklyGoalFocusDone'.tr()
                        : 'journal.weeklyGoalFocusPending'.tr(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: progress.focusPatternCompleted
                              ? AppColors.success
                              : AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _openSetup(BuildContext context, WidgetRef ref, WeeklyProgress progress) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _GoalSetupSheet(
        initialTarget: progress.target,
        initialFocus: progress.focusPattern,
        patterns: _itfPatterns,
        onSave: (target, focus) {
          ref.read(weeklyGoalProvider.notifier).setGoal(target);
          ref.read(weeklyGoalProvider.notifier).setFocusPattern(focus);
        },
      ),
    );
  }
}

// ── Goal Setup Sheet ──────────────────────────────────────────────────────────

class _GoalSetupSheet extends StatefulWidget {
  const _GoalSetupSheet({
    required this.initialTarget,
    required this.initialFocus,
    required this.patterns,
    required this.onSave,
  });

  final int initialTarget;
  final String? initialFocus;
  final List<String> patterns;
  final void Function(int target, String? focus) onSave;

  @override
  State<_GoalSetupSheet> createState() => _GoalSetupSheetState();
}

class _GoalSetupSheetState extends State<_GoalSetupSheet> {
  late int _target;
  String? _focus;

  @override
  void initState() {
    super.initState();
    _target = widget.initialTarget;
    _focus = widget.initialFocus;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text('journal.weeklyGoalTitle'.tr(),
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 20),

              // ── Session target ─────────────────────────────────────
              Text(
                'journal.weeklyGoalTargetLabel'.tr(
                    namedArgs: {'count': _target.toString()}),
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              Slider(
                value: _target.toDouble(),
                min: 1,
                max: 7,
                divisions: 6,
                activeColor: AppColors.primary,
                inactiveColor: AppColors.muted,
                label: _target.toString(),
                onChanged: (v) => setState(() => _target = v.round()),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('settings.weeklyGoalMin'.tr(),
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.textSecondary)),
                  Text('settings.weeklyGoalMax'.tr(),
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.textSecondary)),
                ],
              ),
              const SizedBox(height: 16),

              // ── Focus pattern ──────────────────────────────────────
              Text('journal.weeklyGoalFocusLabel'.tr(),
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    value: _focus,
                    isExpanded: true,
                    dropdownColor: AppColors.surface,
                    hint: Text('journal.weeklyGoalFocusNone'.tr(),
                        style: Theme.of(context).textTheme.bodyMedium),
                    items: [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text('journal.weeklyGoalFocusNone'.tr()),
                      ),
                      ...widget.patterns.map((p) => DropdownMenuItem<String?>(
                            value: p,
                            child: Text(p),
                          )),
                    ],
                    onChanged: (v) => setState(() => _focus = v),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              TulPrimaryButton(
                label: 'settings.save'.tr(),
                onPressed: () {
                  widget.onSave(_target, _focus);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
