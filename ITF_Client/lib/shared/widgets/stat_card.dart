import 'package:flutter/material.dart';

import '../../core/theme/tul_palette.dart';
import '../../core/theme/tul_radius.dart';
import '../../core/theme/tul_shadows.dart';
import '../../core/theme/tul_text_styles.dart';

enum StatCardColor { primary, secondary, accent }

/// Compact 3-up stat card — icon chip + value + label.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.color = StatCardColor.primary,
  });

  final IconData icon;
  final String value;
  final String label;
  final StatCardColor color;

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final accent = switch (color) {
      StatCardColor.primary => palette.primary,
      StatCardColor.secondary => palette.secondary,
      StatCardColor.accent => palette.accent,
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: TulRadius.brXl2,
        border: Border.all(color: palette.border),
        boxShadow: isDark ? TulShadows.cardDark : TulShadows.cardLight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(11),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 18, color: accent),
          ),
          const SizedBox(height: 10),
          Text(value, style: TulTextStyles.statValue(color: palette.text)),
          const SizedBox(height: 2),
          Text(label, style: TulTextStyles.tiny(color: palette.text3)),
        ],
      ),
    );
  }
}
