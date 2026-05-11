import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum UserRole { student, instructor }

@immutable
class AppSettings {
  const AppSettings({
    this.role = UserRole.student,
    this.themeMode = ThemeMode.dark,
    this.locale = const Locale('en'),
    this.onboardingComplete = false,
  });

  final UserRole role;
  final ThemeMode themeMode;
  final Locale locale;
  final bool onboardingComplete;

  AppSettings copyWith({
    UserRole? role,
    ThemeMode? themeMode,
    Locale? locale,
    bool? onboardingComplete,
  }) =>
      AppSettings(
        role: role ?? this.role,
        themeMode: themeMode ?? this.themeMode,
        locale: locale ?? this.locale,
        onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      );
}

class AppSettingsController extends StateNotifier<AppSettings> {
  AppSettingsController(this._prefs) : super(_load(_prefs));

  static const _kRole = 'role';
  static const _kTheme = 'themeMode';
  static const _kLocale = 'locale';
  static const _kOnboarded = 'onboarded';

  final SharedPreferences _prefs;

  static AppSettings _load(SharedPreferences prefs) {
    final roleStr = prefs.getString(_kRole) ?? 'student';
    final themeStr = prefs.getString(_kTheme) ?? 'dark';
    final localeStr = prefs.getString(_kLocale) ?? 'en';
    final onboarded = prefs.getBool(_kOnboarded) ?? false;

    return AppSettings(
      role: roleStr == 'instructor' ? UserRole.instructor : UserRole.student,
      themeMode: switch (themeStr) {
        'light' => ThemeMode.light,
        'system' => ThemeMode.system,
        _ => ThemeMode.dark,
      },
      locale: Locale(localeStr),
      onboardingComplete: onboarded,
    );
  }

  void setRole(UserRole r) {
    state = state.copyWith(role: r);
    _prefs.setString(_kRole, r == UserRole.instructor ? 'instructor' : 'student');
  }

  void setThemeMode(ThemeMode m) {
    state = state.copyWith(themeMode: m);
    _prefs.setString(_kTheme, switch (m) {
      ThemeMode.light => 'light',
      ThemeMode.system => 'system',
      _ => 'dark',
    });
  }

  void setLocale(Locale l) {
    state = state.copyWith(locale: l);
    _prefs.setString(_kLocale, l.languageCode);
  }

  void setOnboardingComplete(bool v) {
    state = state.copyWith(onboardingComplete: v);
    _prefs.setBool(_kOnboarded, v);
  }

  void logout() {
    state = state.copyWith(onboardingComplete: false);
    _prefs.setBool(_kOnboarded, false);
  }
}

final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Override in main() before runApp');
});

final appSettingsProvider =
    StateNotifierProvider<AppSettingsController, AppSettings>((ref) {
  return AppSettingsController(ref.watch(sharedPrefsProvider));
});
