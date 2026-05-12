import 'package:flutter/material.dart';
import 'tul_colors.dart';

/// Brand gradients — the fire/ice signature for primary CTAs and feature cards.
class TulGradients {
  TulGradients._();

  /// Primary brand gradient: red → pink → blue (135deg in CSS).
  /// Use on small surfaces (buttons, text accents, badges) where punch reads well.
  static const brand = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [TulColors.primary, TulColors.pink, TulColors.secondary],
    stops: [0.0, 0.45, 1.0],
  );

  /// Refined variant for large hero surfaces (FeatureCard, big buttons over
  /// dark backgrounds). Same red→cool warmth but one shade deeper across the
  /// board, and the bright pink middle is swapped for a royal purple so the
  /// card reads "wine" rather than "candy."
  static const feature = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFB91C1C), // red-700
      Color(0xFF7E22CE), // purple-700
      Color(0xFF1E40AF), // blue-800
    ],
    stops: [0.0, 0.5, 1.0],
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
