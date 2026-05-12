import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/backend_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/tul_gradients.dart';
import '../../../core/theme/tul_text_styles.dart';
import '../../../shared/widgets/app_shell.dart';
import '../../../shared/widgets/badge.dart';
import '../../../shared/widgets/tul_buttons.dart';
import '../../../shared/widgets/tul_card.dart';
import '../application/dojo_providers.dart';

// ignore_for_file: avoid_dynamic_calls

class StudentDetailScreen extends ConsumerStatefulWidget {
  const StudentDetailScreen({super.key, required this.studentId});

  final int studentId;

  @override
  ConsumerState<StudentDetailScreen> createState() =>
      _StudentDetailScreenState();
}

class _StudentDetailScreenState extends ConsumerState<StudentDetailScreen> {
  final _commentCtrl = TextEditingController();
  bool _isSendingComment = false;
  bool _isAddingHomework = false;
  final _homeworkCtrl = TextEditingController();
  DateTime? _homeworkDue;

  @override
  void dispose() {
    _commentCtrl.dispose();
    _homeworkCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendComment() async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _isSendingComment = true);
    try {
      await ref.read(backendClientProvider).createComment(widget.studentId, text);
      _commentCtrl.clear();
      ref.invalidate(commentsProvider(widget.studentId));
      ref.invalidate(memberDetailProvider(widget.studentId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isSendingComment = false);
    }
  }

  Future<void> _addHomework() async {
    final text = _homeworkCtrl.text.trim();
    if (text.isEmpty || _homeworkDue == null) return;
    setState(() => _isAddingHomework = true);
    try {
      await ref.read(backendClientProvider).createHomework(
            widget.studentId,
            text,
            _homeworkDue!,
          );
      _homeworkCtrl.clear();
      setState(() => _homeworkDue = null);
      ref.invalidate(memberDetailProvider(widget.studentId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('dojo.homeworkAssigned'.tr())),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isAddingHomework = false);
    }
  }

