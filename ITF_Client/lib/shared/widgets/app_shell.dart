import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../features/auth/application/providers.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isInstructor = ref.watch(
      authControllerProvider.select((s) => s.isInstructor),
    );

    final items = isInstructor
        ? <_TabItem>[
            _TabItem(icon: Icons.home_rounded, outlinedIcon: Icons.home_outlined, labelKey: 'nav.home', color: AppColors.primary),
            _TabItem(icon: Icons.center_focus_strong, outlinedIcon: Icons.center_focus_weak_outlined, labelKey: 'nav.analyze', color: AppColors.secondary),
            _TabItem(icon: Icons.groups_rounded, outlinedIcon: Icons.groups_outlined, labelKey: 'nav.dojo', color: AppColors.accent),
            _TabItem(icon: Icons.grid_view_rounded, outlinedIcon: Icons.grid_view_outlined, labelKey: 'nav.patterns', color: AppColors.primary),
            _TabItem(icon: Icons.person_rounded, outlinedIcon: Icons.person_outline_rounded, labelKey: 'nav.me', color: AppColors.secondary),
          ]
        : <_TabItem>[
            _TabItem(icon: Icons.home_rounded, outlinedIcon: Icons.home_outlined, labelKey: 'nav.home', color: AppColors.primary),
            _TabItem(icon: Icons.center_focus_strong, outlinedIcon: Icons.center_focus_weak_outlined, labelKey: 'nav.analyze', color: AppColors.secondary),
            _TabItem(icon: Icons.book_rounded, outlinedIcon: Icons.book_outlined, labelKey: 'nav.journal', color: AppColors.accent),
            _TabItem(icon: Icons.grid_view_rounded, outlinedIcon: Icons.grid_view_outlined, labelKey: 'nav.patterns', color: AppColors.primary),
            _TabItem(icon: Icons.person_rounded, outlinedIcon: Icons.person_outline_rounded, labelKey: 'nav.me', color: AppColors.secondary),
          ];

    return Scaffold(
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

// ── Data ───────────────────────────────────────────────────────────────────────

class _TabItem {
  const _TabItem({
    required this.icon,
    required this.outlinedIcon,
    required this.labelKey,
    required this.color,
  });

  final IconData icon;
  final IconData outlinedIcon;
  final String labelKey;
  final Color color;
}

// ── Custom tab bar ─────────────────────────────────────────────────────────────

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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.stage,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 7),
            decoration: BoxDecoration(
              color: selected
                  ? item.color.withValues(alpha: 0.14)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  selected ? item.icon : item.outlinedIcon,
                  size: 22,
                  color: selected ? item.color : AppColors.textDisabled,
                ),
                const SizedBox(height: 3),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: selected ? item.color : AppColors.textDisabled,
                  ),
                  child: Text(item.labelKey.tr()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
