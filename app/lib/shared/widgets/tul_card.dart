import 'package:flutter/material.dart';

import '../../core/theme/tul_colors.dart';
import '../../core/theme/tul_radius.dart';
import '../../core/theme/tul_shadows.dart';

/// Base card container. Mirrors `.card` from the React prototype.
class TulCard extends StatelessWidget {
  const TulCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = TulRadius.brXl3,
    this.background,
    this.borderColor,
    this.shadow,
    this.onTap,
  });

  /// Compact variant — 16px padding, 18px radius.
  const TulCard.compact({
    super.key,
    required this.child,
    this.background,
    this.borderColor,
    this.shadow,
    this.onTap,
  })  : padding = const EdgeInsets.all(16),
        borderRadius = TulRadius.brXl2;

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final Color? background;
  final Color? borderColor;
  final List<BoxShadow>? shadow;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final container = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: background ?? palette.card,
        borderRadius: borderRadius,
        border: Border.all(color: borderColor ?? palette.border, width: 1),
        boxShadow: shadow ?? (isDark ? TulShadows.cardDark : TulShadows.cardLight),
      ),
      child: child,
    );

    if (onTap == null) return container;
    return Material(
      color: Colors.transparent,
      borderRadius: borderRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: container,
      ),
    );
  }
}
