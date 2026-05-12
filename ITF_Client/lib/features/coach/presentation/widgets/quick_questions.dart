import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/tul_palette.dart';
import '../../../../core/theme/tul_radius.dart';
import '../../../../core/theme/tul_text_styles.dart';

class QuickQuestions extends StatelessWidget {
  const QuickQuestions({super.key, required this.onTap});

  final void Function(String text) onTap;

  static const _keys = [
    'coach.quick.todayPractice',
    'coach.quick.fiveSpirits',
    'coach.quick.walkingStance',
    'coach.quick.gradingTips',
  ];

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _keys.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final label = _keys[i].tr();
          return Material(
            color: palette.card,
            borderRadius: TulRadius.brMd,
            child: InkWell(
              onTap: () => onTap(label),
              borderRadius: TulRadius.brMd,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: TulRadius.brMd,
                  border: Border.all(color: palette.border),
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: TulTextStyles.small(color: palette.text2),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
