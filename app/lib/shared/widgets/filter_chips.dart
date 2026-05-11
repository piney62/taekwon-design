import 'package:flutter/material.dart';

import '../../core/theme/tul_colors.dart';
import '../../core/theme/tul_radius.dart';
import '../../core/theme/tul_text_styles.dart';

class FilterChipsRow extends StatelessWidget {
  const FilterChipsRow({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: options.map((o) {
          final active = o == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: active
                  ? palette.primary.withValues(alpha: 0.14)
                  : palette.card,
              borderRadius: TulRadius.brMd,
              child: InkWell(
                onTap: () => onSelect(o),
                borderRadius: TulRadius.brMd,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: TulRadius.brMd,
                    border: Border.all(
                      color: active
                          ? palette.primary.withValues(alpha: 0.3)
                          : palette.border,
                    ),
                  ),
                  child: Text(
                    o,
                    style: TulTextStyles.small(
                      color: active ? palette.primary : palette.text2,
                    ).copyWith(fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
