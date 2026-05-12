import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/network/backend_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/tul_gradients.dart';
import '../../../../core/theme/tul_palette.dart';
import '../../../../core/theme/tul_radius.dart';
import '../../../../core/theme/tul_text_styles.dart';
import '../../../../shared/widgets/app_shell.dart' show kAppShellContentBottomInset;
import '../../../../shared/widgets/badge.dart';
import '../../../../shared/widgets/grad_header_text.dart';
import '../../../../shared/widgets/list_row.dart';
import '../../../../shared/widgets/tul_buttons.dart';
import '../../../../shared/widgets/tul_card.dart';
import '../../../auth/application/providers.dart';
import '../../application/providers.dart';
import '../../domain/entities/belt_level.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsControllerProvider);
    final authState = ref.watch(authControllerProvider);
    final palette = context.tul;

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
                        style: TulTextStyles.subtitle(color: palette.text2),
                      ),
                      const SizedBox(height: 24),

                      // ── Profile card ─────────────────────────────────
                      _ProfileCard(authState: authState, settings: settings),
                      const SizedBox(height: 16),

                      // ── Account ──────────────────────────────────────
                      TulCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
                              child: Text('Account',
                                  style: TulTextStyles.cardHeader(color: palette.text)),
                            ),
                            ListRow(
                              icon: LucideIcons.shield,
                              iconColor: ListRowColor.primary,
                              title: 'settings.changePassword'.tr(),
                              sub: 'settings.passwordSubtitle'.tr(),
                              onTap: () => showDialog<void>(
                                context: context,
                                builder: (_) => const _ChangePasswordDialog(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Preferences ───────────────────────────────────
                      TulCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
                              child: Text('settings.preferences'.tr(),
                                  style: TulTextStyles.cardHeader(color: palette.text)),
                            ),
                            ListRow(
                              icon: LucideIcons.moon,
                              iconColor: ListRowColor.secondary,
                              title: 'settings.theme'.tr(),
                              sub: 'settings.themeSubtitle'.tr(),
                              trailing: _valueTrailing(
                                  context, _themeLabel(settings.themeMode)),
                              onTap: () => showModalBottomSheet<void>(
                                context: context,
                                backgroundColor: Colors.transparent,
                                builder: (_) => _ThemePicker(
                                  current: settings.themeMode,
                                  onChanged: (v) => ref
                                      .read(settingsControllerProvider.notifier)
                                      .setThemeMode(v),
                                ),
                              ),
                            ),
                            ListRow(
                              icon: LucideIcons.globe,
                              iconColor: ListRowColor.accent,
                              title: 'settings.language'.tr(),
                              sub: 'settings.languageSubtitle'.tr(),
                              trailing: _valueTrailing(
                                  context, _langLabel(settings.languageCode)),
                              onTap: () => showModalBottomSheet<void>(
                                context: context,
                                backgroundColor: Colors.transparent,
                                builder: (_) => _LanguagePicker(
                                  current: settings.languageCode,
                                  onChanged: (v) {
                                    context.setLocale(Locale(v));
                                    ref
                                        .read(settingsControllerProvider.notifier)
                                        .setLanguageCode(v);
                                  },
                                ),
                              ),
                            ),
                            if (!authState.isInstructor)
                              ListRow(
                                icon: LucideIcons.award,
                                iconColor: ListRowColor.primary,
                                title: 'settings.beltLevel'.tr(),
                                trailing: _valueTrailing(
                                    context, settings.beltLevel.i18nKey.tr()),
                                onTap: () => showModalBottomSheet<void>(
                                  context: context,
                                  backgroundColor: Colors.transparent,
                                  builder: (_) => _BeltPicker(
                                    current: settings.beltLevel,
                                    onChanged: (v) => ref
                                        .read(settingsControllerProvider.notifier)
                                        .setBeltLevel(v),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Dojo ──────────────────────────────────────────
                      if (authState.role == 'student')
                        _DojoStudentSection(authState: authState)
                      else if (authState.role == 'instructor')
                        _DojoInstructorSection(authState: authState),
                      const SizedBox(height: 16),

                      // ── About ─────────────────────────────────────────
                      TulCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
                              child: Text('About',
                                  style: TulTextStyles.cardHeader(color: palette.text)),
                            ),
                            ListRow(
                              icon: LucideIcons.info,
                              iconColor: ListRowColor.primary,
                              title: 'settings.termsPrivacy'.tr(),
                              sub: 'settings.termsPrivacySubtitle'.tr(),
                              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Coming soon')),
                              ),
                            ),
                            ListRow(
                              icon: LucideIcons.info,
                              iconColor: ListRowColor.secondary,
                              title: 'settings.support'.tr(),
                              sub: 'settings.supportSubtitle'.tr(),
                              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Coming soon')),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(4, 8, 4, 2),
                              child: Text(
                                'TulMaster v1.0.0 · ITF Edition',
                                style:
                                    TulTextStyles.mono(size: 11, color: palette.text3),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Logout ────────────────────────────────────────
                      TulDestructiveButton(
                        label: 'settings.logout'.tr(),
                        onPressed: () async {
                          await ref
                              .read(authControllerProvider.notifier)
                              .logout();
                        },
                      ),
                      const SizedBox(height: kAppShellContentBottomInset),
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

  Widget _valueTrailing(BuildContext context, String value) {
    final palette = context.tul;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: TulTextStyles.small(color: palette.text3)),
        const SizedBox(width: 4),
        Icon(LucideIcons.chevronRight, size: 16, color: palette.text3),
      ],
    );
  }

  String _themeLabel(ThemeMode m) => switch (m) {
        ThemeMode.dark => 'settings.themeDark'.tr(),
        ThemeMode.light => 'settings.themeLight'.tr(),
        ThemeMode.system => 'settings.themeSystem'.tr(),
      };

  static const _langs = [
    ('ko', '한국어'),
    ('en', 'English'),
    ('es', 'Español'),
    ('ja', '日本語'),
    ('zh', '中文'),
  ];

  String _langLabel(String code) =>
      _langs.firstWhere((l) => l.$1 == code, orElse: () => ('', code)).$2;
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
    final palette = context.tul;

    return TulCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              GestureDetector(
                onTap: _uploadingPhoto ? null : _pickAndUploadPhoto,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 66,
                      height: 66,
                      decoration: const BoxDecoration(
                        gradient: TulGradients.brand,
                        shape: BoxShape.circle,
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
                                      ? LucideIcons.shield
                                      : LucideIcons.user,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              )
                            : Icon(
                                isInstructor
                                    ? LucideIcons.shield
                                    : LucideIcons.user,
                                color: Colors.white,
                                size: 28,
                              ),
                      ),
                    ),
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        width: 24,
                        height: 24,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: TulGradients.brand,
                          shape: BoxShape.circle,
                          border: Border.all(color: palette.stage, width: 2),
                        ),
                        child: _uploadingPhoto
                            ? const Padding(
                                padding: EdgeInsets.all(3),
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5, color: Colors.white),
                              )
                            : const Icon(LucideIcons.camera,
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
                        style: TulTextStyles.cardHeader(color: palette.text)
                            .copyWith(fontSize: 17),
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                      )
                    else
                      Text(
                        auth.displayName.isEmpty ? '—' : auth.displayName,
                        style: TulTextStyles.cardHeader(color: palette.text)
                            .copyWith(fontSize: 17),
                      ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        TulBadge(
                          label: isInstructor
                              ? 'auth.roleInstructor'.tr()
                              : 'auth.roleStudent'.tr(),
                          color: TulBadgeColor.red,
                        ),
                        if (!isInstructor)
                          TulBadge(
                            label: beltLevel.i18nKey.tr(),
                            color: TulBadgeColor.blue,
                          ),
                        if (isInstructor && auth.danRank.isNotEmpty)
                          TulBadge(
                            label: auth.danRank,
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
          if (_editing)
            Row(
              children: [
                Expanded(
                  child: TulSecondaryButton(
                    label: 'journal.cancel'.tr(),
                    onPressed: () {
                      _nameCtrl.text = auth.displayName;
                      setState(() => _editing = false);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: palette.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: TulRadius.brLg),
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
            TulSecondaryButton(
              label: 'settings.editProfile'.tr(),
              onPressed: () => setState(() => _editing = true),
            ),
        ],
      ),
    );
  }
}

// ── Picker sheet base ─────────────────────────────────────────────────────────

class _PickerShell extends StatelessWidget {
  const _PickerShell({required this.title, required this.child});

  final String title;
  final Widget child;

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
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
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
              const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

// ── Theme picker ──────────────────────────────────────────────────────────────

class _ThemePicker extends StatelessWidget {
  const _ThemePicker({required this.current, required this.onChanged});

  final ThemeMode current;
  final void Function(ThemeMode) onChanged;

  @override
  Widget build(BuildContext context) {
    return _PickerShell(
      title: 'settings.theme'.tr(),
      child: Column(
        children: [
          for (final mode in ThemeMode.values)
            RadioListTile<ThemeMode>(
              value: mode,
              groupValue: current,
              title: Text(_label(mode)),
              activeColor: context.tul.primary,
              onChanged: (v) {
                if (v != null) {
                  onChanged(v);
                  Navigator.pop(context);
                }
              },
            ),
        ],
      ),
    );
  }

  String _label(ThemeMode m) => switch (m) {
        ThemeMode.dark => 'settings.themeDark'.tr(),
        ThemeMode.light => 'settings.themeLight'.tr(),
        ThemeMode.system => 'settings.themeSystem'.tr(),
      };
}

// ── Language picker ───────────────────────────────────────────────────────────

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
    return _PickerShell(
      title: 'settings.language'.tr(),
      child: Column(
        children: [
          for (final lang in _langs)
            RadioListTile<String>(
              value: lang.$1,
              groupValue: current,
              title: Text(lang.$2),
              activeColor: context.tul.primary,
              onChanged: (v) {
                if (v != null) {
                  onChanged(v);
                  Navigator.pop(context);
                }
              },
            ),
        ],
      ),
    );
  }
}

