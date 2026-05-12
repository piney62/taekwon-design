import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/network/backend_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/grad_header_text.dart';
import '../../../auth/application/providers.dart';
import '../../application/providers.dart';
import '../../domain/entities/belt_level.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsControllerProvider);
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (settings) => CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Header ──────────────────────────────────────
                      GradHeaderText('settings.title'.tr()),
                      Text(
                        'settings.user'.tr(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 24),

                      // ── Profile card ─────────────────────────────────
                      _ProfileCard(authState: authState, settings: settings),
                      const SizedBox(height: 16),

                      // ── Account section ──────────────────────────────
                      _SectionLabel('Account'),
                      const SizedBox(height: 8),
                      _SectionCard(children: [
                        _SettingsRow(
                          icon: Icons.shield_outlined,
                          iconColor: AppColors.primary,
                          title: 'settings.changePassword'.tr(),
                          subtitle: 'settings.passwordSubtitle'.tr(),
                          onTap: () => showDialog<void>(
                            context: context,
                            builder: (_) => const _ChangePasswordDialog(),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 16),

                      // ── Preferences section ───────────────────────────
                      _SectionLabel('settings.preferences'.tr()),
                      const SizedBox(height: 8),
                      _SectionCard(children: [
                        // Theme
                        _ThemeRow(
                          current: settings.themeMode,
                          onChanged: (v) => ref
                              .read(settingsControllerProvider.notifier)
                              .setThemeMode(v),
                        ),
                        _Divider(),
                        // Language
                        _LanguageRow(
                          current: settings.languageCode,
                          onChanged: (v) {
                            context.setLocale(Locale(v));
                            ref
                                .read(settingsControllerProvider.notifier)
                                .setLanguageCode(v);
                          },
                        ),
                        // Belt Level (student only)
                        if (!authState.isInstructor) ...[
                          _Divider(),
                          _BeltRow(
                            current: settings.beltLevel,
                            onChanged: (v) => ref
                                .read(settingsControllerProvider.notifier)
                                .setBeltLevel(v),
                          ),
                        ],
                      ]),
                      const SizedBox(height: 16),

                      // ── Dojo section ──────────────────────────────────
                      _SectionLabel('nav.dojo'.tr()),
                      const SizedBox(height: 8),
                      if (authState.role == 'student')
                        _DojoStudentSection(authState: authState)
                      else if (authState.role == 'instructor')
                        _DojoInstructorSection(authState: authState),
                      const SizedBox(height: 16),

                      // ── About section ─────────────────────────────────
                      _SectionLabel('About'),
                      const SizedBox(height: 8),
                      _SectionCard(children: [
                        _SettingsRow(
                          icon: Icons.gavel_rounded,
                          iconColor: AppColors.primary,
                          title: 'settings.termsPrivacy'.tr(),
                          subtitle: 'settings.termsPrivacySubtitle'.tr(),
                          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Coming soon')),
                          ),
                        ),
                        _Divider(),
                        _SettingsRow(
                          icon: Icons.support_agent_rounded,
                          iconColor: AppColors.info,
                          title: 'settings.support'.tr(),
                          subtitle: 'settings.supportSubtitle'.tr(),
                          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Coming soon')),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'TulMaster v1.0.0 · ITF Edition',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textDisabled,
                              ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Logout ────────────────────────────────────────
                      Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: AppColors.gradMain,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () async {
                              await ref
                                  .read(authControllerProvider.notifier)
                                  .logout();
                            },
                            child: Center(
                              child: Text(
                                'settings.logout'.tr(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Profile card ──────────────────────────────────────────────────────────────

class _ProfileCard extends ConsumerStatefulWidget {
  const _ProfileCard({required this.authState, required this.settings});

  final dynamic authState;
  final dynamic settings;

  @override
  ConsumerState<_ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends ConsumerState<_ProfileCard> {
  bool _editing = false;
  bool _uploadingPhoto = false;
  late final TextEditingController _nameCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.authState.displayName);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() => _uploadingPhoto = true);
    try {
      await ref.read(authControllerProvider.notifier).uploadAvatar(bytes);
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final isInstructor = auth.isInstructor;
    final beltLevel = widget.settings.beltLevel as BeltLevel;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              GestureDetector(
                onTap: _uploadingPhoto ? null : _pickAndUploadPhoto,
                child: Stack(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: AppColors.gradSoft,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: ClipOval(
                        child: auth.avatarUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl:
                                    'http://localhost:8000${auth.avatarUrl}',
                                fit: BoxFit.cover,
                                placeholder: (_, __) => const SizedBox.shrink(),
                                errorWidget: (_, __, ___) => Icon(
                                  isInstructor
                                      ? Icons.shield_outlined
                                      : Icons.person_outline_rounded,
                                  color: AppColors.primary,
                                  size: 30,
                                ),
                              )
                            : Icon(
                                isInstructor
                                    ? Icons.shield_outlined
                                    : Icons.person_outline_rounded,
                                color: AppColors.primary,
                                size: 30,
                              ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.surface, width: 1.5),
                        ),
                        child: _uploadingPhoto
                            ? const Padding(
                                padding: EdgeInsets.all(3),
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.camera_alt_rounded,
                                size: 11, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              // Name + badges
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_editing)
                      TextField(
                        controller: _nameCtrl,
                        autofocus: true,
                        style: Theme.of(context).textTheme.titleMedium,
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                        ),
                      )
                    else
                      Text(
                        auth.displayName.isEmpty ? '—' : auth.displayName,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      children: [
                        _Badge(
                          label: isInstructor
                              ? 'auth.roleInstructor'.tr()
                              : 'auth.roleStudent'.tr(),
                          color: AppColors.primary,
                        ),
                        if (!isInstructor)
                          _Badge(
                            label: beltLevel.i18nKey.tr(),
                            color: AppColors.secondary,
                          ),
                        if (isInstructor && auth.danRank.isNotEmpty)
                          _Badge(
                            label: auth.danRank,
                            color: AppColors.accent,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (_editing)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      _nameCtrl.text = auth.displayName;
                      setState(() => _editing = false);
                    },
                    child: Text('journal.cancel'.tr()),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _nameCtrl.text.trim().isEmpty
                        ? null
                        : () async {
                            await ref
                                .read(authControllerProvider.notifier)
                                .updateDisplayName(_nameCtrl.text.trim());
                            setState(() => _editing = false);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('settings.nameSaved'.tr())),
                              );
                            }
                          },
                    child: Text('settings.save'.tr()),
                  ),
                ),
              ],
            )
          else
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => setState(() => _editing = true),
                child: Text('settings.editProfile'.tr(),
                    style: const TextStyle(fontWeight: FontWeight.w500)),
              ),
            ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

// ── Section helpers ───────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textDisabled,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: children),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(
        height: 1, indent: 52, endIndent: 16, color: AppColors.border);
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 17),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          )),
                  if (subtitle != null)
                    Text(subtitle!,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
            trailing ??
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textDisabled, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Theme row ─────────────────────────────────────────────────────────────────

class _ThemeRow extends StatelessWidget {
  const _ThemeRow({required this.current, required this.onChanged});

  final ThemeMode current;
  final void Function(ThemeMode) onChanged;

  String _label(ThemeMode m, BuildContext context) => switch (m) {
        ThemeMode.dark => 'settings.themeDark'.tr(),
        ThemeMode.light => 'settings.themeLight'.tr(),
        ThemeMode.system => 'settings.themeSystem'.tr(),
      };

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => showModalBottomSheet<void>(
        context: context,
        builder: (ctx) => _ThemePicker(current: current, onChanged: onChanged),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.dark_mode_outlined,
                  color: AppColors.secondary, size: 17),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('settings.theme'.tr(),
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w500)),
                  Text('settings.themeSubtitle'.tr(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          )),
                ],
              ),
            ),
            Text(_label(current, context),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    )),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textDisabled, size: 20),
          ],
        ),
      ),
    );
  }
}

