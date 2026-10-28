import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/ai/ai_provider.dart';
import '../../../../core/ai/xkiro_ai_service.dart';

final aiServiceProvider = Provider<AiProvider>((ref) => XKiroAiService());

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;

  const ChatState({
    required this.messages,
    this.isLoading = false,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final AiProvider _aiService;
  StreamSubscription<ChatMessage>? _sub;

  ChatNotifier(this._aiService) : super(const ChatState(messages: []));

  void sendMessage(String prompt, {String? specialization}) {
    if (prompt.trim().isEmpty || state.isLoading) return;

    final historySnapshot = List<ChatMessage>.from(state.messages);

    final userMsg = ChatMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}_user',
      content: prompt.trim(),
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );

    final assistantMsgId = '${DateTime.now().millisecondsSinceEpoch}_ai';
    final pendingAiMsg = ChatMessage(
      id: assistantMsgId,
      content: '',
      sender: MessageSender.assistant,
      timestamp: DateTime.now(),
      isStreaming: true,
      isThinkingActive: true,
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg, pendingAiMsg],
      isLoading: true,
    );

    _sub?.cancel();
    _sub = _aiService
        .streamMessage(
          prompt,
          messageId: assistantMsgId,
          specialization: specialization,
          history: historySnapshot,
        )
        .listen(
      (updatedAiMsg) {
        final list = List<ChatMessage>.from(state.messages);
        final idx = list.indexWhere((m) => m.id == assistantMsgId);
        if (idx != -1) {
          list[idx] = updatedAiMsg;
          state = state.copyWith(
            messages: list,
            isLoading: updatedAiMsg.isStreaming,
          );
        } else if (list.isNotEmpty && list.last.sender == MessageSender.assistant) {
          list[list.length - 1] = updatedAiMsg;
          state = state.copyWith(
            messages: list,
            isLoading: updatedAiMsg.isStreaming,
          );
        }
      },
      onDone: () {
        state = state.copyWith(isLoading: false);
      },
      onError: (_) {
        state = state.copyWith(isLoading: false);
      },
    );
  }

  void regenerateLastResponse({String? specialization}) {
    if (state.messages.isEmpty || state.isLoading) return;

    final lastUserIdx =
        state.messages.lastIndexWhere((m) => m.sender == MessageSender.user);
    if (lastUserIdx == -1) return;

    final lastUserPrompt = state.messages[lastUserIdx].content;
    final cleanHistory = state.messages.sublist(0, lastUserIdx);

    _sub?.cancel();
    state = state.copyWith(messages: cleanHistory, isLoading: false);

    sendMessage(lastUserPrompt, specialization: specialization);
  }

  void clearConversation() {
    _sub?.cancel();
    state = const ChatState(messages: [], isLoading: false);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final chatProvider = StateNotifierProvider.autoDispose<ChatNotifier, ChatState>(
  (ref) => ChatNotifier(ref.watch(aiServiceProvider)),
);
