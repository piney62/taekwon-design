import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/tul_colors.dart';
import '../../core/theme/tul_gradients.dart';
import '../../core/theme/tul_text_styles.dart';
import '../../shared/layout/screen_scaffold.dart';
import '../../shared/widgets/gradient_text.dart';
import '../../shared/widgets/progress_ring.dart';
import '../../shared/widgets/tul_app_bar.dart';
import '../../shared/widgets/tul_buttons.dart';
import '../../shared/widgets/tul_card.dart';

enum _ItemStatus { done, pending, optional, todo }

class BeltProgressScreen extends StatelessWidget {
  const BeltProgressScreen({super.key});

  static const _items = [
    ('Training duration (40h)', '38h / 40h', _ItemStatus.todo),
    ('Pattern analyses (20)', '23 / 20', _ItemStatus.done),
    ('Pattern quality avg ≥ 70%', '72%', _ItemStatus.done),
    ('Sparring evaluation by sabum', 'Pending', _ItemStatus.pending),
    ('Breaking evaluation (optional)', 'Not started', _ItemStatus.optional),
  ];

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    return ScreenScaffold(
      appBar: TulAppBar(
        title: 'Belt Progress',
        onBack: () => context.pop(),
      ),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: TulStack(
        children: [
          Center(
            child: Column(
              children: [
                const ProgressRing(value: 70, size: 160, stroke: 14),
                const SizedBox(height: 12),
                Text('TO', style: TulTextStyles.tagLabel(color: palette.text3)),
                const SizedBox(height: 4),
                GradientText(
                  'Green Belt (초록띠)',
                  gradient: TulGradients.brand,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          Text('Readiness checklist', style: TulTextStyles.cardHeader(color: palette.text)),
          TulStack.sm(children: [
            for (final it in _items) _ChecklistItem(label: it.$1, sub: it.$2, status: it.$3),
          ]),
          TulCard(
            background: Color.alphaBlend(
              palette.primary.withValues(alpha: 0.06),
              palette.card,
            ),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Almost there. ',
                    style: TulTextStyles.subtitle(color: palette.text)
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(
                    text:
                        '2 more training hours and a sparring evaluation will put you ready for promotion.',
                    style: TulTextStyles.subtitle(color: palette.text),
                  ),
                ],
              ),
            ),
          ),
          TulPrimaryButton(
            label: 'Take Theory Test',
            icon: LucideIcons.zap,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  const _ChecklistItem({
    required this.label,
    required this.sub,
    required this.status,
  });

  final String label;
  final String sub;
  final _ItemStatus status;

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    Color bg;
    Color fg;
    Widget content;
    switch (status) {
      case _ItemStatus.done:
        bg = palette.green;
        fg = Colors.white;
        content = Icon(LucideIcons.check, size: 14, color: fg);
      case _ItemStatus.pending:
        bg = palette.yellow.withValues(alpha: 0.15);
        fg = palette.yellow;
        content = Text('…', style: TextStyle(color: fg, fontWeight: FontWeight.w700));
      case _ItemStatus.optional:
        bg = palette.text.withValues(alpha: 0.06);
        fg = palette.text3;
        content = Text('?', style: TextStyle(color: fg, fontWeight: FontWeight.w700));
      case _ItemStatus.todo:
        bg = palette.text.withValues(alpha: 0.06);
        fg = palette.text3;
        content = Icon(LucideIcons.flame, size: 12, color: fg);
    }
    return TulCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: content,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TulTextStyles.subtitle(color: palette.text)),
                Text(sub, style: TulTextStyles.tiny(color: palette.text3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
