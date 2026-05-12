import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/network/backend_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_shell.dart';
import '../../../shared/widgets/grad_header_text.dart';
import '../../auth/application/providers.dart';
import '../../journal/application/providers.dart';
import '../../journal/application/weekly_goal_provider.dart';
import '../../journal/domain/entities/training_session.dart';
import '../../journal/presentation/widgets/monthly_sessions_chart.dart';
import '../../journal/presentation/widgets/type_distribution_chart.dart';

// ── Period model ──────────────────────────────────────────────────────────────

enum _PeriodType { weekly, monthly }

class _Period {
  const _Period({required this.type, required this.start, required this.end});

  final _PeriodType type;
  final DateTime start;
  final DateTime end;

  String get label => labelFor('ko');

  String labelFor(String langCode) {
    if (type == _PeriodType.monthly) {
      return DateFormat.yMMMM(langCode).format(start);
    }
    final s = DateFormat('M/d').format(start);
    final e = DateFormat('M/d').format(end);
    return '$s – $e';
  }

  String get startIso => DateFormat('yyyy-MM-dd').format(start);
  String get endIso => DateFormat('yyyy-MM-dd').format(end);

  _Period prev() {
    if (type == _PeriodType.monthly) {
      final d = DateTime(start.year, start.month - 1, 1);
      return _Period(
        type: type,
        start: d,
        end: DateTime(d.year, d.month + 1, 0),
      );
    }
    final s = start.subtract(const Duration(days: 7));
    return _Period(type: type, start: s, end: s.add(const Duration(days: 6)));
  }

  _Period next() {
    if (type == _PeriodType.monthly) {
      final d = DateTime(start.year, start.month + 1, 1);
      return _Period(
        type: type,
        start: d,
        end: DateTime(d.year, d.month + 1, 0),
      );
    }
    final s = start.add(const Duration(days: 7));
    return _Period(type: type, start: s, end: s.add(const Duration(days: 6)));
  }

  bool get isCurrentOrFuture {
    final now = DateTime.now();
    return end.isAfter(now) || DateUtils.isSameDay(end, now);
  }

  static _Period currentMonth() {
    final now = DateTime.now();
    return _Period(
      type: _PeriodType.monthly,
      start: DateTime(now.year, now.month, 1),
      end: DateTime(now.year, now.month + 1, 0),
    );
  }

  static _Period currentWeek() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final start = DateUtils.dateOnly(monday);
    return _Period(
      type: _PeriodType.weekly,
      start: start,
      end: start.add(const Duration(days: 6)),
    );
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final _dojoStatsProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, key) {
  final parts = key.split('|');
  return ref
      .watch(backendClientProvider)
      .getDojoStats(startDate: parts[0], endDate: parts[1]);
});

final _homeworkStatsProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) {
  return ref.watch(backendClientProvider).getHomeworkStats();
});

// ── Root ──────────────────────────────────────────────────────────────────────

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isInstructor =
        ref.watch(authControllerProvider.select((s) => s.isInstructor));
    return isInstructor ? const _InstructorStats() : const _StudentStats();
  }
}

// ── 수련생 통계 ────────────────────────────────────────────────────────────────

class _StudentStats extends ConsumerWidget {
  const _StudentStats();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(journalControllerProvider);
    final sessions = state.sessions;

    return Scaffold(
      appBar: AppBar(
        title: GradHeaderText('nav.stats'.tr(), fontSize: 20),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async => ref.invalidate(journalControllerProvider),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text('stats.weeklyGoalTitle'.tr(),
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  _WeeklyGoalCard(sessions: sessions),
                  const SizedBox(height: 20),
                  Text('stats.cumulativeTitle'.tr(),
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  _CumulativeStatsRow(sessions: sessions),
                  const SizedBox(height: 20),
                  Text('stats.typeDistTitle'.tr(),
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  sessions.isEmpty
                      ? _EmptyCard('stats.noSessionsYet'.tr())
                      : Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: TypeDistributionChart(sessions: sessions),
                          ),
                        ),
                  const SizedBox(height: 20),
                  Text('stats.monthlyTitle'.tr(),
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  sessions.isEmpty
                      ? _EmptyCard('stats.noSessionsYet'.tr())
                      : Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: MonthlySessionsChart(sessions: sessions),
                          ),
                        ),
                  const SizedBox(height: kAppShellContentBottomInset),
                ],
              ),
            ),
    );
  }
}

// ── 사범 통계 ──────────────────────────────────────────────────────────────────

class _InstructorStats extends ConsumerStatefulWidget {
  const _InstructorStats();

