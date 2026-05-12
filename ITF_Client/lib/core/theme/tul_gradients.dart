import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Brand gradients. Two flavors — punchy for small surfaces, refined for
/// hero cards.
class TulGradients {
  TulGradients._();

  /// Punchy red → pink → blue. Use on small surfaces (buttons, text accents,
  /// icon chips) where vibrancy reads as energy. This is the original
  /// `AppColors.gradMain`; re-exported here for new widgets to read from a
  /// single namespace.
  static const brand = AppColors.gradMain;

  /// Softer wash for backgrounds, info pills, accent fills.
  static const brandSoft = AppColors.gradSoft;

  /// Refined "wine" variant for large hero surfaces (FeatureCard, large
  /// CTAs over dark backgrounds). One shade deeper across the board, with
  /// the bright pink middle swapped for a royal purple so the card reads
  /// "wine" rather than "candy."
  ///
  ///   red-500    → red-700    (#EF4444 → #B91C1C)
  ///   pink-500   → purple-700 (#EC4899 → #7E22CE)
  ///   blue-500   → blue-800   (#3B82F6 → #1E40AF)
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

  /// Ring gradient for [ProgressRing] — red to blue, no pink middle.
  static const ring = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primary, AppColors.secondary],
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
    colors: [AppColors.secondary, AppColors.accent],
  );
}
