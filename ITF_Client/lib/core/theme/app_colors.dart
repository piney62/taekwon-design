import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Backgrounds ────────────────────────────────────────────
  static const Color background    = Color(0xFF050507);
  static const Color stage         = Color(0xFF0A0A0C);
  static const Color surface       = Color(0xFF141417);
  static const Color surfaceVariant = Color(0xFF1A1A1F);
  static const Color muted         = Color(0xFF232328);

  // ── Borders ────────────────────────────────────────────────
  static const Color border        = Color(0x14FFFFFF); // 8% white
  static const Color borderStrong  = Color(0x24FFFFFF); // 14% white

  // ── Brand — Primary (Red) ──────────────────────────────────
  static const Color primary       = Color(0xFFEF4444);
  static const Color primaryLight  = Color(0xFFF87171);
  static const Color primaryDeep   = Color(0xFF7F1D1D);

  // Legacy alias kept so existing references compile without changes
  static const Color itfRed        = primary;
  static const Color itfRedDark    = primaryDeep;
  static const Color itfRedLight   = primaryLight;

  // ── Brand — Secondary (Blue) ───────────────────────────────
  static const Color secondary     = Color(0xFF3B82F6);
  static const Color secondaryLight = Color(0xFF60A5FA);

  // ── Brand — Accent (Purple) ────────────────────────────────
  static const Color accent        = Color(0xFF8B5CF6);

  // ── Semantic ───────────────────────────────────────────────
  static const Color success       = Color(0xFF10B981);
  static const Color warning       = Color(0xFFFACC15);
  static const Color info          = Color(0xFF3B82F6);
  static const Color purple        = Color(0xFF8B5CF6);

  // ── Text ───────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFFAFAFA);
  static const Color textSecondary = Color(0xFFA3A3A8);
  static const Color textDisabled  = Color(0xFF6B6B73);

  // Short aliases
  static const Color text          = textPrimary;
  static const Color textMuted     = textSecondary;

  // Legacy aliases
  static const Color outline       = borderStrong;

  // ── Gradients ─────────────────────────────────────────────
  static const LinearGradient gradMain = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.45, 1.0],
    colors: [
      Color(0xFFEF4444),
      Color(0xFFEC4899),
      Color(0xFF3B82F6),
    ],
  );

  static const LinearGradient gradAccent = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF8B5CF6),
      Color(0xFF3B82F6),
    ],
  );

  static const LinearGradient gradSoft = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x2EEF4444),
      Color(0x2E3B82F6),
    ],
  );

  // ── Light theme equivalents ────────────────────────────────
  static const Color lightBackground    = Color(0xFFF5F5F7);
  static const Color lightSurface       = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFFAFAFA);
  static const Color lightMuted         = Color(0xFFF1F1F4);
  static const Color lightBorder        = Color(0x14000000);
  static const Color lightTextPrimary   = Color(0xFF0A0A0C);
  static const Color lightTextSecondary = Color(0xFF5B5B63);
  static const Color lightTextDisabled  = Color(0xFF8A8A92);
  static const Color lightPrimary       = Color(0xFFDC2626);
  static const Color lightSecondary     = Color(0xFF2563EB);
  static const Color lightAccent        = Color(0xFF7C3AED);
}
