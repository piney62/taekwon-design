import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/preferences_service.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../data/repositories/settings_repository_impl.dart';
import '../domain/entities/ai_provider.dart';
import '../domain/entities/app_settings.dart';
import '../domain/entities/belt_level.dart';
import '../domain/repositories/settings_repository.dart';

final settingsRepositoryProvider = FutureProvider<SettingsRepository>((
  ref,
) async {
  final prefs = await ref.watch(preferencesServiceProvider.future);
  final secureStorage = ref.watch(secureStorageProvider);
  return SettingsRepositoryImpl(prefs: prefs, secureStorage: secureStorage);
});

class SettingsController extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async {
    final repo = await ref.watch(settingsRepositoryProvider.future);
    return repo.load();
  }

  Future<void> setBeltLevel(BeltLevel level) async {
    final repo = await ref.read(settingsRepositoryProvider.future);
    await repo.setBeltLevel(level);
    state = AsyncData(state.requireValue.copyWith(beltLevel: level));
  }

  Future<void> setLanguageCode(String code) async {
    final repo = await ref.read(settingsRepositoryProvider.future);
    await repo.setLanguageCode(code);
    state = AsyncData(state.requireValue.copyWith(languageCode: code));
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final repo = await ref.read(settingsRepositoryProvider.future);
    await repo.setThemeMode(mode);
    state = AsyncData(state.requireValue.copyWith(themeMode: mode));
  }

  Future<void> setAiProvider(AiProvider provider) async {
    final repo = await ref.read(settingsRepositoryProvider.future);
    await repo.setAiProvider(provider);
    final hasKey = (await repo.readApiKey(provider)) != null;
    state = AsyncData(state.requireValue.copyWith(
      aiProvider: provider,
      isApiKeyConfigured: hasKey,
    ));
  }

  Future<void> saveApiKey(String key) async {
    final repo = await ref.read(settingsRepositoryProvider.future);
    final provider = state.requireValue.aiProvider;
    await repo.saveApiKey(key, provider);
    state = AsyncData(state.requireValue.copyWith(isApiKeyConfigured: true));
  }

  Future<void> clearApiKey() async {
    final repo = await ref.read(settingsRepositoryProvider.future);
    final provider = state.requireValue.aiProvider;
    await repo.clearApiKey(provider);
    state = AsyncData(state.requireValue.copyWith(isApiKeyConfigured: false));
  }
}

final settingsControllerProvider =
    AsyncNotifierProvider<SettingsController, AppSettings>(
      SettingsController.new,
    );
