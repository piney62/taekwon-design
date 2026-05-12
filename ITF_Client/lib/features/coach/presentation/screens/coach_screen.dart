import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/tul_gradients.dart';
import '../../../../core/theme/tul_palette.dart';
import '../../../../core/theme/tul_radius.dart';
import '../../../../shared/widgets/tul_app_bar.dart';
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
    final palette = context.tul;
    final coachState = ref.watch(coachControllerProvider);

    ref.listen(coachControllerProvider, (prev, next) {
      if (prev?.messages.length != next.messages.length) _scrollToEnd();
    });

    return Scaffold(
      backgroundColor: palette.stage,
      body: SafeArea(
        child: Column(
          children: [
            TulAppBar(
              title: 'coach.title'.tr(),
              onBack: Navigator.canPop(context)
                  ? () => Navigator.pop(context)
                  : null,
              action: coachState.messages.isNotEmpty
                  ? _ClearChip(
                      onClear: () =>
                          ref.read(coachControllerProvider.notifier).clear(),
                    )
                  : null,
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

// ── Clear chip ──────────────────────────────────────────────────────────────────

class _ClearChip extends StatelessWidget {
  const _ClearChip({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    return Tooltip(
      message: 'coach.clearChat'.tr(),
      child: Material(
        color: palette.card,
        borderRadius: TulRadius.brMd,
        child: InkWell(
          onTap: onClear,
          borderRadius: TulRadius.brMd,
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: TulRadius.brMd,
              border: Border.all(color: palette.border),
            ),
            child: Icon(LucideIcons.trash2, size: 16, color: palette.text2),
          ),
        ),
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
    final palette = context.tul;
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
                      gradient: TulGradients.brandSoft,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: palette.primary.withValues(alpha: 0.2)),
                    ),
                    child: Icon(Icons.chat_rounded,
                        size: 34, color: palette.primary),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'coach.welcomeMessage'.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: palette.text2,
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
    final palette = context.tul;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, right: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: palette.card,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
              ),
              border: Border.all(color: palette.border),
            ),
            child: SizedBox(
              width: 32,
              height: 14,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _Dot(color: palette.text3),
                  _Dot(color: palette.text3),
                  _Dot(color: palette.text3),
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
  const _Dot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
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
    final palette = context.tul;
    return Container(
      width: double.infinity,
      color: palette.primary.withValues(alpha: 0.15),
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: palette.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 13, color: palette.text),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: onDismiss,
            color: palette.text2,
          ),
        ],
      ),
    );
  }
}
