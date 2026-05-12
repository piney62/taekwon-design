import 'package:flutter/material.dart';

import 'ai_provider.dart';
import 'belt_level.dart';

class AppSettings {
  const AppSettings({
    required this.beltLevel,
    required this.languageCode,
    required this.aiProvider,
    required this.isApiKeyConfigured,
    required this.themeMode,
  });

  final BeltLevel beltLevel;
  final String languageCode;
  final AiProvider aiProvider;
  final bool isApiKeyConfigured;
  final ThemeMode themeMode;

  AppSettings copyWith({
    BeltLevel? beltLevel,
    String? languageCode,
    AiProvider? aiProvider,
    bool? isApiKeyConfigured,
    ThemeMode? themeMode,
  }) {
    return AppSettings(
      beltLevel: beltLevel ?? this.beltLevel,
      languageCode: languageCode ?? this.languageCode,
      aiProvider: aiProvider ?? this.aiProvider,
      isApiKeyConfigured: isApiKeyConfigured ?? this.isApiKeyConfigured,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}
