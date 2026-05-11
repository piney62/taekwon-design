import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/providers/app_settings.dart';
import '../../core/theme/tul_colors.dart';
import '../../core/theme/tul_radius.dart';

@immutable
class TulTab {
  const TulTab({
    required this.key,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String key;
  final String label;
  final IconData icon;
  final TabAccent color;
}

enum TabAccent { primary, secondary, accent }

/// Translucent blurred 5-tab bottom navigation.
class TulBottomNav extends StatelessWidget {
  const TulBottomNav({
    super.key,
    required this.role,
    required this.currentKey,
    required this.onSelect,
  });

  final UserRole role;
  final String currentKey;
  final ValueChanged<String> onSelect;

  static List<TulTab> tabsFor(UserRole role) => role == UserRole.instructor
      ? const [
          TulTab(key: 'home', label: 'Home', icon: LucideIcons.home, color: TabAccent.primary),
          TulTab(key: 'analyze', label: 'Analyze', icon: LucideIcons.activity, color: TabAccent.secondary),
          TulTab(key: 'dojang', label: 'Dojang', icon: LucideIcons.users, color: TabAccent.accent),
          TulTab(key: 'patterns', label: 'Patterns', icon: LucideIcons.book, color: TabAccent.primary),
          TulTab(key: 'me', label: 'Me', icon: LucideIcons.user, color: TabAccent.secondary),
        ]
      : const [
          TulTab(key: 'home', label: 'Home', icon: LucideIcons.home, color: TabAccent.primary),
          TulTab(key: 'analyze', label: 'Analyze', icon: LucideIcons.activity, color: TabAccent.secondary),
          TulTab(key: 'journal', label: 'Journal', icon: LucideIcons.trendingUp, color: TabAccent.accent),
          TulTab(key: 'patterns', label: 'Patterns', icon: LucideIcons.book, color: TabAccent.primary),
          TulTab(key: 'me', label: 'Me', icon: LucideIcons.user, color: TabAccent.secondary),
        ];

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    final tabs = tabsFor(role);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: palette.tabbarBg,
            border: Border(top: BorderSide(color: palette.border)),
          ),
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
          child: Row(
            children: tabs.map((t) {
              final active = t.key == currentKey;
              final accent = switch (t.color) {
                TabAccent.primary => palette.primary,
                TabAccent.secondary => palette.secondary,
                TabAccent.accent => palette.accent,
              };
              return Expanded(
                child: _TabButton(
                  tab: t,
                  active: active,
                  accent: accent,
                  onTap: () => onSelect(t.key),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.tab,
    required this.active,
    required this.accent,
    required this.onTap,
  });

  final TulTab tab;
  final bool active;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    final fg = active ? accent : palette.text3;
    return Material(
      color: active ? accent.withValues(alpha: 0.10) : Colors.transparent,
      borderRadius: TulRadius.brLg,
      child: InkWell(
        onTap: onTap,
        borderRadius: TulRadius.brLg,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(tab.icon, size: 20, color: fg),
              const SizedBox(height: 4),
              Text(
                tab.label,
                style: TextStyle(
                  color: fg,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
