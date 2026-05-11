import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/tul_colors.dart';
import '../../core/theme/tul_radius.dart';
import '../../core/theme/tul_text_styles.dart';
import '../../shared/widgets/star_rating.dart';
import '../../shared/widgets/tul_buttons.dart';
import '../../shared/widgets/tul_modal_sheet.dart';

class AddTrainingModal extends StatefulWidget {
  const AddTrainingModal({super.key});

  static Future<void> show(BuildContext context) {
    return TulModalSheet.show(
      context: context,
      title: 'Add Training Session',
      child: const AddTrainingModal(),
    );
  }

  @override
  State<AddTrainingModal> createState() => _AddTrainingModalState();
}

class _AddTrainingModalState extends State<AddTrainingModal> {
  int _stars = 4;
  String _type = 'pattern';
  String _pattern = 'chon-ji';
  final _durationCtl = TextEditingController(text: '45');
  final _memoCtl = TextEditingController(
    text: 'Focused on stance depth. Need to work on hip rotation in M3.',
  );

  @override
  void dispose() {
    _durationCtl.dispose();
    _memoCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _label('Date'),
          _readonlyChip('2026-05-12'),
          _label('Training type'),
          _dropdown(
            value: _type,
            items: const [
              ('pattern', 'Pattern'),
              ('sparring', 'Sparring'),
              ('breaking', 'Breaking'),
              ('other', 'Other'),
            ],
            onChanged: (v) => setState(() => _type = v),
          ),
          _label('Pattern'),
          _dropdown(
            value: _pattern,
            items: const [
              ('chon-ji', 'Chon-Ji (천지)'),
              ('dan-gun', 'Dan-Gun (단군)'),
              ('do-san', 'Do-San (도산)'),
            ],
            onChanged: (v) => setState(() => _pattern = v),
          ),
          _label('Duration (minutes)'),
          TextField(
            controller: _durationCtl,
            keyboardType: TextInputType.number,
          ),
          _label('Self rating'),
          StarRating(value: _stars, onChanged: (v) => setState(() => _stars = v)),
          _label('Memo'),
          TextField(controller: _memoCtl, maxLines: 3),
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
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 8),
        child: Text(text, style: TulTextStyles.small(color: context.tul.text2)),
      );

  Widget _readonlyChip(String value) {
    final palette = context.tul;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: palette.muted,
        borderRadius: TulRadius.brLg,
        border: Border.all(color: palette.border),
      ),
      child: Row(
        children: [
          Expanded(child: Text(value, style: TulTextStyles.body(color: palette.text))),
          Icon(LucideIcons.calendar, size: 16, color: palette.text3),
        ],
      ),
    );
  }

  Widget _dropdown({
    required String value,
    required List<(String, String)> items,
    required ValueChanged<String> onChanged,
  }) {
    final palette = context.tul;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: palette.muted,
        borderRadius: TulRadius.brLg,
        border: Border.all(color: palette.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: palette.card,
          icon: Icon(LucideIcons.chevronDown, size: 16, color: palette.text2),
          style: TextStyle(color: palette.text, fontSize: 14),
          items: items
              .map((e) => DropdownMenuItem(value: e.$1, child: Text(e.$2)))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}
