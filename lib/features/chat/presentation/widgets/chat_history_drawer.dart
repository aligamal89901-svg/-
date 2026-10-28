import 'package:flutter/material.dart';
import '../../domain/chat_session.dart';

class ChatHistoryDrawer extends StatelessWidget {
  final List<ChatSession> sessions;
  final String? activeSessionId;
  final VoidCallback onNewChat;
  final ValueChanged<ChatSession> onSelectSession;
  final ValueChanged<String> onDeleteSession;

  const ChatHistoryDrawer({
    super.key,
    required this.sessions,
    required this.activeSessionId,
    required this.onNewChat,
    required this.onSelectSession,
    required this.onDeleteSession,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF1E2124),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  onNewChat();
                },
                icon: const Icon(Icons.add, color: Colors.white, size: 20),
                label: const Text(
                  'محادثة جديدة',
                  style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007A64),
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
            const Divider(color: Colors.white12, height: 1),
            Expanded(
              child: sessions.isEmpty
                  ? const Center(
                      child: Text(
                        'لا توجد محادثات سابقة بعد',
                        style: TextStyle(fontFamily: 'Cairo', color: Colors.white38, fontSize: 13),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: sessions.length,
                      itemBuilder: (context, index) {
                        final s = sessions[index];
                        final isSelected = s.id == activeSessionId;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white.withValues(alpha: 0.08) : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF007A64).withValues(alpha: 0.5) : Colors.transparent,
                            ),
                          ),
                          child: ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                            leading: Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 18,
                              color: isSelected ? const Color(0xFF00C49F) : Colors.white54,
                            ),
                            title: Text(
                              s.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 13,
                                color: isSelected ? Colors.white : Colors.white70,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, size: 16, color: Colors.white24),
                              onPressed: () => onDeleteSession(s.id),
                              splashRadius: 18,
                              tooltip: 'حذف المحادثة',
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              onSelectSession(s);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
