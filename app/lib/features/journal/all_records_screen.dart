import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/tul_colors.dart';
import '../../core/theme/tul_gradients.dart';
import '../../core/theme/tul_radius.dart';
import '../../core/theme/tul_text_styles.dart';
import '../../shared/layout/screen_scaffold.dart';
import '../../shared/widgets/filter_chips.dart';
import '../../shared/widgets/star_rating.dart';
import '../../shared/widgets/tul_app_bar.dart';
import '../../shared/widgets/tul_card.dart';
import 'add_training_modal.dart';

class AllRecordsScreen extends StatefulWidget {
  const AllRecordsScreen({super.key});

  @override
  State<AllRecordsScreen> createState() => _AllRecordsScreenState();
}

class _AllRecordsScreenState extends State<AllRecordsScreen> {
  String _filter = 'All';

  static const _records = [
    ('Chon-Ji Pattern', 'Today · 45m', 4, 'Stance depth needs work'),
    ('Sparring Practice', 'Yesterday · 30m', 5, 'Great rhythm — Sabum'),
    ('Dan-Gun Pattern', 'May 10 · 38m', 4, null),
    ('Chon-Ji Pattern', 'May 8 · 50m', 3, null),
    ('Breaking Drill', 'May 5 · 22m', 4, null),
  ];

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    return ScreenScaffold(
      appBar: TulAppBar(
        title: 'All Records',
        onBack: () => context.pop(),
        action: _AddIconButton(
          onTap: () => AddTrainingModal.show(context),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: TulStack.sm(
        children: [
          FilterChipsRow(
            options: const ['All', 'Pattern', 'Sparring', 'Breaking', 'Auto-saved'],
            selected: _filter,
            onSelect: (v) => setState(() => _filter = v),
          ),
          const SizedBox(height: 6),
          for (final r in _records)
            TulCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(r.$1, style: TulTextStyles.bodyStrong(color: palette.text))),
                      Icon(LucideIcons.pencil, size: 14, color: palette.text3),
                      const SizedBox(width: 8),
                      Icon(LucideIcons.trash2, size: 14, color: palette.text3),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(r.$2, style: TulTextStyles.tiny(color: palette.text3)),
                  const SizedBox(height: 8),
                  StarRating(value: r.$3, size: 14),
                  if (r.$4 != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: palette.secondary.withValues(alpha: 0.08),
                        borderRadius: TulRadius.brXs,
                      ),
                      child: Text(
                        r.$4!,
                        style: TulTextStyles.tiny(color: palette.secondary),
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _AddIconButton extends StatelessWidget {
  const _AddIconButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: TulRadius.brMd,
      child: InkWell(
        onTap: onTap,
        borderRadius: TulRadius.brMd,
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: TulGradients.brand,
            borderRadius: TulRadius.brMd,
          ),
          child: const Icon(LucideIcons.plus, size: 18, color: Colors.white),
        ),
      ),
    );
  }
}
