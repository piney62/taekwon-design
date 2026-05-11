import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/tul_colors.dart';
import '../../core/theme/tul_gradients.dart';
import '../../core/theme/tul_radius.dart';
import '../../core/theme/tul_text_styles.dart';
import '../../shared/layout/screen_scaffold.dart';
import '../../shared/widgets/gradient_text.dart';
import '../../shared/widgets/tul_buttons.dart';
import '../../shared/widgets/tul_card.dart';

class AnalyzeEntryScreen extends StatefulWidget {
  const AnalyzeEntryScreen({super.key, this.prefill = false});

  final bool prefill;

  @override
  State<AnalyzeEntryScreen> createState() => _AnalyzeEntryScreenState();
}

class _AnalyzeEntryScreenState extends State<AnalyzeEntryScreen> {
  String _pattern = 'chon-ji';
  String _movement = 'm1';

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    return ScreenScaffold(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      child: TulStack(
        children: [
          DefaultTextStyle.merge(
            style: TulTextStyles.title(color: palette.text),
            child: Wrap(
              children: [
                const Text('Pose '),
                GradientText('Analysis', gradient: TulGradients.brand, style: TulTextStyles.title()),
              ],
            ),
          ),
          Text(
            'Upload or capture your pattern movement for instant feedback.',
            style: TulTextStyles.subtitle(color: palette.text2),
          ),
          TulCard(
            child: TulStack(children: [
              _DropdownField(
                label: 'Pattern',
                value: _pattern,
                items: const [
                  ('chon-ji', 'Chon-Ji (천지)'),
                  ('dan-gun', 'Dan-Gun (단군)'),
                  ('do-san', 'Do-San (도산)'),
                  ('won-hyo', 'Won-Hyo (원효)'),
                  ('yul-gok', 'Yul-Gok (율곡)'),
                ],
                onChanged: (v) => setState(() => _pattern = v),
              ),
              _DropdownField(
                label: 'Movement',
                value: _movement,
                items: const [
                  ('m1', 'Movement 1 — Walking stance low block'),
                  ('m2', 'Movement 2 — Walking stance middle punch'),
                  ('m3', 'Movement 3 — L-stance inner forearm block'),
                ],
                onChanged: (v) => setState(() => _movement = v),
              ),
              if (widget.prefill)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: palette.secondary.withValues(alpha: 0.08),
                    borderRadius: TulRadius.brSm,
                    border: Border.all(color: palette.secondary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.zap, size: 14, color: palette.secondary),
                      const SizedBox(width: 8),
                      Text(
                        "Pre-filled from Today's Focus",
                        style: TulTextStyles.tiny(color: palette.secondary),
                      ),
                    ],
                  ),
                ),
            ]),
          ),
          // Dashed dropzone
          DottedBorder(
            borderType: BorderType.RRect,
            radius: const Radius.circular(22),
            color: palette.borderStrong,
            strokeWidth: 1.5,
            dashPattern: const [6, 4],
            child: SizedBox(
              height: 220,
              width: double.infinity,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: TulGradients.brandSoft,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(LucideIcons.scanLine, size: 26, color: palette.primary),
                    ),
                    const SizedBox(height: 10),
                    Text('Upload your pose', style: TulTextStyles.bodyStrong(color: palette.text)),
                    const SizedBox(height: 4),
                    Text(
                      'Take or upload a photo · auto-compared\nagainst the master reference',
                      textAlign: TextAlign.center,
                      style: TulTextStyles.tiny(color: palette.text3),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(child: _SourceButton(icon: LucideIcons.upload, label: 'Gallery', color: palette.secondary)),
              const SizedBox(width: 12),
              Expanded(child: _SourceButton(icon: LucideIcons.camera, label: 'Camera', color: palette.primary)),
            ],
          ),
          TulPrimaryButton(
            label: 'Analyze Movement',
            onPressed: () => context.go('/analyze/result'),
          ),
          // Reference info
          TulCard(
            background: Color.alphaBlend(
              palette.primary.withValues(alpha: 0.06),
              palette.card,
            ),
            borderColor: palette.primary.withValues(alpha: 0.18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: palette.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(LucideIcons.activity, size: 20, color: palette.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Compared to master reference',
                          style: TulTextStyles.smallStrong(color: palette.text)),
                      const SizedBox(height: 4),
                      Text(
                        'Form, stance and technique are scored against the ITF reference for this exact movement.',
                        style: TulTextStyles.tiny(color: palette.text2)
                            .copyWith(height: 1.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          TulGhostButton(
            label: 'View past analyses →',
            onPressed: () => context.go('/analyze/history'),
          ),
        ],
      ),
    );
  }
}

class _SourceButton extends StatelessWidget {
  const _SourceButton({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    return Material(
      color: palette.card,
      borderRadius: TulRadius.brLg,
      child: InkWell(
        onTap: () {},
        borderRadius: TulRadius.brLg,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
          decoration: BoxDecoration(
            borderRadius: TulRadius.brLg,
            border: Border.all(color: palette.borderStrong),
          ),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(height: 10),
              Text(label, style: TulTextStyles.subtitle(color: palette.text)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<(String, String)> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TulTextStyles.small(color: palette.text2)),
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
        ),
      ],
    );
  }
}
