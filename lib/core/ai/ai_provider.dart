enum MessageSender { user, assistant }

class ToolExecutionData {
  final String toolName;
  final String commandOrInput;
  final String? targetPath;
  final String? output;
  final int? exitCode;
  final bool isRunning;
  final bool isCompleted;

  const ToolExecutionData({
    required this.toolName,
    required this.commandOrInput,
    this.targetPath,
    this.output,
    this.exitCode,
    this.isRunning = false,
    this.isCompleted = false,
  });

  ToolExecutionData copyWith({
    String? toolName,
    String? commandOrInput,
    String? targetPath,
    String? output,
    int? exitCode,
    bool? isRunning,
    bool? isCompleted,
  }) {
    return ToolExecutionData(
      toolName: toolName ?? this.toolName,
      commandOrInput: commandOrInput ?? this.commandOrInput,
      targetPath: targetPath ?? this.targetPath,
      output: output ?? this.output,
      exitCode: exitCode ?? this.exitCode,
      isRunning: isRunning ?? this.isRunning,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class ChatMessage {
  final String id;
  final String content;
  final MessageSender sender;
  final DateTime timestamp;
  final bool isStreaming;
  final String? realThinking;
  final bool isThinkingActive;
  final int thinkingDurationMs;
  final List<String> suggestions;
  final List<ToolExecutionData> toolExecutions;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.sender,
    required this.timestamp,
    this.isStreaming = false,
    this.realThinking,
    this.isThinkingActive = false,
    this.thinkingDurationMs = 0,
    this.suggestions = const [],
    this.toolExecutions = const [],
  });

  ChatMessage copyWith({
    String? id,
    String? content,
    MessageSender? sender,
    DateTime? timestamp,
    bool? isStreaming,
    String? realThinking,
    bool? isThinkingActive,
    int? thinkingDurationMs,
    List<String>? suggestions,
    List<ToolExecutionData>? toolExecutions,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      isStreaming: isStreaming ?? this.isStreaming,
      realThinking: realThinking ?? this.realThinking,
      isThinkingActive: isThinkingActive ?? this.isThinkingActive,
      thinkingDurationMs: thinkingDurationMs ?? this.thinkingDurationMs,
      suggestions: suggestions ?? this.suggestions,
      toolExecutions: toolExecutions ?? this.toolExecutions,
    );
  }
}

abstract class AiProvider {
  Stream<ChatMessage> streamMessage(
    String prompt, {
    required String messageId,
    String? specialization,
    List<ChatMessage>? history,
  });
}
