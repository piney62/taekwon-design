import 'package:flutter/material.dart';

import '../../core/theme/tul_colors.dart';
import '../../core/theme/tul_radius.dart';
import '../../core/theme/tul_text_styles.dart';

/// Dashed/striped placeholder used as image dropzone in the prototype.
class PlaceholderBox extends StatelessWidget {
  const PlaceholderBox({
    super.key,
    required this.label,
    this.height = 160,
    this.width = double.infinity,
  });

  final String label;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: palette.muted,
        borderRadius: TulRadius.brXl,
        border: Border.all(color: palette.border),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _StripePainter(color: palette.stripe),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '// placeholder',
                    style: TulTextStyles.mono(
                      size: 11,
                      color: palette.text3.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TulTextStyles.mono(
                      size: 11,
                      color: palette.text3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StripePainter extends CustomPainter {
  _StripePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    // 45deg stripes, 8px on / 8px off.
    final spacing = 16.0;
    final stripeW = 8.0;
    final diag = size.width + size.height;
    for (double x = -size.height; x < diag; x += spacing) {
      final path = Path()
        ..moveTo(x, 0)
        ..lineTo(x + stripeW, 0)
        ..lineTo(x + stripeW + size.height, size.height)
        ..lineTo(x + size.height, size.height)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_StripePainter old) => old.color != color;
}
