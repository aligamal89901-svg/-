import os
import re

# 1. تحديد ملف شاشة المحادثة الأساسي بدقة
target_file = None
for root, dirs, files in os.walk('/root/nasaq/lib/features'):
    for f in files:
        if f.endswith('.dart'):
            p = os.path.join(root, f)
            with open(p, 'r', encoding='utf-8', errors='ignore') as fp:
                txt = fp.read()
                if 'Scaffold' in txt and ('chat_bubble' in txt or 'ChatMessage' in txt) and ('ListView' in txt or '_messages' in txt):
                    target_file = p
                    break
    if target_file:
        break

if not target_file:
    print("[!] لم يتم العثور على ملف الشاشة تلقائياً، جاري البحث في مسار chat_view...")
    for root, dirs, files in os.walk('/root/nasaq/lib'):
        for f in files:
            if 'chat' in f.lower() and ('screen' in f.lower() or 'view' in f.lower()):
                target_file = os.path.join(root, f)
                break

print(f"[✓] الملف المستهدف للربط: {target_file}")

with open(target_file, 'r', encoding='utf-8') as f:
    code = f.read()

# 2. إضافة الاستيرادات اللازمة بحزمة nasaq لتجنب أخطاء المسارات النسبية
imports_to_add = """import 'package:nasaq/features/chat/domain/chat_session.dart';
import 'package:nasaq/features/chat/data/chat_storage_service.dart';
import 'package:nasaq/features/chat/presentation/widgets/chat_history_drawer.dart';
"""
if 'chat_history_drawer.dart' not in code:
    code = imports_to_add + code

# 3. حقن مفتاح Scaffold ومتغيرات إدارة الجلسات داخل كلاس الـ State
state_vars = """
  final GlobalKey<ScaffoldState> _nasaqScaffoldKey = GlobalKey<ScaffoldState>();
  List<ChatSession> _savedSessions = [];
  String? _currentSessionId;

  Future<void> _loadSavedHistory() async {
    final list = await ChatStorageService.loadSessions('general');
    if (mounted) {
      setState(() {
        _savedSessions = list;
      });
    }
  }

  void _startNewChatSession() {
    setState(() {
      _currentSessionId = DateTime.now().millisecondsSinceEpoch.toString();
      _messages.clear();
    });
  }

  void _openExistingSession(ChatSession s) {
    setState(() {
      _currentSessionId = s.id;
      _messages = List.from(s.messages);
    });
  }

  Future<void> _removeSession(String id) async {
    await ChatStorageService.deleteSession(id);
    setState(() {
      _savedSessions.removeWhere((s) => s.id == id);
      if (_currentSessionId == id) {
        _startNewChatSession();
      }
    });
  }

  void _persistChatSession() {
    if (_messages.isEmpty) return;
    final firstMsg = _messages.first.content.trim();
    final title = firstMsg.length > 28 ? '${firstMsg.substring(0, 28)}...' : (firstMsg.isEmpty ? 'محادثة جديدة' : firstMsg);
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
      messages: List.from(_messages),
    );

    setState(() {
      if (existingIdx != -1) {
        _savedSessions[existingIdx] = session;
      } else {
        _savedSessions.insert(0, session);
      }
    });
    ChatStorageService.saveSessions(_savedSessions);
  }
"""

if '_nasaqScaffoldKey' not in code:
    # حقن المتغيرات بعد فتح كلاس State
    code = re.sub(
        r'(class\s+_\w+State\s+extends\s+State<[\w\s,<>]+>\s*\{)',
        r'\1\n' + state_vars,
        code,
        count=1
    )

# 4. استدعاء تحميل الجلسات في initState
if '_loadSavedHistory()' not in code:
    if 'initState()' in code:
        code = re.sub(
            r'(void\s+initState\(\)\s*\{[\s\S]*?super\.initState\(\);)',
            r'\1\n    _loadSavedHistory();',
            code,
            count=1
        )
    else:
        code = re.sub(
            r'(class\s+_\w+State\s+extends\s+State<[\w\s,<>]+>\s*\{)',
            r'\1\n  @override\n  void initState() {\n    super.initState();\n    _loadSavedHistory();\n  }\n',
            code,
            count=1
        )

# 5. ربط المفتاح والقائمة الجانبية (Drawer) داخل الـ Scaffold
if 'drawer: ChatHistoryDrawer' not in code:
    code = re.sub(
        r'Scaffold\s*\(',
        r'''Scaffold(
      key: _nasaqScaffoldKey,
      drawer: ChatHistoryDrawer(
        sessions: _savedSessions,
        activeSessionId: _currentSessionId,
        onNewChat: _startNewChatSession,
        onSelectSession: _openExistingSession,
        onDeleteSession: _removeSession,
      ),''',
        code,
        count=1
    )

# 6. إضافة زر القائمة وزر محادثة جديدة في الـ AppBar
buttons_code = """
          IconButton(
            icon: const Icon(Icons.history_rounded, size: 22, color: Color(0xFF007A64)),
            tooltip: 'سجل المحادثات',
            onPressed: () => _nasaqScaffoldKey.currentState?.openDrawer(),
          ),
          IconButton(
            icon: const Icon(Icons.add_comment_outlined, size: 20, color: Color(0xFF007A64)),
            tooltip: 'محادثة جديدة',
            onPressed: _startNewChatSession,
          ),
"""

if 'سجل المحادثات' not in code:
    # إضافتها إما في actions أو بجوار أزرار الشريط العلوي
    if 'actions:' in code:
        code = re.sub(r'actions:\s*\[', r'actions: [' + buttons_code, code, count=1)
    else:
        code = re.sub(r'(title:\s*[\s\S]*?,)', r'\1\n      actions: [' + buttons_code + '],', code, count=1)

# 7. الحفظ التلقائي عند اكتمال رد المساعد
if '_persistChatSession()' not in code:
    code = re.sub(
        r'(isStreaming:\s*false,)',
        r'\1\n); _persistChatSession(',
        code
    )
    # تنظيف أي خطأ صياغة بسيط ناتج عن الاستبدال
    code = code.replace('); _persistChatSession(', '); _persistChatSession();')

with open(target_file, 'w', encoding='utf-8') as f:
    f.write(code)

print("[✓] تم دمج القائمة الجانبية وأزرار المحادثة الجديدة بنجاح تام!")
