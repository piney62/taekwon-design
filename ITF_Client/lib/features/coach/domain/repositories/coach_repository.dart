import '../entities/chat_message.dart';

abstract class CoachRepository {
  Future<ChatMessage> reply({required List<ChatMessage> history});
}
