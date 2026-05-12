import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/tul_palette.dart';
import '../../core/theme/tul_radius.dart';
import '../../features/auth/application/providers.dart';

/// Root scaffold for the authenticated tabs. Hosts the [StatefulNavigationShell]
/// content and renders the brand bottom tab bar underneath.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isInstructor = ref.watch(
      authControllerProvider.select((s) => s.isInstructor),
    );

    final items = isInstructor ? _instructorTabs : _studentTabs;

    return Scaffold(
      // Keep the bar opaque-on-top so screens can scroll their content right
      // up to the tab bar without having to reserve bottom padding themselves.
      // extendBody: true sounded nice for the frosted effect, but it forced
      // every screen to add a tab-bar-height bottom inset to avoid clipping
      // the last item — a foot-gun for the dozen+ existing screens.
      extendBody: false,
      body: navigationShell,
      bottomNavigationBar: _TulTabBar(
        items: items,
        currentIndex: navigationShell.currentIndex,
        onTap: (i) => navigationShell.goBranch(
          i,
          initialLocation: i == navigationShell.currentIndex,
        ),
      ),
    );
  }
}

// ── Tab definitions ──────────────────────────────────────────────────────────

const _studentTabs = <_TabItem>[
  _TabItem(
    icon: Icons.home_rounded,
    outlinedIcon: Icons.home_outlined,
    labelKey: 'nav.home',
    accent: _Accent.primary,
  ),
  _TabItem(
    icon: Icons.center_focus_strong,
    outlinedIcon: Icons.center_focus_weak_outlined,
    labelKey: 'nav.analyze',
    accent: _Accent.secondary,
  ),
  _TabItem(
    icon: Icons.book_rounded,
    outlinedIcon: Icons.book_outlined,
    labelKey: 'nav.journal',
    accent: _Accent.accent,
  ),
  _TabItem(
    icon: Icons.grid_view_rounded,
    outlinedIcon: Icons.grid_view_outlined,
    labelKey: 'nav.patterns',
    accent: _Accent.primary,
  ),
  _TabItem(
    icon: Icons.person_rounded,
    outlinedIcon: Icons.person_outline_rounded,
    labelKey: 'nav.me',
    accent: _Accent.secondary,
  ),
];

const _instructorTabs = <_TabItem>[
  _TabItem(
    icon: Icons.home_rounded,
    outlinedIcon: Icons.home_outlined,
    labelKey: 'nav.home',
    accent: _Accent.primary,
  ),
  _TabItem(
    icon: Icons.center_focus_strong,
    outlinedIcon: Icons.center_focus_weak_outlined,
    labelKey: 'nav.analyze',
    accent: _Accent.secondary,
  ),
  _TabItem(
    icon: Icons.groups_rounded,
    outlinedIcon: Icons.groups_outlined,
    labelKey: 'nav.dojo',
    accent: _Accent.accent,
  ),
  _TabItem(
    icon: Icons.grid_view_rounded,
    outlinedIcon: Icons.grid_view_outlined,
    labelKey: 'nav.patterns',
    accent: _Accent.primary,
  ),
  _TabItem(
    icon: Icons.person_rounded,
    outlinedIcon: Icons.person_outline_rounded,
    labelKey: 'nav.me',
    accent: _Accent.secondary,
  ),
];

enum _Accent { primary, secondary, accent }

class _TabItem {
  const _TabItem({
    required this.icon,
    required this.outlinedIcon,
    required this.labelKey,
    required this.accent,
  });

  final IconData icon;
  final IconData outlinedIcon;
  final String labelKey;
  final _Accent accent;

  Color color(TulPalette p) => switch (accent) {
        _Accent.primary => p.primary,
        _Accent.secondary => p.secondary,
        _Accent.accent => p.accent,
      };
}

// ── The bar ──────────────────────────────────────────────────────────────────

class _TulTabBar extends StatelessWidget {
  const _TulTabBar({
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<_TabItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: palette.tabbarBg,
            border: Border(top: BorderSide(color: palette.border)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
              child: Row(
                children: List.generate(items.length, (i) {
                  return Expanded(
                    child: _TabButton(
                      item: items[i],
                      selected: i == currentIndex,
                      onTap: () => onTap(i),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _TabItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    final color = item.color(palette);
    final fg = selected ? color : AppColors.textDisabled;

    return Material(
      color: selected ? color.withValues(alpha: 0.12) : Colors.transparent,
      borderRadius: TulRadius.brLg,
      child: InkWell(
        onTap: onTap,
        borderRadius: TulRadius.brLg,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected ? item.icon : item.outlinedIcon,
                size: 22,
                color: fg,
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: fg,
                ),
                child: Text(item.labelKey.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
