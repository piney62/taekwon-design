import 'package:flutter/material.dart';

import '../../core/theme/tul_palette.dart';
import '../../core/theme/tul_radius.dart';
import '../../core/theme/tul_text_styles.dart';

/// Small segmented control — pill bg with active inset.
class SegmentedControl<T> extends StatelessWidget {
  const SegmentedControl({
    super.key,
    required this.segments,
    required this.value,
    required this.onChanged,
  });

  final List<(T, String)> segments;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: palette.muted,
        borderRadius: TulRadius.brMd,
        border: Border.all(color: palette.border),
      ),
      child: Row(
        children: segments.map((seg) {
          final active = seg.$1 == value;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(seg.$1),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: active ? palette.card : Colors.transparent,
                  borderRadius: BorderRadius.circular(TulRadius.sm),
                  border: active
                      ? Border.all(color: palette.borderStrong)
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  seg.$2,
                  style: TulTextStyles.subtitle(
                    color: active ? palette.text : palette.text2,
                  ).copyWith(fontWeight: active ? FontWeight.w600 : FontWeight.w500),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
