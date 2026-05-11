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
import '../../shared/widgets/stat_card.dart';
import '../../shared/widgets/tul_buttons.dart';
import '../../shared/widgets/tul_card.dart';

class InstructorHomeScreen extends ConsumerWidget {
  const InstructorHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.tul;
    return ScreenScaffold(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      child: TulStack(
        children: [
          _Header(onSettings: () => context.go('/me')),

          // Needs attention
          TulCard(
            borderColor: palette.primary.withValues(alpha: 0.3),
            background: Color.alphaBlend(
              palette.primary.withValues(alpha: 0.08),
              palette.card,
            ),
            child: TulStack.sm(children: [
              Row(
                children: [
                  Icon(LucideIcons.alertCircle, size: 18, color: palette.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('Needs Attention', style: TulTextStyles.cardHeader(color: palette.text)),
                  ),
                  const TulBadge(label: '3', color: TulBadgeColor.red),
                ],
              ),
              const ListRow(
                icon: LucideIcons.user,
                iconColor: ListRowColor.primary,
                title: 'Jiwon Park',
                sub: 'No training in 8 days · Yellow Belt',
              ),
              const ListRow(
                icon: LucideIcons.user,
                iconColor: ListRowColor.primary,
                title: 'Alex Chen',
                sub: 'Repeated weak stance on Chon-Ji M3',
              ),
              const ListRow(
                icon: LucideIcons.user,
                iconColor: ListRowColor.primary,
                title: 'Sara Lee',
                sub: 'Homework overdue · 2 days',
              ),
            ]),
          ),

          // Stats row
          const Row(
            children: [
              Expanded(child: StatCard(icon: LucideIcons.users, value: '12', label: 'Trained today', color: StatCardColor.primary)),
              SizedBox(width: 10),
              Expanded(child: StatCard(icon: LucideIcons.flame, value: '4', label: 'Idle students', color: StatCardColor.secondary)),
              SizedBox(width: 10),
              Expanded(child: StatCard(icon: LucideIcons.alertCircle, value: '6', label: 'Pending HW', color: StatCardColor.accent)),
            ],
          ),

          // Quick actions
          Row(
            children: [
              Expanded(
                child: TulPrimaryButton(
                  label: 'Assign HW',
                  icon: LucideIcons.plus,
                  onPressed: () => context.go('/tab3'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TulSecondaryButton(
                  label: 'Invite',
                  icon: LucideIcons.qrCode,
                  onPressed: () {},
                ),
              ),
            ],
          ),

          // Pending reviews
          TulCard(
            child: TulStack.sm(children: [
              Row(
                children: [
                  Expanded(child: Text('Pending Reviews', style: TulTextStyles.cardHeader(color: palette.text))),
                  const TulBadge(label: '4 waiting', color: TulBadgeColor.muted),
                ],
              ),
              ListRow(
                icon: LucideIcons.scanLine,
                iconColor: ListRowColor.secondary,
                title: 'Jiwon · Chon-Ji M5',
                sub: 'Submitted 2h ago',
                onTap: () => context.go('/tab3/student/1'),
              ),
              ListRow(
                icon: LucideIcons.scanLine,
                iconColor: ListRowColor.secondary,
                title: 'Alex · Dan-Gun M12',
                sub: 'Submitted yesterday',
                onTap: () => context.go('/tab3/student/2'),
              ),
              ListRow(
                icon: LucideIcons.scanLine,
                iconColor: ListRowColor.secondary,
                title: 'Sara · Do-San M2',
                sub: 'Submitted 2 days ago',
                onTap: () => context.go('/tab3/student/3'),
              ),
            ]),
          ),

          // Dojang snapshot
          TulCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(child: Text('Dojang Snapshot', style: TulTextStyles.cardHeader(color: palette.text))),
                    TulGhostButton(label: 'Open', onPressed: () => context.go('/tab3')),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: _MiniStat(value: '28', label: 'Total students', gradient: false)),
                    const SizedBox(width: 10),
                    Expanded(child: _MiniStat(value: '78%', label: 'Weekly activity', gradient: true)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.value, required this.label, required this.gradient});

  final String value;
  final String label;
  final bool gradient;

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.text.withValues(alpha: 0.03),
        borderRadius: TulRadius.brLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          gradient
              ? GradientText(
                  value,
                  gradient: TulGradients.brand,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.48),
                )
              : Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.48)),
          const SizedBox(height: 4),
          Text(label, style: TulTextStyles.tiny(color: palette.text3)),
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
                        gradient: TulGradients.instructor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(LucideIcons.award, size: 14, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Text('Sabum · 3rd Dan', style: TulTextStyles.small(color: palette.text2)),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Good morning,', style: TulTextStyles.title(color: palette.text)),
                GradientText('Master Kim', gradient: TulGradients.brand, style: TulTextStyles.title()),
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
