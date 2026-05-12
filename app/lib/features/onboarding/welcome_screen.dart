import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
              const SizedBox(height: 48),
              // Logo with a subtle red bloom behind it
              Center(
                child: Container(
                  width: 168,
                  height: 168,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [Color(0x29EF4444), Colors.transparent],
                      stops: [0, 0.75],
                    ),
                  ),
                  child: Image.asset(
                    'assets/logo_white.png',
                    width: 124,
                    height: 124,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              GradientText(
                'TulMaster',
                gradient: TulGradients.brand,
                style: TulTextStyles.splashTitle(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              Text(
                'Master every pattern.\nTrain with precision.',
                textAlign: TextAlign.center,
                style: TulTextStyles.subtitle(color: palette.text2)
                    .copyWith(height: 1.55),
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
