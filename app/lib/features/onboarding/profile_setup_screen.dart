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
import '../../shared/widgets/badge.dart';
import '../../shared/widgets/gradient_text.dart';
import '../../shared/widgets/step_indicator.dart';
import '../../shared/widgets/tul_buttons.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  String _belt = 'yellow';
  String _dan = '3';
  final _dojangCtl = TextEditingController(text: "Master Kim's Dojang");
  final _yearsCtl = TextEditingController(text: '8');
  final _inviteCtl = TextEditingController(text: 'KIMSOUL2026');

  @override
  void dispose() {
    _dojangCtl.dispose();
    _yearsCtl.dispose();
    _inviteCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    final role = ref.watch(appSettingsProvider.select((s) => s.role));
    final isInstructor = role == UserRole.instructor;

    return ScreenScaffold(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: TulStack(
        children: [
          const StepIndicator(current: 3, total: 3),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: DefaultTextStyle.merge(
              style: TulTextStyles.title(color: palette.text),
              child: Wrap(
                children: [
                  const Text('Set up your '),
                  GradientText('profile', gradient: TulGradients.brand, style: TulTextStyles.title()),
                ],
              ),
            ),
          ),
          Text(
            isInstructor
                ? 'Tell us about your dojang.'
                : 'Tell us where you are on the belt path.',
            style: TulTextStyles.subtitle(color: palette.text2),
          ),
          if (isInstructor) ...[
            _label('Dojang name'),
            TextField(controller: _dojangCtl),
            _label('Dan grade'),
            _DropdownField(
              value: _dan,
              items: const [
                ('1', '1st Dan (초단)'),
                ('2', '2nd Dan (이단)'),
                ('3', '3rd Dan (삼단)'),
                ('4', '4th Dan (사단)'),
              ],
              onChanged: (v) => setState(() => _dan = v),
            ),
            _label('Years teaching'),
            TextField(
              controller: _yearsCtl,
              keyboardType: TextInputType.number,
            ),
          ] else ...[
            _label('Current belt'),
            _DropdownField(
              value: _belt,
              items: const [
                ('white', 'White Belt (흰띠)'),
                ('yellow', 'Yellow Belt (노란띠)'),
                ('green', 'Green Belt (초록띠)'),
                ('blue', 'Blue Belt (파란띠)'),
                ('red', 'Red Belt (빨간띠)'),
              ],
              onChanged: (v) => setState(() => _belt = v),
            ),
            _label('Dojang invite code · optional'),
            TextField(
              controller: _inviteCtl,
              decoration: const InputDecoration(
                hintText: 'e.g. KIMSOUL2026',
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: TulGradients.brandSoft,
                borderRadius: TulRadius.brXl2,
                border: Border.all(color: palette.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.school, size: 18, color: palette.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: 'Will connect to ',
                        style: TulTextStyles.small(color: palette.text),
                        children: [
                          TextSpan(
                            text: "Master Kim's Dojang",
                            style: TulTextStyles.smallStrong(color: palette.text),
                          ),
                          const TextSpan(text: ' · ITF Seoul Chapter'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const TulBadge(
                    label: 'Valid',
                    color: TulBadgeColor.green,
                    icon: LucideIcons.check,
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TulSecondaryButton(
                  label: 'Back',
                  onPressed: () => context.go('/onboarding/account'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TulPrimaryButton(
                  label: 'Start training',
                  onPressed: () {
                    ref.read(appSettingsProvider.notifier).setOnboardingComplete(true);
                    context.go('/home');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text(text, style: TulTextStyles.small(color: context.tul.text2)),
      );
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String value;
  final List<(String, String)> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: palette.muted,
        borderRadius: TulRadius.brLg,
        border: Border.all(color: palette.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: palette.card,
          icon: Icon(LucideIcons.chevronDown, size: 16, color: palette.text2),
          style: TextStyle(color: palette.text, fontSize: 14),
          items: items
              .map((e) => DropdownMenuItem(value: e.$1, child: Text(e.$2)))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}