  Future<void> _completeHomework(int homeworkId) async {
    try {
      await ref.read(backendClientProvider).completeHomework(homeworkId);
      ref.invalidate(memberDetailProvider(widget.studentId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(memberDetailProvider(widget.studentId));
    final commentsAsync = ref.watch(commentsProvider(widget.studentId));
    final journalAsync = ref.watch(studentJournalProvider(widget.studentId));

    return Scaffold(
      appBar: AppBar(
        title: detailAsync.when(
          data: (d) => Text(d['display_name'] as String? ?? ''),
          loading: () => const Text(''),
          error: (_, __) => const Text(''),
        ),
      ),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${'common.error'.tr()}: $e')),
        data: (detail) => DefaultTabController(
          length: 3,
          child: Column(
            children: [
              _StudentHeader(detail: detail),
              TabBar(tabs: [
                Tab(text: 'dojo.tabTraining'.tr()),
                Tab(text: 'dojo.tabComment'.tr()),
                Tab(text: 'dojo.tabHomework'.tr()),
              ]),
              Expanded(
                child: TabBarView(children: [
                  // ── 훈련현황 탭 ───────────────────────────────────────
                  _JournalTab(journalAsync: journalAsync),
                  // ── 코멘트 탭 ─────────────────────────────────────────
                  _CommentsTab(
                    commentsAsync: commentsAsync,
                    commentCtrl: _commentCtrl,
                    isSending: _isSendingComment,
                    onSend: _sendComment,
                    onDelete: (id) async {
                      await ref.read(backendClientProvider).deleteComment(id);
                      ref.invalidate(commentsProvider(widget.studentId));
                    },
                  ),
                  // ── 숙제 탭 ───────────────────────────────────────────
                  _HomeworkTab(
                    detail: detail,
                    homeworkCtrl: _homeworkCtrl,
                    homeworkDue: _homeworkDue,
                    isAdding: _isAddingHomework,
                    onPickDate: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate:
                            DateTime.now().add(const Duration(days: 3)),
                        firstDate: DateTime.now(),
                        lastDate:
                            DateTime.now().add(const Duration(days: 90)),
                      );
                      if (picked != null) {
                        setState(() => _homeworkDue = picked);
                      }
                    },
                    onAdd: _addHomework,
                    onComplete: _completeHomework,
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 학생 요약 헤더 ─────────────────────────────────────────────────────────────

class _StudentHeader extends StatelessWidget {
  const _StudentHeader({required this.detail});
  final Map<String, dynamic> detail;

  @override
  Widget build(BuildContext context) {
    final belt = detail['belt_level'] as String? ?? '';
    final connectedAt = detail['connected_at'] as String? ?? '';
    final pendingCount = detail['pending_homework_count'] as int? ?? 0;

    final beltLabel = 'belt.${belt.isEmpty ? 'white' : belt}'.tr();

    String connectedStr = '';
    try {
      final dt = DateTime.parse(connectedAt);
      connectedStr =
          '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {}

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: TulCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: TulGradients.brandSoft,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                (detail['display_name'] as String? ?? '?')[0].toUpperCase(),
                style: TulTextStyles.h2(color: Colors.white),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    detail['display_name'] as String? ?? '',
                    style: TulTextStyles.bodyStrong(color: AppColors.text),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'dojo.connectedBelt'.tr(namedArgs: {'belt': beltLabel, 'date': connectedStr}),
                    style: TulTextStyles.small(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            if (pendingCount > 0)
              TulBadge(
                label: 'dojo.pendingHwBadge'.tr(namedArgs: {'count': pendingCount.toString()}),
                color: TulBadgeColor.yellow,
              ),
          ],
        ),
      ),
    );
  }
}

// ── 코멘트 탭 ─────────────────────────────────────────────────────────────────

class _CommentsTab extends StatelessWidget {
  const _CommentsTab({
    required this.commentsAsync,
    required this.commentCtrl,
    required this.isSending,
    required this.onSend,
    required this.onDelete,
  });

  final AsyncValue<List<Map<String, dynamic>>> commentsAsync;
  final TextEditingController commentCtrl;
  final bool isSending;
  final VoidCallback onSend;
  final Future<void> Function(int) onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: commentsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('${'common.error'.tr()}: $e')),
            data: (comments) => comments.isEmpty
                ? Center(
                    child: Text(
                      'dojo.noComments'.tr(),
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: comments.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final c = comments[i];
                      final createdAt = c['created_at'] as String? ?? '';
                      String dateStr = '';
                      try {
                        final dt = DateTime.parse(createdAt).toLocal();
                        dateStr =
                            '${dt.month}/${dt.day} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
                      } catch (_) {}
                      return TulCard(
                        background: AppColors.info.withValues(alpha: 0.08),
                        borderColor: AppColors.info.withValues(alpha: 0.2),
                        padding: const EdgeInsets.all(12),
                        borderRadius: BorderRadius.circular(10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.chat_bubble_outline,
                                size: 16, color: AppColors.info),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    c['content'] as String? ?? '',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    dateStr,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                            color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  size: 18, color: AppColors.textSecondary),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => onDelete(c['id'] as int),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ),
        // ── 코멘트 입력 ──────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, kAppShellContentBottomInset),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              top: BorderSide(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.5)),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: commentCtrl,
                  maxLength: 500,
                  maxLines: 3,
                  minLines: 1,
                  decoration: InputDecoration(
                    hintText: 'dojo.commentHint'.tr(),
                    border: const OutlineInputBorder(),
                    isDense: true,
                    counterText: '',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: isSending ? null : onSend,
                icon: isSending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── 훈련현황 탭 ────────────────────────────────────────────────────────────────

class _JournalTab extends StatelessWidget {
  const _JournalTab({required this.journalAsync});
  final AsyncValue<Map<String, dynamic>> journalAsync;

  @override
  Widget build(BuildContext context) {
    return journalAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('${'common.error'.tr()}: $e')),
      data: (journal) {
        final sessions =
            (journal['sessions'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        final weaknesses =
            (journal['weaknesses'] as List?)?.cast<Map<String, dynamic>>() ??
                [];
        final readiness =
            journal['readiness'] as Map<String, dynamic>? ?? {};

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, kAppShellContentBottomInset),
          children: [
            // ── 승급 준비 ───────────────────────────────────────────────
            Text('dojo.readinessTitle'.tr(),
                style: TulTextStyles.cardHeader(color: AppColors.text)),
            const SizedBox(height: 8),
            TulCard(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  _ReadinessRow(
                    label: 'dojo.sparring'.tr(),
                    checked: readiness['sparring_check'] as bool? ?? false,
                  ),
                  _ReadinessRow(
                    label: 'dojo.breaking'.tr(),
                    checked: readiness['breaking_check'] as bool? ?? false,
                  ),
                  _ReadinessRow(
                    label: 'dojo.theoryTest'.tr(),
                    checked:
                        readiness['theory_test_passed'] as bool? ?? false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── 약점 패턴 ───────────────────────────────────────────────
            if (weaknesses.isNotEmpty) ...[
              Text('dojo.weaknessFmt'.tr(namedArgs: {'count': weaknesses.length.toString()}),
                  style: TulTextStyles.cardHeader(color: AppColors.text)),
              const SizedBox(height: 8),
              ...weaknesses.map((w) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: TulCard(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_outlined,
                              color: AppColors.warning, size: 20),
                          const SizedBox(width: 10),
                          Expanded(child: Text(w['movement_name'] as String? ?? '')),
                          TulBadge(
                            label: '${w['consecutive_count']}${'stats.sessionsSuffix'.tr()}',
                            color: TulBadgeColor.yellow,
                          ),
                        ],
                      ),
                    ),
                  )),
              const SizedBox(height: 16),
            ],

            // ── 최근 훈련 기록 ──────────────────────────────────────────
            Text('dojo.recentSessionsTitle'.tr(),
                style: TulTextStyles.cardHeader(color: AppColors.text)),
            const SizedBox(height: 8),
            if (sessions.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text('dojo.noTrainingRecords'.tr(),
                      style: const TextStyle(color: AppColors.textSecondary)),
                ),
              )
            else
              ...sessions.map((s) {
                final dateStr = s['session_date'] as String? ?? '';
                final score = s['score'] as int? ?? 0;
                final type = s['training_type'] as String? ?? '';
                final mins = s['duration_minutes'] as int? ?? 0;
                final notes = s['notes'] as String? ?? '';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TulCard(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              dateStr,
                              style: TulTextStyles.small(color: AppColors.textSecondary),
                            ),
                            const Spacer(),
                            Text(type, style: TulTextStyles.smallStrong(color: AppColors.text)),
                            const SizedBox(width: 8),
                            Text('$mins${'journal.min'.tr()}',
                                style: TulTextStyles.small(color: AppColors.textSecondary)),
                            const SizedBox(width: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(
                                5,
                                (i) => Icon(
                                  i < score ? Icons.star : Icons.star_border,
                                  size: 14,
                                  color: AppColors.warning,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (notes.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(notes, style: TulTextStyles.small(color: AppColors.textSecondary)),
                        ],
                      ],
                    ),
                  ),
                );
              }),
          ],
        );
      },
    );
  }
}

class _ReadinessRow extends StatelessWidget {
  const _ReadinessRow({required this.label, required this.checked});
  final String label;
  final bool checked;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Icon(
        checked ? Icons.check_circle : Icons.radio_button_unchecked,
        color: checked ? AppColors.success : AppColors.textSecondary,
        size: 20,
      ),
      title: Text(label),
    );
  }
}

// ── 숙제 탭 ───────────────────────────────────────────────────────────────────

class _HomeworkTab extends StatelessWidget {
  const _HomeworkTab({
    required this.detail,
    required this.homeworkCtrl,
    required this.homeworkDue,
    required this.isAdding,
    required this.onPickDate,
    required this.onAdd,
    required this.onComplete,
  });

  final Map<String, dynamic> detail;
  final TextEditingController homeworkCtrl;
  final DateTime? homeworkDue;
  final bool isAdding;
  final VoidCallback onPickDate;
  final VoidCallback onAdd;
  final Future<void> Function(int) onComplete;

  @override
  Widget build(BuildContext context) {
    final pendingList = (detail['pending_homework'] as List?)
            ?.cast<Map<String, dynamic>>() ??
        [];
    final completedList = (detail['completed_homework'] as List?)
            ?.cast<Map<String, dynamic>>() ??
        [];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, kAppShellContentBottomInset),
      children: [
        // ── 현재 숙제 목록 ─────────────────────────────────────────────
        if (pendingList.isNotEmpty) ...[
          Text('dojo.pendingHwFmt'.tr(namedArgs: {'count': pendingList.length.toString()}),
              style: TulTextStyles.cardHeader(color: AppColors.text)),
          const SizedBox(height: 8),
          ...pendingList.map((hw) {
            final dueStr = hw['due_date'] as String? ?? '';
            String dueFmt = '';
            try {
              final dt = DateTime.parse(dueStr);
              dueFmt = 'dojo.dueDateFmt'.tr(namedArgs: {'month': dt.month.toString(), 'day': dt.day.toString()});
            } catch (_) {}
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TulCard(
                padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                child: Row(
                  children: [
                    const Icon(Icons.assignment_outlined, color: AppColors.info),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(hw['content'] as String? ?? '', style: TulTextStyles.bodyStrong(color: AppColors.text)),
                          if (dueFmt.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(dueFmt, style: TulTextStyles.small(color: AppColors.textSecondary)),
                          ],
                        ],
                      ),
                    ),
                    TulGhostButton(
                      label: 'dojo.complete'.tr(),
                      onPressed: () => onComplete(hw['id'] as int),
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            );
          }),
          const Divider(height: 24),
        ],

        // ── 완료된 숙제 이력 ───────────────────────────────────────────
        if (completedList.isNotEmpty) ...[
          Text('dojo.completedHwFmt'.tr(namedArgs: {'count': completedList.length.toString()}),
              style: TulTextStyles.cardHeader(color: AppColors.text)),
          const SizedBox(height: 8),
          ...completedList.map((hw) {
            final completedAt = hw['completed_at'] as String?;
            final completedBy = hw['completed_by'] as String? ?? '';
            String timeFmt = '';
            try {
              if (completedAt != null) {
                final dt = DateTime.parse(completedAt).toLocal();
                final diff = DateTime.now().difference(dt).inDays;
                timeFmt = diff == 0
                    ? 'common.today'.tr()
                    : diff == 1
                        ? 'common.yesterday'.tr()
                        : 'common.daysAgo'.tr(namedArgs: {'count': diff.toString()});
              }
            } catch (_) {}
            final byLabel = completedBy == 'student' ? 'dojo.completedByStudent'.tr() : 'dojo.completedByInstructor'.tr();
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TulCard(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, color: AppColors.success, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hw['content'] as String? ?? '',
                            style: TulTextStyles.body(color: AppColors.textSecondary).copyWith(
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$byLabel${timeFmt.isNotEmpty ? ' · $timeFmt' : ''}',
                            style: TulTextStyles.small(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const Divider(height: 24),
        ],

        // ── 새 숙제 지정 ───────────────────────────────────────────────
        Text('dojo.assignHomework'.tr(),
            style: TulTextStyles.cardHeader(color: AppColors.text)),
        const SizedBox(height: 8),
        TextField(
          controller: homeworkCtrl,
          maxLength: 200,
          maxLines: 3,
          minLines: 2,
          decoration: InputDecoration(
            hintText: 'dojo.homeworkHint'.tr(),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: onPickDate,
          icon: const Icon(Icons.calendar_today_outlined, size: 18),
          label: Text(
            homeworkDue != null
                ? 'dojo.dueDateSet'.tr(namedArgs: {'month': homeworkDue!.month.toString(), 'day': homeworkDue!.day.toString()})
                : 'dojo.selectDueDate'.tr(),
          ),
        ),
        const SizedBox(height: 12),
        TulPrimaryButton(
          label: pendingList.length >= 3 ? 'dojo.maxHomework'.tr() : 'dojo.assign'.tr(),
          onPressed: (isAdding || pendingList.length >= 3) ? null : onAdd,
        ),
      ],
    );
  }
}
