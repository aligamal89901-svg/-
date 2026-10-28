import re

file_path = '/root/nasaq/lib/features/chat/presentation/chat_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

# 1. اكتشاف اسم مصفوفة الرسائل المستخدمة في الشاشة
msg_var = '_messages'
for l in lines:
    m = re.search(r'List<ChatMessage>\s+([a-zA-Z0-9_]+)', l)
    if m:
        msg_var = m.group(1)
        break

state_declarations = f"""
  final GlobalKey<ScaffoldState> _nasaqScaffoldKey = GlobalKey<ScaffoldState>();
  List<ChatSession> _savedSessions = [];
  String? _currentSessionId;

  Future<void> _loadSavedHistory() async {{
    final list = await ChatStorageService.loadSessions('general');
    if (mounted) {{
      setState(() {{
        _savedSessions = list;
      }});
    }}
  }}

  void _startNewChatSession() {{
    setState(() {{
      _currentSessionId = DateTime.now().millisecondsSinceEpoch.toString();
      {msg_var}.clear();
    }});
  }}

  void _openExistingSession(ChatSession s) {{
    setState(() {{
      _currentSessionId = s.id;
      {msg_var}.clear();
      {msg_var}.addAll(s.messages);
    }});
  }}

  Future<void> _removeSession(String id) async {{
    await ChatStorageService.deleteSession(id);
    setState(() {{
      _savedSessions.removeWhere((s) => s.id == id);
      if (_currentSessionId == id) {{
        _startNewChatSession();
      }}
    }});
  }}

  void _persistChatSession() {{
    if ({msg_var}.isEmpty) return;
    final firstMsg = {msg_var}.first.content.trim();
    final title = firstMsg.length > 26 ? '${{firstMsg.substring(0, 26)}}...' : (firstMsg.isEmpty ? 'محادثة جديدة' : firstMsg);
    final now = DateTime.now();
    final sid = _currentSessionId ?? now.millisecondsSinceEpoch.toString();
    _currentSessionId = sid;

    final existingIdx = _savedSessions.indexWhere((s) => s.id == sid);
    final session = ChatSession(
      id: sid,
      title: title,
      type: 'general',
      createdAt: existingIdx != -1 ? _savedSessions[existingIdx].createdAt : now,
      updatedAt: now,
      messages: List.from({msg_var}),
    );

    setState(() {{
      if (existingIdx != -1) {{
        _savedSessions[existingIdx] = session;
      }} else {{
        _savedSessions.insert(0, session);
      }}
    }});
    ChatStorageService.saveSessions(_savedSessions);
  }}
"""

# 2. حقن الدوال والمتغيرات مباشرة بعد سطر تعريف كلاس State
inserted = False
new_lines = []
for line in lines:
    new_lines.append(line)
    if not inserted and 'class _' in line and 'State' in line and '{' in line:
        new_lines.append(state_declarations)
        inserted = True

with open(file_path, 'w', encoding='utf-8') as f:
    f.writelines(new_lines)

print(f"[✓] تم حقن تعريفات الجلسات بنجاح بالاعتماد على المصفوفة ({msg_var}).")
