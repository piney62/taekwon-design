import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tul_colors.dart';
import '../../core/theme/tul_gradients.dart';
import '../../core/theme/tul_text_styles.dart';
import '../../shared/layout/screen_scaffold.dart';
import '../../shared/widgets/gradient_text.dart';
import '../../shared/widgets/tul_app_bar.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  static const _milestones = [
    ('1955', "Name 'Taekwon-Do' adopted", 'On 11 April 1955 the name was officially decided by a special board.', false),
    ('1966', 'ITF founded', 'International Taekwon-Do Federation established by General Choi Hong Hi.', false),
    ('1972', 'ITF HQ moves to Toronto', 'International base relocated; first World Championship follows shortly after.', false),
    ('1983', 'Encyclopedia published', "15-volume Taekwon-Do Encyclopedia codifies the art's full curriculum.", false),
    ('2002', 'Passing of the founder', 'General Choi Hong Hi passes; ITF continues under his lineage.', false),
    ('Today', 'Global practice', 'Over 90 countries practice ITF Taekwon-Do.', true),
  ];

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      appBar: TulAppBar(title: 'ITF History', onBack: () => context.pop()),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < _milestones.length; i++)
            _TimelineItem(
              year: _milestones[i].$1,
              title: _milestones[i].$2,
              description: _milestones[i].$3,
              isFuture: _milestones[i].$4,
              isLast: i == _milestones.length - 1,
            ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.year,
    required this.title,
    required this.description,
    required this.isFuture,
    required this.isLast,
  });

  final String year;
  final String title;
  final String description;
  final bool isFuture;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline rail
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    gradient: isFuture ? TulGradients.brand : null,
                    color: isFuture ? null : palette.text2,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: palette.stage,
                      width: 3,
                    ),
                    boxShadow: isFuture
                        ? [
                            BoxShadow(
                              color: palette.primary.withValues(alpha: 0.4),
                              blurRadius: 12,
                            ),
                          ]
                        : null,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: palette.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  isFuture
                      ? GradientText(
                          year,
                          gradient: TulGradients.brand,
                          style: TulTextStyles.mono(
                            size: 11,
                            weight: FontWeight.w700,
                            letterSpacing: 1.3,
                          ),
                        )
                      : Text(
                          year,
                          style: TulTextStyles.mono(
                            size: 11,
                            weight: FontWeight.w700,
                            color: palette.text3,
                            letterSpacing: 1.3,
                          ),
                        ),
                  const SizedBox(height: 4),
                  Text(title,
                      style: TulTextStyles.cardHeader(color: palette.text)
                          .copyWith(fontSize: 16)),
                  const SizedBox(height: 6),
                  Text(description,
                      style: TulTextStyles.subtitle(color: palette.text2)
                          .copyWith(height: 1.6)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
