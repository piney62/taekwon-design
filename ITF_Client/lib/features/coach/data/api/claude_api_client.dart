import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../../core/network/ai_api_client.dart';
import '../../../../core/network/api_exception.dart';

class ClaudeApiClient implements AiApiClient {
  ClaudeApiClient(this._client);

  final http.Client _client;

  static const String _endpoint = 'https://api.anthropic.com/v1/messages';
  static const String _apiVersion = '2023-06-01';
  static const String _model = 'claude-haiku-4-5-20251001';
  static const int _maxTokens = 1024;

  @override
  Future<String> generateReply({
    required String apiKey,
    required String systemPrompt,
    required List<({String role, String content})> messages,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'x-api-key': apiKey,
      'anthropic-version': _apiVersion,
      if (kIsWeb) 'anthropic-dangerous-direct-browser-access': 'true',
    };

    final body = jsonEncode({
      'model': _model,
      'max_tokens': _maxTokens,
      'system': systemPrompt,
      'messages': messages
          .map((m) => {'role': m.role, 'content': m.content})
          .toList(),
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

    if (response.statusCode == 401) {
      throw const UnauthorizedException();
    }
    if (response.statusCode == 429) {
      throw const RateLimitException();
    }
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
    final blocks = decoded['content'] as List<dynamic>?;
    if (blocks == null || blocks.isEmpty) {
      throw const UnknownApiException('Empty response from Claude');
    }

    final textBlock = blocks.firstWhere(
      (b) => b is Map<String, dynamic> && b['type'] == 'text',
      orElse: () => null,
    );
    if (textBlock == null) {
      throw const UnknownApiException('No text content in response');
    }

    return (textBlock as Map<String, dynamic>)['text'] as String;
  }
}
