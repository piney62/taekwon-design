abstract interface class AiApiClient {
  Future<String> generateReply({
    required String apiKey,
    required String systemPrompt,
    required List<({String role, String content})> messages,
  });
}
