import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../core/theme/tul_colors.dart';
import '../core/theme/tul_text_styles.dart';
import '../shared/layout/screen_scaffold.dart';
import '../shared/widgets/tul_app_bar.dart';

/// Temporary placeholder screen used while we build out features.
class StubScreen extends StatelessWidget {
  const StubScreen({
    super.key,
    required this.title,
    this.showBack = false,
    this.description,
  });

  final String title;
  final bool showBack;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    return ScreenScaffold(
      appBar: showBack
          ? TulAppBar(title: title, onBack: () => context.pop())
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Icon(LucideIcons.info, size: 56, color: palette.text3),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TulTextStyles.h2(color: palette.text),
          ),
          const SizedBox(height: 8),
          Text(
            description ?? 'Coming soon.',
            textAlign: TextAlign.center,
            style: TulTextStyles.subtitle(color: palette.text2),
          ),
        ],
      ),
    );
  }
}
