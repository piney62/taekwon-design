import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/backend_client.dart';
import '../../../../core/theme/app_colors.dart';

// 수련생 본인의 미완 숙제 목록 provider
final myHomeworkProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>(
  (ref) => ref.watch(backendClientProvider).getMyHomework(),
);

class HomeworkBanner extends ConsumerWidget {
  const HomeworkBanner({
    super.key,
    required this.instructorName,
    required this.homeworkText,
  });

  final String instructorName;
  final String homeworkText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeworkAsync = ref.watch(myHomeworkProvider);

    return homeworkAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (list) {
        if (list.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 2, bottom: 6),
                child: Row(
                  children: [
                    Icon(Icons.assignment_outlined,
                        size: 16, color: AppColors.info),
                    const SizedBox(width: 6),
                    Text(
                      'journal.hwBannerTitle'.tr(namedArgs: {'name': instructorName, 'count': list.length.toString()}),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppColors.info,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
              ...list.map((hw) => _HomeworkItem(
                    hw: hw,
                    onComplete: () async {
                      await ref
                          .read(backendClientProvider)
                          .completeHomework(hw['id'] as int);
                      ref.invalidate(myHomeworkProvider);
                    },
                  )),
            ],
          ),
        );
      },
    );
  }
}

class _HomeworkItem extends StatefulWidget {
  const _HomeworkItem({required this.hw, required this.onComplete});
  final Map<String, dynamic> hw;
  final Future<void> Function() onComplete;

  @override
  State<_HomeworkItem> createState() => _HomeworkItemState();
}

class _HomeworkItemState extends State<_HomeworkItem> {
  bool _isCompleting = false;

  String _formatDue(String? raw) {
    if (raw == null) return '';
    try {
      final dt = DateTime.parse(raw);
      return 'dojo.dueDateFmt'.tr(namedArgs: {'month': dt.month.toString(), 'day': dt.day.toString()});
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = widget.hw['content'] as String? ?? '';
    final dueStr = _formatDue(widget.hw['due_date'] as String?);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.check_box_outline_blank,
              size: 18, color: AppColors.info),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(content,
                    style: Theme.of(context).textTheme.bodySmall),
                if (dueStr.isNotEmpty)
                  Text(dueStr,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          )),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _isCompleting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.success,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text('journal.hwCompleteTitle'.tr()),
                        content: Text('journal.hwCompleteConfirm'.tr(namedArgs: {'content': content})),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text('journal.cancel'.tr()),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text('dojo.complete'.tr()),
                          ),
                        ],
                      ),
                    );
                    if (ok != true) return;
                    setState(() => _isCompleting = true);
                    try {
                      await widget.onComplete();
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString())),
                        );
                      }
                    } finally {
                      if (mounted) setState(() => _isCompleting = false);
                    }
                  },
                  child: Text('dojo.complete'.tr()),
                ),
        ],
      ),
    );
  }
}
