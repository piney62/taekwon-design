import 'package:flutter/material.dart';

import '../../core/theme/tul_colors.dart';
import '../../core/theme/tul_radius.dart';
import '../../core/theme/tul_text_styles.dart';

enum Severity { critical, improve, watch }

class SeverityTag extends StatelessWidget {
  const SeverityTag({super.key, required this.severity, this.label});

  final Severity severity;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    final (color, defaultLabel) = switch (severity) {
      Severity.critical => (palette.primary, 'Critical'),
      Severity.improve => (palette.yellow, 'Needs Improvement'),
      Severity.watch => (palette.secondary, 'Watch'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(TulRadius.pill),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label ?? defaultLabel,
        style: TulTextStyles.mono(size: 10, color: color, letterSpacing: 1),
      ),
    );
  }
}
