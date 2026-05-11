import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/tul_colors.dart';
import '../../core/theme/tul_gradients.dart';
import '../../core/theme/tul_radius.dart';
import '../../core/theme/tul_text_styles.dart';
import '../../shared/layout/screen_scaffold.dart';
import '../../shared/widgets/feature_card.dart';
import '../../shared/widgets/list_row.dart';
import '../../shared/widgets/tul_card.dart';
import 'patterns_data.dart';

class PatternsMainScreen extends StatelessWidget {
  const PatternsMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    return ScreenScaffold(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      child: TulStack(
        children: [
          // Title
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              Text('ITF Patterns ',
                  style: TulTextStyles.title(color: palette.text)),
              Text('(틀)',
                  style: TulTextStyles.korean(
                    size: 18,
                    color: palette.text3,
                  )),
            ],
          ),
          Text('Master all 24 ITF Taekwon-Do patterns.',
              style: TulTextStyles.subtitle(color: palette.text2)),

          // Search
          TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(LucideIcons.search, size: 18, color: palette.text3),
              hintText: 'Search patterns…',
              fillColor: palette.card,
              border: OutlineInputBorder(
                borderRadius: TulRadius.brLg,
                borderSide: BorderSide(color: palette.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: TulRadius.brLg,
                borderSide: BorderSide(color: palette.border),
              ),
            ),
          ),

          // Current pattern feature
          FeatureCard(
            label: 'Current Pattern',
            title: 'Chon-Ji (천지)',
            body: '19 movements · White-Yellow Belt',
            progress: 65,
            primaryLabel: 'Study Now',
            secondaryLabel: 'Details',
            onPrimary: () => context.go('/patterns/detail/1'),
            onSecondary: () => context.go('/patterns/detail/1'),
            icon: LucideIcons.book,
          ),

          // All patterns
          Text('All Patterns (24)', style: TulTextStyles.cardHeader(color: palette.text)),
          TulStack.sm(children: [
            for (final p in patternsList) _PatternRow(pattern: p),
          ]),

          // Reference section
          TulCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('ITF Reference', style: TulTextStyles.cardHeader(color: palette.text)),
                const SizedBox(height: 8),
                ListRow(
                  icon: LucideIcons.library,
                  iconColor: ListRowColor.primary,
                  title: 'Terminology Dictionary',
                  sub: 'Korean terms · stances, blocks, kicks',
                  onTap: () => context.go('/patterns/terminology'),
                ),
                ListRow(
                  icon: LucideIcons.award,
                  iconColor: ListRowColor.secondary,
                  title: '5 Tenets (오대정신)',
                  sub: 'Courtesy, Integrity, Perseverance…',
                  onTap: () => context.go('/patterns/tenets'),
                ),
                ListRow(
                  icon: LucideIcons.book,
                  iconColor: ListRowColor.accent,
                  title: 'ITF History',
                  sub: 'Timeline from founding to today',
                  onTap: () => context.go('/patterns/history'),
                ),
                ListRow(
                  icon: LucideIcons.messageCircle,
                  iconColor: ListRowColor.primary,
                  title: 'Coach (chat)',
                  sub: 'Ask anything about technique',
                  onTap: () => context.go('/patterns/coach'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PatternRow extends StatelessWidget {
  const _PatternRow({required this.pattern});

  final PatternInfo pattern;

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    return Opacity(
      opacity: pattern.locked ? 0.55 : 1,
      child: TulCard(
        padding: const EdgeInsets.all(12),
        onTap: pattern.locked
            ? null
            : () => context.go('/patterns/detail/${pattern.number}'),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: pattern.isCurrent
                    ? TulGradients.brand
                    : pattern.locked
                        ? null
                        : TulGradients.brandSoft,
                color: pattern.locked ? palette.muted : null,
                borderRadius: BorderRadius.circular(11),
              ),
              child: pattern.locked
                  ? Icon(LucideIcons.lock, size: 16, color: palette.text3)
                  : Text(
                      '${pattern.number}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: pattern.isCurrent ? Colors.white : palette.text,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      text: pattern.name,
                      style: TulTextStyles.bodyStrong(color: palette.text),
                      children: [
                        TextSpan(
                          text: '  (${pattern.korean})',
                          style: TulTextStyles.body(color: palette.text3),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${pattern.movements} movements · ${pattern.belt}',
                    style: TulTextStyles.tiny(color: palette.text3),
                  ),
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight, size: 16, color: palette.text3),
          ],
        ),
      ),
    );
  }
}
