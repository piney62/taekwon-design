import 'package:flutter/widgets.dart';

/// Box-shadow tokens used by [TulCard], [FeatureCard], [TulPrimaryButton]
/// and other shared widgets.
class TulShadows {
  TulShadows._();

  // ── Generic card lift ─────────────────────────────────────
  static const cardDark = [
    BoxShadow(
      color: Color(0x4D000000), // 30% black
      blurRadius: 24,
      offset: Offset(0, 4),
    ),
  ];

  static const cardLight = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 3, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x0F000000), blurRadius: 28, offset: Offset(0, 8)),
  ];

  // ── FeatureCard halo (wine-toned to match the refined gradient) ─
  static const featureDark = [
    BoxShadow(
      color: Color(0x33B91C1C), // 20% red-700
      blurRadius: 50,
      offset: Offset(0, 18),
    ),
  ];

  static const featureLight = [
    BoxShadow(
      color: Color(0x26B91C1C), // 15% red-700
      blurRadius: 50,
      offset: Offset(0, 18),
    ),
  ];

  // ── Primary button glow ──────────────────────────────────
  static const primaryButton = [
    BoxShadow(
      color: Color(0x4DEF4444), // 30% primary red
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  // ── Phone frame (web preview) ────────────────────────────
  static const phoneFrame = [
    BoxShadow(
      color: Color(0x99000000),
      blurRadius: 120,
      offset: Offset(0, 40),
    ),
  ];
}
