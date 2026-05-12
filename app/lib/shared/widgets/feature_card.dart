import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/tul_colors.dart';
import '../../core/theme/tul_gradients.dart';
import '../../core/theme/tul_radius.dart';
import '../../core/theme/tul_shadows.dart';

/// Brand-gradient hero card. Used for "Today's Focus", featured patterns, etc.
class FeatureCard extends StatelessWidget {
  const FeatureCard({
    super.key,
    required this.label,
    required this.title,
    this.body,
    this.progress,
    this.primaryLabel,
    this.secondaryLabel,
    this.onPrimary,
    this.onSecondary,
    this.icon = LucideIcons.zap,
  });

  final String label;
  final String title;
  final String? body;

  /// 0..100 — renders a thin white progress bar above actions.
  final double? progress;
  final String? primaryLabel;
  final String? secondaryLabel;
  final VoidCallback? onPrimary;
  final VoidCallback? onSecondary;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: TulRadius.brXl4,
        boxShadow: isDark ? TulShadows.featureDark : TulShadows.featureLight,
      ),
      child: ClipRRect(
        borderRadius: TulRadius.brXl4,
        child: Stack(
          children: [
            // Gradient fills the whole card, sized by the content below.
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(gradient: TulGradients.brand),
              ),
            ),
            // Soft white glows (CSS::before / ::after equivalents). RadialGradient
            // gives a true fading bloom instead of a hard-edged disc.
            Positioned(
              top: -40,
              right: -40,
              child: _Bloom(size: 200, intensity: 0.22),
            ),
            Positioned(
              bottom: -40,
              left: -30,
              child: _Bloom(size: 160, intensity: 0.10),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 16, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.44,
                  ),
                ),
                if (body != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    body!,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.88),
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
                if (progress != null) ...[
                  const SizedBox(height: 18),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: (progress!.clamp(0, 100)) / 100,
                      minHeight: 6,
                      backgroundColor: Colors.white.withValues(alpha: 0.18),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ],
                if (primaryLabel != null || secondaryLabel != null) ...[
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      if (primaryLabel != null)
                        Expanded(
                          child: _FeatureButton(
                            label: primaryLabel!,
                            onPressed: onPrimary,
                            white: true,
                          ),
                        ),
                      if (primaryLabel != null && secondaryLabel != null)
                        const SizedBox(width: 10),
                      if (secondaryLabel != null)
                        Expanded(
                          child: _FeatureButton(
                            label: secondaryLabel!,
                            onPressed: onSecondary,
                            white: false,
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Soft radial bloom — white center fading to fully transparent.
/// Mimics a Gaussian blur disc without needing a backdrop filter.
class _Bloom extends StatelessWidget {
  const _Bloom({required this.size, required this.intensity});

  final double size;
  final double intensity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              Colors.white.withValues(alpha: intensity),
              Colors.white.withValues(alpha: 0),
            ],
            stops: const [0.0, 1.0],
          ),
        ),
      ),
    );
  }
}

class _FeatureButton extends StatelessWidget {
  const _FeatureButton({
    required this.label,
    required this.white,
    this.onPressed,
  });

  final String label;
  final bool white;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final bg = white ? Colors.white : Colors.white.withValues(alpha: 0.18);
    final fg = white ? TulColors.primary : Colors.white;
    return Material(
      color: bg,
      borderRadius: TulRadius.brLg,
      child: InkWell(
        onTap: onPressed,
        borderRadius: TulRadius.brLg,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 14),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
