import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../application/providers.dart';
import '../../domain/entities/training_session.dart';
import '../widgets/add_session_sheet.dart';
import '../widgets/session_card.dart';

const _pageSize = 10;

class AllSessionsScreen extends ConsumerStatefulWidget {
  const AllSessionsScreen({super.key, this.showWeaknesses = false});

  final bool showWeaknesses;

  @override
  ConsumerState<AllSessionsScreen> createState() => _AllSessionsScreenState();
}

class _AllSessionsScreenState extends ConsumerState<AllSessionsScreen> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(journalControllerProvider);
    final allSessions = state.sessions;
    final totalCount = allSessions.length;
    final totalPages = (totalCount / _pageSize).ceil().clamp(1, 999);

    if (_currentPage >= totalPages) {
      _currentPage = (totalPages - 1).clamp(0, 999);
    }

    final pageStart = _currentPage * _pageSize;
    final pageEnd = (pageStart + _pageSize).clamp(0, totalCount);
    final pageSessions = allSessions.sublist(pageStart, pageEnd);

    return Scaffold(
      appBar: AppBar(
        title: Text('journal.allSessions'.tr()),
        actions: [
          if (totalCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  'journal.totalSessionsFmt'.tr(namedArgs: {'count': totalCount.toString()}),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ),
            ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(journalControllerProvider);
                setState(() => _currentPage = 0);
              },
              child: allSessions.isEmpty
                  ? Center(
                      child: Text(
                        'journal.noSessionsYet'.tr(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                      children: [
                        ...pageSessions.map(
                          (s) => SessionCard(
                            session: s,
                            onEdit: () => _editSession(s),
                            onDelete: () => ref
                                .read(journalControllerProvider.notifier)
                                .deleteSession(s.id),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _PaginationBar(
                          currentPage: _currentPage,
                          totalPages: totalPages,
                          pageStart: pageStart,
                          pageEnd: pageEnd,
                          totalCount: totalCount,
                          onPrev: _currentPage > 0
                              ? () => setState(() => _currentPage--)
                              : null,
                          onNext: _currentPage < totalPages - 1
                              ? () => setState(() => _currentPage++)
                              : null,
                        ),
                      ],
                    ),
            ),
    );
  }

  Future<void> _addSession() async {
    final session = await showModalBottomSheet<TrainingSession>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const AddSessionSheet(),
    );
    if (session != null) {
      await ref.read(journalControllerProvider.notifier).addSession(session);
      setState(() => _currentPage = 0);
    }
  }

  Future<void> _editSession(TrainingSession existing) async {
    final session = await showModalBottomSheet<TrainingSession>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddSessionSheet(existing: existing),
    );
    if (session != null) {
      await ref.read(journalControllerProvider.notifier).updateSession(session);
    }
  }
}

// ── Pagination bar ────────────────────────────────────────────────────────────

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({
    required this.currentPage,
    required this.totalPages,
    required this.pageStart,
    required this.pageEnd,
    required this.totalCount,
    required this.onPrev,
    required this.onNext,
  });

  final int currentPage;
  final int totalPages;
  final int pageStart;
  final int pageEnd;
  final int totalCount;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: onPrev,
          color: onPrev != null ? AppColors.itfRed : AppColors.textDisabled,
        ),
        const SizedBox(width: 8),
        Column(
          children: [
            Text(
              '${currentPage + 1} / $totalPages',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              '${pageStart + 1}–$pageEnd / $totalCount',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: onNext,
          color: onNext != null ? AppColors.itfRed : AppColors.textDisabled,
        ),
      ],
    );
  }
}
