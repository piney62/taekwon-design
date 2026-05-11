import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/theme/tul_colors.dart';
import '../../core/theme/tul_gradients.dart';
import '../../core/theme/tul_radius.dart';
import '../../core/theme/tul_text_styles.dart';
import '../../shared/layout/screen_scaffold.dart';
import '../../shared/widgets/badge.dart';
import '../../shared/widgets/filter_chips.dart';
import '../../shared/widgets/gradient_text.dart';
import '../../shared/widgets/tul_buttons.dart';
import '../../shared/widgets/tul_card.dart';
import 'invite_modal.dart';

class DojangMainScreen extends StatefulWidget {
  const DojangMainScreen({super.key});

  @override
  State<DojangMainScreen> createState() => _DojangMainScreenState();
}

class _DojangMainScreenState extends State<DojangMainScreen> {
  String _filter = 'All';
  final _hwCtl = TextEditingController(
    text: 'Practice low block 100x. Submit a Chon-Ji M1 analysis.',
  );

  static const _students = [
    ('Jiwon Park', 'Yellow Belt', 'Active 8d ago', TulBadgeColor.yellow, true),
    ('Alex Chen', 'Green Belt', 'Active today', TulBadgeColor.green, false),
    ('Sara Lee', 'Yellow Belt', 'Active 2d ago', TulBadgeColor.yellow, false),
    ('Marco Rossi', 'Blue Belt', 'Active today', TulBadgeColor.blue, false),
    ('Nina Yamada', 'Yellow-Green', 'Active 4h ago', TulBadgeColor.yellow, false),
    ('David Kim', 'Green Belt', 'Active yesterday', TulBadgeColor.green, false),
  ];

  @override
  void dispose() {
    _hwCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    return ScreenScaffold(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      child: TulStack(
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GradientText('Dojang',
                        gradient: TulGradients.brand, style: TulTextStyles.title()),
                    Text('Manage students and homework.',
                        style: TulTextStyles.subtitle(color: palette.text2)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: _IconChip(
                  icon: LucideIcons.refreshCw,
                  onTap: () {},
                ),
              ),
            ],
          ),

          // Invite Code card (gradient)
          TulCard(
            background: Color.alphaBlend(
              palette.accent.withValues(alpha: 0.10),
              palette.card,
            ),
            borderColor: palette.accent.withValues(alpha: 0.2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(child: Text('Invite Code', style: TulTextStyles.cardHeader(color: palette.text))),
                    const TulBadge(label: 'Active', color: TulBadgeColor.green),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: TulRadius.brMd,
                      ),
                      child: QrImageView(
                        data: 'KIMSOUL2026',
                        backgroundColor: Colors.white,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: Colors.black,
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'KIMSOUL2026',
                            style: TulTextStyles.mono(
                              size: 18,
                              weight: FontWeight.w700,
                              color: palette.text,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text('Expires May 18 · 12 used',
                              style: TulTextStyles.tiny(color: palette.text3)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _MiniButton(
                        icon: LucideIcons.qrCode,
                        label: 'Open QR',
                        onTap: () => InviteModal.show(context),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _MiniButton(
                        icon: LucideIcons.share2,
                        label: 'Share',
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: 8),
                    _MiniButton(
                      icon: LucideIcons.copy,
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Assign Homework
          TulCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Assign Homework', style: TulTextStyles.cardHeader(color: palette.text)),
                const SizedBox(height: 12),
                TextField(
                  controller: _hwCtl,
                  maxLines: 3,
                  maxLength: 200,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Practice low block 100x. Submit a Chon-Ji M1 analysis.',
                  ),
                ),
                const SizedBox(height: 6),
                Text('Due date', style: TulTextStyles.small(color: palette.text2)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: palette.muted,
                    borderRadius: TulRadius.brLg,
                    border: Border.all(color: palette.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: Text('2026-05-18', style: TulTextStyles.body(color: palette.text))),
                      Icon(LucideIcons.calendar, size: 16, color: palette.text3),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                TulPrimaryButton(
                  label: 'Assign to all students',
                  icon: LucideIcons.plus,
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // Students header
          Row(
            children: [
              Expanded(
                child: Text('Students (28)', style: TulTextStyles.cardHeader(color: palette.text)),
              ),
              FilterChipsRow(
                options: const ['All', 'Idle'],
                selected: _filter,
                onSelect: (v) => setState(() => _filter = v),
              ),
            ],
          ),

          // Students list
          TulStack.sm(children: [
            for (final s in _students)
              _StudentRow(
                name: s.$1,
                belt: s.$2,
                lastActive: s.$3,
                beltColor: s.$4,
                alert: s.$5,
                onTap: () => context.go('/tab3/student/${s.$1.replaceAll(' ', '-')}'),
              ),
          ]),
        ],
      ),
    );
  }
}

class _StudentRow extends StatelessWidget {
  const _StudentRow({
    required this.name,
    required this.belt,
    required this.lastActive,
    required this.beltColor,
    required this.alert,
    required this.onTap,
  });

  final String name;
  final String belt;
  final String lastActive;
  final TulBadgeColor beltColor;
  final bool alert;
  final VoidCallback onTap;

  String get _initials =>
      name.split(' ').map((p) => p.isEmpty ? '' : p[0]).join();

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    return TulCard(
      padding: const EdgeInsets.all(12),
      onTap: onTap,
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: TulGradients.brandSoft,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Text(
                  _initials,
                  style: TulTextStyles.bodyStrong(color: palette.text),
                ),
              ),
              if (alert)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: palette.primary,
                      border: Border.all(color: palette.stage, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TulTextStyles.bodyStrong(color: palette.text)),
                const SizedBox(height: 2),
                Text(lastActive, style: TulTextStyles.tiny(color: palette.text3)),
              ],
            ),
          ),
          TulBadge(label: belt, color: beltColor),
        ],
      ),
    );
  }
}

class _IconChip extends StatelessWidget {
  const _IconChip({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    return Material(
      color: palette.card,
      borderRadius: TulRadius.brMd,
      child: InkWell(
        onTap: onTap,
        borderRadius: TulRadius.brMd,
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: TulRadius.brMd,
            border: Border.all(color: palette.border),
          ),
          child: Icon(icon, size: 16, color: palette.text),
        ),
      ),
    );
  }
}

class _MiniButton extends StatelessWidget {
  const _MiniButton({required this.icon, this.label, required this.onTap});

  final IconData icon;
  final String? label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    return Material(
      color: palette.card,
      borderRadius: TulRadius.brMd,
      child: InkWell(
        onTap: onTap,
        borderRadius: TulRadius.brMd,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: TulRadius.brMd,
            border: Border.all(color: palette.borderStrong),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: palette.text),
              if (label != null) ...[
                const SizedBox(width: 6),
                Text(label!, style: TulTextStyles.small(color: palette.text)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
