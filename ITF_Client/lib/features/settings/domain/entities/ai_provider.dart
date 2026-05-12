enum AiProvider {
  groq,
  grok,
  claude;

  String get displayName => switch (this) {
        AiProvider.groq => 'Groq (LLaMA 3.3)',
        AiProvider.grok => 'Grok (xAI)',
        AiProvider.claude => 'Claude (Anthropic)',
      };
}
