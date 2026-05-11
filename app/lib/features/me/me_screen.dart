import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/providers/app_settings.dart';
import '../../core/theme/tul_colors.dart';
import '../../core/theme/tul_gradients.dart';
import '../../core/theme/tul_radius.dart';
import '../../core/theme/tul_text_styles.dart';
import '../../shared/layout/screen_scaffold.dart';
import '../../shared/widgets/badge.dart';
import '../../shared/widgets/gradient_text.dart';
import '../../shared/widgets/list_row.dart';
import '../../shared/widgets/tul_buttons.dart';
import '../../shared/widgets/tul_card.dart';
import 'change_password_modal.dart';
import 'edit_profile_modal.dart';

class MeScreen extends ConsumerWidget {
  const MeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.tul;
    final settings = ref.watch(appSettingsProvider);
    final settingsCtl = ref.read(appSettingsProvider.notifier);
    final isInstructor = settings.role == UserRole.instructor;

    return ScreenScaffold(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      child: TulStack(
        children: [
          // Title
          Text('Profile', style: TulTextStyles.title(color: palette.text)),
          DefaultTextStyle.merge(
            style: TulTextStyles.subtitle(color: palette.text2),
            child: Wrap(
              children: [
                const Text('Manage your '),
                GradientText(
                  'ITF Taekwon-Do',
                  gradient: TulGradients.koreanText,
                  style: TulTextStyles.subtitle(),
                ),
                const Text(' journey'),
              ],
            ),
          ),

          // Profile card
          TulCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    _Avatar(isInstructor: isInstructor),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isInstructor ? 'Master Kim' : 'Nick Anderson',
                            style: TulTextStyles.cardHeader(color: palette.text)
                                .copyWith(fontSize: 18),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              TulBadge(
                                label: isInstructor ? 'Instructor' : 'ITF Student',
                                color: TulBadgeColor.red,
                              ),
                              TulBadge(
                                label: isInstructor
                                    ? '3rd Dan (삼단)'
                                    : 'Yellow Belt (노란띠)',
                                color: TulBadgeColor.blue,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TulSecondaryButton(
                  label: 'Edit Profile',
                  onPressed: () => EditProfileModal.show(context),
                ),
              ],
            ),
          ),

          // Account
          TulCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
                  child: Text('Account',
                      style: TulTextStyles.cardHeader(color: palette.text)),
                ),
                ListRow(
                  icon: LucideIcons.shield,
                  iconColor: ListRowColor.primary,
                  title: 'Change Password',
                  sub: 'Last changed Jan 2026',
                  onTap: () => ChangePasswordModal.show(context),
                ),
              ],
            ),
          ),

          // Preferences
          TulCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
                  child: Text('Preferences',
                      style: TulTextStyles.cardHeader(color: palette.text)),
                ),
                ListRow(
                  icon: LucideIcons.moon,
                  iconColor: ListRowColor.secondary,
                  title: 'Theme',
                  sub: 'Appearance',
                  trailing: _trailingValue(
                    context,
                    _themeLabel(settings.themeMode),
                  ),
                  onTap: () => _showThemePicker(context, ref),
                ),
                ListRow(
                  icon: LucideIcons.globe,
                  iconColor: ListRowColor.accent,
                  title: 'Language',
                  sub: 'App language',
                  trailing: _trailingValue(
                    context,
                    _localeLabel(settings.locale),
                  ),
                  onTap: () => _showLocalePicker(context, ref),
                ),
                ListRow(
                  icon: LucideIcons.users,
                  iconColor: ListRowColor.primary,
                  title: 'View as',
                  sub: 'Switch role for demo',
                  trailing: _trailingValue(
                    context,
                    isInstructor ? 'Instructor' : 'Student',
                  ),
                  onTap: () => settingsCtl.setRole(
                    isInstructor ? UserRole.student : UserRole.instructor,
                  ),
                ),
              ],
            ),
          ),

          // Dojang card
          TulCard(
            background: Color.alphaBlend(
              palette.primary.withValues(alpha: 0.06),
              palette.card,
            ),
            borderColor: palette.primary.withValues(alpha: 0.2),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: TulGradients.brand,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(LucideIcons.school, size: 22, color: Colors.white),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Master Kim's Dojang",
                          style: TulTextStyles.bodyStrong(color: palette.text)),
                      const SizedBox(height: 3),
                      Text('ITF Seoul Chapter · Joined Oct 2023',
                          style: TulTextStyles.tiny(color: palette.text3)),
                      const SizedBox(height: 6),
                      const TulBadge(label: 'Active Member', color: TulBadgeColor.red),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // About
          TulCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
                  child: Text('About',
                      style: TulTextStyles.cardHeader(color: palette.text)),
                ),
                const ListRow(
                  icon: LucideIcons.info,
                  iconColor: ListRowColor.primary,
                  title: 'Terms & Privacy',
                  sub: 'Read the fine print',
                ),
                const ListRow(
                  icon: LucideIcons.info,
                  iconColor: ListRowColor.secondary,
                  title: 'Support',
                  sub: 'Get help · contact us',
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 10, 4, 2),
                  child: Text(
                    'TulMaster v1.0.0 · ITF Edition',
                    style: TulTextStyles.mono(size: 11, color: palette.text3),
                  ),
                ),
              ],
            ),
          ),

          // Logout
          TulDestructiveButton(
            label: 'Logout',
            onPressed: () => _showLogoutDialog(context, settingsCtl),
          ),
        ],
      ),
    );
  }

  Widget _trailingValue(BuildContext context, String value) {
    final palette = context.tul;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: TulTextStyles.subtitle(color: palette.text3)),
        const SizedBox(width: 4),
        Icon(LucideIcons.chevronRight, size: 16, color: palette.text3),
      ],
    );
  }

  String _themeLabel(ThemeMode m) => switch (m) {
        ThemeMode.dark => 'Dark',
        ThemeMode.light => 'Light',
        ThemeMode.system => 'System',
      };

  String _localeLabel(Locale l) => switch (l.languageCode) {
        'ko' => '한국어',
        'es' => 'Español',
        'ja' => '日本語',
        'zh' => '中文',
        _ => 'English',
      };

  void _showThemePicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _OptionSheet<ThemeMode>(
        title: 'Theme',
        current: ref.read(appSettingsProvider).themeMode,
        options: const [
          (ThemeMode.dark, 'Dark'),
          (ThemeMode.light, 'Light'),
          (ThemeMode.system, 'System'),
        ],
        onChoose: (v) {
          ref.read(appSettingsProvider.notifier).setThemeMode(v);
          Navigator.of(ctx).pop();
        },
      ),
    );
  }

  void _showLocalePicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _OptionSheet<String>(
        title: 'Language',
        current: ref.read(appSettingsProvider).locale.languageCode,
        options: const [
          ('en', 'English'),
          ('ko', '한국어'),
          ('es', 'Español'),
          ('ja', '日本語'),
          ('zh', '中文'),
        ],
        onChoose: (v) {
          ref.read(appSettingsProvider.notifier).setLocale(Locale(v));
          Navigator.of(ctx).pop();
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AppSettingsController ctl) {
    final palette = context.tul;
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => Dialog(
        backgroundColor: palette.card,
        shape: const RoundedRectangleBorder(borderRadius: TulRadius.brXl3),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Log out?', style: TulTextStyles.h2(color: palette.text)),
              const SizedBox(height: 8),
              Text(
                "You'll need to sign in again to continue training.",
                style: TulTextStyles.subtitle(color: palette.text2),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: TulSecondaryButton(
                      label: 'Cancel',
                      onPressed: () => Navigator.of(dialogCtx).pop(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TulDestructiveButton(
                      label: 'Log out',
                      onPressed: () {
                        Navigator.of(dialogCtx).pop();
                        ctl.logout();
                        context.go('/welcome');
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.isInstructor});

  final bool isInstructor;

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 72,
          height: 72,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: TulGradients.brand,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: palette.primary.withValues(alpha: 0.3),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: const Icon(LucideIcons.user, size: 32, color: Colors.white),
        ),
        Positioned(
          bottom: -4,
          right: -4,
          child: Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: isInstructor
                  ? const LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : const LinearGradient(
                      colors: [Color(0xFFFACC15), Color(0xFFF59E0B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: palette.stage, width: 3),
            ),
            child: const Icon(LucideIcons.award, size: 12, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _OptionSheet<T> extends StatelessWidget {
  const _OptionSheet({
    required this.title,
    required this.current,
    required this.options,
    required this.onChoose,
  });

  final String title;
  final T current;
  final List<(T, String)> options;
  final ValueChanged<T> onChoose;

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    return Container(
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: const BorderRadius.vertical(top: TulRadius.rXl4),
        border: Border.all(color: palette.border),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: palette.borderStrong,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(title, style: TulTextStyles.h2(color: palette.text)),
              const SizedBox(height: 14),
              for (final opt in options) ...[
                _OptionRow(
                  label: opt.$2,
                  selected: opt.$1 == current,
                  onTap: () => onChoose(opt.$1),
                ),
                if (opt != options.last) const SizedBox(height: 4),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    return Material(
      color: selected ? palette.primary.withValues(alpha: 0.08) : Colors.transparent,
      borderRadius: TulRadius.brMd,
      child: InkWell(
        onTap: onTap,
        borderRadius: TulRadius.brMd,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TulTextStyles.body(
                    color: selected ? palette.primary : palette.text,
                  ).copyWith(fontWeight: selected ? FontWeight.w600 : FontWeight.w400),
                ),
              ),
              if (selected)
                Icon(LucideIcons.check, size: 18, color: palette.primary),
            ],
          ),
        ),
      ),
    );
  }
}
