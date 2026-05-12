import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Theme-aware palette exposed via `Theme.of(context).extension<TulPalette>()`,
/// or the [TulPaletteX] convenience getter `context.tul`.
///
/// Values come straight from [AppColors] so existing code that references
/// `AppColors.primary` etc. and new widgets that read `context.tul.primary`
/// stay in lock-step. The point of this extension is to let widgets resolve
/// dark vs light tones from a single source without sprinkling
/// `Theme.of(context).brightness == Brightness.dark ? ... : ...` checks.
@immutable
class TulPalette extends ThemeExtension<TulPalette> {
  const TulPalette({
    required this.bg,
    required this.stage,
    required this.card,
    required this.card2,
    required this.muted,
    required this.border,
    required this.borderStrong,
    required this.text,
    required this.text2,
    required this.text3,
    required this.hover,
    required this.track,
    required this.tabbarBg,
    required this.modalVeil,
    required this.stripe,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.green,
    required this.yellow,
    required this.pink,
  });

  // ── Surface tones ─────────────────────────────────────────
  final Color bg;
  final Color stage;
  final Color card;
  final Color card2;
  final Color muted;
  final Color border;
  final Color borderStrong;

  // ── Text tones ────────────────────────────────────────────
  final Color text;
  final Color text2;
  final Color text3;

  // ── Interaction tones ─────────────────────────────────────
  final Color hover;
  final Color track;
  final Color tabbarBg;
  final Color modalVeil;
  final Color stripe;

  // ── Brand / semantic accents ──────────────────────────────
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color green;
  final Color yellow;
  final Color pink;

  static const dark = TulPalette(
    bg: AppColors.background,
    stage: AppColors.stage,
    card: AppColors.surface,
    card2: AppColors.surfaceVariant,
    muted: AppColors.muted,
    border: AppColors.border,
    borderStrong: AppColors.borderStrong,
    text: AppColors.textPrimary,
    text2: AppColors.textSecondary,
    text3: AppColors.textDisabled,
    hover: Color(0x08FFFFFF),
    track: Color(0x1AFFFFFF),
    tabbarBg: Color(0xF50A0A0C), // 0.96 alpha — opaque enough to read cleanly
    modalVeil: Color(0x8C000000),
    stripe: Color(0x0AFFFFFF),
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    accent: AppColors.accent,
    green: AppColors.success,
    yellow: AppColors.warning,
    pink: Color(0xFFEC4899),
  );

  static const light = TulPalette(
    bg: AppColors.lightBackground,
    stage: AppColors.lightSurface,
    card: AppColors.lightSurface,
    card2: AppColors.lightSurfaceVariant,
    muted: AppColors.lightMuted,
    border: AppColors.lightBorder,
    borderStrong: Color(0x24000000),
    text: AppColors.lightTextPrimary,
    text2: AppColors.lightTextSecondary,
    text3: AppColors.lightTextDisabled,
    hover: Color(0x08000000),
    track: Color(0x14000000),
    tabbarBg: Color(0xF7FFFFFF), // 0.97 alpha
    modalVeil: Color(0x590F0F14),
    stripe: Color(0x0A000000),
    primary: AppColors.lightPrimary,
    secondary: AppColors.lightSecondary,
    accent: AppColors.lightAccent,
    green: AppColors.success,
    yellow: AppColors.warning,
    pink: Color(0xFFEC4899),
  );

  @override
  TulPalette copyWith({
    Color? bg,
    Color? stage,
    Color? card,
    Color? card2,
    Color? muted,
    Color? border,
    Color? borderStrong,
    Color? text,
    Color? text2,
    Color? text3,
    Color? hover,
    Color? track,
    Color? tabbarBg,
    Color? modalVeil,
    Color? stripe,
    Color? primary,
    Color? secondary,
    Color? accent,
    Color? green,
    Color? yellow,
    Color? pink,
  }) {
    return TulPalette(
      bg: bg ?? this.bg,
      stage: stage ?? this.stage,
      card: card ?? this.card,
      card2: card2 ?? this.card2,
      muted: muted ?? this.muted,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      text: text ?? this.text,
      text2: text2 ?? this.text2,
      text3: text3 ?? this.text3,
      hover: hover ?? this.hover,
      track: track ?? this.track,
      tabbarBg: tabbarBg ?? this.tabbarBg,
      modalVeil: modalVeil ?? this.modalVeil,
      stripe: stripe ?? this.stripe,
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      accent: accent ?? this.accent,
      green: green ?? this.green,
      yellow: yellow ?? this.yellow,
      pink: pink ?? this.pink,
    );
  }

  @override
  TulPalette lerp(ThemeExtension<TulPalette>? other, double t) {
    if (other is! TulPalette) return this;
    return TulPalette(
      bg: Color.lerp(bg, other.bg, t)!,
      stage: Color.lerp(stage, other.stage, t)!,
      card: Color.lerp(card, other.card, t)!,
      card2: Color.lerp(card2, other.card2, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      text: Color.lerp(text, other.text, t)!,
      text2: Color.lerp(text2, other.text2, t)!,
      text3: Color.lerp(text3, other.text3, t)!,
      hover: Color.lerp(hover, other.hover, t)!,
      track: Color.lerp(track, other.track, t)!,
      tabbarBg: Color.lerp(tabbarBg, other.tabbarBg, t)!,
      modalVeil: Color.lerp(modalVeil, other.modalVeil, t)!,
      stripe: Color.lerp(stripe, other.stripe, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      green: Color.lerp(green, other.green, t)!,
      yellow: Color.lerp(yellow, other.yellow, t)!,
      pink: Color.lerp(pink, other.pink, t)!,
    );
  }
}

/// Convenience getter so widgets can write `context.tul.primary`.
extension TulPaletteX on BuildContext {
  TulPalette get tul => Theme.of(this).extension<TulPalette>()!;
}
