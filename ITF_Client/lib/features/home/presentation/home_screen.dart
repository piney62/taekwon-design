import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/tul_gradients.dart';
import '../../../core/theme/tul_palette.dart';
import '../../../core/theme/tul_radius.dart';
import '../../../core/theme/tul_text_styles.dart';
import '../../../shared/widgets/app_shell.dart' show kAppShellContentBottomInset;
import '../../../shared/widgets/feature_card.dart';
import '../../../shared/widgets/gradient_text.dart';
import '../../../shared/widgets/list_row.dart';
import '../../../shared/widgets/stat_card.dart';
import '../../../shared/widgets/tul_buttons.dart';
import '../../../shared/widgets/tul_card.dart';
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
    final palette = context.tul;

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
                      // ── Header ──────────────────────────────────────────
                      _StudentHeader(authState: authState, palette: palette),
                      const SizedBox(height: 20),

                      // ── Stat strip ──────────────────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              icon: LucideIcons.flame,
                              value: '$streak',
                              label: 'journal.streak'.tr(),
                              color: StatCardColor.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: StatCard(
                              icon: LucideIcons.target,
                              value: '$beltPct%',
                              label: 'home.statsTitle'.tr(),
                              color: StatCardColor.secondary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: StatCard(
                              icon: LucideIcons.trendingUp,
                              value: '$monthCount',
                              label: 'journal.thisMonth'.tr(),
                              color: StatCardColor.accent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ── Today's Focus feature card ───────────────────────
                      FeatureCard(
                        icon: LucideIcons.zap,
                        label: "Today's Focus",
                        title: _currentPattern(beltLevel),
                        body: 'home.todayRecommendation'.tr(),
                        progress: beltPct.toDouble(),
                        primaryLabel: 'Start Training',
                        secondaryLabel: 'View Details',
                        onPrimary: () => context.go(AppRoutes.poseAnalysis),
                        onSecondary: () => context.go(AppRoutes.learn),
                      ),
                      const SizedBox(height: 16),

                      // ── This week card ──────────────────────────────────
                      TulCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'home.thisWeek'.tr(),
                              style: TulTextStyles.cardHeader(color: palette.text),
                            ),
                            const SizedBox(height: 12),
                            _WeekDots(sessions: sessions),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Recent sessions card ─────────────────────────────
                      if (journalState.isLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (sessions.isEmpty)
                        TulCard(
                          child: Column(
                            children: [
                              Icon(LucideIcons.clipboardList,
                                  color: palette.text3, size: 32),
                              const SizedBox(height: 8),
                              Text(
                                'home.noSessionsYet'.tr(),
                                style: TextStyle(
                                    color: palette.text2, fontSize: 13),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          onTap: () => context.go(AppRoutes.journal),
                        )
                      else
                        TulCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'home.recentSessions'.tr(),
                                      style: TulTextStyles.cardHeader(
                                          color: palette.text),
                                    ),
                                  ),
                                  if (sessions.length > 3)
                                    TulGhostButton(
                                      label: 'home.viewAll'.tr(),
                                      onPressed: () =>
                                          context.go(AppRoutes.journal),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              ...sessions.take(3).map((s) {
                                final dateStr = DateFormat(
                                  'MM/dd (E)',
                                  context.locale.languageCode,
                                ).format(s.date);
                                final sub = s.patternName.isNotEmpty
                                    ? '${s.patternName} · ${s.durationMinutes}${'journal.min'.tr()}'
                                    : '$dateStr · ${s.durationMinutes}${'journal.min'.tr()}';
                                final scorePct = s.score * 20;
                                return ListRow(
                                  icon: _typeIcon(s.type),
                                  iconColor: _typeListColor(s.type),
                                  title: s.type.i18nKey.tr(),
                                  sub: sub,
                                  trailing: Text(
                                    '$scorePct',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: _typeAccent(s.type, palette),
                                    ),
                                  ),
                                  onTap: () => context.go(AppRoutes.journal),
                                );
                              }),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
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

  // ── Data helpers ─────────────────────────────────────────────────────────────

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

  static String _currentPattern(BeltLevel belt) => switch (belt) {
        BeltLevel.white => 'Chon-Ji Pattern (천지)',
        BeltLevel.yellow => 'Dan-Gun Pattern (단군)',
        BeltLevel.green => 'Do-San Pattern (도산)',
        BeltLevel.blue => 'Won-Hyo Pattern (원효)',
        BeltLevel.red => 'Yul-Gok Pattern (율곡)',
        BeltLevel.black => 'Joong-Gun Pattern (중근)',
      };

  static IconData _typeIcon(TrainingType type) => switch (type) {
        TrainingType.pattern => LucideIcons.target,
        TrainingType.sparring => LucideIcons.zap,
        TrainingType.kicks => LucideIcons.flame,
        TrainingType.punches => LucideIcons.activity,
        TrainingType.fitness => LucideIcons.trendingUp,
        TrainingType.other => LucideIcons.circle,
      };

  static ListRowColor _typeListColor(TrainingType type) => switch (type) {
        TrainingType.pattern => ListRowColor.primary,
        TrainingType.sparring => ListRowColor.secondary,
        TrainingType.kicks => ListRowColor.accent,
        TrainingType.punches => ListRowColor.primary,
        TrainingType.fitness => ListRowColor.secondary,
        TrainingType.other => ListRowColor.accent,
      };

  static Color _typeAccent(TrainingType type, TulPalette p) => switch (type) {
        TrainingType.pattern => p.primary,
        TrainingType.sparring => p.secondary,
        TrainingType.kicks => p.accent,
        TrainingType.punches => p.primary,
        TrainingType.fitness => p.green,
        TrainingType.other => p.text3,
      };
}

// ── Student header ────────────────────────────────────────────────────────────

class _StudentHeader extends StatelessWidget {
  const _StudentHeader({required this.authState, required this.palette});

  final dynamic authState;
  final TulPalette palette;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: TulGradients.brand,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(LucideIcons.flame,
                        size: 14, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'ITF TulMaster',
                    style: TextStyle(
                      fontSize: 12,
                      color: palette.text2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'home.greeting'.tr(namedArgs: {'name': ''}),
                style: Theme.of(context)
                    .textTheme
                    .headlineLarge
                    ?.copyWith(height: 1.1, color: palette.text),
              ),
              GradientText(
                authState.displayName.isEmpty ? '—' : authState.displayName,
                gradient: TulGradients.brand,
                style: Theme.of(context)
                    .textTheme
                    .headlineLarge
                    ?.copyWith(height: 1.1),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Material(
          color: palette.card,
          borderRadius: TulRadius.brLg,
          child: InkWell(
            onTap: () => context.push(AppRoutes.settings),
            borderRadius: TulRadius.brLg,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: TulRadius.brLg,
                border: Border.all(color: palette.border),
              ),
              alignment: Alignment.center,
              child: Icon(LucideIcons.settings, size: 18, color: palette.text),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Week dots ─────────────────────────────────────────────────────────────────

class _WeekDots extends StatelessWidget {
  const _WeekDots({required this.sessions});

  final List<TrainingSession> sessions;

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: (now.weekday - 1) % 7));
    final trainedDays = sessions
        .where((s) =>
            s.date.isAfter(monday.subtract(const Duration(days: 1))))
        .map((s) => DateTime(s.date.year, s.date.month, s.date.day))
        .toSet();

    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Row(
      children: List.generate(7, (i) {
        final day = monday.add(Duration(days: i));
        final dayOnly = DateTime(day.year, day.month, day.day);
        final trained = trainedDays.contains(dayOnly);
        final isToday = dayOnly == DateTime(now.year, now.month, now.day);

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: i == 0 ? 0 : 3, right: i == 6 ? 0 : 3),
            child: Column(
              children: [
                Text(
                  labels[i],
                  style: TulTextStyles.tiny(color: palette.text3),
                ),
                const SizedBox(height: 6),
                AspectRatio(
                  aspectRatio: 1,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      gradient: trained ? TulGradients.brand : null,
                      color: trained
                          ? null
                          : isToday
                              ? palette.primary.withValues(alpha: 0.08)
                              : palette.text.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(10),
                      border: isToday && !trained
                          ? Border.all(
                              color: palette.primary.withValues(alpha: 0.4))
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: trained
                        ? const Icon(LucideIcons.check,
                            size: 12, color: Colors.white)
                        : null,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
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
          padding: const EdgeInsets.fromLTRB(
              20, 8, 20, kAppShellContentBottomInset),
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
