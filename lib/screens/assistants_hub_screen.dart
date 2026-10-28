import 'package:flutter/material.dart';
import '../core/nasaq_theme.dart';
import '../models/nasaq_models.dart';
import '../widgets/heritage_ornaments.dart';

class AssistantsHubScreen extends StatelessWidget {
  final List<AssistantModel> assistants;
  final ApiConnectionConfig apiConfig;
  final bool isDarkMode;
  final Map<String, Set<String>> enabledSkillsByAssistant;
  final Map<String, List<ChatMessage>> conversationsByAssistant;
  final VoidCallback onToggleTheme;
  final VoidCallback onBackToWelcome;
  final ValueChanged<ApiConnectionConfig> onUpdateApiConfig;
  final ValueChanged<AssistantModel> onOpenAssistant;

  const AssistantsHubScreen({
    super.key,
    required this.assistants,
    required this.apiConfig,
    required this.isDarkMode,
    required this.enabledSkillsByAssistant,
    required this.conversationsByAssistant,
    required this.onToggleTheme,
    required this.onBackToWelcome,
    required this.onUpdateApiConfig,
    required this.onOpenAssistant,
  });

  void _openApiSettings(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: ApiSettingsSheet(
          currentConfig: apiConfig,
          onSave: onUpdateApiConfig,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'شاشة البوابة الترحيبية',
          onPressed: onBackToWelcome,
          icon: const Icon(Icons.auto_awesome_rounded),
        ),
        title: const Row(
          children: [
            Text(
              'نَسَق',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22),
            ),
            SizedBox(width: 6),
            FourPointStar(size: 14),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'ساحة المساعدين المتخصصين',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'إعدادات النماذج والـ API',
            onPressed: () => _openApiSettings(context),
            icon: const Icon(Icons.tune_rounded),
          ),
          IconButton(
            tooltip: isDarkMode ? 'الوضع الرملي النهاري' : 'الوضع الليلي',
            onPressed: onToggleTheme,
            icon: Icon(
              isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSystemStatusBanner(context),
          const SizedBox(height: 18),
          Text(
            'المساعدون المتخصصون',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'اختر المساعد المناسب لمهمتك؛ لكل مساعد مهاراته المستقلة وسياقه المفصول.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 14),
          ...assistants.map((assistant) {
            final enabledCount =
                enabledSkillsByAssistant[assistant.id]?.length ?? 0;
            final messageCount =
                conversationsByAssistant[assistant.id]?.length ?? 0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => onOpenAssistant(assistant),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: assistant.accentColor
                                    .withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                assistant.icon,
                                color: assistant.accentColor,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    assistant.name,
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${assistant.tagline} • ${assistant.title}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: NasaqColors.iconAzure,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          assistant.summary,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(height: 1.5),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _HubBadge(
                              icon: Icons.auto_awesome_rounded,
                              label:
                                  '$enabledCount من ${assistant.skills.length} مهارات نشطة',
                            ),
                            _HubBadge(
                              icon: Icons.build_circle_outlined,
                              label:
                                  '${assistant.allowedTools.length} أدوات متاحة',
                            ),
                            if (messageCount > 0)
                              _HubBadge(
                                icon: Icons.chat_bubble_outline_rounded,
                                label: '$messageCount رسائل',
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSystemStatusBanner(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  apiConfig.simulationMode
                      ? Icons.verified_user_outlined
                      : Icons.cloud_done_rounded,
                  color: NasaqColors.accentGold,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    apiConfig.simulationMode
                        ? 'وضع المحاكاة المعمارية نشط (بدون استهلاك API)'
                        : 'متصل بمزود: ${apiConfig.providerName}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => _openApiSettings(context),
                  child: const Text('ضبط النموذج'),
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _HubBadge(
                  icon: Icons.memory_rounded,
                  label: 'النموذج: ${apiConfig.modelId}',
                ),
                _HubBadge(
                  icon: Icons.link_rounded,
                  label: apiConfig.baseUrl,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HubBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HubBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: NasaqColors.accentGold.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: NasaqColors.primaryNavy),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class ApiSettingsSheet extends StatefulWidget {
  final ApiConnectionConfig currentConfig;
  final ValueChanged<ApiConnectionConfig> onSave;

  const ApiSettingsSheet({
    super.key,
    required this.currentConfig,
    required this.onSave,
  });

  @override
  State<ApiSettingsSheet> createState() => _ApiSettingsSheetState();
}

class _ApiSettingsSheetState extends State<ApiSettingsSheet> {
  late final TextEditingController _providerCtrl;
  late final TextEditingController _baseUrlCtrl;
  late final TextEditingController _modelIdCtrl;
  late bool _simulationMode;

  @override
  void initState() {
    super.initState();
    _providerCtrl =
        TextEditingController(text: widget.currentConfig.providerName);
    _baseUrlCtrl = TextEditingController(text: widget.currentConfig.baseUrl);
    _modelIdCtrl = TextEditingController(text: widget.currentConfig.modelId);
    _simulationMode = widget.currentConfig.simulationMode;
  }

  @override
  void dispose() {
    _providerCtrl.dispose();
    _baseUrlCtrl.dispose();
    _modelIdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        right: 16,
        left: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.settings_ethernet_rounded),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'إعدادات مزود النماذج (API Layer)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const Divider(),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'وضع المحاكاة المعمارية المحلية',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              subtitle: const Text(
                'يختبر منسّق المهام والمهارات والواجهات دون إرسال طلبات خارجية أو استهلاك رصيد API.',
                style: TextStyle(fontSize: 12),
              ),
              value: _simulationMode,
              onChanged: (val) => setState(() => _simulationMode = val),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _providerCtrl,
              decoration: const InputDecoration(
                labelText: 'اسم المزود (Provider Name)',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _baseUrlCtrl,
              decoration: const InputDecoration(
                labelText: 'عنوان الخدمة (Base URL)',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _modelIdCtrl,
              decoration: const InputDecoration(
                labelText: 'معرّف النموذج الفعلي (Model ID)',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  widget.onSave(
                    widget.currentConfig.copyWith(
                      providerName: _providerCtrl.text.trim(),
                      baseUrl: _baseUrlCtrl.text.trim(),
                      modelId: _modelIdCtrl.text.trim(),
                      simulationMode: _simulationMode,
                    ),
                  );
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.save_outlined),
                label: const Text('حفظ الإعدادات'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