// ── Belt picker ───────────────────────────────────────────────────────────────

class _BeltPicker extends StatelessWidget {
  const _BeltPicker({required this.current, required this.onChanged});

  final BeltLevel current;
  final void Function(BeltLevel) onChanged;

  @override
  Widget build(BuildContext context) {
    return _PickerShell(
      title: 'settings.beltLevel'.tr(),
      child: Column(
        children: [
          for (final belt in BeltLevel.values)
            RadioListTile<BeltLevel>(
              value: belt,
              groupValue: current,
              title: Text(belt.i18nKey.tr()),
              activeColor: context.tul.primary,
              onChanged: (v) {
                if (v != null) {
                  onChanged(v);
                  Navigator.pop(context);
                }
              },
            ),
        ],
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
    final palette = context.tul;
    return AlertDialog(
      backgroundColor: palette.card,
      title: Text('settings.changePassword'.tr(),
          style: TulTextStyles.h2(color: palette.text)),
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
              Text(_error!, style: TextStyle(color: palette.primary)),
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
    final palette = context.tul;

    if (authState.dojoConnected) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: TulGradients.brand,
          borderRadius: TulRadius.brXl3,
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
                  child: const Icon(LucideIcons.school,
                      color: Colors.white, size: 20),
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
                        style: TulTextStyles.bodyStrong(color: Colors.white),
                      ),
                      if (authState.instructorName.isNotEmpty)
                        Text(
                          authState.instructorName,
                          style: TulTextStyles.small(
                              color: Colors.white.withValues(alpha: 0.75)),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Active Member',
                    style: TulTextStyles.mono(size: 11, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(
                    color: Colors.white.withValues(alpha: 0.5)),
              ),
              onPressed: _isSaving ? null : _disconnect,
              icon: const Icon(LucideIcons.link, size: 16),
              label: Text('settings.leaveDojoTitle'.tr()),
            ),
          ],
        ),
      );
    }

    return TulCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'settings.connectDojoPrompt'.tr(),
            style: TulTextStyles.small(color: palette.text2),
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
                        const Icon(LucideIcons.qrCode, size: 18),
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
                style: TulTextStyles.small(color: palette.primary)),
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
    final palette = context.tul;
    String planLabel;
    switch (authState.dojoPlan) {
      case 'paid_a':
        planLabel = 'dojo.planPaidA'.tr();
      default:
        planLabel = 'dojo.planFree'.tr();
    }

    return TulCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: TulGradients.brand,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(LucideIcons.school,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  authState.dojoName as String? ?? '',
                  style: TulTextStyles.bodyStrong(color: palette.text),
                ),
                Text(
                  planLabel,
                  style: TulTextStyles.small(color: palette.text3),
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
