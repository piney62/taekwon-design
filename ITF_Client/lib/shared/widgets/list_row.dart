import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/tul_palette.dart';
import '../../core/theme/tul_radius.dart';
import '../../core/theme/tul_text_styles.dart';

enum ListRowColor { primary, secondary, accent }

/// Avatar (icon) + title + sub + chevron/trailing.
class ListRow extends StatelessWidget {
  const ListRow({
    super.key,
    required this.icon,
    this.iconColor = ListRowColor.primary,
    required this.title,
    this.sub,
    this.trailing,
    this.onTap,
    this.locked = false,
  });

  final IconData icon;
  final ListRowColor iconColor;
  final String title;
  final String? sub;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    final accent = switch (iconColor) {
      ListRowColor.primary => palette.primary,
      ListRowColor.secondary => palette.secondary,
      ListRowColor.accent => palette.accent,
    };

    return Opacity(
      opacity: locked ? 0.5 : 1.0,
      child: Material(
        color: Colors.transparent,
        borderRadius: TulRadius.brLg,
        child: InkWell(
          onTap: onTap,
          borderRadius: TulRadius.brLg,
          hoverColor: palette.hover,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: locked ? palette.muted : accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    locked ? LucideIcons.lock : icon,
                    size: 18,
                    color: locked ? palette.text3 : accent,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TulTextStyles.bodyMd(color: palette.text),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (sub != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          sub!,
                          style: TulTextStyles.small(color: palette.text3),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                trailing ??
                    Icon(LucideIcons.chevronRight, size: 16, color: palette.text3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