class _ThemePicker extends StatelessWidget {
  const _ThemePicker({required this.current, required this.onChanged});

  final ThemeMode current;
  final void Function(ThemeMode) onChanged;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text('settings.theme'.tr(),
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            for (final mode in ThemeMode.values)
              RadioListTile<ThemeMode>(
                value: mode,
                groupValue: current,
                title: Text(_label(mode)),
                activeColor: AppColors.primary,
                onChanged: (v) {
                  if (v != null) {
                    onChanged(v);
                    Navigator.pop(context);
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  String _label(ThemeMode m) => switch (m) {
        ThemeMode.dark => 'settings.themeDark'.tr(),
        ThemeMode.light => 'settings.themeLight'.tr(),
        ThemeMode.system => 'settings.themeSystem'.tr(),
      };
}

// ── Language row ──────────────────────────────────────────────────────────────

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({required this.current, required this.onChanged});

  final String current;
  final void Function(String) onChanged;

  static const _langs = [
    ('ko', '한국어'),
    ('en', 'English'),
    ('es', 'Español'),
    ('ja', '日本語'),
    ('zh', '中文'),
  ];

  String get _currentLabel =>
      _langs.firstWhere((l) => l.$1 == current, orElse: () => ('', current)).$2;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => showModalBottomSheet<void>(
        context: context,
        builder: (ctx) =>
            _LanguagePicker(current: current, onChanged: onChanged),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.language_rounded,
                  color: AppColors.accent, size: 17),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('settings.language'.tr(),
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w500)),
                  Text('settings.languageSubtitle'.tr(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          )),
                ],
              ),
            ),
            Text(_currentLabel,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    )),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textDisabled, size: 20),
          ],
        ),
      ),
    );
  }
}

