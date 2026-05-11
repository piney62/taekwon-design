import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography tokens. Font families are loaded lazily via google_fonts.
/// Inter — body. Noto Sans KR — Korean. JetBrains Mono — mono labels.
class TulTextStyles {
  TulTextStyles._();

  static TextStyle _inter({
    required double size,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double? height,
    double letterSpacing = 0,
  }) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );

  static TextStyle mono({
    required double size,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double letterSpacing = 0,
  }) =>
      GoogleFonts.jetBrainsMono(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
      );

  static TextStyle korean({
    required double size,
    FontWeight weight = FontWeight.w400,
    Color? color,
  }) =>
      GoogleFonts.notoSansKr(
        fontSize: size,
        fontWeight: weight,
        color: color,
      );

  // Display
  static TextStyle splashTitle({Color? color}) => _inter(
        size: 38,
        weight: FontWeight.w800,
        color: color,
        letterSpacing: -1.14, // -0.03em
      );

  // Titles
  static TextStyle title({Color? color}) => _inter(
        size: 28,
        weight: FontWeight.w700,
        color: color,
        letterSpacing: -0.56,
        height: 1.15,
      );

  static TextStyle h2({Color? color}) => _inter(
        size: 20,
        weight: FontWeight.w700,
        color: color,
        letterSpacing: -0.2,
      );

  static TextStyle topBar({Color? color}) => _inter(
        size: 18,
        weight: FontWeight.w700,
        color: color,
        letterSpacing: -0.18,
      );

  static TextStyle cardHeader({Color? color}) => _inter(
        size: 15,
        weight: FontWeight.w600,
        color: color,
        letterSpacing: -0.15,
      );

  // Body
  static TextStyle body({Color? color}) => _inter(
        size: 14,
        weight: FontWeight.w400,
        color: color,
        height: 1.5,
      );

  static TextStyle bodyMd({Color? color}) => _inter(
        size: 14,
        weight: FontWeight.w500,
        color: color,
      );

  static TextStyle bodyStrong({Color? color}) => _inter(
        size: 14,
        weight: FontWeight.w600,
        color: color,
      );

  static TextStyle subtitle({Color? color}) => _inter(
        size: 13,
        weight: FontWeight.w400,
        color: color,
        height: 1.5,
      );

  static TextStyle small({Color? color}) => _inter(
        size: 12,
        weight: FontWeight.w400,
        color: color,
      );

  static TextStyle smallStrong({Color? color}) => _inter(
        size: 12,
        weight: FontWeight.w600,
        color: color,
      );

  static TextStyle tiny({Color? color}) => _inter(
        size: 11,
        weight: FontWeight.w400,
        color: color,
      );

  static TextStyle micro({Color? color}) => _inter(
        size: 10,
        weight: FontWeight.w500,
        color: color,
      );

  // Numeric / stat
  static TextStyle statValue({Color? color}) => _inter(
        size: 22,
        weight: FontWeight.w700,
        color: color,
        letterSpacing: -0.44,
      );

  static TextStyle gaugeNum({Color? color}) => _inter(
        size: 56,
        weight: FontWeight.w800,
        color: color,
        letterSpacing: -2.24,
        height: 1,
      );

  // Mono labels (JetBrains Mono)
  static TextStyle railTitle({Color? color}) => mono(
        size: 11,
        weight: FontWeight.w400,
        color: color,
        letterSpacing: 1.32,
      );

  static TextStyle tagLabel({Color? color}) => mono(
        size: 11,
        weight: FontWeight.w500,
        color: color,
        letterSpacing: 1.1,
      );

  static TextStyle gaugeLabel({Color? color}) => mono(
        size: 11,
        weight: FontWeight.w500,
        color: color,
        letterSpacing: 1.1,
      );
}
