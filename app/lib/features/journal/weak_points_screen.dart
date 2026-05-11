import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/tul_colors.dart';
import '../../core/theme/tul_radius.dart';
import '../../core/theme/tul_text_styles.dart';
import '../../shared/layout/screen_scaffold.dart';
import '../../shared/widgets/badge.dart';
import '../../shared/widgets/severity_tag.dart';
import '../../shared/widgets/tul_app_bar.dart';
import '../../shared/widgets/tul_card.dart';

class WeakPointsScreen extends StatelessWidget {
  const WeakPointsScreen({super.key});

  static const _data = [
    (Severity.critical, 'Walking stance low block', 'Chon-Ji M1', 4, 'First detected May 2'),
    (Severity.improve, 'L-stance inner forearm', 'Chon-Ji M3', 3, 'First detected May 5'),
    (Severity.improve, 'Hip rotation on block', 'Dan-Gun M7', 3, 'First detected May 7'),
    (Severity.watch, 'High block follow-through', 'Do-San M2', 2, 'First detected May 8'),
  ];

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    return ScreenScaffold(
      appBar: TulAppBar(
        title: 'Weak Points',
        onBack: () => context.pop(),
      ),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: TulStack.sm(
        children: [
          TulCard(
            background: Color.alphaBlend(
              palette.primary.withValues(alpha: 0.06),
              palette.card,
            ),
            borderColor: palette.primary.withValues(alpha: 0.2),
            padding: const EdgeInsets.all(16),
            borderRadius: TulRadius.brXl3,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(LucideIcons.info, size: 20, color: TulColors.primary2),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Movements that scored low on 2+ consecutive analyses are tracked here. Tap one to retry it with the analyzer pre-filled.',
                    style: TulTextStyles.small(color: palette.text2).copyWith(height: 1.55),
                  ),
                ),
              ],
            ),
          ),
          for (final r in _data)
            TulCard.compact(
              onTap: () => context.go('/analyze'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: SeverityTag(severity: r.$1)),
                      TulBadge(label: '×${r.$4} consecutive', color: TulBadgeColor.muted),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(r.$2, style: TulTextStyles.cardHeader(color: palette.text)),
                  const SizedBox(height: 4),
                  Text(r.$3, style: TulTextStyles.tiny(color: palette.text3)),
                  const SizedBox(height: 8),
                  Text(r.$5, style: TulTextStyles.micro(color: palette.text2)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
