import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/tul_palette.dart';
import '../../core/theme/tul_radius.dart';
import '../../core/theme/tul_text_styles.dart';

/// Drill-down top bar — back chip + title + optional action.
class TulAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TulAppBar({
    super.key,
    required this.title,
    this.onBack,
    this.action,
  });

  final String title;
  final VoidCallback? onBack;
  final Widget? action;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 18),
      child: Row(
        children: [
          if (onBack != null) ...[
            Material(
              color: palette.card,
              borderRadius: TulRadius.brMd,
              child: InkWell(
                onTap: onBack,
                borderRadius: TulRadius.brMd,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: TulRadius.brMd,
                    border: Border.all(color: palette.border),
                  ),
                  child: Icon(
                    LucideIcons.chevronLeft,
                    size: 18,
                    color: palette.text,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              title,
              style: TulTextStyles.topBar(color: palette.text),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}
