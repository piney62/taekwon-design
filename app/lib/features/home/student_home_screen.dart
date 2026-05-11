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
import '../../shared/widgets/feature_card.dart';
import '../../shared/widgets/gradient_text.dart';
import '../../shared/widgets/list_row.dart';
import '../../shared/widgets/stat_card.dart';
import '../../shared/widgets/tul_buttons.dart';
import '../../shared/widgets/tul_card.dart';

class StudentHomeScreen extends ConsumerWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.tul;
    return ScreenScaffold(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      child: TulStack(
        children: [
          _Header(
            onSettings: () => context.go('/me'),
          ),
          const Row(
            children: [
              Expanded(child: StatCard(icon: LucideIcons.flame, value: '10', label: 'Day Streak', color: StatCardColor.primary)),
              SizedBox(width: 10),
              Expanded(child: StatCard(icon: LucideIcons.target, value: '70%', label: 'Belt Progress', color: StatCardColor.secondary)),
              SizedBox(width: 10),
              Expanded(child: StatCard(icon: LucideIcons.trendingUp, value: '15', label: 'This Month', color: StatCardColor.accent)),
            ],
          ),
          FeatureCard(
            label: "Today's Focus",
            title: 'Chon-Ji Pattern (천지)',
            body: 'Practice movements 1-5 · Focus on stance and balance',
            primaryLabel: 'Start Training',
            secondaryLabel: 'View Details',
            onPrimary: () => context.go('/analyze'),
            onSecondary: () => context.go('/patterns/detail/1'),
          ),
          // Sabum's homework
          TulCard(
            child: TulStack.sm(children: [
              Row(
                children: [
                  Expanded(
                    child: Text("Sabum's Homework", style: TulTextStyles.cardHeader(color: palette.text)),
                  ),
                  const TulBadge(label: '2 tasks', color: TulBadgeColor.muted),
                ],
              ),
              _HomeworkItem(text: 'Practice low block technique', sub: 'Due in 3 days'),
              _HomeworkItem(text: 'Analyze Chon-Ji movements 10-15', sub: 'Due in 5 days'),
            ]),
          ),
          // This week
          TulCard(
            child: TulStack.sm(children: [
              Text('This Week', style: TulTextStyles.cardHeader(color: palette.text)),
              Row(
                children: List.generate(7, (i) {
                  final filled = [0, 1, 2, 4].contains(i);
                  final letters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: i == 0 ? 0 : 3, right: i == 6 ? 0 : 3),
                      child: Column(
                        children: [
                          Text(letters[i], style: TulTextStyles.tiny(color: palette.text3)),
                          const SizedBox(height: 6),
                          AspectRatio(
                            aspectRatio: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: filled ? TulGradients.brand : null,
                                color: filled ? null : palette.text.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: filled
                                  ? const Icon(LucideIcons.check, size: 12, color: Colors.white)
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ]),
          ),
          // Recent activity
          TulCard(
            child: TulStack.sm(children: [
              Row(
                children: [
                  Expanded(child: Text('Recent Activity', style: TulTextStyles.cardHeader(color: palette.text))),
                  TulGhostButton(label: 'View all', onPressed: () {}),
                ],
              ),
              ListRow(
                icon: LucideIcons.target,
                iconColor: ListRowColor.primary,
                title: 'Chon-Ji Analysis',
                sub: 'Today · 68% accuracy',
                trailing: Text(
                  '+5',
                  style: TulTextStyles.bodyStrong(color: palette.primary),
                ),
                onTap: () => context.go('/analyze/result'),
              ),
              ListRow(
                icon: LucideIcons.trendingUp,
                iconColor: ListRowColor.secondary,
                title: 'Training Session',
                sub: 'Yesterday · 45 min',
                trailing: Text(
                  '+8',
                  style: TulTextStyles.bodyStrong(color: palette.secondary),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onSettings});

  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 6),
      child: Row(
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
                      child: const Icon(LucideIcons.flame, size: 14, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Text('ITF TulMaster', style: TulTextStyles.small(color: palette.text2)),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Welcome back,', style: TulTextStyles.title(color: palette.text)),
                GradientText('Nick!', gradient: TulGradients.brand, style: TulTextStyles.title()),
              ],
            ),
          ),
          Material(
            color: palette.card,
            borderRadius: TulRadius.brLg,
            child: InkWell(
              onTap: onSettings,
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
      ),
    );
  }
}

class _HomeworkItem extends StatefulWidget {
  const _HomeworkItem({required this.text, required this.sub});

  final String text;
  final String sub;

  @override
  State<_HomeworkItem> createState() => _HomeworkItemState();
}

class _HomeworkItemState extends State<_HomeworkItem> {
  bool _checked = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    return Material(
      color: palette.text.withValues(alpha: 0.03),
      borderRadius: TulRadius.brLg,
      child: InkWell(
        onTap: () => setState(() => _checked = !_checked),
        borderRadius: TulRadius.brLg,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: SizedBox(
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
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.text,
                      style: TulTextStyles.subtitle(color: palette.text).copyWith(
                        decoration: _checked ? TextDecoration.lineThrough : null,
                        color: _checked ? palette.text3 : palette.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(widget.sub, style: TulTextStyles.tiny(color: palette.text3)),
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
