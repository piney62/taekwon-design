import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/theme/tul_colors.dart';
import '../../core/theme/tul_gradients.dart';
import '../../core/theme/tul_radius.dart';
import '../../core/theme/tul_text_styles.dart';
import '../../shared/widgets/gradient_text.dart';
import '../../shared/widgets/tul_buttons.dart';
import '../../shared/widgets/tul_modal_sheet.dart';

class InviteModal extends StatefulWidget {
  const InviteModal({super.key});

  static Future<void> show(BuildContext context) {
    return TulModalSheet.show(
      context: context,
      title: 'Invite students',
      child: const InviteModal(),
    );
  }

  @override
  State<InviteModal> createState() => _InviteModalState();
}

class _InviteModalState extends State<InviteModal> {
  String _expiry = '7';

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: TulRadius.brXl,
              ),
              child: QrImageView(
                data: 'KIMSOUL2026',
                size: 180,
                backgroundColor: Colors.white,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: Colors.black,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Column(
            children: [
              Text(
                'INVITE CODE',
                style: TulTextStyles.tagLabel(color: palette.text3),
              ),
              const SizedBox(height: 6),
              GradientText(
                'KIMSOUL2026',
                gradient: TulGradients.brand,
                style: TulTextStyles.mono(
                  size: 24,
                  weight: FontWeight.w700,
                  letterSpacing: 1.9,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text('Expiry', style: TulTextStyles.small(color: palette.text2)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: BoxDecoration(
              color: palette.muted,
              borderRadius: TulRadius.brLg,
              border: Border.all(color: palette.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _expiry,
                isExpanded: true,
                dropdownColor: palette.card,
                icon: Icon(LucideIcons.chevronDown, size: 16, color: palette.text2),
                style: TextStyle(color: palette.text, fontSize: 14),
                items: const [
                  DropdownMenuItem(value: '1', child: Text('24 hours')),
                  DropdownMenuItem(value: '7', child: Text('7 days')),
                  DropdownMenuItem(value: '30', child: Text('30 days')),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _expiry = v);
                },
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TulSecondaryButton(
                  label: 'Share',
                  icon: LucideIcons.share2,
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TulSecondaryButton(
                  label: 'Copy',
                  icon: LucideIcons.copy,
                  onPressed: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TulPrimaryButton(
            label: 'Done',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
