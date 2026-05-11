import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/tul_colors.dart';
import '../../core/theme/tul_gradients.dart';
import '../../core/theme/tul_text_styles.dart';
import '../../shared/widgets/gradient_text.dart';
import '../../shared/widgets/tul_buttons.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    return Scaffold(
      backgroundColor: palette.stage,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              Container(
                width: 88,
                height: 88,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: TulGradients.brand,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: const Icon(LucideIcons.flame, size: 44, color: Colors.white),
              ),
              const SizedBox(height: 32),
              GradientText(
                'TulMaster',
                gradient: TulGradients.brand,
                style: TulTextStyles.splashTitle(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                "Master every pattern.\nTrain with precision.",
                textAlign: TextAlign.center,
                style: TulTextStyles.subtitle(color: palette.text2),
              ),
              const Spacer(),
              TulPrimaryButton(
                label: 'Get Started',
                onPressed: () => context.go('/onboarding/role'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.go('/onboarding/login'),
                child: Text.rich(
                  TextSpan(
                    text: 'Already have an account? ',
                    style: TulTextStyles.small(color: palette.text2),
                    children: [
                      TextSpan(
                        text: 'Sign in',
                        style: TulTextStyles.smallStrong(color: palette.primary),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
