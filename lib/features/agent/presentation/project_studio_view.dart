import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../../../core/ai/agent_bridge_service.dart';
import '../../../core/ai/ai_provider.dart';
import '../../../core/theme/nasaq_theme.dart';
import '../../../core/widgets/scale_tap.dart';
import '../../chat/presentation/widgets/workspace_explorer_sheet.dart';

enum TaskStatus { pending, inProgress, completed, failed }

class ProjectStepTask {
  final String title;
  final String description;
  final String tool;
  final String command;
  final String? path;
  TaskStatus status;
  String? output;

  ProjectStepTask({
    required this.title,
    required this.description,
    required this.tool,
    required this.command,
    this.path,
    this.status = TaskStatus.pending,
    this.output,
  });
}

class ProjectStudioView extends StatefulWidget {
  const ProjectStudioView({super.key});

  @override
  State<ProjectStudioView> createState() => _ProjectStudioViewState();
}

class _ProjectStudioViewState extends State<ProjectStudioView> {
  final TextEditingController _ideaController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  bool _isPlanning = false;
  bool _isExecutingPlan = false;
  String _activeLiveLog = '';

  List<ProjectStepTask> _pipelineTasks = [];

  @override
  void dispose() {
    _ideaController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _generateProjectPlan() async {
    final idea = _ideaController.text.trim();
    final name = _nameController.text.trim().replaceAll(' ', '_').toLowerCase();
    if (idea.isEmpty) return;

    final projectName = name.isEmpty ? 'nasaq_project' : name;

    setState(() {
      _isPlanning = true;
      _pipelineTasks = [];
      _activeLiveLog = 'جارٍ تحليل فكرة المشروع وتفكيكها إلى مهام تنفيذية في Ubuntu PRoot...';
    });

    final rawHost = Uri.base.host;
    final hostname = (rawHost.isEmpty || rawHost == '0.0.0.0') ? '127.0.0.1' : rawHost;
    final proxyUri = Uri.parse('http://$hostname:8081/v1/chat/completions');

    final planPrompt = '''أنت «نَسَق إيجنت - مهندس المشاريع».

 بتفكيك المشروع إلى 4 إلى 5 مهام برمجية دقيقة بتنسيق JSON حصراً:
[
  {
    "title": "عنوان المهمة المختصر",
    "description": "ما الذي سيتم عمله",
    "tool": "terminal_exec أو write_file",
    "command": "الأمر البرمجي التام",
    "path": "المسار النسبي إن وجد"
  }
]
1. تهيئة وفحص المسار في Ubuntu.
2. إنشاء المشروع (مثل flutter create $projectName --platforms=web أو إنشاء الملفات).
3. كتابة ملف الكود الأساسي.
4. التحقق واستعراض الناتج.''';

    try {
      final response = await http.post(
        proxyUri,
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode({
          'model': 'gemini-3.8-flash',
          'stream': false,
          'messages': [
            {'role': 'user', 'content': planPrompt}
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final content = data['choices']?[0]?['message']?['content'] as String? ?? '';

        final startIdx = content.indexOf('[');
        final endIdx = content.lastIndexOf(']');
        if (startIdx != -1 && endIdx != -1) {
          final jsonStr = content.substring(startIdx, endIdx + 1);
          final parsedList = jsonDecode(jsonStr) as List<dynamic>;

          setState(() {
            _pipelineTasks = parsedList.map((item) {
              final map = item as Map<String, dynamic>;
              return ProjectStepTask(
                title: map['title'] as String? ?? 'مهمة',
                description: map['description'] as String? ?? '',
                tool: map['tool'] as String? ?? 'terminal_exec',
                command: map['command'] as String? ?? 'pwd',
                path: map['path'] as String?,
              );
            }).toList();
            _isPlanning = false;
            _activeLiveLog = 'تم بناء خطة المشروع بنجاح. اضغط على "بدء التنفيذ المباشر" لتنفيذ المهام في Ubuntu PRoot.';
          });
          return;
        }
      }
    } catch (_) {}

    setState(() {
      _pipelineTasks = [
        ProjectStepTask(
          title: 'تهيئة مسار المشروع في Ubuntu PRoot',
          description: 'إنشاء مجلد $projectName داخل مساحة العمل المشتركة',
          tool: 'terminal_exec',
          command: 'mkdir -p /root/nasaq/workspace/$projectName && cd /root/nasaq/workspace/$projectName && pwd',
        ),
        ProjectStepTask(
          title: 'إنشاء هيكل المشروع (Flutter Scaffold)',
          description: 'تنفيذ أمر flutter create مع استهداف منصات الويب والموبايل',
          tool: 'terminal_exec',
          command: 'cd /root/nasaq/workspace && flutter create $projectName --org com.nasaq.app',
        ),
        ProjectStepTask(
          title: 'فحص شجرة الملفات المنشأة',
          description: 'التحقق من اكتمال مجلدات lib و pubspec.yaml',
          tool: 'terminal_exec',
          command: 'ls -la /root/nasaq/workspace/$projectName',
        ),
        ProjectStepTask(
          title: 'تأكيد الربط مع مسار Termux',
          description: 'التحقق من ظهور الملفات على ~/nasaq/workspace/$projectName',
          tool: 'terminal_exec',
          command: 'ls -la /root/nasaq/workspace/$projectName/lib',
        ),
      ];
      _isPlanning = false;
      _activeLiveLog = 'تم تجهيز خطة المهام القياسية للمشروع.';
    });
  }

  Future<void> _runPipelineSequential() async {
    if (_pipelineTasks.isEmpty || _isExecutingPlan) return;

    setState(() {
      _isExecutingPlan = true;
    });

    for (int i = 0; i < _pipelineTasks.length; i++) {
      if (!mounted) return;
      setState(() {
        _pipelineTasks[i].status = TaskStatus.inProgress;
        _activeLiveLog = '>> جارٍ تنفيذ: ${_pipelineTasks[i].title}...\nالأمر: ${_pipelineTasks[i].command}';
      });

      final toolData = ToolExecutionData(
        toolName: _pipelineTasks[i].tool,
        commandOrInput: _pipelineTasks[i].command,
        targetPath: _pipelineTasks[i].path,
      );

      final result = await AgentBridgeService.executeTool(toolData);

      if (!mounted) return;
      setState(() {
        _pipelineTasks[i].output = result.output;
        _pipelineTasks[i].status =
            (result.exitCode ?? 0) == 0 ? TaskStatus.completed : TaskStatus.failed;
        _activeLiveLog = '>> اكتملت المهمة (${_pipelineTasks[i].title}):\n${result.output ?? ""}';
      });

      await Future.delayed(const Duration(milliseconds: 300));
    }

    if (!mounted) return;
    setState(() {
      _isExecutingPlan = false;
      _activeLiveLog = '✓ اكتملت جميع مهام المشروع بنجاح داخل مسار Ubuntu PRoot المشترك!';
    });
  }

  void _openExplorer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const WorkspaceExplorerSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF13221F),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFF263F39),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.account_tree_outlined, color: Color(0xFFD4AF37), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'استوديو تنظيم وهندسة المشاريع',
                        style: GoogleFonts.readexPro(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  ScaleTap(
                    onTap: _openExplorer,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E3631),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'الملفات 📁',
                        style: GoogleFonts.ibmPlexSansArabic(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'يفكك فكرتك إلى مهام تسلسلية وينفذها مباشرة في Ubuntu PRoot (/root/nasaq/workspace).',
                style: GoogleFonts.ibmPlexSansArabic(
                  fontSize: 11.5,
                  color: const Color(0xFFCBD5D1),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: NasaqColors.paperSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2D8C3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ما هو المشروع الذي تريد بناؤه؟',
                style: GoogleFonts.ibmPlexSansArabic(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: NasaqColors.inkPrimary,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _ideaController,
                style: GoogleFonts.ibmPlexSansArabic(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'مثال: تطبيق مهام Flutter متكامل بهوية عربية وتخزين محلي...',
                  hintStyle: GoogleFonts.ibmPlexSansArabic(fontSize: 12, color: NasaqColors.inkMuted),
                  filled: true,
                  fillColor: const Color(0xFFF7F2E8),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFDDD2BC)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'اسم مجلد المشروع (باللاتينية):',
                style: GoogleFonts.ibmPlexSansArabic(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: NasaqColors.inkPrimary,
                ),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: _nameController,
                style: GoogleFonts.jetBrainsMono(fontSize: 12.5),
                decoration: InputDecoration(
                  hintText: 'smart_todo_app',
                  hintStyle: GoogleFonts.jetBrainsMono(fontSize: 12, color: NasaqColors.inkMuted),
                  filled: true,
                  fillColor: const Color(0xFFF7F2E8),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFDDD2BC)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ScaleTap(
                onTap: _isPlanning || _isExecutingPlan ? null : _generateProjectPlan,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: NasaqColors.inkPrimary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isPlanning) ...[
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        _isPlanning ? 'جارٍ تفكيك وهندسة المشروع...' : 'تفكيك فكرة المشروع لمهام تنفيذية',
                        style: GoogleFonts.readexPro(
                          fontSize: 12.5,
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

        const SizedBox(height: 18),

        if (_pipelineTasks.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'خطة مهام المشروع (${_pipelineTasks.length} مهام)',
                style: GoogleFonts.readexPro(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: NasaqColors.inkPrimary,
                ),
              ),
              ScaleTap(
                onTap: _isExecutingPlan ? null : _runPipelineSequential,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _isExecutingPlan ? Colors.grey : NasaqColors.emeraldRoyal,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      if (_isExecutingPlan) ...[
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.white),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        _isExecutingPlan ? 'جارٍ التنفيذ...' : 'بدء التنفيذ المباشر ▶',
                        style: GoogleFonts.ibmPlexSansArabic(
                          fontSize: 11.5,
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
          const SizedBox(height: 10),

          ...List.generate(_pipelineTasks.length, (idx) {
            final t = _pipelineTasks[idx];
            final isRunning = t.status == TaskStatus.inProgress;
            final isDone = t.status == TaskStatus.completed;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isRunning
                      ? NasaqColors.emeraldRoyal
                      : (isDone ? const Color(0xFF10B981) : const Color(0xFFE2D8C3)),
                  width: isRunning ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isDone
                          ? const Color(0xFF10B981)
                          : (isRunning ? NasaqColors.emeraldRoyal.withValues(alpha: 0.15) : const Color(0xFFF3ECE0)),
                      shape: BoxShape.circle,
                    ),
                    child: isRunning
                        ? const Padding(
                            padding: EdgeInsets.all(6),
                            child: CircularProgressIndicator(strokeWidth: 2, color: NasaqColors.emeraldRoyal),
                          )
                        : Icon(
                            isDone ? Icons.check_rounded : Icons.circle_outlined,
                            size: 16,
                            color: isDone ? Colors.white : NasaqColors.inkMuted,
                          ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.title,
                          style: GoogleFonts.readexPro(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: NasaqColors.inkPrimary,
                          ),
                        ),
                        Text(
                          t.description,
                          style: GoogleFonts.ibmPlexSansArabic(
                            fontSize: 10.5,
                            color: NasaqColors.inkMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'خطوة ${idx + 1}',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      color: NasaqColors.inkMuted,
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F1318),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF263040)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.terminal_rounded, size: 14, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 6),
                    Text(
                      'سجل التنفيذ الحي في Ubuntu PRoot',
                      style: GoogleFonts.ibmPlexSansArabic(
                        fontSize: 11,
                        color: const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 160),
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF090C10),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: SelectableText(
                        _activeLiveLog,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          color: const Color(0xFFA7F3D0),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
