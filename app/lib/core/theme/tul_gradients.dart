import 'package:flutter/material.dart';
import 'tul_colors.dart';

/// Brand gradients — the fire/ice signature for primary CTAs and feature cards.
class TulGradients {
  TulGradients._();

  /// Primary brand gradient: red → pink → blue (135deg in CSS).
  static const brand = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [TulColors.primary, TulColors.pink, TulColors.secondary],
    stops: [0.0, 0.45, 1.0],
  );

  /// Softer wash for backgrounds and badge fills.
  static LinearGradient brandSoft = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      TulColors.primary.withValues(alpha: 0.18),
      TulColors.secondary.withValues(alpha: 0.18),
    ],
  );

  /// Ring gradient for [ProgressRing] — red to blue.
  static const ring = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [TulColors.primary, TulColors.secondary],
  );

  /// Korean term accent — blue to violet.
  static const koreanText = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF60A5FA), Color(0xFFA78BFA)],
  );

  /// Instructor badge accent — blue to violet (135deg).
  static const instructor = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [TulColors.secondary, TulColors.accent],
  );
}
