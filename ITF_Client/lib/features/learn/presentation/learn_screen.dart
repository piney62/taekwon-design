import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/grad_header_text.dart';
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
    final filtered = _filtered;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildSearch()),
            SliverToBoxAdapter(child: _buildCurrentCard()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: Text(
                  'learn.allPatterns'.tr(
                      namedArgs: {'count': itfPatterns.length.toString()}),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
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
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
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
            style:
                const TextStyle(fontSize: 14, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: TextField(
          controller: _searchCtrl,
          onChanged: (v) => setState(() => _query = v),
          style: const TextStyle(color: AppColors.text, fontSize: 14),
          decoration: const InputDecoration(
            hintText: 'Search patterns...',
            hintStyle:
                TextStyle(color: AppColors.textDisabled, fontSize: 14),
            prefixIcon: Icon(Icons.search_rounded,
                size: 20, color: AppColors.textDisabled),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentCard() {
    final p = itfPatterns[0];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.gradMain,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.menu_book_rounded,
                    size: 16, color: Colors.white70),
                const SizedBox(width: 6),
                Text(
                  'learn.currentPattern'.tr(),
                  style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                      letterSpacing: 0.5),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '${p.name} (${p.korean})',
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              '${p.moves} movements · White Belt',
              style: const TextStyle(fontSize: 13, color: Colors.white70),
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: const LinearProgressIndicator(
                value: 0.65,
                backgroundColor: Colors.white24,
                color: Colors.white,
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _openDetail(p, 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'learn.studyNow'.tr(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _openDetail(p, 1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'learn.details'.tr(),
                      style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReference() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'learn.itfReference'.tr(),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 12),
            _RefRow(
              icon: Icons.menu_book_rounded,
              iconColor: AppColors.primary,
              title: 'learn.terminology'.tr(),
              sub: 'learn.terminologyDesc'.tr(),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                    builder: (_) => const TerminologyPage()),
              ),
            ),
            _RefRow(
              icon: Icons.star_rounded,
              iconColor: AppColors.secondary,
              title: 'learn.fiveSpirits'.tr(),
              sub: 'learn.fiveSpiritsDesc'.tr(),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                    builder: (_) => const FiveTenetsPage()),
              ),
            ),
            _RefRow(
              icon: Icons.history_edu_rounded,
              iconColor: AppColors.accent,
              title: 'learn.history'.tr(),
              sub: 'learn.historyDesc'.tr(),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (_) => const HistoryPage()),
              ),
            ),
            _RefRow(
              icon: Icons.chat_rounded,
              iconColor: AppColors.primary,
              title: 'learn.aiCoach'.tr(),
              sub: 'learn.aiCoachDesc'.tr(),
              onTap: () => context.push(AppRoutes.coach),
              isLast: true,
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Opacity(
        opacity: unlocked ? 1.0 : 0.55,
        child: GestureDetector(
          onTap: unlocked ? onTap : null,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isCurrent
                    ? AppColors.primary.withValues(alpha: 0.3)
                    : AppColors.border,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: isCurrent
                        ? AppColors.gradMain
                        : unlocked
                            ? AppColors.gradSoft
                            : null,
                    color: unlocked ? null : AppColors.muted,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: unlocked
                      ? Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isCurrent
                                  ? Colors.white
                                  : AppColors.text,
                            ),
                          ),
                        )
                      : const Icon(Icons.lock_rounded,
                          size: 16, color: AppColors.textDisabled),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: pattern.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.text,
                              ),
                            ),
                            TextSpan(
                              text: ' (${pattern.korean})',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textDisabled,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${pattern.moves} movements · ${pattern.beltEn}',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right,
                    size: 16, color: AppColors.textDisabled),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Reference row ──────────────────────────────────────────────────────────────

class _RefRow extends StatelessWidget {
  const _RefRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.sub,
    required this.onTap,
    this.isLast = false,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String sub;
  final VoidCallback onTap;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: iconColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text),
                      ),
                      Text(
                        sub,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right,
                    size: 16, color: AppColors.textDisabled),
              ],
            ),
          ),
        ),
        if (!isLast) Divider(height: 1, color: AppColors.border),
      ],
    );
  }
}
