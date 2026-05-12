import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/grad_header_text.dart';
import '../../application/providers.dart';
import '../widgets/composer_bar.dart';
import '../widgets/message_bubble.dart';
import '../widgets/quick_questions.dart';

class CoachScreen extends ConsumerStatefulWidget {
  const CoachScreen({super.key});

  @override
  ConsumerState<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends ConsumerState<CoachScreen> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send(String text) async {
    await ref.read(coachControllerProvider.notifier).sendMessage(text);
    _scrollToEnd();
  }

  @override
  Widget build(BuildContext context) {
    final coachState = ref.watch(coachControllerProvider);

    ref.listen(coachControllerProvider, (prev, next) {
      if (prev?.messages.length != next.messages.length) _scrollToEnd();
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              hasMessages: coachState.messages.isNotEmpty,
              onClear: () =>
                  ref.read(coachControllerProvider.notifier).clear(),
            ),
            Expanded(
              child: coachState.messages.isEmpty
                  ? _EmptyState(onQuickTap: _send)
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      itemCount: coachState.messages.length +
                          (coachState.isReplying ? 1 : 0),
                      itemBuilder: (context, i) {
                        if (i >= coachState.messages.length) {
                          return const _TypingIndicator();
                        }
                        final msg = coachState.messages[i];
                        return MessageBubble(
                          message: msg,
                          onDeletePair: coachState.isReplying
                              ? null
                              : () => ref
                                  .read(coachControllerProvider.notifier)
                                  .deleteMessagePair(msg.id),
                        );
                      },
                    ),
            ),
            if (coachState.error != null)
              _ErrorBar(
                message: coachState.error!,
                onDismiss: () =>
                    ref.read(coachControllerProvider.notifier).dismissError(),
              ),
            ComposerBar(
              enabled: !coachState.isReplying,
              onSend: _send,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Top bar ────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.hasMessages, required this.onClear});

  final bool hasMessages;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          if (canPop)
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.chevron_left, size: 28),
              color: AppColors.text,
            )
          else
            const SizedBox(width: 8),
          GradHeaderText('coach.title'.tr(), fontSize: 20),
          const Spacer(),
          if (hasMessages)
            IconButton(
              tooltip: 'coach.clearChat'.tr(),
              onPressed: onClear,
              icon: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(Icons.delete_sweep_outlined,
                    size: 18, color: AppColors.textMuted),
              ),
              padding: EdgeInsets.zero,
            ),
        ],
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onQuickTap});
  final ValueChanged<String> onQuickTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: AppColors.gradSoft,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2)),
                    ),
                    child: const Icon(Icons.chat_rounded,
                        size: 34, color: AppColors.primary),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'coach.welcomeMessage'.tr(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textMuted,
                      height: 1.55,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        QuickQuestions(onTap: onQuickTap),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ── Typing indicator ───────────────────────────────────────────────────────────

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, right: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
              ),
              border: Border.all(color: AppColors.border),
            ),
            child: const SizedBox(
              width: 32,
              height: 14,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _Dot(),
                  _Dot(),
                  _Dot(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: const BoxDecoration(
          color: AppColors.textDisabled, shape: BoxShape.circle),
    );
  }
}

// ── Error bar ──────────────────────────────────────────────────────────────────

class _ErrorBar extends StatelessWidget {
  const _ErrorBar({required this.message, required this.onDismiss});

  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.primaryDeep.withValues(alpha: 0.3),
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.primaryLight),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.text),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: onDismiss,
            color: AppColors.textMuted,
          ),
        ],
      ),
    );
  }
}
