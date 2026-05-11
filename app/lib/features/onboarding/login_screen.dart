import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/providers/app_settings.dart';
import '../../core/theme/tul_colors.dart';
import '../../core/theme/tul_gradients.dart';
import '../../core/theme/tul_text_styles.dart';
import '../../shared/layout/screen_scaffold.dart';
import '../../shared/widgets/tul_app_bar.dart';
import '../../shared/widgets/tul_buttons.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _userCtl = TextEditingController(text: 'nick.anderson');
  final _pwCtl = TextEditingController(text: '••••••••');

  @override
  void dispose() {
    _userCtl.dispose();
    _pwCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    return ScreenScaffold(
      appBar: TulAppBar(
        title: 'Sign in',
        onBack: () => context.go('/welcome'),
      ),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: TulGradients.brand,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(LucideIcons.flame, size: 28, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  'Welcome back',
                  style: TulTextStyles.h2(color: palette.text).copyWith(fontSize: 22),
                ),
                const SizedBox(height: 6),
                Text(
                  'Continue your training journey.',
                  style: TulTextStyles.subtitle(color: palette.text2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text('Username', style: TulTextStyles.small(color: palette.text2)),
          const SizedBox(height: 8),
          TextField(controller: _userCtl),
          const SizedBox(height: 16),
          Text('Password', style: TulTextStyles.small(color: palette.text2)),
          const SizedBox(height: 8),
          TextField(controller: _pwCtl, obscureText: true),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TulGhostButton(
              label: 'Forgot password?',
              onPressed: () {},
            ),
          ),
          const SizedBox(height: 16),
          TulPrimaryButton(
            label: 'Sign in',
            onPressed: () {
              ref.read(appSettingsProvider.notifier).setOnboardingComplete(true);
              context.go('/home');
            },
          ),
        ],
      ),
    );
  }
}
