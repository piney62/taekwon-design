import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/tul_colors.dart';
import '../../core/theme/tul_gradients.dart';
import '../../core/theme/tul_radius.dart';
import '../../core/theme/tul_text_styles.dart';
import '../../shared/layout/screen_scaffold.dart';
import '../../shared/widgets/badge.dart';
import '../../shared/widgets/severity_tag.dart';
import '../../shared/widgets/tul_app_bar.dart';
import '../../shared/widgets/tul_buttons.dart';
import '../../shared/widgets/tul_card.dart';

class StudentDetailScreen extends StatelessWidget {
  const StudentDetailScreen({super.key, this.studentName = 'Jiwon Park'});

  final String studentName;

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    return ScreenScaffold(
      appBar: TulAppBar(
        title: studentName,
        onBack: () => context.pop(),
        action: _IconChip(icon: LucideIcons.messageCircle, onTap: () {}),
      ),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: TulStack(
        children: [
          // Profile card
          TulCard(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: TulGradients.brand,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    'JP',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(studentName,
                          style: TulTextStyles.cardHeader(color: palette.text)
                              .copyWith(fontSize: 18)),
                      const SizedBox(height: 6),
                      const Row(
                        children: [
                          TulBadge(label: 'Yellow Belt', color: TulBadgeColor.yellow),
                          SizedBox(width: 6),
                          TulBadge(label: 'Joined Mar 2026', color: TulBadgeColor.muted),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Activity
          TulCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Activity', style: TulTextStyles.cardHeader(color: palette.text)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _MiniStat(label: 'FREQUENCY', value: '2× / week')),
                    const SizedBox(width: 10),
                    Expanded(child: _MiniStat(label: 'LAST SESSION', value: '8 days ago', accentColor: palette.primary)),
                  ],
                ),
              ],
            ),
          ),

          // Patterns & weak points
          TulCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Patterns & weak points', style: TulTextStyles.cardHeader(color: palette.text)),
                const SizedBox(height: 6),
                Text('Analyzed: Chon-Ji, Dan-Gun',
                    style: TulTextStyles.small(color: palette.text2)),
                const SizedBox(height: 6),
                _WeakRow(label: 'Chon-Ji M1 · stance depth', count: 5, severity: Severity.critical),
                _WeakRow(label: 'Chon-Ji M3 · L-stance', count: 3, severity: Severity.improve, divider: true),
              ],
            ),
          ),

          // Homework
          TulCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Homework', style: TulTextStyles.cardHeader(color: palette.text)),
                const SizedBox(height: 6),
                _HwRow(label: 'Practice low block 100x', status: TulBadgeColor.green, statusLabel: 'Done'),
                _HwRow(label: 'Submit Chon-Ji M1 analysis', status: TulBadgeColor.yellow, statusLabel: 'Pending', divider: true),
              ],
            ),
          ),

          // Action buttons
          TulPrimaryButton(
            label: 'Send comment',
            icon: LucideIcons.messageCircle,
            onPressed: () {},
          ),
          TulSecondaryButton(
            label: 'Assign homework',
            icon: LucideIcons.plus,
            onPressed: () {},
          ),
          TulDestructiveButton(
            label: 'Remove from dojang',
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value, this.accentColor});

  final String label;
  final String value;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.text.withValues(alpha: 0.03),
        borderRadius: TulRadius.brMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TulTextStyles.tagLabel(color: palette.text3)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: accentColor ?? palette.text,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
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
      padding: const EdgeInsets.symmetric(vertical: 8),
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

class _HwRow extends StatelessWidget {
  const _HwRow({
    required this.label,
    required this.status,
    required this.statusLabel,
    this.divider = false,
  });

  final String label;
  final TulBadgeColor status;
  final String statusLabel;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: divider
          ? BoxDecoration(border: Border(top: BorderSide(color: palette.border)))
          : null,
      child: Row(
        children: [
          Expanded(child: Text(label, style: TulTextStyles.subtitle(color: palette.text))),
          TulBadge(label: statusLabel, color: status),
        ],
      ),
    );
  }
}

class _IconChip extends StatelessWidget {
  const _IconChip({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    return Material(
      color: palette.card,
      borderRadius: TulRadius.brMd,
      child: InkWell(
        onTap: onTap,
        borderRadius: TulRadius.brMd,
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: TulRadius.brMd,
            border: Border.all(color: palette.border),
          ),
          child: Icon(icon, size: 16, color: palette.text2),
        ),
      ),
    );
  }
}
