import 'package:flutter/material.dart';

import '../../core/theme/tul_colors.dart';
import '../../core/theme/tul_radius.dart';

enum TulBadgeColor { red, blue, green, yellow, muted }

/// Small pill label. Mirrors `.badge` + color variants.
class TulBadge extends StatelessWidget {
  const TulBadge({
    super.key,
    required this.label,
    this.color = TulBadgeColor.muted,
    this.icon,
  });

  final String label;
  final TulBadgeColor color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;

    Color bg, fg, border;
    switch (color) {
      case TulBadgeColor.red:
        bg = palette.primary.withValues(alpha: 0.12);
        fg = TulColors.primary2;
        border = palette.primary.withValues(alpha: 0.25);
      case TulBadgeColor.blue:
        bg = palette.secondary.withValues(alpha: 0.12);
        fg = TulColors.secondary2;
        border = palette.secondary.withValues(alpha: 0.25);
      case TulBadgeColor.green:
        bg = palette.green.withValues(alpha: 0.12);
        fg = palette.green;
        border = palette.green.withValues(alpha: 0.25);
      case TulBadgeColor.yellow:
        bg = palette.yellow.withValues(alpha: 0.12);
        fg = palette.yellow;
        border = palette.yellow.withValues(alpha: 0.25);
      case TulBadgeColor.muted:
        bg = palette.stripe;
        fg = palette.text2;
        border = palette.border;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(TulRadius.pill),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
