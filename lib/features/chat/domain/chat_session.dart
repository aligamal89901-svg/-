import '../../../core/ai/ai_provider.dart';

class ChatSession {
  final String id;
  String title;
  final String type; // 'agent' or 'general'
  final DateTime createdAt;
  DateTime updatedAt;
  List<ChatMessage> messages;

  ChatSession({
    required this.id,
    required this.title,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    required this.messages,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'type': type,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'messages': messages.map((m) => {
      'id': m.id,
      'content': m.content,
      'sender': m.sender.name,
      'timestamp': m.timestamp.toIso8601String(),
      'thinking': m.realThinking,
    }).toList(),
  };

  factory ChatSession.fromJson(Map<String, dynamic> json) => ChatSession(
    id: json['id'] as String,
    title: json['title'] as String? ?? 'محادثة جديدة',
    type: json['type'] as String? ?? 'general',
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
    messages: (json['messages'] as List<dynamic>? ?? []).map((m) => ChatMessage(
      id: m['id'] as String,
      content: m['content'] as String,
      sender: m['sender'] == 'user' ? MessageSender.user : MessageSender.assistant,
      timestamp: DateTime.parse(m['timestamp'] as String),
      realThinking: m['thinking'] as String?,
      isStreaming: false,
    )).toList(),
  );
}
