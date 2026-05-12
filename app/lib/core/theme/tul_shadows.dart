import 'package:flutter/widgets.dart';

class TulShadows {
  TulShadows._();

  static const cardDark = [
    BoxShadow(
      color: Color(0x4D000000), // rgba(0,0,0,0.3)
      blurRadius: 24,
      offset: Offset(0, 4),
    ),
  ];

  static const cardLight = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 3,
      offset: Offset(0, 1),
    ),
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 28,
      offset: Offset(0, 8),
    ),
  ];

  // Halo for the refined FeatureCard. Uses red-700 (the same hue as the
  // card's gradient start) instead of the punchy primary red so the bloom
  // around the card stays in the same "wine" family as the surface.
  static const featureDark = [
    BoxShadow(
      color: Color(0x33B91C1C),
      blurRadius: 50,
      offset: Offset(0, 18),
    ),
  ];

  static const featureLight = [
    BoxShadow(
      color: Color(0x26B91C1C),
      blurRadius: 50,
      offset: Offset(0, 18),
    ),
  ];

  static const primaryButton = [
    BoxShadow(
      color: Color(0x4DEF4444),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  static const phoneFrame = [
    BoxShadow(
      color: Color(0x99000000),
      blurRadius: 120,
      offset: Offset(0, 40),
    ),
  ];
}
