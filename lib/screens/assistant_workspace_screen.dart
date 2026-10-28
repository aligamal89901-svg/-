import 'package:flutter/material.dart';
import '../core/nasaq_theme.dart';
import '../models/nasaq_models.dart';
import '../services/nasaq_coordinator.dart';

class AssistantWorkspaceScreen extends StatefulWidget {
  final AssistantModel assistant;
  final ApiConnectionConfig apiConfig;
  final Set<String> enabledSkillIds;
  final List<ChatMessage> messages;
  final void Function(String skillId, bool isEnabled) onToggleSkill;
  final ValueChanged<ChatMessage> onSendMessage;
  final VoidCallback onClearConversation;

  const AssistantWorkspaceScreen({
    super.key,
    required this.assistant,
    required this.apiConfig,
    required this.enabledSkillIds,
    required this.messages,
    required this.onToggleSkill,
    required this.onSendMessage,
    required this.onClearConversation,
  });

  @override
  State<AssistantWorkspaceScreen> createState() =>
      _AssistantWorkspaceScreenState();
}

class _AssistantWorkspaceScreenState extends State<AssistantWorkspaceScreen> {
  final TextEditingController _inputController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _handleSend([String? presetPrompt]) async {
    final text = (presetPrompt ?? _inputController.text).trim();
    if (text.isEmpty || _isProcessing) return;

    if (presetPrompt == null) {
      _inputController.clear();
    }

    final userMsg = ChatMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      isUser: true,
      content: text,
      timestamp: DateTime.now(),
    );
    widget.onSendMessage(userMsg);

    setState(() {
      _isProcessing = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 300));

    final packet = NasaqCoordinator.buildPacket(
      assistant: widget.assistant,
      enabledSkillIds: widget.enabledSkillIds,
      userPrompt: text,
      modelId: widget.apiConfig.modelId,
    );

    final replyText = NasaqCoordinator.generateArchitecturalPreviewResponse(
      widget.assistant,
      packet,
    );

    final assistantMsg = ChatMessage(
      id: '${DateTime.now().microsecondsSinceEpoch}_reply',
      isUser: false,
      content: replyText,
      timestamp: DateTime.now(),
      appliedSkills: packet.selectedSkills,
      modelId: widget.apiConfig.modelId,
      promptPacket: packet,
    );

    if (!mounted) return;
    widget.onSendMessage(assistantMsg);
    setState(() {
      _isProcessing = false;
    });
  }

  void _openSkillsSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Row(
                    children: [
                      Icon(
                        widget.assistant.icon,
                        color: widget.assistant.accentColor,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'مهارات وتعليمات: ${widget.assistant.name}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const Divider(),
                  const Text(
                    'التعليمات الأساسية (System Persona):',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        widget.assistant.systemPersona,
                        style: const TextStyle(fontSize: 12, height: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'سجل المهارات (Skills Registry):',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  ...widget.assistant.skills.map((skill) {
                    final isEnabled =
                        widget.enabledSkillIds.contains(skill.id);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: SwitchListTile(
                        title: Text(
                          skill.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        subtitle: Text(
                          '${skill.scope.label} • ${skill.description}',
                          style: const TextStyle(fontSize: 11),
                        ),
                        value: isEnabled,
                        onChanged: (val) {
                          widget.onToggleSkill(skill.id, val);
                          setSheetState(() {});
                          setState(() {});
                        },
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showPromptInspector(CompiledPromptPacket packet) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text(
            'فاحص حزمة التوجيه (Prompt Inspector)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: SelectableText(
              packet.toStructuredPreview(),
              style: const TextStyle(fontSize: 12, height: 1.5),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('إغلاق'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeSkills = widget.assistant.skills
        .where((s) => widget.enabledSkillIds.contains(s.id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.assistant.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '${widget.assistant.tagline} • ${activeSkills.length} مهارات مفعّلة',
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'إدارة المهارات',
            onPressed: _openSkillsSheet,
            icon: const Icon(Icons.auto_awesome_mosaic_rounded),
          ),
          if (widget.messages.isNotEmpty)
            IconButton(
              tooltip: 'مسح المحادثة',
              onPressed: widget.onClearConversation,
              icon: const Icon(Icons.delete_sweep_rounded),
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: NasaqColors.accentGold.withValues(alpha: 0.12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded, size: 15),
                  const SizedBox(width: 6),
                  const Text(
                    'المهارات النشطة:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  ...activeSkills.map(
                    (skill) => Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: ActionChip(
                        label: Text(
                          skill.name,
                          style: const TextStyle(fontSize: 11),
                        ),
                        onPressed: _openSkillsSheet,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: widget.messages.isEmpty
                ? ListView(
                    padding: const EdgeInsets.all(18),
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'هوية ${widget.assistant.name}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                widget.assistant.systemPersona,
                                style: const TextStyle(
                                  fontSize: 13,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'جرّب إرسال مهمة لاختبار منسّق المهارات:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...widget.assistant.starterPrompts.map(
                        (prompt) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Icon(
                              Icons.play_arrow_rounded,
                              color: widget.assistant.accentColor,
                            ),
                            title: Text(
                              prompt,
                              style: const TextStyle(fontSize: 13),
                            ),
                            onTap: () => _handleSend(prompt),
                          ),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: widget.messages.length,
                    itemBuilder: (context, index) {
                      final msg = widget.messages[index];
                      final isUser = msg.isUser;
                      return Align(
                        alignment: isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          constraints: const BoxConstraints(maxWidth: 520),
                          decoration: BoxDecoration(
                            color: isUser
                                ? NasaqColors.primaryNavy
                                : theme.cardTheme.color,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: NasaqColors.cardBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SelectableText(
                                msg.content,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  height: 1.55,
                                  color: isUser ? Colors.white : null,
                                ),
                              ),
                              if (!isUser && msg.promptPacket != null) ...[
                                const SizedBox(height: 8),
                                TextButton.icon(
                                  onPressed: () =>
                                      _showPromptInspector(msg.promptPacket!),
                                  icon: const Icon(
                                    Icons.visibility_outlined,
                                    size: 15,
                                  ),
                                  label: const Text(
                                    'فحص حزمة التوجيه',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (_isProcessing) const LinearProgressIndicator(minHeight: 2),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      onSubmitted: (_) => _handleSend(),
                      decoration: InputDecoration(
                        hintText: 'اكتب مهمتك لـ ${widget.assistant.name}...',
                        filled: true,
                        fillColor: theme.cardTheme.color,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _isProcessing ? null : () => _handleSend(),
                    child: const Text('إرسال'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
