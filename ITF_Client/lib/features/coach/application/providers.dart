import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/backend_client.dart';
import '../data/repositories/coach_repository_impl.dart';
import '../domain/entities/chat_message.dart';
import '../domain/entities/chat_role.dart';
import '../domain/repositories/coach_repository.dart';
import 'coach_state.dart';

final coachRepositoryProvider = Provider<CoachRepository>((ref) {
  return CoachRepositoryImpl(ref.watch(backendClientProvider));
});

class CoachController extends Notifier<CoachState> {
  @override
  CoachState build() => const CoachState();

  Future<void> sendMessage(String content) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty || state.isReplying) return;

    final userMessage = ChatMessage.user(trimmed);
    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isReplying: true,
      error: null,
    );

    try {
      final repo = ref.read(coachRepositoryProvider);
      final reply = await repo.reply(history: state.messages);
      state = state.copyWith(
        messages: [...state.messages, reply],
        isReplying: false,
      );
    } catch (e) {
      state = state.copyWith(isReplying: false, error: e.toString());
    }
  }

  void deleteMessagePair(String messageId) {
    final messages = state.messages;
    final idx = messages.indexWhere((m) => m.id == messageId);
    if (idx == -1) return;

    final toRemove = <int>{idx};
    if (messages[idx].role == ChatRole.user && idx + 1 < messages.length) {
      toRemove.add(idx + 1);
    } else if (messages[idx].role == ChatRole.assistant && idx > 0) {
      toRemove.add(idx - 1);
    }

    final updated = [
      for (int i = 0; i < messages.length; i++)
        if (!toRemove.contains(i)) messages[i],
    ];
    state = state.copyWith(messages: updated);
  }

  void clear() => state = const CoachState();

  void dismissError() => state = state.copyWith(error: null);
}

final coachControllerProvider =
    NotifierProvider<CoachController, CoachState>(CoachController.new);
