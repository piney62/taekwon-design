import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ComposerBar extends StatefulWidget {
  const ComposerBar({
    super.key,
    required this.enabled,
    required this.onSend,
  });

  final bool enabled;
  final void Function(String text) onSend;

  @override
  State<ComposerBar> createState() => _ComposerBarState();
}

class _ComposerBarState extends State<ComposerBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    widget.onSend(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  controller: _controller,
                  enabled: widget.enabled,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _submit(),
                  style: const TextStyle(
                      color: AppColors.text, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'coach.inputHint'.tr(),
                    hintStyle: const TextStyle(
                        color: AppColors.textDisabled, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: widget.enabled ? _submit : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: widget.enabled
                      ? AppColors.gradMain
                      : null,
                  color: widget.enabled ? null : AppColors.muted,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.send_rounded,
                    size: 20, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