  @override
  ConsumerState<_InstructorStats> createState() => _InstructorStatsState();
}

class _InstructorStatsState extends ConsumerState<_InstructorStats> {
  _Period _period = _Period.currentMonth();

  void _setPeriodType(_PeriodType type) {
    setState(() {
      _period = type == _PeriodType.monthly
          ? _Period.currentMonth()
          : _Period.currentWeek();
    });
  }

  void _prev() => setState(() => _period = _period.prev());

  void _next() {
    if (_period.isCurrentOrFuture) return;
    setState(() => _period = _period.next());
  }

  @override
  Widget build(BuildContext context) {
    final key = '${_period.startIso}|${_period.endIso}';
    final statsAsync = ref.watch(_dojoStatsProvider(key));
    final hwAsync = ref.watch(_homeworkStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: GradHeaderText('stats.dojoTitle'.tr(), fontSize: 20),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          _PeriodSelector(
            period: _period,
            onTypeChanged: _setPeriodType,
            onPrev: _prev,
            onNext: _next,
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(_dojoStatsProvider(key));
                ref.invalidate(_homeworkStatsProvider);
              },
              child: statsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('${'common.error'.tr()}: $e')),
                data: (stats) => _InstructorStatsBody(
                  stats: stats,
                  period: _period,
                  hwAsync: hwAsync,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Period selector widget ────────────────────────────────────────────────────

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({
    required this.period,
    required this.onTypeChanged,
    required this.onPrev,
    required this.onNext,
  });

  final _Period period;
  final ValueChanged<_PeriodType> onTypeChanged;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final isWeekly = period.type == _PeriodType.weekly;
    final canNext = !period.isCurrentOrFuture;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.surfaceVariant, width: 1),
        ),
      ),
      child: Column(
        children: [
          // monthly / weekly toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ToggleBtn(
                label: 'stats.monthly'.tr(),
                active: !isWeekly,
                onTap: () => onTypeChanged(_PeriodType.monthly),
              ),
              const SizedBox(width: 8),
              _ToggleBtn(
                label: 'stats.weekly'.tr(),
                active: isWeekly,
                onTap: () => onTypeChanged(_PeriodType.weekly),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // ← label →
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 20),
                onPressed: onPrev,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
              Text(
                period.labelFor(Localizations.localeOf(context).languageCode),
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: canNext ? null : AppColors.textDisabled,
                ),
                onPressed: canNext ? onNext : null,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  const _ToggleBtn({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.itfRed : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: active ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }
}

// ── Instructor stats body ─────────────────────────────────────────────────────

class _InstructorStatsBody extends StatelessWidget {
  const _InstructorStatsBody({
    required this.stats,
    required this.period,
    required this.hwAsync,
  });

  final List<Map<String, dynamic>> stats;
  final _Period period;
  final AsyncValue<Map<String, dynamic>> hwAsync;

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) {
      return Center(
        child: Text('stats.noStudents'.tr(),
            style: const TextStyle(color: AppColors.textSecondary)),
      );
    }

    final langCode = Localizations.localeOf(context).languageCode;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SummaryRow(stats: stats),
        const SizedBox(height: 20),

        Text('stats.activityTitle'.tr(),
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          period.labelFor(langCode),
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        _TrainingDonutCard(stats: stats),
        const SizedBox(height: 20),

        Text('stats.homeworkTitle'.tr(),
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        hwAsync.when(
          loading: () => const Card(
            child: SizedBox(
              height: 60,
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (e, _) =>
              _EmptyCard('stats.homeworkError'.tr()),
          data: (hw) => _HomeworkDonutCard(hw: hw),
        ),
        const SizedBox(height: kAppShellContentBottomInset),
      ],
    );
  }
}

// ── Summary row ───────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.stats});
  final List<Map<String, dynamic>> stats;

  @override
  Widget build(BuildContext context) {
    final active = stats
        .where((s) => (s['sessions_in_period'] as int? ?? 0) > 0)
        .length;
    final totalPendingHw =
        stats.fold<int>(0, (sum, s) => sum + (s['pending_homework'] as int? ?? 0));

    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            child: _SummaryCard(
              icon: Icons.people,
              color: AppColors.info,
              value: 'stats.studentCountFmt'.tr(namedArgs: {'count': stats.length.toString()}),
              label: 'stats.totalStudentsLabel'.tr(),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SummaryCard(
              icon: Icons.fitness_center,
              color: AppColors.success,
              value: 'stats.studentCountFmt'.tr(namedArgs: {'count': active.toString()}),
              label: 'stats.activeLabel'.tr(),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SummaryCard(
              icon: Icons.assignment_late_outlined,
              color: totalPendingHw > 0 ? AppColors.warning : AppColors.textSecondary,
              value: '$totalPendingHw${'stats.hwCountSuffix'.tr()}',
              label: 'stats.pendingHwLabel'.tr(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Training donut chart ──────────────────────────────────────────────────────

List<({String label, String subtitle, int minSessions, Color color})> _buildTiers() => [
  (label: 'stats.tierActive'.tr(), subtitle: 'stats.tierActive5'.tr(), minSessions: 5, color: AppColors.success),
  (label: 'stats.tierNormal'.tr(), subtitle: 'stats.tierNormal24'.tr(), minSessions: 2, color: AppColors.info),
  (label: 'stats.tierLow'.tr(), subtitle: 'stats.tierLow1'.tr(), minSessions: 1, color: AppColors.warning),
  (label: 'stats.tierNone'.tr(), subtitle: 'stats.tierNone0'.tr(), minSessions: 0, color: AppColors.textDisabled),
];

int _tierIndex(int sessions) {
  if (sessions >= 5) return 0;
  if (sessions >= 2) return 1;
  if (sessions >= 1) return 2;
  return 3;
}

class _TrainingDonutCard extends StatefulWidget {
  const _TrainingDonutCard({required this.stats});
  final List<Map<String, dynamic>> stats;

  @override
  State<_TrainingDonutCard> createState() => _TrainingDonutCardState();
}

class _TrainingDonutCardState extends State<_TrainingDonutCard> {
  int _touched = -1;

  @override
  Widget build(BuildContext context) {
    final kTiers = _buildTiers();
    final tierCounts = List.filled(4, 0);
    final tierStudents = List.generate(4, (_) => <Map<String, dynamic>>[]);

    for (final s in widget.stats) {
      final sessions = s['sessions_in_period'] as int? ?? 0;
      final idx = _tierIndex(sessions);
      tierCounts[idx]++;
      tierStudents[idx].add(s);
    }

    final sections = <PieChartSectionData>[];
    for (var i = 0; i < 4; i++) {
      final count = tierCounts[i];
      if (count == 0) continue;
      final isTouched = _touched == i;
      sections.add(PieChartSectionData(
        value: count.toDouble(),
        color: kTiers[i].color,
        radius: isTouched ? 52 : 44,
        title: 'stats.studentCountFmt'.tr(namedArgs: {'count': count.toString()}),
        titleStyle: TextStyle(
          fontSize: isTouched ? 13 : 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 150,
              height: 150,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 36,
                  sectionsSpace: 2,
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {
                      if (event is FlTapUpEvent) {
                        final idx = response?.touchedSection?.touchedSectionIndex ?? -1;
                        if (idx >= 0) {
                          int count = 0;
                          for (var t = 0; t < 4; t++) {
                            if (tierCounts[t] == 0) continue;
                            if (count == idx) {
                              _showStudentSheet(
                                  context, kTiers[t].label, tierStudents[t]);
                              break;
                            }
                            count++;
                          }
                        }
                        setState(() => _touched = -1);
                      } else if (event.isInterestedForInteractions) {
                        final idx = response?.touchedSection?.touchedSectionIndex ?? -1;
                        setState(() => _touched = idx);
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < 4; i++)
                    if (tierCounts[i] > 0)
                      _LegendRow(
                        color: kTiers[i].color,
                        label: kTiers[i].label,
                        count: tierCounts[i],
                        subtitle: kTiers[i].subtitle,
                        onTap: () => _showStudentSheet(
                            context, kTiers[i].label, tierStudents[i]),
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStudentSheet(
      BuildContext context, String tierLabel, List<Map<String, dynamic>> students) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _StudentListSheet(
        title: 'stats.tierStudentsFmt'.tr(namedArgs: {'tier': tierLabel}),
        students: students,
        valueKey: 'sessions_in_period',
        valueSuffix: 'stats.sessionsSuffix'.tr(),
      ),
    );
  }
}

// ── Homework donut chart ──────────────────────────────────────────────────────

class _HomeworkDonutCard extends StatefulWidget {
  const _HomeworkDonutCard({required this.hw});
  final Map<String, dynamic> hw;

  @override
  State<_HomeworkDonutCard> createState() => _HomeworkDonutCardState();
}

class _HomeworkDonutCardState extends State<_HomeworkDonutCard> {
  int _touched = -1;

  @override
  Widget build(BuildContext context) {
    final pending = widget.hw['pending_total'] as int? ?? 0;
    final completed = widget.hw['completed_total'] as int? ?? 0;
    final total = pending + completed;

    if (total == 0) {
      return _EmptyCard('stats.noData'.tr());
    }

    final sections = [
      PieChartSectionData(
        value: pending.toDouble(),
        color: AppColors.warning,
        radius: _touched == 0 ? 52 : 44,
        title: '$pending',
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        value: completed.toDouble(),
        color: AppColors.success,
        radius: _touched == 1 ? 52 : 44,
        title: '$completed',
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 150,
              height: 150,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 36,
                  sectionsSpace: 2,
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {
                      if (event is FlTapUpEvent) {
                        final idx = response
                                ?.touchedSection?.touchedSectionIndex ??
                            -1;
                        if (idx == 0) {
                          _showHomeworkSheet(context, isPending: true);
                        } else if (idx == 1) {
                          _showHomeworkSheet(context, isPending: false);
                        }
                        setState(() => _touched = -1);
                      } else if (event.isInterestedForInteractions) {
                        setState(() => _touched =
                            response?.touchedSection?.touchedSectionIndex ??
                                -1);
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LegendRow(
                    color: AppColors.warning,
                    label: 'stats.hwPending'.tr(),
                    count: pending,
                    subtitle: 'stats.hwCountSuffix'.tr(),
                    onTap: () => _showHomeworkSheet(context, isPending: true),
                  ),
                  _LegendRow(
                    color: AppColors.success,
                    label: 'stats.hwCompleted'.tr(),
                    count: completed,
                    subtitle: 'stats.hwCompletedSuffix'.tr(),
                    onTap: () => _showHomeworkSheet(context, isPending: false),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHomeworkSheet(BuildContext context, {required bool isPending}) {
    final key = isPending ? 'pending_details' : 'completed_details';
    final details =
        (widget.hw[key] as List?)?.cast<Map<String, dynamic>>() ?? [];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _HomeworkDetailSheet(
        title: isPending ? 'stats.hwPendingTitle'.tr() : 'stats.hwCompletedTitle'.tr(),
        details: details,
        isPending: isPending,
      ),
    );
  }
}

// ── Bottom sheet: student tier list ──────────────────────────────────────────

class _StudentListSheet extends StatelessWidget {
  const _StudentListSheet({
    required this.title,
    required this.students,
    required this.valueKey,
    required this.valueSuffix,
  });

  final String title;
  final List<Map<String, dynamic>> students;
  final String valueKey;
  final String valueSuffix;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.45,
      minChildSize: 0.25,
      maxChildSize: 0.85,
      builder: (_, controller) => Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textDisabled,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Text(title,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                Text(
                    'stats.studentCountFmt'.tr(namedArgs: {'count': students.length.toString()}),
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          const Divider(height: 16),
          Expanded(
            child: ListView.builder(
              controller: controller,
              itemCount: students.length,
              itemBuilder: (_, i) {
                final s = students[i];
                final name = s['display_name'] as String? ?? '';
                final belt = s['belt_level'] as String? ?? '';
                final val = s[valueKey] as int? ?? 0;
                return ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.itfRed.withValues(alpha: 0.12),
                    child: Text(
                      name.isNotEmpty ? name[0] : '?',
                      style: const TextStyle(
                          color: AppColors.itfRed,
                          fontSize: 13,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(name,
                      style:
                          const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: belt.isNotEmpty ? Text(belt) : null,
                  trailing: Text(
                    '$val$valueSuffix',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bottom sheet: homework details ────────────────────────────────────────────

class _HomeworkDetailSheet extends StatelessWidget {
  const _HomeworkDetailSheet({
    required this.title,
    required this.details,
    required this.isPending,
  });

  final String title;
  final List<Map<String, dynamic>> details;
  final bool isPending;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (_, controller) => Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textDisabled,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ),
          const Divider(height: 16),
          if (details.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Text('stats.noData'.tr(),
                  style: const TextStyle(color: AppColors.textSecondary)),
            )
          else
            Expanded(
              child: ListView.builder(
                controller: controller,
                itemCount: details.length,
                itemBuilder: (_, i) {
                  final entry = details[i];
                  final studentName = entry['student_name'] as String? ?? '';
                  final items =
                      (entry['items'] as List?)?.cast<Map<String, dynamic>>() ??
                          [];
                  return ExpansionTile(
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: (isPending ? AppColors.warning : AppColors.success)
                          .withValues(alpha: 0.15),
                      child: Text(
                        studentName.isNotEmpty ? studentName[0] : '?',
                        style: TextStyle(
                          color: isPending ? AppColors.warning : AppColors.success,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(studentName,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('${items.length}${'stats.hwCountSuffix'.tr()}'),
                    children: items.map((hw) {
                      final content = hw['content'] as String? ?? '';
                      final dateStr = isPending
                          ? hw['due_date'] as String?
                          : hw['completed_at'] as String?;
                      String dateDisplay = '';
                      if (dateStr != null) {
                        final d = DateTime.tryParse(dateStr);
                        if (d != null) {
                          if (isPending) {
                            dateDisplay = 'dojo.dueDateFmt'.tr(namedArgs: {
                              'month': d.month.toString(),
                              'day': d.day.toString(),
                            });
                          } else {
                            dateDisplay = '${'dojo.complete'.tr()} ${DateFormat('MM/dd').format(d.toLocal())}';
                          }
                        }
                      }
                      return ListTile(
                        dense: true,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 32, vertical: 0),
                        leading: Icon(
                          isPending
                              ? Icons.assignment_outlined
                              : Icons.check_circle_outline,
                          size: 16,
                          color: isPending
                              ? AppColors.warning
                              : AppColors.success,
                        ),
                        title: Text(content,
                            style: const TextStyle(fontSize: 13)),
                        trailing: dateDisplay.isNotEmpty
                            ? Text(
                                dateDisplay,
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary),
                              )
                            : null,
                      );
                    }).toList(),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

// ── Legend row ────────────────────────────────────────────────────────────────

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.color,
    required this.label,
    required this.count,
    required this.subtitle,
    required this.onTap,
  });

  final Color color;
  final String label;
  final int count;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  Text(subtitle,
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
            Text('$count',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontWeight: FontWeight.bold, color: color)),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, size: 14, color: AppColors.textDisabled),
          ],
        ),
      ),
    );
  }
}

// ── Shared small widgets ──────────────────────────────────────────────────────

class _EmptyCard extends StatelessWidget {
  const _EmptyCard(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            text,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.textSecondary),
          ),
        ),
      ),
    );
  }
}

class _WeeklyGoalCard extends ConsumerWidget {
  const _WeeklyGoalCard({required this.sessions});
  final List<TrainingSession> sessions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalAsync = ref.watch(weeklyGoalProvider);
    return goalAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (goal) {
        final now = DateTime.now();
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final thisWeek = sessions
            .where((s) => !s.date.isBefore(DateUtils.dateOnly(weekStart)))
            .length;
        final target = goal.target;
        final progress = target == 0 ? 0.0 : (thisWeek / target).clamp(0.0, 1.0);
        final done = thisWeek >= target;

        return Card(
          color: done ? AppColors.success.withValues(alpha: 0.08) : null,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      done ? Icons.check_circle : Icons.flag_outlined,
                      size: 16,
                      color: done ? AppColors.success : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      done
                          ? 'stats.weeklyGoalDone'.tr()
                          : 'stats.weeklyGoalProgress'.tr(namedArgs: {'done': thisWeek.toString(), 'goal': target.toString()}),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: done ? AppColors.success : null,
                          ),
                    ),
                    const Spacer(),
                    Text(
                      '${(progress * 100).round()}%',
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
                    value: progress,
                    minHeight: 6,
                    backgroundColor: AppColors.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      done ? AppColors.success : AppColors.itfRed,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CumulativeStatsRow extends StatelessWidget {
  const _CumulativeStatsRow({required this.sessions});
  final List<TrainingSession> sessions;

  @override
  Widget build(BuildContext context) {
    final totalMin =
        sessions.fold<int>(0, (sum, s) => sum + s.durationMinutes);
    final avgScore = sessions.isEmpty
        ? 0.0
        : sessions.fold<double>(0, (sum, s) => sum + s.score) / sessions.length;

    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.fitness_center,
              color: AppColors.itfRed,
              value: '${sessions.length}${'stats.sessionsSuffix'.tr()}',
              label: 'stats.totalSessions'.tr(),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatCard(
              icon: Icons.timer_outlined,
              color: AppColors.info,
              value: totalMin >= 60
                  ? '${totalMin ~/ 60}h ${totalMin % 60}m'
                  : '$totalMin${'journal.min'.tr()}',
              label: 'stats.totalTime'.tr(),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatCard(
              icon: Icons.star_rounded,
              color: AppColors.warning,
              value: sessions.isEmpty ? '-' : avgScore.toStringAsFixed(1),
              label: 'journal.avgScore'.tr(),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
