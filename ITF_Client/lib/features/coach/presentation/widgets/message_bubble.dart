import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/tul_gradients.dart';
import '../../../../core/theme/tul_palette.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chat_role.dart';

class MessageBubble extends StatefulWidget {
  const MessageBubble({
    super.key,
    required this.message,
    this.onDeletePair,
  });

  final ChatMessage message;
  final VoidCallback? onDeletePair;

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  bool _hovered = false;

  void _confirmDelete() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('coach.deletePairTitle'.tr()),
        content: Text('coach.deletePairContent'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('journal.cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.onDeletePair!();
            },
            style: TextButton.styleFrom(
                foregroundColor: context.tul.primary),
            child: Text('journal.delete'.tr()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.tul;
    final isUser = widget.message.role == ChatRole.user;

    const userRadius = BorderRadius.only(
      topLeft: Radius.circular(18),
      topRight: Radius.circular(18),
      bottomLeft: Radius.circular(18),
      bottomRight: Radius.circular(4),
    );
    const aiRadius = BorderRadius.only(
      topLeft: Radius.circular(18),
      topRight: Radius.circular(18),
      bottomLeft: Radius.circular(4),
      bottomRight: Radius.circular(18),
    );

    Widget bubble;
    if (isUser) {
      bubble = GestureDetector(
        onLongPress: widget.onDeletePair == null ? null : _confirmDelete,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: const BoxDecoration(
            gradient: TulGradients.brand,
            borderRadius: userRadius,
          ),
          child: Text(
            widget.message.content,
            style: const TextStyle(
                color: Colors.white, fontSize: 14, height: 1.45),
          ),
        ),
      );
    } else {
      bubble = GestureDetector(
        onLongPress: widget.onDeletePair == null ? null : _confirmDelete,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: palette.card,
            borderRadius: aiRadius,
            border: Border.all(color: palette.border),
          ),
          child: Text(
            widget.message.content,
            style: TextStyle(
                color: palette.text, fontSize: 14, height: 1.45),
          ),
        ),
      );
    }

    final deleteBtn = widget.onDeletePair == null
        ? null
        : AnimatedOpacity(
            opacity: _hovered ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 150),
            child: IconButton(
              onPressed: _confirmDelete,
              icon: const Icon(Icons.delete_outline, size: 18),
              color: palette.text3,
              tooltip: 'coach.deletePairTooltip'.tr(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            ),
          );

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: 8,
          left: isUser ? 48 : 0,
          right: isUser ? 0 : 48,
        ),
        child: Row(
          mainAxisAlignment:
              isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: isUser
              ? [
                  ?deleteBtn,
                  const SizedBox(width: 4),
                  Flexible(child: bubble),
                ]
              : [
                  Flexible(child: bubble),
                  const SizedBox(width: 4),
                  ?deleteBtn,
                ],
        ),
      ),
    );
  }
}
