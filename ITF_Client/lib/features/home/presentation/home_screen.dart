import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/application/providers.dart';
import '../../journal/application/providers.dart';
import '../../journal/domain/entities/training_session.dart';
import '../../journal/domain/entities/training_type.dart';
import '../../settings/application/providers.dart';
import '../../settings/domain/entities/belt_level.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final settingsAsync = ref.watch(settingsControllerProvider);
    final journalState = ref.watch(journalControllerProvider);

    final beltLevel = settingsAsync.valueOrNull?.beltLevel ?? BeltLevel.white;

    if (authState.isInstructor) {
      return _InstructorHome(authState: authState);
    }

    final sessions = journalState.sessions;
    final streak = _calcStreak(sessions);
    final monthCount = _monthCount(sessions);
    final beltPct = _beltProgress(sessions, beltLevel);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(journalControllerProvider),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Header row ──────────────────────────────────
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Brand tag
                                Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        gradient: AppColors.gradMain,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Icon(
                                        Icons.local_fire_department,
                                        size: 13,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'ITF TulMaster',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppColors.textSecondary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'home.greeting'
                                      .tr(namedArgs: {'name': ''}),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineLarge
                                      ?.copyWith(height: 1.1),
                                ),
                                ShaderMask(
                                  shaderCallback: (b) =>
                                      AppColors.gradMain.createShader(b),
                                  child: Text(
                                    authState.displayName.isEmpty
                                        ? '—'
                                        : authState.displayName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineLarge
                                        ?.copyWith(
                                          color: Colors.white,
                                          height: 1.1,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          InkWell(
                            onTap: () => context.push(AppRoutes.settings),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AppColors.border,
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.settings_outlined,
                                size: 18,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── Today's Focus feature card ──────────────────
                      _TodaysFocusCard(
                        beltLevel: beltLevel,
                        onStart: () => context.go(AppRoutes.poseAnalysis),
                        onDetails: () => context.go(AppRoutes.learn),
                      ),
                      const SizedBox(height: 20),

                      // ── Stat strip ──────────────────────────────────
                      _StatStrip(
                        streak: streak,
                        beltPct: beltPct,
                        monthCount: monthCount,
                      ),
                      const SizedBox(height: 20),

                      // ── This week calendar ──────────────────────────
                      _ThisWeekGrid(sessions: sessions),
                      const SizedBox(height: 20),

                      // ── Recent sessions header ──────────────────────
                      _SectionHeader(
                        title: 'home.recentSessions'.tr(),
                        onViewAll: sessions.length > 3
                            ? () => context.go(AppRoutes.journal)
                            : null,
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),

            // ── Recent sessions table ───────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: journalState.isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : sessions.isEmpty
                        ? _EmptySessionsHint(
                            onTap: () => context.go(AppRoutes.journal),
                          )
                        : _SessionTable(sessions: sessions.take(3).toList()),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  int _calcStreak(List<TrainingSession> sessions) {
    if (sessions.isEmpty) return 0;
    final sorted = [...sessions]..sort((a, b) => b.date.compareTo(a.date));
    final today = DateTime.now();
    int streak = 0;
    DateTime check = DateTime(today.year, today.month, today.day);
    for (final s in sorted) {
      final d = DateTime(s.date.year, s.date.month, s.date.day);
      if (d == check) {
        streak++;
        check = check.subtract(const Duration(days: 1));
      } else if (d.isBefore(check)) {
        break;
      }
    }
    return streak;
  }

  int _monthCount(List<TrainingSession> sessions) {
    final now = DateTime.now();
    return sessions
        .where((s) => s.date.year == now.year && s.date.month == now.month)
        .length;
  }

  int _beltProgress(List<TrainingSession> sessions, BeltLevel belt) {
    // Rough heuristic: sessions toward next belt target
    const targets = {
      BeltLevel.white: 10,
      BeltLevel.yellow: 20,
      BeltLevel.green: 30,
      BeltLevel.blue: 40,
      BeltLevel.red: 50,
      BeltLevel.black: 60,
    };
    final target = targets[belt] ?? 20;
    return ((sessions.length / target) * 100).clamp(0, 100).round();
  }
}

// ── Stat strip ────────────────────────────────────────────────────────────────

class _StatStrip extends StatelessWidget {
  const _StatStrip({
    required this.streak,
    required this.beltPct,
    required this.monthCount,
  });

  final int streak;
  final int beltPct;
  final int monthCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(
          icon: Icons.local_fire_department,
          iconColor: AppColors.primary,
          value: '$streak',
          label: 'journal.streakUnit'.tr(),
          sublabel: 'journal.streak'.tr(),
        ),
        const SizedBox(width: 10),
        _StatCard(
          icon: Icons.track_changes_outlined,
          iconColor: AppColors.secondary,
          value: '$beltPct%',
          label: '',
          sublabel: 'home.statsTitle'.tr(),
        ),
        const SizedBox(width: 10),
        _StatCard(
          icon: Icons.trending_up_rounded,
          iconColor: AppColors.accent,
          value: '$monthCount',
          label: 'journal.thisMonthUnit'.tr(),
          sublabel: 'journal.thisMonth'.tr(),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.sublabel,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final String sublabel;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(height: 10),
            Text(
              label.isEmpty ? value : '$value $label',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              sublabel,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Today's Focus card ────────────────────────────────────────────────────────

class _TodaysFocusCard extends StatelessWidget {
  const _TodaysFocusCard({
    required this.beltLevel,
    required this.onStart,
    required this.onDetails,
  });

  final BeltLevel beltLevel;
  final VoidCallback onStart;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) {
    final patternName = _currentPattern(beltLevel);
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.gradMain,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.bolt_rounded,
                  color: Colors.white70,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  "Today's Focus",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              patternName,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'home.todayRecommendation'.tr(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: onStart,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    child: const Text('Start Training'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDetails,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(
                        color: Colors.white38,
                        width: 1,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    child: const Text('View Details'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _currentPattern(BeltLevel belt) => switch (belt) {
        BeltLevel.white => 'Chon-Ji Pattern (천지)',
        BeltLevel.yellow => 'Dan-Gun Pattern (단군)',
        BeltLevel.green => 'Do-San Pattern (도산)',
        BeltLevel.blue => 'Won-Hyo Pattern (원효)',
        BeltLevel.red => 'Yul-Gok Pattern (율곡)',
        BeltLevel.black => 'Joong-Gun Pattern (중근)',
      };
}



class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontSize: 13,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── This week grid ────────────────────────────────────────────────────────────

class _ThisWeekGrid extends StatelessWidget {
  const _ThisWeekGrid({required this.sessions});

  final List<TrainingSession> sessions;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // Monday-based week
    final monday = now.subtract(Duration(days: (now.weekday - 1) % 7));
    final trainedDays = sessions
        .where((s) => s.date.isAfter(monday.subtract(const Duration(days: 1))))
        .map((s) => DateTime(s.date.year, s.date.month, s.date.day))
        .toSet();

    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'home.thisWeek'.tr(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(7, (i) {
              final day = monday.add(Duration(days: i));
              final dayOnly = DateTime(day.year, day.month, day.day);
              final trained = trainedDays.contains(dayOnly);
              final isToday = dayOnly ==
                  DateTime(now.year, now.month, now.day);
              return Expanded(
                child: Column(
                  children: [
                    Text(
                      labels[i],
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textDisabled,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      height: 32,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        gradient: trained ? AppColors.gradMain : null,
                        color: trained
                            ? null
                            : isToday
                                ? AppColors.primary.withValues(alpha: 0.08)
                                : AppColors.muted,
                        borderRadius: BorderRadius.circular(9),
                        border: isToday && !trained
                            ? Border.all(
                                color: AppColors.primary.withValues(alpha: 0.4))
                            : null,
                      ),
                      child: trained
                          ? const Icon(Icons.check_rounded,
                              size: 14, color: Colors.white)
                          : null,
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.onViewAll});

  final String title;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        if (onViewAll != null)
          GestureDetector(
            onTap: onViewAll,
            child: Text(
              'home.viewAll'.tr(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
      ],
    );
  }
}

// ── Empty hint ────────────────────────────────────────────────────────────────

class _EmptySessionsHint extends StatelessWidget {
  const _EmptySessionsHint({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.add_circle_outline_rounded,
                color: AppColors.textDisabled,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                'home.noSessionsYet'.tr(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Session table ─────────────────────────────────────────────────────────────

class _SessionTable extends StatelessWidget {
  const _SessionTable({required this.sessions});

  final List<TrainingSession> sessions;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        children: [
          for (int i = 0; i < sessions.length; i++) ...[
            _SessionRow(session: sessions[i]),
            if (i < sessions.length - 1)
              Divider(
                height: 1,
                thickness: 1,
                color: AppColors.border,
                indent: 16,
                endIndent: 16,
              ),
          ],
        ],
      ),
    );
  }
}

class _SessionRow extends StatelessWidget {
  const _SessionRow({required this.session});

  final TrainingSession session;

  static IconData _typeIcon(TrainingType type) => switch (type) {
        TrainingType.pattern => Icons.auto_awesome_motion,
        TrainingType.sparring => Icons.sports_martial_arts,
        TrainingType.kicks => Icons.directions_run,
        TrainingType.punches => Icons.sports_kabaddi,
        TrainingType.fitness => Icons.fitness_center,
        TrainingType.other => Icons.sports,
      };

  static Color _typeColor(TrainingType type) => switch (type) {
        TrainingType.pattern => AppColors.primary,
        TrainingType.sparring => AppColors.secondary,
        TrainingType.kicks => AppColors.accent,
        TrainingType.punches => AppColors.warning,
        TrainingType.fitness => AppColors.success,
        TrainingType.other => AppColors.textSecondary,
      };

  @override
  Widget build(BuildContext context) {
    final color = _typeColor(session.type);
    final scorePct = (session.score * 20).clamp(0, 100);
    final dateStr =
        DateFormat('MM/dd (E)', context.locale.languageCode).format(session.date);
    final subtitle = session.patternName.isNotEmpty
        ? '${session.patternName} · ${session.durationMinutes}${'journal.min'.tr()}'
        : '$dateStr · ${session.durationMinutes}${'journal.min'.tr()}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Icon chip
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_typeIcon(session.type), color: color, size: 18),
          ),
          const SizedBox(width: 12),
          // Title + subtitle + progress bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        session.type.i18nKey.tr(),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dateStr,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textDisabled,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: scorePct / 100,
                    minHeight: 5,
                    backgroundColor: color.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Score number
          Text(
            '$scorePct',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Instructor Home ───────────────────────────────────────────────────────────

class _InstructorHome extends ConsumerWidget {
  const _InstructorHome({required this.authState});

  final dynamic authState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final beltColor = AppColors.accent;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            // ── Header ──────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              gradient: AppColors.gradMain,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.local_fire_department,
                              size: 13,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'ITF TulMaster',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'home.greeting'.tr(namedArgs: {'name': ''}),
                        style: Theme.of(context)
                            .textTheme
                            .headlineLarge
                            ?.copyWith(height: 1.1),
                      ),
                      ShaderMask(
                        shaderCallback: (b) =>
                            AppColors.gradMain.createShader(b),
                        child: Text(
                          authState.displayName.isEmpty
                              ? '—'
                              : authState.displayName,
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.copyWith(
                                color: Colors.white,
                                height: 1.1,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () => context.push(AppRoutes.settings),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(
                      Icons.settings_outlined,
                      size: 18,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Instructor profile badge ─────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: beltColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: beltColor.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                    child:
                        Icon(Icons.shield_outlined, color: beltColor, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authState.danRank.isNotEmpty
                              ? authState.danRank
                              : 'auth.roleInstructor'.tr(),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (authState.dojoName.isNotEmpty)
                          Text(
                            authState.dojoName,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Quick actions ────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _ActionTile(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: 'home.askCoach'.tr(),
                    color: AppColors.secondary,
                    onTap: () => context.go(AppRoutes.coach),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ActionTile(
                    icon: Icons.groups_outlined,
                    label: 'nav.dojo'.tr(),
                    color: AppColors.accent,
                    onTap: () => context.go(AppRoutes.journal),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Dojo hint card ───────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.groups_outlined,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'home.instructorDojoHint'.tr(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
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
