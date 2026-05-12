import 'package:flutter/material.dart';

import '../../../../core/storage/preferences_service.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/ai_provider.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/entities/belt_level.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl({
    required this.prefs,
    required this.secureStorage,
  });

  final PreferencesService prefs;
  final SecureStorageService secureStorage;

  static const _kBeltLevel = 'pref.belt_level';
  static const _kLanguage = 'pref.language';
  static const _kAiProvider = 'pref.ai_provider';
  static const _kThemeMode = 'pref.theme_mode';

  String _apiKeyFor(AiProvider provider) => 'secret.api_key.${provider.name}';

  @override
  Future<AppSettings> load() async {
    final beltStr = prefs.getString(_kBeltLevel);
    final lang = prefs.getString(_kLanguage) ?? 'ko';
    final providerStr = prefs.getString(_kAiProvider);
    final provider = _parseProvider(providerStr);
    final hasKey = await secureStorage.contains(_apiKeyFor(provider));
    final themeStr = prefs.getString(_kThemeMode);

    return AppSettings(
      beltLevel: _parseBelt(beltStr),
      languageCode: lang,
      aiProvider: provider,
      isApiKeyConfigured: hasKey,
      themeMode: _parseTheme(themeStr),
    );
  }

  @override
  Future<void> setBeltLevel(BeltLevel level) async {
    await prefs.setString(_kBeltLevel, level.name);
  }

  @override
  Future<void> setLanguageCode(String code) async {
    await prefs.setString(_kLanguage, code);
  }

  @override
  Future<void> setThemeMode(ThemeMode mode) async {
    await prefs.setString(_kThemeMode, mode.name);
  }

  @override
  Future<void> setAiProvider(AiProvider provider) async {
    await prefs.setString(_kAiProvider, provider.name);
  }

  @override
  Future<void> saveApiKey(String key, AiProvider provider) =>
      secureStorage.write(_apiKeyFor(provider), key);

  @override
  Future<String?> readApiKey(AiProvider provider) =>
      secureStorage.read(_apiKeyFor(provider));

  @override
  Future<void> clearApiKey(AiProvider provider) =>
      secureStorage.delete(_apiKeyFor(provider));

  BeltLevel _parseBelt(String? raw) {
    if (raw == null) return BeltLevel.white;
    return BeltLevel.values.firstWhere(
      (b) => b.name == raw,
      orElse: () => BeltLevel.white,
    );
  }

  AiProvider _parseProvider(String? raw) {
    if (raw == null) return AiProvider.groq;
    return AiProvider.values.firstWhere(
      (p) => p.name == raw,
      orElse: () => AiProvider.groq,
    );
  }

  ThemeMode _parseTheme(String? raw) {
    return switch (raw) {
      'light' => ThemeMode.light,
      'system' => ThemeMode.system,
      _ => ThemeMode.dark,
    };
  }
}
