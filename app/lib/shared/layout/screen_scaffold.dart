import 'package:flutter/material.dart';

import '../../core/theme/tul_colors.dart';

/// Default screen body — scrollable, padded, with bottom space for the tab bar.
class ScreenScaffold extends StatelessWidget {
  const ScreenScaffold({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(20, 8, 20, 100),
    this.appBar,
    this.floatingActionButton,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    return Scaffold(
      backgroundColor: palette.stage,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

/// Stack helper: vertical column with spacing between children.
class TulStack extends StatelessWidget {
  const TulStack({
    super.key,
    required this.children,
    this.spacing = 16,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
  });

  /// Convenience: smaller spacing.
  const TulStack.sm({
    super.key,
    required this.children,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
  }) : spacing = 10;

  /// Convenience: larger spacing.
  const TulStack.lg({
    super.key,
    required this.children,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
  }) : spacing = 22;

  final List<Widget> children;
  final double spacing;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    final out = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) out.add(SizedBox(height: spacing));
      out.add(children[i]);
    }
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: MainAxisSize.min,
      children: out,
    );
  }
}
