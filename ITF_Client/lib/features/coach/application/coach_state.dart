import '../domain/entities/chat_message.dart';

class CoachState {
  const CoachState({
    this.messages = const [],
    this.isReplying = false,
    this.error,
  });

  final List<ChatMessage> messages;
  final bool isReplying;
  final String? error;

  CoachState copyWith({
    List<ChatMessage>? messages,
    bool? isReplying,
    Object? error = _sentinel,
  }) {
    return CoachState(
      messages: messages ?? this.messages,
      isReplying: isReplying ?? this.isReplying,
      error: identical(error, _sentinel) ? this.error : error as String?,
    );
  }
}

const _sentinel = Object();
