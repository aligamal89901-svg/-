import 'package:nasaq/widgets/terminal_status_badge.dart';
import '../domain/chat_session.dart';
import '../data/chat_storage_service.dart';
import 'widgets/chat_history_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/ai/ai_provider.dart';
import '../../../../core/theme/nasaq_theme.dart';
import '../../../../core/widgets/nasaq_background.dart';
import '../../../../core/widgets/scale_tap.dart';
import 'providers/chat_provider.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/workspace_explorer_sheet.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String specializationTitle;
  final String specializationSubtitle;
  final Color? accentColor;
  final List<String>? starterPrompts;

  const ChatScreen({
    super.key,
    required this.specializationTitle,
    required this.specializationSubtitle,
    this.accentColor,
    this.starterPrompts,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {

  final GlobalKey<ScaffoldState> _nasaqScaffoldKey = GlobalKey<ScaffoldState>();
  List<ChatSession> _savedSessions = [];
  String? _currentSessionId;
  final List<ChatMessage> _messages = [];

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
      _messages.clear();
      _messages.addAll(s.messages);
        _persistChatSession();
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
    final title = firstMsg.length > 26 ? '${firstMsg.substring(0, 26)}...' : (firstMsg.isEmpty ? 'محادثة جديدة' : firstMsg);
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


@override
  void initState() {
    super.initState();
    _loadSavedHistory();
  }

  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutQuad,
        );
      }
    });
  }

  void _sendMessage([String? customPrompt]) {
    final prompt = customPrompt ?? _textController.text;
    if (prompt.trim().isEmpty) return;

    ref.read(chatProvider.notifier).sendMessage(
          prompt,
          specialization: widget.specializationTitle,
        );

    if (customPrompt == null) {
      _textController.clear();
    }
    _scrollToBottom();
  }

  void _openWorkspaceExplorer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const WorkspaceExplorerSheet(),
    );
  }

  List<String> _resolveActiveSuggestions(List<ChatMessage> messages) {
    if (messages.isNotEmpty) {
      for (int i = messages.length - 1; i >= 0; i--) {
        if (messages[i].sender == MessageSender.assistant &&
            messages[i].suggestions.isNotEmpty) {
          return messages[i].suggestions;
        }
      }
    }
    return widget.starterPrompts ??
        const [
          'افحص محتويات مجلد مساحة العمل المشتركة',
          'أنشئ سكربت أتمتة واحفظه في Ubuntu PRoot',
        ];
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final accent = widget.accentColor ?? NasaqColors.emeraldRoyal;
    final activeSuggestions = _resolveActiveSuggestions(chatState.messages);

    ref.listen<ChatState>(chatProvider, (previous, next) {
      if (previous?.messages.length != next.messages.length) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      key: _nasaqScaffoldKey,
      drawer: ChatHistoryDrawer(
        sessions: _savedSessions,
        activeSessionId: _currentSessionId,
        onNewChat: _startNewChatSession,
        onSelectSession: _openExistingSession,
        onDeleteSession: _removeSession,
      ),
      body: NasaqBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: NasaqColors.paperSurface.withValues(alpha: 0.95),
                  border: const Border(
                    bottom: BorderSide(
                      color: Color(0xFFE6DEC9),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    ScaleTap(
                      onTap: () => context.pop(),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3ECE0),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFDDD3BE),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                          color: NasaqColors.inkPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.specializationTitle,
                            style: GoogleFonts.readexPro(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: NasaqColors.inkPrimary,
                            ),
                          ),
                          const TerminalStatusBadge(),
                        ],
                      ),
                    ),
                    ScaleTap(
                      onTap: _openWorkspaceExplorer,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3ECE0),
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(color: const Color(0xFFDDD3BE)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.folder_open_rounded,
                              size: 15,
                              color: NasaqColors.inkPrimary,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'الملفات',
                              style: GoogleFonts.ibmPlexSansArabic(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: NasaqColors.inkPrimary,
                              ),
                            ),
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

                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ScaleTap(
                      onTap: () {
                        ref.read(chatProvider.notifier).clearConversation();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3ECE0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.refresh_rounded,
                          size: 17,
                          color: NasaqColors.inkMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: chatState.messages.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF4ECE0),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFDDD2BC),
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'ن',
                                  style: GoogleFonts.readexPro(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: NasaqColors.emeraldRoyal,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                widget.specializationTitle,
                                style: GoogleFonts.readexPro(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: NasaqColors.inkPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'متصل ببيئة Ubuntu PRoot (/root/nasaq/workspace).\nاطلب تنفيذ أوامر أو إنشاء وتعديل ملفات حقيقية.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.ibmPlexSansArabic(
                                  fontSize: 12,
                                  color: NasaqColors.inkMuted,
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                        itemCount: chatState.messages.length,
                        itemBuilder: (context, index) {
                          final msg = chatState.messages[index];
                          final isLastAssistant = index == chatState.messages.length - 1 &&
                              msg.sender == MessageSender.assistant;

                          return ChatBubble(
                            message: msg,
                            specializationTitle: widget.specializationTitle,
                            accentColor: accent,
                            onRegenerate: isLastAssistant
                                ? () => ref
                                    .read(chatProvider.notifier)
                                    .regenerateLastResponse(
                                      specialization: widget.specializationTitle,
                                    )
                                : null,
                          );
                        },
                      ),
              ),

              if (activeSuggestions.isNotEmpty && !chatState.isLoading)
                Container(
                  height: 38,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: activeSuggestions.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, idx) {
                      final item = activeSuggestions[idx];
                      return ScaleTap(
                        onTap: () => _sendMessage(item),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFBF8F2),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: const Color(0xFFDDD2BC),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            item,
                            style: GoogleFonts.ibmPlexSansArabic(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF2C241B),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

              Container(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                decoration: const BoxDecoration(
                  color: NasaqColors.paperSurface,
                  border: Border(
                    top: BorderSide(
                      color: Color(0xFFE6DEC9),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4EDE2),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: const Color(0xFFDDD2BC),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          controller: _textController,
                          style: GoogleFonts.ibmPlexSansArabic(
                            fontSize: 14,
                            color: NasaqColors.inkPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText: 'اطلب أمراً أو مهمة في Ubuntu...',
                            hintStyle: GoogleFonts.ibmPlexSansArabic(
                              fontSize: 13,
                              color: NasaqColors.inkMuted,
                            ),
                            border: InputBorder.none,
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ScaleTap(
                      onTap: chatState.isLoading ? null : () => _sendMessage(),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: chatState.isLoading
                              ? const Color(0xFFB8AE9C)
                              : NasaqColors.emeraldRoyal,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          chatState.isLoading
                              ? Icons.hourglass_empty_rounded
                              : Icons.arrow_upward_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
