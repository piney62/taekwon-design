import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/application/providers.dart';

class ItfCoachApp extends ConsumerWidget {
  const ItfCoachApp({super.key});

  static const _mobileMaxWidth = 430.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref
            .watch(settingsControllerProvider)
            .valueOrNull
            ?.themeMode ??
        ThemeMode.dark;

    return MaterialApp.router(
      title: 'ITF Coach',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      routerConfig: router,
      builder: kIsWeb ? _webBuilder : null,
    );
  }

  static Widget _webBuilder(BuildContext context, Widget? child) {
    final mq = MediaQuery.of(context);
    final screenW = mq.size.width;
    final appW = screenW.clamp(0.0, _mobileMaxWidth);

    return Container(
      color: const Color(0xFF000000),
      alignment: Alignment.topCenter,
      child: MediaQuery(
        data: mq.copyWith(size: Size(appW, mq.size.height)),
        child: SizedBox(
          width: appW,
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}
