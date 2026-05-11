import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tul_colors.dart';
import '../../core/theme/tul_text_styles.dart';
import '../../shared/layout/screen_scaffold.dart';
import '../../shared/widgets/tul_app_bar.dart';
import '../../shared/widgets/tul_card.dart';

class TenetsScreen extends StatelessWidget {
  const TenetsScreen({super.key});

  static const _tenets = [
    ('Courtesy', '예의', '禮儀', _Accent.primary, 'Respect senior and junior students; bow on entering the dojang.'),
    ('Integrity', '염치', '廉恥', _Accent.secondary, 'Know what is right; have the will to live by it.'),
    ('Perseverance', '인내', '忍耐', _Accent.accent, 'Patience and persistence overcome every obstacle.'),
    ('Self-Control', '극기', '克己', _Accent.primary, 'Master your impulses, both in training and outside.'),
    ('Indomitable Spirit', '백절불굴', '百折不屈', _Accent.secondary, 'Stand firm in the face of any adversity.'),
  ];

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    return ScreenScaffold(
      appBar: TulAppBar(title: '5 Tenets (오대정신)', onBack: () => context.pop()),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: TulStack.sm(
        children: [
          for (final t in _tenets)
            TulCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _IconChip(hanja: t.$3.substring(0, 1), accent: t.$4),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.$1,
                                style: TulTextStyles.cardHeader(color: palette.text)
                                    .copyWith(fontSize: 16)),
                            const SizedBox(height: 2),
                            Text('${t.$2} · ${t.$3}',
                                style: TulTextStyles.small(color: palette.text3)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(t.$5,
                      style: TulTextStyles.subtitle(color: palette.text2)
                          .copyWith(height: 1.6)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

enum _Accent { primary, secondary, accent }

class _IconChip extends StatelessWidget {
  const _IconChip({required this.hanja, required this.accent});

  final String hanja;
  final _Accent accent;

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    final color = switch (accent) {
      _Accent.primary => palette.primary,
      _Accent.secondary => palette.secondary,
      _Accent.accent => palette.accent,
    };
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Text(
        hanja,
        style: TulTextStyles.korean(
          size: 18,
          weight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
