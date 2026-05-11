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

  static const featureDark = [
    BoxShadow(
      color: Color(0x40EF4444),
      blurRadius: 50,
      offset: Offset(0, 20),
    ),
  ];

  static const featureLight = [
    BoxShadow(
      color: Color(0x33EF4444),
      blurRadius: 50,
      offset: Offset(0, 20),
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
