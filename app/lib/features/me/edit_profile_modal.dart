import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/tul_colors.dart';
import '../../core/theme/tul_gradients.dart';
import '../../core/theme/tul_text_styles.dart';
import '../../shared/widgets/tul_buttons.dart';
import '../../shared/widgets/tul_modal_sheet.dart';

class EditProfileModal extends StatefulWidget {
  const EditProfileModal({super.key});

  static Future<void> show(BuildContext context) {
    return TulModalSheet.show(
      context: context,
      title: 'Edit Profile',
      child: const EditProfileModal(),
    );
  }

  @override
  State<EditProfileModal> createState() => _EditProfileModalState();
}

class _EditProfileModalState extends State<EditProfileModal> {
  final _name = TextEditingController(text: 'Nick Anderson');

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: TulGradients.brand,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(LucideIcons.user, size: 36, color: Colors.white),
                ),
                Positioned(
                  bottom: -4,
                  right: -4,
                  child: Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: palette.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: palette.stage, width: 2),
                    ),
                    child: Icon(LucideIcons.camera, size: 14, color: palette.text),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text('Display name', style: TulTextStyles.small(color: palette.text2)),
          const SizedBox(height: 8),
          TextField(controller: _name),
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
