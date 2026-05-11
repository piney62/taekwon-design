import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/providers/app_settings.dart';
import '../../core/theme/tul_colors.dart';
import '../../core/theme/tul_gradients.dart';
import '../../core/theme/tul_radius.dart';
import '../../core/theme/tul_text_styles.dart';
import '../../shared/layout/screen_scaffold.dart';
import '../../shared/widgets/gradient_text.dart';
import '../../shared/widgets/step_indicator.dart';
import '../../shared/widgets/tul_buttons.dart';

class RoleScreen extends ConsumerWidget {
  const RoleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.tul;
    final role = ref.watch(appSettingsProvider.select((s) => s.role));
    final settings = ref.read(appSettingsProvider.notifier);

    return ScreenScaffold(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: TulStack(
        children: [
          const StepIndicator(current: 1, total: 3),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: DefaultTextStyle.merge(
              style: TulTextStyles.title(color: palette.text),
              child: Wrap(
                children: [
                  const Text('Choose your '),
                  GradientText('role', gradient: TulGradients.brand, style: TulTextStyles.title()),
                ],
              ),
            ),
          ),
          Text(
            'This shapes your home screen and tools.',
            style: TulTextStyles.subtitle(color: palette.text2),
          ),
          TulStack.sm(children: [
            _RoleCard(
              icon: LucideIcons.user,
              accent: palette.primary,
              title: 'Student',
              body: 'Train daily, analyze your patterns, and track your belt journey.',
              selected: role == UserRole.student,
              onTap: () => settings.setRole(UserRole.student),
            ),
            _RoleCard(
              icon: LucideIcons.users,
              accent: palette.secondary,
              title: 'Instructor (Sabum)',
              body: 'Manage your dojang, assign homework, and review student progress.',
              selected: role == UserRole.instructor,
              onTap: () => settings.setRole(UserRole.instructor),
            ),
          ]),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TulSecondaryButton(
                  label: 'Back',
                  onPressed: () => context.go('/welcome'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TulPrimaryButton(
                  label: 'Continue',
                  onPressed: () => context.go('/onboarding/account'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.accent,
    required this.title,
    required this.body,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String body;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    return Material(
      color: Colors.transparent,
      borderRadius: TulRadius.brXl3,
      child: InkWell(
        onTap: onTap,
        borderRadius: TulRadius.brXl3,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: palette.card,
            borderRadius: TulRadius.brXl3,
            border: Border.all(
              color: selected ? accent : palette.border,
              width: selected ? 1.5 : 1,
            ),
            boxShadow: selected
                ? [BoxShadow(color: accent.withValues(alpha: 0.18), blurRadius: 28, offset: const Offset(0, 8))]
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, size: 26, color: accent),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TulTextStyles.cardHeader(color: palette.text)
                          .copyWith(fontSize: 17),
                    ),
                    const SizedBox(height: 4),
                    Text(body, style: TulTextStyles.small(color: palette.text2)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? accent : Colors.transparent,
                  border: Border.all(
                    color: selected ? accent : palette.borderStrong,
                    width: 2,
                  ),
                ),
                child: selected
                    ? const Icon(LucideIcons.check, size: 14, color: Colors.white)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
