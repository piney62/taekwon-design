import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/tul_colors.dart';

class StarRating extends StatelessWidget {
  const StarRating({
    super.key,
    required this.value,
    this.onChanged,
    this.size = 26,
  });

  /// 0 to 5.
  final int value;
  final ValueChanged<int>? onChanged;
  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    final readOnly = onChanged == null;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final n = i + 1;
        final on = n <= value;
        final color = on ? palette.yellow : palette.text3;
        final icon = Icon(LucideIcons.star, size: size, color: color);
        if (readOnly) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: icon,
          );
        }
        return GestureDetector(
          onTap: () => onChanged?.call(n),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: icon,
          ),
        );
      }),
    );
  }
}