class _LanguagePicker extends StatelessWidget {
  const _LanguagePicker({required this.current, required this.onChanged});

  final String current;
  final void Function(String) onChanged;

  static const _langs = [
    ('ko', '한국어'),
    ('en', 'English'),
    ('es', 'Español'),
    ('ja', '日本語'),
    ('zh', '中文'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text('settings.language'.tr(),
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            for (final lang in _langs)
              RadioListTile<String>(
                value: lang.$1,
                groupValue: current,
                title: Text(lang.$2),
                activeColor: AppColors.primary,
                onChanged: (v) {
                  if (v != null) {
                    onChanged(v);
                    Navigator.pop(context);
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}

// ── Belt row ──────────────────────────────────────────────────────────────────

class _BeltRow extends StatelessWidget {
  const _BeltRow({required this.current, required this.onChanged});

  final BeltLevel current;
  final void Function(BeltLevel) onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => showModalBottomSheet<void>(
        context: context,
        builder: (ctx) => _BeltPicker(current: current, onChanged: onChanged),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.military_tech_outlined,
                  color: AppColors.warning, size: 17),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text('settings.beltLevel'.tr(),
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w500)),
            ),
            Text(current.i18nKey.tr(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    )),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textDisabled, size: 20),
          ],
        ),
      ),
    );
  }
}

class _BeltPicker extends StatelessWidget {
  const _BeltPicker({required this.current, required this.onChanged});

  final BeltLevel current;
  final void Function(BeltLevel) onChanged;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text('settings.beltLevel'.tr(),
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            for (final belt in BeltLevel.values)
              RadioListTile<BeltLevel>(
                value: belt,
                groupValue: current,
                title: Text(belt.i18nKey.tr()),
                activeColor: AppColors.primary,
                onChanged: (v) {
                  if (v != null) {
                    onChanged(v);
                    Navigator.pop(context);
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}

// ── Change password dialog ────────────────────────────────────────────────────

class _ChangePasswordDialog extends ConsumerStatefulWidget {
  const _ChangePasswordDialog();

  @override
  ConsumerState<_ChangePasswordDialog> createState() =>
      _ChangePasswordDialogState();
}

class _ChangePasswordDialogState
    extends ConsumerState<_ChangePasswordDialog> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  String? _error;
  bool _isSaving = false;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_newCtrl.text != _confirmCtrl.text) {
      setState(() => _error = 'auth.passwordMismatch'.tr());
      return;
    }
    if (_newCtrl.text.length < 4) {
      setState(() => _error = 'auth.passwordTooShort'.tr());
      return;
    }
    setState(() {
      _isSaving = true;
      _error = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).changePassword(
            currentPassword: _currentCtrl.text,
            newPassword: _newCtrl.text,
          );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('settings.passwordChanged'.tr())),
        );
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
        _error = 'settings.wrongPassword'.tr();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('settings.changePassword'.tr()),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _currentCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'settings.currentPassword'.tr(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _newCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'settings.newPassword'.tr(),
                hintText: 'settings.newPasswordHint'.tr(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirmCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'settings.confirmNewPassword'.tr(),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!,
                  style: const TextStyle(color: AppColors.primary)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('journal.cancel'.tr()),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _save,
          child: Text('settings.save'.tr()),
        ),
      ],
    );
  }
}

