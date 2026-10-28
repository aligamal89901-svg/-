import re

file_path = '/root/nasaq/lib/features/chat/presentation/chat_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. إزالة كود الجلسات المحقون بالخطأ سابقاً لتنظيف الملف
content = re.sub(
    r'  final GlobalKey<ScaffoldState> _nasaqScaffoldKey[\s\S]*?ChatStorageService\.saveSessions\(_savedSessions\);\s*\}\s*',
    '',
    content
)

# 2. اكتشاف المتغير الحقيقي لقائمة الرسائل داخل الشاشة
candidates = []
for m in re.finditer(r'(?:List<ChatMessage>|final|var)\s+(_?[a-zA-Z0-9]+)\s*=\s*(?:<ChatMessage>\[\]|\[\])', content):
    name = m.group(1)
    if name not in ['messages', 'sessions', '_savedSessions']:
        candidates.append(name)

for m in re.finditer(r'(_[a-zA-Z0-9_]+)\.(?:length|add|insert)', content):
    name = m.group(1)
    if name not in ['_savedSessions', '_nasaqScaffoldKey']:
        candidates.append(name)

real_msg_var = candidates[0] if candidates else '_messages'
print(f"[✓] متغير الرسائل المعتمد: {real_msg_var}")

# التأكد هل المتغير معرّف في الكلاس، وإن لم يكن معرّفاً نعرّفه
field_def = ""
if not re.search(r'\b' + re.escape(real_msg_var) + r'\b\s*=', content):
    field_def = f"  List<ChatMessage> {real_msg_var} = [];\n"
    print(f"[✓] تمت إضافة تعريف {real_msg_var} كقائمة رسائل في رأس الكلاس.")

clean_state_code = f"""
  final GlobalKey<ScaffoldState> _nasaqScaffoldKey = GlobalKey<ScaffoldState>();
  List<ChatSession> _savedSessions = [];
  String? _currentSessionId;
{field_def}
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
      {real_msg_var}.clear();
    }});
  }}

  void _openExistingSession(ChatSession s) {{
    setState(() {{
      _currentSessionId = s.id;
      {real_msg_var}.clear();
      {real_msg_var}.addAll(s.messages);
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
    if ({real_msg_var}.isEmpty) return;
    final firstMsg = {real_msg_var}.first.content.trim();
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
      messages: List.from({real_msg_var}),
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

# 3. حقن الكود السليم في رأس كلاس _ChatScreenState
content = re.sub(
    r'(class\s+_\w*State\s+extends\s+[^{]+\{)',
    r'\1\n' + clean_state_code,
    content,
    count=1
)

# 4. ربط دالة _persistChatSession لحفظ الرسائل ومنع تحذير unused_element
if '_persistChatSession();' not in content:
    content = re.sub(r'(\bsetState\s*\(\s*\(\)\s*\{[\s\S]*?\b' + re.escape(real_msg_var) + r'\.add[\s\S]*?\};\s*\})', r'\1\n    _persistChatSession();', content)
    if '_persistChatSession();' not in content:
        content = re.sub(r'(\bonSubmitted:[\s\S]*?\{)', r'\1\n      _persistChatSession();', content)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("[✓] تم الإصلاح بنجاح تام.")
