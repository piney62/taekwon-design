import 'package:flutter/material.dart';

import '../../core/theme/tul_colors.dart';
import '../../core/theme/tul_text_styles.dart';
import '../../shared/widgets/tul_buttons.dart';
import '../../shared/widgets/tul_modal_sheet.dart';

class ChangePasswordModal extends StatefulWidget {
  const ChangePasswordModal({super.key});

  static Future<void> show(BuildContext context) {
    return TulModalSheet.show(
      context: context,
      title: 'Change Password',
      child: const ChangePasswordModal(),
    );
  }

  @override
  State<ChangePasswordModal> createState() => _ChangePasswordModalState();
}

class _ChangePasswordModalState extends State<ChangePasswordModal> {
  final _current = TextEditingController(text: '••••••••');
  final _next = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Current password', style: TulTextStyles.small(color: palette.text2)),
          const SizedBox(height: 8),
          TextField(controller: _current, obscureText: true),
          const SizedBox(height: 16),
          Text('New password', style: TulTextStyles.small(color: palette.text2)),
          const SizedBox(height: 8),
          TextField(
            controller: _next,
            obscureText: true,
            decoration: const InputDecoration(hintText: 'At least 8 characters'),
          ),
          const SizedBox(height: 16),
          Text('Confirm new password', style: TulTextStyles.small(color: palette.text2)),
          const SizedBox(height: 8),
          TextField(controller: _confirm, obscureText: true),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: TulSecondaryButton(
                  label: 'Cancel',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TulPrimaryButton(
                  label: 'Save',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
