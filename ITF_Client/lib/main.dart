import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Read saved language before Riverpod initializes
  final prefs = await SharedPreferences.getInstance();
  final langCode = prefs.getString('pref.language') ?? 'ko';

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ko'), Locale('en'), Locale('es'), Locale('ja'), Locale('zh')],
      path: 'assets/i18n',
      fallbackLocale: const Locale('ko'),
      startLocale: Locale(langCode),
      child: const ProviderScope(child: ItfCoachApp()),
    ),
  );
}
