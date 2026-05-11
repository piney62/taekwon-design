import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/tul_colors.dart';

/// Circular progress indicator with the brand gradient stroke and centered %.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.value,
    this.size = 120,
    this.stroke = 10,
    this.label,
  });

  /// Percent, 0 to 100.
  final double value;
  final double size;
  final double stroke;

  /// Override the centered label; defaults to `value` followed by a percent sign.
  final String? label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          value: value.clamp(0, 100) / 100,
          stroke: stroke,
          trackColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0x14FFFFFF)
              : const Color(0x14000000),
        ),
        child: Center(
          child: Text(
            label ?? '${value.round()}%',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: size / 4,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.value,
    required this.stroke,
    required this.trackColor,
  });

  final double value;
  final double stroke;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - stroke) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawCircle(center, radius, trackPaint);

    if (value <= 0) return;

    final rect = Rect.fromCircle(center: center, radius: radius);
    final ringPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [TulColors.primary, TulColors.secondary],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * value,
      false,
      ringPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value || old.stroke != stroke || old.trackColor != trackColor;
}
