import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/tul_colors.dart';
import '../../core/theme/tul_gradients.dart';
import '../../core/theme/tul_radius.dart';
import '../../core/theme/tul_text_styles.dart';
import '../../shared/layout/screen_scaffold.dart';
import '../../shared/widgets/gradient_text.dart';
import '../../shared/widgets/placeholder_box.dart';
import '../../shared/widgets/tul_app_bar.dart';
import '../../shared/widgets/tul_buttons.dart';
import '../../shared/widgets/tul_card.dart';

enum _Severity { critical, improve, watch }

class AnalyzeResultScreen extends StatelessWidget {
  const AnalyzeResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    return ScreenScaffold(
      appBar: TulAppBar(
        title: 'Analysis Result',
        onBack: () => context.pop(),
      ),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: TulStack(
        children: [
          // Side-by-side comparison
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'YOUR POSE',
                      style: TulTextStyles.tiny(color: palette.primary),
                    ),
                    const SizedBox(height: 6),
                    const PlaceholderBox(label: 'your photo\nChon-Ji M1', height: 180),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MASTER REF',
                      style: TulTextStyles.tiny(color: palette.secondary),
                    ),
                    const SizedBox(height: 6),
                    const PlaceholderBox(label: 'reference\nwalking stance', height: 180),
                  ],
                ),
              ),
            ],
          ),
          // Score card
          TulCard(
            child: Column(
              children: [
                Text(
                  'OVERALL SCORE',
                  style: TulTextStyles.gaugeLabel(color: palette.text3),
                ),
                const SizedBox(height: 8),
                GradientText(
                  '68',
                  gradient: TulGradients.brand,
                  style: TulTextStyles.gaugeNum(),
                ),
                const SizedBox(height: 8),
                Text(
                  'Needs improvement · stance depth',
                  style: TulTextStyles.small(color: palette.text2),
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: SizedBox(
                    height: 6,
                    child: Stack(
                      children: [
                        Container(color: palette.text.withValues(alpha: 0.06)),
                        FractionallySizedBox(
                          widthFactor: 0.68,
                          child: Container(
                            decoration: const BoxDecoration(gradient: TulGradients.brand),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('0', style: TulTextStyles.mono(size: 10, color: palette.text3)),
                    Text('50', style: TulTextStyles.mono(size: 10, color: palette.text3)),
                    Text('100', style: TulTextStyles.mono(size: 10, color: palette.text3)),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text('Detected issues', style: TulTextStyles.cardHeader(color: palette.text)),
          ),
          const TulStack.sm(children: [
            _IssueCard(
              severity: _Severity.critical,
              title: 'Front leg not bent enough',
              tip: 'In walking stance the front knee should be over the toes — bend 15° more.',
            ),
            _IssueCard(
              severity: _Severity.improve,
              title: 'Hip alignment slightly off',
              tip: 'Rotate hips fully forward when blocking; engage your core.',
            ),
            _IssueCard(
              severity: _Severity.watch,
              title: 'Blocking arm angle',
              tip: 'Forearm should be at 45° from ground at end position.',
            ),
          ]),
          // Actions
          TulPrimaryButton(
            label: 'Save to Journal',
            icon: LucideIcons.check,
            onPressed: () => context.pop(),
          ),
          Row(
            children: [
              Expanded(
                child: TulSecondaryButton(
                  label: 'Retry',
                  icon: LucideIcons.refreshCw,
                  onPressed: () => context.pop(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TulSecondaryButton(
                  label: 'Ask Coach',
                  icon: LucideIcons.messageCircle,
                  onPressed: () => context.go('/patterns/coach'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IssueCard extends StatelessWidget {
  const _IssueCard({
    required this.severity,
    required this.title,
    required this.tip,
  });

  final _Severity severity;
  final String title;
  final String tip;

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    final (sevColor, sevLabel) = switch (severity) {
      _Severity.critical => (palette.primary, 'Critical'),
      _Severity.improve => (palette.yellow, 'Improve'),
      _Severity.watch => (palette.secondary, 'Watch'),
    };

    return TulCard.compact(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: sevColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(TulRadius.pill),
                  border: Border.all(color: sevColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  sevLabel.toUpperCase(),
                  style: TulTextStyles.mono(size: 10, color: sevColor, letterSpacing: 1),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title, style: TulTextStyles.smallStrong(color: palette.text)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(tip, style: TulTextStyles.small(color: palette.text2).copyWith(height: 1.5)),
        ],
      ),
    );
  }
}
