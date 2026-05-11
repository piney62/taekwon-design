import 'package:flutter/material.dart';

import '../../core/theme/tul_colors.dart';
import '../../core/theme/tul_gradients.dart';
import '../../core/theme/tul_radius.dart';
import '../../core/theme/tul_shadows.dart';

/// Primary gradient pill button — main CTA across the app.
class TulPrimaryButton extends StatelessWidget {
  const TulPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final button = Container(
      decoration: BoxDecoration(
        gradient: TulGradients.brand,
        borderRadius: TulRadius.brLg,
        boxShadow: TulShadows.primaryButton,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: TulRadius.brLg,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: Colors.white),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}

class TulSecondaryButton extends StatelessWidget {
  const TulSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    final button = Material(
      color: palette.card,
      borderRadius: TulRadius.brLg,
      child: InkWell(
        onTap: onPressed,
        borderRadius: TulRadius.brLg,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: TulRadius.brLg,
            border: Border.all(color: palette.borderStrong),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: palette.text),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  color: palette.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}

class TulGhostButton extends StatelessWidget {
  const TulGhostButton({
    super.key,
    required this.label,
    this.onPressed,
    this.color,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color ?? Theme.of(context).colorScheme.primary,
        padding: EdgeInsets.zero,
        minimumSize: const Size(0, 0),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class TulDestructiveButton extends StatelessWidget {
  const TulDestructiveButton({
    super.key,
    required this.label,
    this.onPressed,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final btn = Material(
      color: TulColors.primary.withValues(alpha: 0.10),
      borderRadius: TulRadius.brLg,
      child: InkWell(
        onTap: onPressed,
        borderRadius: TulRadius.brLg,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: TulRadius.brLg,
            border: Border.all(color: TulColors.primary.withValues(alpha: 0.3)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(
              color: TulColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
    return expanded ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}
