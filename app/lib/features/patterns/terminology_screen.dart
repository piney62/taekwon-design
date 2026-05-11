import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/tul_colors.dart';
import '../../core/theme/tul_radius.dart';
import '../../core/theme/tul_text_styles.dart';
import '../../shared/layout/screen_scaffold.dart';
import '../../shared/widgets/filter_chips.dart';
import '../../shared/widgets/tul_app_bar.dart';
import '../../shared/widgets/tul_card.dart';

class TerminologyScreen extends StatefulWidget {
  const TerminologyScreen({super.key});

  @override
  State<TerminologyScreen> createState() => _TerminologyScreenState();
}

class _TerminologyScreenState extends State<TerminologyScreen> {
  String _category = 'Stances';

  static const _data = <String, List<(String, String, String, String)>>{
    'Stances': [
      ('앞굽이', 'Ap kubi', 'Walking stance', 'Front leg bent, back leg straight.'),
      ('뒷굽이', 'Dwit kubi', 'L-stance', '70% weight on back leg, foot at 90°.'),
      ('주춤서기', 'Joochum sogi', 'Sitting stance', 'Equal weight, knees bent outward.'),
    ],
    'Blocks': [
      ('내려막기', 'Naeryeo makgi', 'Low block', 'Forearm sweeps downward across body.'),
      ('안팔목막기', 'An palmok makgi', 'Inner forearm block', 'Inside edge blocks toward center.'),
      ('올려막기', 'Olryeo makgi', 'High block', 'Forearm rises above forehead.'),
    ],
    'Kicks': [
      ('앞차기', 'Ap chagi', 'Front kick', 'Knee chambers, foot snaps forward.'),
      ('돌려차기', 'Dollyo chagi', 'Turning (roundhouse) kick', 'Hip rotates, instep strikes target.'),
    ],
    'Strikes': [
      ('주먹지르기', 'Jumeok jireugi', 'Punch', 'Fist drives in straight line to target.'),
      ('손칼치기', 'Sonkal chigi', 'Knife-hand strike', 'Edge of open hand strikes outward.'),
    ],
  };

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    final items = _data[_category]!;
    return ScreenScaffold(
      appBar: TulAppBar(title: 'Terminology', onBack: () => context.pop()),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: TulStack.sm(
        children: [
          FilterChipsRow(
            options: _data.keys.toList(),
            selected: _category,
            onSelect: (v) => setState(() => _category = v),
          ),
          const SizedBox(height: 6),
          TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(LucideIcons.search, size: 16, color: palette.text3),
              hintText: 'Search Korean or English…',
              fillColor: palette.card,
              border: OutlineInputBorder(
                borderRadius: TulRadius.brMd,
                borderSide: BorderSide(color: palette.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: TulRadius.brMd,
                borderSide: BorderSide(color: palette.border),
              ),
            ),
          ),
          for (final t in items)
            TulCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          t.$1,
                          style: TulTextStyles.korean(
                            size: 17,
                            weight: FontWeight.w700,
                            color: palette.text,
                          ),
                        ),
                      ),
                      Text(
                        t.$2,
                        style: TulTextStyles.mono(
                          size: 11,
                          color: palette.text3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(t.$3, style: TulTextStyles.subtitle(color: palette.primary)),
                  const SizedBox(height: 4),
                  Text(t.$4,
                      style: TulTextStyles.small(color: palette.text2)
                          .copyWith(height: 1.5)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
