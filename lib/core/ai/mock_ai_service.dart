import 'dart:async';
import 'ai_provider.dart';

class MockAiService implements AiProvider {
  @override
  Stream<ChatMessage> streamMessage(
    String prompt, {
    required String messageId,
    String? specialization,
    List<ChatMessage>? history,
  }) async* {
    yield ChatMessage(
      id: messageId,
      content: 'رد تجريبي من نَسَق.',
      sender: MessageSender.assistant,
      timestamp: DateTime.now(),
      isStreaming: false,
      suggestions: const ['شرح تفصيلي', 'خطوة تالية'],
    );
  }
}
