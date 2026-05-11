import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/tul_colors.dart';
import '../../core/theme/tul_text_styles.dart';
import '../../shared/layout/screen_scaffold.dart';
import '../../shared/widgets/placeholder_box.dart';
import '../../shared/widgets/segmented_control.dart';
import '../../shared/widgets/tul_app_bar.dart';
import '../../shared/widgets/tul_card.dart';
import 'patterns_data.dart';

enum _DetailTab { image, video }

class PatternDetailScreen extends StatefulWidget {
  const PatternDetailScreen({super.key, this.patternNumber = 1});

  final int patternNumber;

  @override
  State<PatternDetailScreen> createState() => _PatternDetailScreenState();
}

class _PatternDetailScreenState extends State<PatternDetailScreen> {
  _DetailTab _tab = _DetailTab.image;
  String _direction = 'front';
  int _movement = 1;

  PatternInfo get _pattern => patternsList.firstWhere(
        (p) => p.number == widget.patternNumber,
        orElse: () => patternsList.first,
      );

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    final p = _pattern;
    return ScreenScaffold(
      appBar: TulAppBar(
        title: '${p.number} · ${p.name}  (${p.korean})',
        onBack: () => context.pop(),
      ),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: TulStack(
        children: [
          SegmentedControl<_DetailTab>(
            segments: const [
              (_DetailTab.image, 'Image Study'),
              (_DetailTab.video, 'Video Study'),
            ],
            value: _tab,
            onChanged: (v) => setState(() => _tab = v),
          ),
          if (_tab == _DetailTab.image) ...[
            PlaceholderBox(
              label: 'reference photo\nM$_movement · $_direction view',
              height: 280,
            ),
            SegmentedControl<String>(
              segments: const [
                ('front', 'Front'),
                ('back', 'Back'),
                ('left', 'Left'),
                ('right', 'Right'),
              ],
              value: _direction,
              onChanged: (v) => setState(() => _direction = v),
            ),
            TulCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  _NavButton(
                    label: 'Prev',
                    icon: LucideIcons.chevronLeft,
                    onTap: _movement > 1 ? () => setState(() => _movement--) : null,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text('MOVEMENT', style: TulTextStyles.tagLabel(color: palette.text3)),
                        const SizedBox(height: 2),
                        Text('$_movement of ${p.movements}',
                            style: TulTextStyles.bodyStrong(color: palette.text)),
                      ],
                    ),
                  ),
                  _NavButton(
                    label: 'Next',
                    icon: LucideIcons.chevronRight,
                    trailing: true,
                    onTap: _movement < p.movements
                        ? () => setState(() => _movement++)
                        : null,
                  ),
                ],
              ),
            ),
          ] else
            const _VideoPlayerPlaceholder(),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text('About ${p.name}',
                style: TulTextStyles.cardHeader(color: palette.text)),
          ),
          Text(
            'Chon-Ji means literally "the Heaven the Earth." It is, in the Orient, '
            'interpreted as the creation of the world or the beginning of human history. '
            'The pattern consists of two similar parts; one representing the Heaven and '
            'the other the Earth.',
            style: TulTextStyles.subtitle(color: palette.text2).copyWith(height: 1.6),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.label,
    required this.icon,
    this.onTap,
    this.trailing = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool trailing;

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    final disabled = onTap == null;
    final color = disabled ? palette.text3 : palette.text;
    return Opacity(
      opacity: disabled ? 0.5 : 1,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!trailing) Icon(icon, size: 16, color: color),
            if (!trailing) const SizedBox(width: 6),
            Text(label, style: TulTextStyles.subtitle(color: color)),
            if (trailing) const SizedBox(width: 6),
            if (trailing) Icon(icon, size: 16, color: color),
          ],
        ),
      ),
    );
  }
}

class _VideoPlayerPlaceholder extends StatelessWidget {
  const _VideoPlayerPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        const PlaceholderBox(label: 'video player', height: 220),
        Container(
          width: 64,
          height: 64,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            shape: BoxShape.circle,
          ),
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: const SizedBox(
                width: 64,
                height: 64,
                child: Icon(LucideIcons.play, size: 28, color: Colors.white),
              ),
            ),
          ),
        ),
        Positioned(
          left: 14,
          right: 14,
          bottom: 14,
          child: Row(
            children: [
              Text(
                '0:24',
                style: TulTextStyles.mono(size: 11, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: 0.32,
                    minHeight: 6,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '1:14',
                style: TulTextStyles.mono(size: 11, color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
