import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/app_settings.dart';
import '../../shared/widgets/tul_bottom_nav.dart';

/// Hosts the 5-tab navigation. Body is the active branch from go_router shell.
class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.navShell});

  final StatefulNavigationShell navShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(appSettingsProvider.select((s) => s.role));
    final tabs = TulBottomNav.tabsFor(role);
    final currentKey = tabs[navShell.currentIndex].key;

    return Scaffold(
      extendBody: true,
      body: navShell,
      bottomNavigationBar: TulBottomNav(
        role: role,
        currentKey: currentKey,
        onSelect: (key) {
          final i = tabs.indexWhere((t) => t.key == key);
          if (i >= 0) {
            navShell.goBranch(i, initialLocation: i == navShell.currentIndex);
          }
        },
      ),
    );
  }
}
