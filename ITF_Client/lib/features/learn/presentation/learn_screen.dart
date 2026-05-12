import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/tul_gradients.dart';
import '../../../core/theme/tul_palette.dart';
import '../../../core/theme/tul_text_styles.dart';
import '../../../shared/widgets/app_shell.dart' show kAppShellContentBottomInset;
import '../../../shared/widgets/feature_card.dart';
import '../../../shared/widgets/grad_header_text.dart';
import '../../../shared/widgets/list_row.dart';
import '../../../shared/widgets/tul_card.dart';
import '../domain/entities/pattern.dart';
import 'pages/five_tenets_page.dart';
import 'pages/history_page.dart';
import 'pages/terminology_page.dart';
import 'screens/pattern_detail_screen.dart';

// Hardcoded for now — connect to user profile belt level provider when ready
bool _isUnlocked(int idx) => idx < 5;

class LearnScreen extends ConsumerStatefulWidget {
  const LearnScreen({super.key});

  @override
  ConsumerState<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends ConsumerState<LearnScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<(int, ItfPattern)> get _filtered {
    final q = _query.toLowerCase();
    return itfPatterns
        .asMap()
        .entries
        .where((e) =>
            q.isEmpty ||
            e.value.name.toLowerCase().contains(q) ||
            e.value.korean.contains(q))
        .map((e) => (e.key, e.value))
        .toList();
  }

  void _openDetail(ItfPattern p, int index) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => PatternDetailScreen(pattern: p, index: index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    final filtered = _filtered;
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildSearch(palette)),
            SliverToBoxAdapter(child: _buildCurrentCard()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: Text(
                  'learn.allPatterns'.tr(
                      namedArgs: {'count': itfPatterns.length.toString()}),
                  style: TulTextStyles.cardHeader(color: palette.text),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final idx = filtered[i].$1;
                  final p = filtered[i].$2;
                  return _PatternRow(
                    index: idx,
                    pattern: p,
                    unlocked: _isUnlocked(idx),
                    isCurrent: idx == 0,
                    onTap: () => _openDetail(p, idx + 1),
                  );
                },
                childCount: filtered.length,
              ),
            ),
            SliverToBoxAdapter(child: _buildReference()),
            const SliverToBoxAdapter(
              child: SizedBox(height: kAppShellContentBottomInset),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GradHeaderText('learn.patternsTitle'.tr()),
          const SizedBox(height: 6),
          Text(
            'learn.patternsSubtitle'.tr(),
            style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch(TulPalette palette) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Container(
        decoration: BoxDecoration(
          color: palette.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: palette.border),
        ),
        child: TextField(
          controller: _searchCtrl,
          onChanged: (v) => setState(() => _query = v),
          style: TextStyle(color: palette.text, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'learn.searchHint'.tr(),
            hintStyle: TextStyle(color: palette.text3, fontSize: 14),
            prefixIcon:
                Icon(LucideIcons.search, size: 18, color: palette.text3),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentCard() {
    final p = itfPatterns[0];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: FeatureCard(
        icon: LucideIcons.book,
        label: 'learn.currentPattern'.tr(),
        title: '${p.name} (${p.korean})',
        body: '${'learn.movesCount'.tr(namedArgs: {'count': '${p.moves}'})} · ${'belt.white'.tr()}',
        progress: 65,
        primaryLabel: 'learn.studyNow'.tr(),
        secondaryLabel: 'learn.details'.tr(),
        onPrimary: () => _openDetail(p, 1),
        onSecondary: () => _openDetail(p, 1),
      ),
    );
  }

  Widget _buildReference() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: TulCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'learn.itfReference'.tr(),
              style: TulTextStyles.cardHeader(color: context.tul.text),
            ),
            const SizedBox(height: 4),
            ListRow(
              icon: LucideIcons.library,
              iconColor: ListRowColor.primary,
              title: 'learn.terminology'.tr(),
              sub: 'learn.terminologyDesc'.tr(),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                    builder: (_) => const TerminologyPage()),
              ),
            ),
            ListRow(
              icon: LucideIcons.award,
              iconColor: ListRowColor.secondary,
              title: 'learn.fiveSpirits'.tr(),
              sub: 'learn.fiveSpiritsDesc'.tr(),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                    builder: (_) => const FiveTenetsPage()),
              ),
            ),
            ListRow(
              icon: LucideIcons.bookOpen,
              iconColor: ListRowColor.accent,
              title: 'learn.history'.tr(),
              sub: 'learn.historyDesc'.tr(),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (_) => const HistoryPage()),
              ),
            ),
            ListRow(
              icon: LucideIcons.messageCircle,
              iconColor: ListRowColor.primary,
              title: 'learn.aiCoach'.tr(),
              sub: 'learn.aiCoachDesc'.tr(),
              onTap: () => context.push(AppRoutes.coach),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Pattern row ────────────────────────────────────────────────────────────────

class _PatternRow extends StatelessWidget {
  const _PatternRow({
    required this.index,
    required this.pattern,
    required this.unlocked,
    required this.isCurrent,
    required this.onTap,
  });

  final int index;
  final ItfPattern pattern;
  final bool unlocked;
  final bool isCurrent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Opacity(
        opacity: unlocked ? 1.0 : 0.55,
        child: TulCard(
          padding: const EdgeInsets.all(12),
          onTap: unlocked ? onTap : null,
          borderColor:
              isCurrent ? palette.primary.withValues(alpha: 0.3) : null,
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: isCurrent
                      ? TulGradients.brand
                      : unlocked
                          ? TulGradients.brandSoft
                          : null,
                  color: unlocked ? null : palette.muted,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: unlocked
                    ? Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isCurrent ? Colors.white : palette.text,
                        ),
                      )
                    : Icon(LucideIcons.lock, size: 16, color: palette.text3),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        text: pattern.name,
                        style: TulTextStyles.bodyStrong(color: palette.text),
                        children: [
                          TextSpan(
                            text: '  (${pattern.korean})',
                            style: TulTextStyles.body(color: palette.text3),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${pattern.moves} movements · ${pattern.beltEn}',
                      style: TulTextStyles.tiny(color: palette.text3),
                    ),
                  ],
                ),
              ),
              Icon(LucideIcons.chevronRight, size: 16, color: palette.text3),
            ],
          ),
        ),
      ),
    );
  }
}
