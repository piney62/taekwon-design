import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/tul_colors.dart';
import '../../core/theme/tul_gradients.dart';
import '../../core/theme/tul_text_styles.dart';
import '../../shared/layout/screen_scaffold.dart';
import '../../shared/widgets/gradient_text.dart';
import '../../shared/widgets/step_indicator.dart';
import '../../shared/widgets/tul_buttons.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _showPassword = false;
  final _usernameCtl = TextEditingController(text: 'nick.anderson');
  final _displayCtl = TextEditingController(text: 'Nick Anderson');
  final _pwCtl = TextEditingController(text: '••••••••');
  final _pw2Ctl = TextEditingController(text: '••••••••');

  @override
  void dispose() {
    _usernameCtl.dispose();
    _displayCtl.dispose();
    _pwCtl.dispose();
    _pw2Ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;

    return ScreenScaffold(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: TulStack(
        children: [
          const StepIndicator(current: 2, total: 3),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: DefaultTextStyle.merge(
              style: TulTextStyles.title(color: palette.text),
              child: Wrap(
                children: [
                  const Text('Create your '),
                  GradientText('account', gradient: TulGradients.brand, style: TulTextStyles.title()),
                ],
              ),
            ),
          ),
          Text(
            'You can change these anytime in Settings.',
            style: TulTextStyles.subtitle(color: palette.text2),
          ),
          _Field(
            label: 'Username',
            controller: _usernameCtl,
            helper: 'Letters, numbers and dots.',
          ),
          _Field(label: 'Display name', controller: _displayCtl),
          _Field(
            label: 'Password',
            controller: _pwCtl,
            obscureText: !_showPassword,
            suffix: IconButton(
              onPressed: () => setState(() => _showPassword = !_showPassword),
              icon: Icon(
                _showPassword ? LucideIcons.eye : LucideIcons.eyeOff,
                size: 18,
                color: palette.text2,
              ),
            ),
          ),
          _Field(
            label: 'Confirm password',
            controller: _pw2Ctl,
            obscureText: true,
            success: true,
            helper: '✓ Passwords match.',
            helperColor: palette.green,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TulSecondaryButton(
                  label: 'Back',
                  onPressed: () => context.go('/onboarding/role'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TulPrimaryButton(
                  label: 'Continue',
                  onPressed: () => context.go('/onboarding/profile'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    this.helper,
    this.helperColor,
    this.obscureText = false,
    this.success = false,
    this.suffix,
  });

  final String label;
  final TextEditingController controller;
  final String? helper;
  final Color? helperColor;
  final bool obscureText;
  final bool success;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TulTextStyles.small(color: palette.text2)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            suffixIcon: suffix,
            enabledBorder: success
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: palette.green),
                  )
                : null,
          ),
        ),
        if (helper != null) ...[
          const SizedBox(height: 6),
          Text(
            helper!,
            style: TulTextStyles.tiny(color: helperColor ?? palette.text3),
          ),
        ],
      ],
    );
  }
}