// ── Dojo student section ──────────────────────────────────────────────────────

class _DojoStudentSection extends ConsumerStatefulWidget {
  const _DojoStudentSection({required this.authState});

  final dynamic authState;

  @override
  ConsumerState<_DojoStudentSection> createState() =>
      _DojoStudentSectionState();
}

class _DojoStudentSectionState extends ConsumerState<_DojoStudentSection> {
  final _codeCtrl = TextEditingController();
  bool _isSaving = false;
  String? _error;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    final code = _codeCtrl.text.trim().toUpperCase();
    if (code.length != 5) {
      setState(() => _error = 'settings.enterFiveChar'.tr());
      return;
    }
    setState(() {
      _isSaving = true;
      _error = null;
    });
    try {
      await ref.read(backendClientProvider).useInviteCode(code);
      await ref.read(authControllerProvider.notifier).refresh();
      _codeCtrl.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('settings.connectedSuccess'.tr())),
        );
      }
    } catch (e) {
      setState(() =>
          _error = e.toString().replaceFirst('Exception: bad_request:', ''));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _disconnect() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('settings.leaveDojoTitle'.tr()),
        content: Text('settings.leaveDojoBody'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('journal.cancel'.tr()),
          ),
          FilledButton(
            style:
                FilledButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('settings.leave'.tr()),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _isSaving = true);
    try {
      await ref.read(backendClientProvider).leaveDojo();
      await ref.read(authControllerProvider.notifier).refresh();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    if (authState.dojoConnected) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppColors.gradMain,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.home_rounded,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authState.dojoName.isNotEmpty
                            ? authState.dojoName
                            : 'nav.dojo'.tr(),
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Colors.white),
                      ),
                      if (authState.instructorName.isNotEmpty)
                        Text(
                          authState.instructorName,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.75)),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Active Member',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
              ),
              onPressed: _isSaving ? null : _disconnect,
              icon: const Icon(Icons.link_off_rounded, size: 16),
              label: Text('settings.leaveDojoTitle'.tr()),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'settings.connectDojoPrompt'.tr(),
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _codeCtrl,
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 5,
                  decoration: InputDecoration(
                    labelText: 'settings.inviteCodeInput'.tr(),
                    hintText: 'HANB1',
                    counterText: '',
                    prefixIcon:
                        const Icon(Icons.qr_code_outlined, size: 18),
                  ),
                  onChanged: (_) => setState(() => _error = null),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _isSaving ? null : _connect,
                child: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Text('settings.connect'.tr()),
              ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 6),
            Text(_error!,
                style: const TextStyle(
                    color: AppColors.primary, fontSize: 12)),
          ],
        ],
      ),
    );
  }
}

// ── Dojo instructor section ───────────────────────────────────────────────────

class _DojoInstructorSection extends StatelessWidget {
  const _DojoInstructorSection({required this.authState});

  final dynamic authState;

  @override
  Widget build(BuildContext context) {
    String planLabel;
    switch (authState.dojoPlan) {
      case 'paid_a':
        planLabel = 'dojo.planPaidA'.tr();
      default:
        planLabel = 'dojo.planFree'.tr();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppColors.gradSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.home_outlined,
                color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  authState.dojoName as String? ?? '',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  planLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── RadioGroup helper ────────────────────────────────────────────────────────

class RadioGroup<T> extends InheritedWidget {
  const RadioGroup({
    super.key,
    required this.groupValue,
    required this.onChanged,
    required super.child,
  });

  final T groupValue;
  final ValueChanged<T?> onChanged;

  static RadioGroup<T> of<T>(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<RadioGroup<T>>()!;

  @override
  bool updateShouldNotify(RadioGroup<T> old) =>
      groupValue != old.groupValue;
}
