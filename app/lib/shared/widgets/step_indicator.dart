import 'package:flutter/material.dart';

import '../../core/theme/tul_colors.dart';
import '../../core/theme/tul_gradients.dart';
import '../../core/theme/tul_text_styles.dart';

/// Bar-style step indicator used in the onboarding flow.
class StepIndicator extends StatelessWidget {
  const StepIndicator({
    super.key,
    required this.current,
    required this.total,
  });

  /// 1-based.
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    return Row(
      children: [
        for (var i = 1; i <= total; i++) ...[
          Container(
            width: 32,
            height: 4,
            decoration: BoxDecoration(
              gradient: i <= current ? TulGradients.brand : null,
              color: i > current ? palette.muted : null,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          if (i < total) const SizedBox(width: 6),
        ],
        const SizedBox(width: 12),
        Text(
          'STEP $current / $total',
          style: TulTextStyles.tagLabel(color: palette.text3),
        ),
      ],
    );
  }
}
