import re

file_path = '/root/nasaq/lib/features/chat/presentation/chat_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# الأزرار الجديدة المصممة بنفس ذوق وهوية نَسَق
header_buttons = """
                  // زر سجل المحادثات والقائمة الجانبية
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      _loadSavedHistory();
                      _nasaqScaffoldKey.currentState?.openDrawer();
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0ECE1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2DDD2)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.history_rounded, size: 16, color: Color(0xFF007A64)),
                          SizedBox(width: 4),
                          Text(
                            'السجل',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E2124),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // زر محادثة جديدة
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: _startNewChatSession,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF007A64),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_rounded, size: 16, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'جديدة',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
"""

# البحث عن موضع زر 'الملفات' في ترويسة الشاشة وحقن الأزرار بجواره مباشرة
if 'زر سجل المحادثات والقائمة الجانبية' not in content:
    pos = content.find("'الملفات'")
    if pos == -1:
        pos = content.find('"الملفات"')

    if pos != -1:
        # البحث عن نهاية ودجت زر الملفات (القوس والفاصلة التالية له)
        end_pos = content.find('),', pos)
        if end_pos != -1:
            end_pos += 2
            # إذا كان هناك قوس آخر يغلق InkWell/GestureDetector
            next_close = content.find('),', end_pos)
            if next_close != -1 and (next_close - end_pos) < 30:
                end_pos = next_close + 2

            content = content[:end_pos] + header_buttons + content[end_pos:]
            print("[✓] تم زرع زري 'السجل' و 'جديدة' بجانب زر الملفات في الترويسة بنجاح.")

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
