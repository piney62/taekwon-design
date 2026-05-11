import 'package:flutter/material.dart';

/// Color tokens. Two sets — dark (primary) and light.
/// Values mirror the CSS variables in the React prototype.
class TulColors {
  TulColors._();

  // ── Dark (primary) ─────────────────────────────────────────────
  static const darkBg = Color(0xFF050507);
  static const darkStage = Color(0xFF0A0A0C);
  static const darkCard = Color(0xFF141417);
  static const darkCard2 = Color(0xFF1A1A1F);
  static const darkMuted = Color(0xFF232328);
  static const darkBorder = Color(0x14FFFFFF); // rgba(255,255,255,0.08)
  static const darkBorderStrong = Color(0x24FFFFFF); // 0.14
  static const darkText = Color(0xFFFAFAFA);
  static const darkText2 = Color(0xFFA3A3A8);
  static const darkText3 = Color(0xFF6B6B73);
  static const darkHover = Color(0x08FFFFFF);
  static const darkTrack = Color(0x1AFFFFFF);
  static const darkTabbarBg = Color(0xD90A0A0C); // 0.85 alpha
  static const darkModalVeil = Color(0x8C000000); // 0.55
  static const darkStripe = Color(0x0AFFFFFF);

  // ── Light ─────────────────────────────────────────────────────
  static const lightBg = Color(0xFFF5F5F7);
  static const lightStage = Color(0xFFFFFFFF);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightCard2 = Color(0xFFFAFAFA);
  static const lightMuted = Color(0xFFF1F1F4);
  static const lightBorder = Color(0x14000000);
  static const lightBorderStrong = Color(0x24000000);
  static const lightText = Color(0xFF0A0A0C);
  static const lightText2 = Color(0xFF5B5B63);
  static const lightText3 = Color(0xFF8A8A92);
  static const lightHover = Color(0x08000000);
  static const lightTrack = Color(0x14000000);
  static const lightTabbarBg = Color(0xEBFFFFFF); // 0.92
  static const lightModalVeil = Color(0x590F0F14); // 0.35
  static const lightStripe = Color(0x0A000000);

  // ── Accents (shared across both modes) ─────────────────────────
  static const primary = Color(0xFFEF4444);
  static const primary2 = Color(0xFFF87171);
  static const primaryDeep = Color(0xFF7F1D1D);
  static const secondary = Color(0xFF3B82F6);
  static const secondary2 = Color(0xFF60A5FA);
  static const accent = Color(0xFF8B5CF6);
  static const green = Color(0xFF10B981);
  static const yellow = Color(0xFFFACC15);
  static const pink = Color(0xFFEC4899);

  // Light-variant primaries (slightly darker for contrast)
  static const primaryLight = Color(0xFFDC2626);
  static const secondaryLight = Color(0xFF2563EB);
  static const accentLight = Color(0xFF7C3AED);

  // ── Belt colors (functional, not decorative) ──────────────────
  static const beltWhite = Color(0xFFFAFAFA);
  static const beltYellow = Color(0xFFFACC15);
  static const beltGreen = Color(0xFF10B981);
  static const beltBlue = Color(0xFF3B82F6);
  static const beltRed = Color(0xFFEF4444);
  static const beltBlack = Color(0xFF18181B);
}

/// Theme-aware color set, exposed via [Theme.of(context).extension<TulPalette>()].
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

  final Color bg;
  final Color stage;
  final Color card;
  final Color card2;
  final Color muted;
  final Color border;
  final Color borderStrong;
  final Color text;
  final Color text2;
  final Color text3;
  final Color hover;
  final Color track;
  final Color tabbarBg;
  final Color modalVeil;
  final Color stripe;
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color green;
  final Color yellow;
  final Color pink;

  static const dark = TulPalette(
    bg: TulColors.darkBg,
    stage: TulColors.darkStage,
    card: TulColors.darkCard,
    card2: TulColors.darkCard2,
    muted: TulColors.darkMuted,
    border: TulColors.darkBorder,
    borderStrong: TulColors.darkBorderStrong,
    text: TulColors.darkText,
    text2: TulColors.darkText2,
    text3: TulColors.darkText3,
    hover: TulColors.darkHover,
    track: TulColors.darkTrack,
    tabbarBg: TulColors.darkTabbarBg,
    modalVeil: TulColors.darkModalVeil,
    stripe: TulColors.darkStripe,
    primary: TulColors.primary,
    secondary: TulColors.secondary,
    accent: TulColors.accent,
    green: TulColors.green,
    yellow: TulColors.yellow,
    pink: TulColors.pink,
  );

  static const light = TulPalette(
    bg: TulColors.lightBg,
    stage: TulColors.lightStage,
    card: TulColors.lightCard,
    card2: TulColors.lightCard2,
    muted: TulColors.lightMuted,
    border: TulColors.lightBorder,
    borderStrong: TulColors.lightBorderStrong,
    text: TulColors.lightText,
    text2: TulColors.lightText2,
    text3: TulColors.lightText3,
    hover: TulColors.lightHover,
    track: TulColors.lightTrack,
    tabbarBg: TulColors.lightTabbarBg,
    modalVeil: TulColors.lightModalVeil,
    stripe: TulColors.lightStripe,
    primary: TulColors.primaryLight,
    secondary: TulColors.secondaryLight,
    accent: TulColors.accentLight,
    green: TulColors.green,
    yellow: TulColors.yellow,
    pink: TulColors.pink,
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

extension TulPaletteX on BuildContext {
  TulPalette get tul => Theme.of(this).extension<TulPalette>()!;
}
