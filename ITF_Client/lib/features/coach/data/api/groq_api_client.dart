import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/network/ai_api_client.dart';
import '../../../../core/network/api_exception.dart';

class GroqApiClient implements AiApiClient {
  GroqApiClient(this._client);

  final http.Client _client;

  static const String _endpoint =
      'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'llama-3.3-70b-versatile';
  static const int _maxTokens = 1024;

  @override
  Future<String> generateReply({
    required String apiKey,
    required String systemPrompt,
    required List<({String role, String content})> messages,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    final allMessages = [
      {'role': 'system', 'content': systemPrompt},
      ...messages.map((m) => {'role': m.role, 'content': m.content}),
    ];

    final body = jsonEncode({
      'model': _model,
      'max_tokens': _maxTokens,
      'messages': allMessages,
    });

    http.Response response;
    try {
      response = await _client.post(
        Uri.parse(_endpoint),
        headers: headers,
        body: body,
      );
    } catch (e) {
      throw NetworkException('Network error: $e');
    }

    if (response.statusCode == 400 || response.statusCode == 401) {
      throw const UnauthorizedException(
        'Invalid API key. Check your Groq API key in Settings.',
      );
    }
    if (response.statusCode == 429) throw const RateLimitException();
    if (response.statusCode >= 500) {
      throw ServerException('Server error: ${response.statusCode}');
    }
    if (response.statusCode != 200) {
      throw UnknownApiException(
        'Unexpected status ${response.statusCode}: ${response.body}',
      );
    }

    final decoded =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final choices = decoded['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) {
      throw const UnknownApiException('Empty response from Groq');
    }

    final message =
        (choices.first as Map<String, dynamic>)['message']
            as Map<String, dynamic>?;
    if (message == null) {
      throw const UnknownApiException('No message in Groq response');
    }

    return message['content'] as String;
  }
}
