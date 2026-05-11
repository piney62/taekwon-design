import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'tul_colors.dart';
import 'tul_radius.dart';

/// App-wide ThemeData for dark and light modes.
class AppTheme {
  AppTheme._();

  static ThemeData dark() => _build(
        brightness: Brightness.dark,
        palette: TulPalette.dark,
        scaffoldBg: TulColors.darkStage,
      );

  static ThemeData light() => _build(
        brightness: Brightness.light,
        palette: TulPalette.light,
        scaffoldBg: TulColors.lightStage,
      );

  static ThemeData _build({
    required Brightness brightness,
    required TulPalette palette,
    required Color scaffoldBg,
  }) {
    final baseTextTheme = brightness == Brightness.dark
        ? Typography.material2021().white
        : Typography.material2021().black;
    final textTheme = GoogleFonts.interTextTheme(baseTextTheme).apply(
      bodyColor: palette.text,
      displayColor: palette.text,
    );

    return ThemeData(
      brightness: brightness,
      useMaterial3: true,
      scaffoldBackgroundColor: scaffoldBg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: palette.primary,
        brightness: brightness,
        primary: palette.primary,
        secondary: palette.secondary,
        tertiary: palette.accent,
        error: palette.primary,
        surface: palette.card,
      ),
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,
      iconTheme: IconThemeData(color: palette.text, size: 20),
      dividerColor: palette.border,
      extensions: [palette],
      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.muted,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(color: palette.text3, fontSize: 14),
        labelStyle: TextStyle(color: palette.text2, fontSize: 12),
        border: OutlineInputBorder(
          borderRadius: TulRadius.brLg,
          borderSide: BorderSide(color: palette.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: TulRadius.brLg,
          borderSide: BorderSide(color: palette.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: TulRadius.brLg,
          borderSide: BorderSide(color: palette.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: TulRadius.brLg,
          borderSide: BorderSide(color: palette.primary),
        ),
      ),
      // Bottom sheets (modal style)
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.card,
        modalBackgroundColor: palette.card,
        modalBarrierColor: palette.modalVeil,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: TulRadius.rXl4),
        ),
        showDragHandle: false,
        elevation: 0,
      ),
      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: palette.card,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: TulRadius.brXl3,
        ),
      ),
      // AppBar (we use a custom one, but set sane defaults)
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: palette.text),
        titleTextStyle: TextStyle(
          color: palette.text,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.18,
        ),
      ),
      // Bottom nav
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: palette.tabbarBg,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: palette.primary,
        unselectedItemColor: palette.text3,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        elevation: 0,
      ),
    );
  }
}
