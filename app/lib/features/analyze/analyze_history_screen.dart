import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tul_colors.dart';
import '../../core/theme/tul_gradients.dart';
import '../../core/theme/tul_text_styles.dart';
import '../../shared/layout/screen_scaffold.dart';
import '../../shared/widgets/filter_chips.dart';
import '../../shared/widgets/gradient_text.dart';
import '../../shared/widgets/placeholder_box.dart';
import '../../shared/widgets/tul_app_bar.dart';
import '../../shared/widgets/tul_card.dart';

class AnalyzeHistoryScreen extends StatefulWidget {
  const AnalyzeHistoryScreen({super.key});

  @override
  State<AnalyzeHistoryScreen> createState() => _AnalyzeHistoryScreenState();
}

class _AnalyzeHistoryScreenState extends State<AnalyzeHistoryScreen> {
  String _filter = 'All patterns';

  static const _records = [
    ('Chon-Ji M1', 'Today · 14:22', 68),
    ('Chon-Ji M3', 'Yesterday · 19:08', 74),
    ('Dan-Gun M5', 'May 8 · 21:00', 82),
    ('Chon-Ji M1', 'May 7 · 18:30', 61),
    ('Do-San M2', 'May 5 · 20:15', 70),
  ];

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    return ScreenScaffold(
      appBar: TulAppBar(
        title: 'Past Analyses',
        onBack: () => context.pop(),
      ),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: TulStack.sm(
        children: [
          FilterChipsRow(
            options: const ['All patterns', 'Chon-Ji', 'Dan-Gun', 'Do-San'],
            selected: _filter,
            onSelect: (v) => setState(() => _filter = v),
          ),
          const SizedBox(height: 6),
          for (final r in _records)
            TulCard.compact(
              onTap: () => context.go('/analyze/result'),
              child: Row(
                children: [
                  const PlaceholderBox(label: 'img', height: 56, width: 56),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(r.$1, style: TulTextStyles.smallStrong(color: palette.text)),
                        const SizedBox(height: 2),
                        Text(r.$2, style: TulTextStyles.tiny(color: palette.text3)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      GradientText(
                        '${r.$3}',
                        gradient: TulGradients.brand,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      Text('score', style: TulTextStyles.tiny(color: palette.text3)),
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
