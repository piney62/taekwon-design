import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/training_session.dart';
import '../../domain/entities/training_type.dart';

class SessionCard extends StatelessWidget {
  const SessionCard({
    super.key,
    required this.session,
    required this.onEdit,
    required this.onDelete,
  });

  final TrainingSession session;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final dateStr =
        DateFormat('MM/dd (E)', locale == 'ko' ? 'ko' : locale)
            .format(session.date);

    final typeColor = _typeColor(session.type);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(14, 13, 6, 13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _typeIcon(session.type),
              color: typeColor,
              size: 22,
            ),
          ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row: type name + save badge
                  Row(
                    children: [
                      Text(
                        session.type.i18nKey.tr(),
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      if (session.patternName.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        Text(
                          '· ${session.patternName}',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: AppColors.itfRed,
                                  ),
                        ),
                      ],
                      const SizedBox(width: 6),
                      session.isAutoSaved
                          ? _Badge(
                              label: 'journal.autoSavedBadge'.tr(),
                              isAuto: true,
                            )
                          : _Badge(label: 'journal.manualBadge'.tr()),
                    ],
                  ),
                  const SizedBox(height: 3),
                  // Date + duration
                  Text(
                    '$dateStr · ${session.durationMinutes}${'journal.min'.tr()}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 5),
                  // Stars
                  _StarRow(score: session.score),
                  // Notes
                  if (session.notes.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      session.notes,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                  // Instructor comment (dojo mode)
                  if (session.instructorComment.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    _InstructorComment(comment: session.instructorComment),
                  ],
                ],
              ),
            ),
            // Edit button
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 18),
              color: AppColors.textDisabled,
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
              onPressed: onEdit,
            ),
            // Delete button
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18),
              color: AppColors.textDisabled,
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text('journal.deleteConfirmTitle'.tr()),
                    content: Text('journal.deleteConfirmBody'.tr()),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text('journal.cancel'.tr()),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                            foregroundColor: AppColors.itfRed),
                        onPressed: () => Navigator.pop(ctx, true),
                        child: Text('journal.delete'.tr()),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) onDelete();
              },
            ),
          ],
        ),
    );
  }

  IconData _typeIcon(TrainingType type) => switch (type) {
        TrainingType.pattern => Icons.auto_awesome_motion,
        TrainingType.sparring => Icons.sports_martial_arts,
        TrainingType.kicks => Icons.directions_run,
        TrainingType.punches => Icons.sports_kabaddi,
        TrainingType.fitness => Icons.fitness_center,
        TrainingType.other => Icons.sports,
      };

  Color _typeColor(TrainingType type) => switch (type) {
        TrainingType.pattern => AppColors.primary,
        TrainingType.sparring => AppColors.secondary,
        TrainingType.kicks => AppColors.accent,
        TrainingType.punches => AppColors.warning,
        TrainingType.fitness => AppColors.success,
        TrainingType.other => AppColors.textSecondary,
      };
}

// ── Instructor comment bubble ─────────────────────────────────────────────────

class _InstructorComment extends StatelessWidget {
  const _InstructorComment({required this.comment});
  final String comment;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.chat_bubble_outline,
              size: 13, color: AppColors.success),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'journal.instructorCommentFmt'.tr(namedArgs: {'comment': comment}),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.success,
                    fontSize: 11,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Star row ──────────────────────────────────────────────────────────────────

class _StarRow extends StatelessWidget {
  const _StarRow({required this.score});
  final int score;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < score;
        return Icon(
          filled ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 15,
          color: filled ? AppColors.warning : AppColors.textDisabled,
        );
      }),
    );
  }
}

// ── Badge ─────────────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  const _Badge({required this.label, this.isAuto = false});
  final String label;
  final bool isAuto;

  @override
  Widget build(BuildContext context) {
    final color = isAuto ? AppColors.info : AppColors.textDisabled;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontSize: 10,
            ),
      ),
    );
  }
}
