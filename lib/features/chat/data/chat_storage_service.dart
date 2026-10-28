import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/chat_session.dart';

class ChatStorageService {
  static const String _storageKey = 'nasaq_saved_sessions_v1';

  static Future<List<ChatSession>> loadSessions(String type) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw == null || raw.isEmpty) return [];

      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((item) => ChatSession.fromJson(item as Map<String, dynamic>))
          .where((s) => s.type == type)
          .toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveSessions(List<ChatSession> sessions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      final all = <String, ChatSession>{};
      if (raw != null && raw.isNotEmpty) {
        final list = jsonDecode(raw) as List<dynamic>;
        for (final item in list) {
          final s = ChatSession.fromJson(item as Map<String, dynamic>);
          all[s.id] = s;
        }
      }
      for (final s in sessions) {
        all[s.id] = s;
      }
      final encoded = jsonEncode(all.values.map((s) => s.toJson()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (_) {}
  }

  static Future<void> deleteSession(String sessionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw == null) return;
      final list = jsonDecode(raw) as List<dynamic>;
      final updated = list.where((item) => item['id'] != sessionId).toList();
      await prefs.setString(_storageKey, jsonEncode(updated));
    } catch (_) {}
  }
}
