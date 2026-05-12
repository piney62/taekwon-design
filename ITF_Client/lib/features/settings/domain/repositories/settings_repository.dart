import 'package:flutter/material.dart';

import '../entities/ai_provider.dart';
import '../entities/app_settings.dart';
import '../entities/belt_level.dart';

abstract class SettingsRepository {
  Future<AppSettings> load();

  Future<void> setBeltLevel(BeltLevel level);

  Future<void> setLanguageCode(String code);

  Future<void> setThemeMode(ThemeMode mode);

  Future<void> setAiProvider(AiProvider provider);

  Future<void> saveApiKey(String key, AiProvider provider);

  Future<String?> readApiKey(AiProvider provider);

  Future<void> clearApiKey(AiProvider provider);
}
