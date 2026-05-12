import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class GradHeaderText extends StatelessWidget {
  const GradHeaderText(
    this.text, {
    super.key,
    this.fontSize = 26.0,
    this.height = 1.15,
  });

  final String text;
  final double fontSize;
  final double height;

  @override
  Widget build(BuildContext context) {
    final parts = text.trim().split(' ');
    final prefix = parts.first;
    final accent = parts.length > 1 ? parts.skip(1).join(' ') : '';

    final style = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      color: Colors.white,
      height: height,
    );

    if (accent.isEmpty) {
      return ShaderMask(
        shaderCallback: (b) => AppColors.gradMain.createShader(b),
        child: Text(prefix, style: style),
      );
    }

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(text: '$prefix ', style: style),
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: ShaderMask(
              shaderCallback: (b) => AppColors.gradMain.createShader(b),
              child: Text(accent, style: style),
            ),
          ),
        ],
      ),
    );
  }
}
