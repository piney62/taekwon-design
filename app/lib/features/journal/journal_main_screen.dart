import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/tul_colors.dart';
import '../../core/theme/tul_gradients.dart';
import '../../core/theme/tul_radius.dart';
import '../../core/theme/tul_text_styles.dart';
import '../../shared/layout/screen_scaffold.dart';
import '../../shared/widgets/badge.dart';
import '../../shared/widgets/gradient_text.dart';
import '../../shared/widgets/list_row.dart';
import '../../shared/widgets/progress_ring.dart';
import '../../shared/widgets/severity_tag.dart';
import '../../shared/widgets/stat_card.dart';
import '../../shared/widgets/tul_buttons.dart';
import '../../shared/widgets/tul_card.dart';
import 'add_training_modal.dart';

class JournalMainScreen extends ConsumerWidget {
  const JournalMainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.tul;

    return ScreenScaffold(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      child: TulStack(
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DefaultTextStyle.merge(
                      style: TulTextStyles.title(color: palette.text),
                      child: Wrap(
                        children: [
                          const Text('Training '),
                          GradientText('Journal',
                              gradient: TulGradients.brand,
                              style: TulTextStyles.title()),
                        ],
                      ),
                    ),
                    Text('Track progress and ITF belt advancement.',
                        style: TulTextStyles.subtitle(color: palette.text2)),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 18),
                child: TulBadge(
                  label: "Master Kim's",
                  color: TulBadgeColor.blue,
                  icon: LucideIcons.school,
                ),
              ),
            ],
          ),
          // Stats
          const Row(
            children: [
              Expanded(child: StatCard(icon: LucideIcons.flame, value: '10', label: 'days streak', color: StatCardColor.primary)),
              SizedBox(width: 10),
              Expanded(child: StatCard(icon: LucideIcons.trendingUp, value: '15', label: 'this month', color: StatCardColor.secondary)),
              SizedBox(width: 10),
              Expanded(child: StatCard(icon: LucideIcons.target, value: '2', label: 'pending HW', color: StatCardColor.accent)),
            ],
          ),
          // Sabum HW
          TulCard(
            child: TulStack.sm(children: [
              Row(
                children: [
                  Expanded(child: Text("Sabum's Homework", style: TulTextStyles.cardHeader(color: palette.text))),
                  const TulBadge(label: '2 tasks', color: TulBadgeColor.muted),
                ],
              ),
              _HwRow(text: 'Practice low block', sub: 'Due in 3 days'),
              _HwRow(text: 'Analyze Chon-Ji M10-15', sub: 'Due in 5 days'),
            ]),
          ),
          // Belt progress card
          TulCard(
            onTap: () => context.go('/tab3/belt-progress'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(child: Text('Belt Progress', style: TulTextStyles.cardHeader(color: palette.text))),
                    Icon(LucideIcons.chevronRight, size: 16, color: palette.text3),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const ProgressRing(value: 70, size: 88, stroke: 8),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('NEXT BELT', style: TulTextStyles.tagLabel(color: palette.text3)),
                          const SizedBox(height: 4),
                          Text('Yellow → Green',
                              style: TulTextStyles.cardHeader(color: palette.text)
                                  .copyWith(fontSize: 16)),
                          const SizedBox(height: 8),
                          Text('3 of 5 criteria met',
                              style: TulTextStyles.tiny(color: palette.text3)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Weak points
          TulCard(
            onTap: () => context.go('/tab3/weak-points'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(child: Text('Weak Points', style: TulTextStyles.cardHeader(color: palette.text))),
                    Icon(LucideIcons.chevronRight, size: 16, color: palette.text3),
                  ],
                ),
                const SizedBox(height: 12),
                _WeakRow(label: 'Chon-Ji M1 · low block', count: 4, severity: Severity.critical),
                _WeakRow(label: 'Chon-Ji M3 · L-stance', count: 3, severity: Severity.improve, divider: true),
                _WeakRow(label: 'Dan-Gun M7 · hip rotation', count: 2, severity: Severity.watch, divider: true),
              ],
            ),
          ),
          // Calendar
          TulCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(child: Text('May 2026', style: TulTextStyles.cardHeader(color: palette.text))),
                    Icon(LucideIcons.calendar, size: 16, color: palette.text3),
                  ],
                ),
                const SizedBox(height: 18),
                const _CalendarGrid(today: 12, trainingDays: {2, 5, 8, 12, 15, 18, 22, 25, 28}),
              ],
            ),
          ),
          // Add training (dashed)
          _DashedAddButton(
            onTap: () => AddTrainingModal.show(context),
          ),
          // Recent records
          TulCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(child: Text('Recent Records', style: TulTextStyles.cardHeader(color: palette.text))),
                    TulGhostButton(label: 'View all', onPressed: () => context.go('/tab3/all-records')),
                  ],
                ),
                const SizedBox(height: 14),
                ListRow(
                  icon: LucideIcons.target,
                  iconColor: ListRowColor.primary,
                  title: 'Chon-Ji Pattern',
                  sub: '45 min · 6 movements',
                  trailing: Text('68%', style: TulTextStyles.bodyStrong(color: palette.primary)),
                ),
                ListRow(
                  icon: LucideIcons.trendingUp,
                  iconColor: ListRowColor.secondary,
                  title: 'Sparring Practice',
                  sub: '30 min · 3 rounds',
                  trailing: Text('85%', style: TulTextStyles.bodyStrong(color: palette.secondary)),
                ),
                ListRow(
                  icon: LucideIcons.target,
                  iconColor: ListRowColor.accent,
                  title: 'Dan-Gun Pattern',
                  sub: '38 min · 8 movements',
                  trailing: Text('74%', style: TulTextStyles.bodyStrong(color: palette.accent)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HwRow extends StatefulWidget {
  const _HwRow({required this.text, required this.sub});

  final String text;
  final String sub;

  @override
  State<_HwRow> createState() => _HwRowState();
}

class _HwRowState extends State<_HwRow> {
  bool _checked = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    return InkWell(
      onTap: () => setState(() => _checked = !_checked),
      borderRadius: TulRadius.brMd,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: palette.text.withValues(alpha: 0.03),
          borderRadius: TulRadius.brMd,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: Checkbox(
                value: _checked,
                onChanged: (v) => setState(() => _checked = v ?? false),
                activeColor: palette.primary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.text, style: TulTextStyles.subtitle(color: palette.text)),
                  Text(widget.sub, style: TulTextStyles.tiny(color: palette.text3)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeakRow extends StatelessWidget {
  const _WeakRow({
    required this.label,
    required this.count,
    required this.severity,
    this.divider = false,
  });

  final String label;
  final int count;
  final Severity severity;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    final color = switch (severity) {
      Severity.critical => palette.primary,
      Severity.improve => palette.yellow,
      Severity.watch => palette.secondary,
    };
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: divider
          ? BoxDecoration(border: Border(top: BorderSide(color: palette.border)))
          : null,
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: Text(
              '×$count',
              textAlign: TextAlign.center,
              style: TulTextStyles.smallStrong(color: color),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: TulTextStyles.subtitle(color: palette.text))),
        ],
      ),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({required this.today, required this.trainingDays});

  final int today;
  final Set<int> trainingDays;

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    const headers = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: List.generate(7, (i) {
            final weekend = i >= 5;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  headers[i],
                  textAlign: TextAlign.center,
                  style: TulTextStyles.micro(
                    color: weekend ? palette.secondary : palette.text3,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            childAspectRatio: 1,
          ),
          itemCount: 31,
          itemBuilder: (context, i) {
            final day = i + 1;
            final trained = trainingDays.contains(day);
            final isToday = day == today;
            Color? bg;
            Color textColor;
            Border? border;
            List<BoxShadow>? shadow;
            if (isToday) {
              bg = null;
              textColor = Colors.white;
              shadow = [
                BoxShadow(
                  color: palette.primary.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ];
            } else if (trained) {
              bg = palette.primary.withValues(alpha: 0.12);
              textColor = TulColors.primary2;
              border = Border.all(color: palette.primary.withValues(alpha: 0.25));
            } else {
              bg = Colors.transparent;
              textColor = palette.text2;
            }
            return Container(
              decoration: BoxDecoration(
                color: bg,
                gradient: isToday ? TulGradients.brand : null,
                borderRadius: BorderRadius.circular(10),
                border: border,
                boxShadow: shadow,
              ),
              alignment: Alignment.center,
              child: Text(
                '$day',
                style: TextStyle(
                  fontSize: 12,
                  color: textColor,
                  fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _DashedAddButton extends StatelessWidget {
  const _DashedAddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    return Material(
      color: palette.card,
      borderRadius: TulRadius.brXl,
      child: InkWell(
        onTap: onTap,
        borderRadius: TulRadius.brXl,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: TulRadius.brXl,
            border: Border.all(
              color: palette.borderStrong,
              width: 1.5,
              style: BorderStyle.solid,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.plus, size: 18, color: palette.text),
              const SizedBox(width: 8),
              Text(
                'Add Training Session',
                style: TulTextStyles.bodyStrong(color: palette.text),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
