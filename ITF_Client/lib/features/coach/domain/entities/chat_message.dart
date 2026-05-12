import 'chat_role.dart';

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
  });

  final String id;
  final ChatRole role;
  final String content;
  final DateTime timestamp;

  factory ChatMessage.user(String content) {
    final now = DateTime.now();
    return ChatMessage(
      id: 'u_${now.microsecondsSinceEpoch}',
      role: ChatRole.user,
      content: content,
      timestamp: now,
    );
  }

  factory ChatMessage.assistant(String content) {
    final now = DateTime.now();
    return ChatMessage(
      id: 'a_${now.microsecondsSinceEpoch}',
      role: ChatRole.assistant,
      content: content,
      timestamp: now,
    );
  }
}
