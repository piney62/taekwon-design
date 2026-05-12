import 'package:flutter/material.dart';

import '../../core/theme/tul_palette.dart';
import '../../core/theme/tul_radius.dart';
import '../../core/theme/tul_text_styles.dart';

/// Wrapped bottom-sheet body: drag handle + optional title + scrollable content.
class TulModalSheet extends StatelessWidget {
  const TulModalSheet({
    super.key,
    this.title,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(20, 8, 20, 24),
  });

  final String? title;
  final Widget child;
  final EdgeInsetsGeometry padding;

  /// Show as a modal bottom sheet. Wraps content with [SafeArea].
  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    required Widget child,
    bool isScrollControlled = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: TulModalSheet(title: title, child: child),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    return Container(
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: const BorderRadius.vertical(top: TulRadius.rXl4),
        border: Border(
          top: BorderSide(color: palette.border),
          left: BorderSide(color: palette.border),
          right: BorderSide(color: palette.border),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: palette.borderStrong,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              if (title != null) ...[
                Text(title!, style: TulTextStyles.h2(color: palette.text)),
                const SizedBox(height: 18),
              ],
              Flexible(child: child),
            ],
          ),
        ),
      ),
    );
  }
}
