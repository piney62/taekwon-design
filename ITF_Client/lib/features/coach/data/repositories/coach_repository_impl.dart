import '../../../../core/network/backend_client.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/coach_repository.dart';

class CoachRepositoryImpl implements CoachRepository {
  CoachRepositoryImpl(this._client);

  final BackendClient _client;

  @override
  Future<ChatMessage> reply({required List<ChatMessage> history}) async {
    final messages = history
        .map((m) => {'role': m.role.apiName, 'content': m.content})
        .toList();
    final replyText = await _client.chat(messages);
    return ChatMessage.assistant(replyText);
  }
}
