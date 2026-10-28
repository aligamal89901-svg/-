import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/nasaq_theme.dart';
import '../../../core/widgets/scale_tap.dart';

class AgentToolModel {
  final String id;
  final String name;
  final String commandCode;
  final String description;
  final IconData icon;
  final Color color;

  const AgentToolModel({
    required this.id,
    required this.name,
    required this.commandCode,
    required this.description,
    required this.icon,
    required this.color,
  });
}

const List<AgentToolModel> _agentTools = [
  AgentToolModel(
    id: 'code_synth',
    name: 'مولّد المعماريات',
    commandCode: 'tool.code_architect',
    description: 'يبني هيكل ملفات المشروع ويفحص التبعيات تلقائياً',
    icon: Icons.account_tree_rounded,
    color: Color(0xFF0F766E),
  ),
  AgentToolModel(
    id: 'term_exec',
    name: 'منفّذ الطرفية',
    commandCode: 'tool.terminal_runner',
    description: 'يولّد سلاسل أوامر Ubuntu و Termux للتشغيل المباشر',
    icon: Icons.terminal_rounded,
    color: Color(0xFFD97706),
  ),
  AgentToolModel(
    id: 'ui_craft',
    name: 'مهندس الواجهات',
    commandCode: 'tool.rtl_ui_builder',
    description: 'يصمم واجهات عصرية متوافقة مع معايير نَسَق',
    icon: Icons.auto_awesome_mosaic_rounded,
    color: Color(0xFF7C3AED),
  ),
  AgentToolModel(
    id: 'bug_hunter',
    name: 'محلل الأخطاء',
    commandCode: 'tool.log_inspector',
    description: 'يفكك سجلات الأخطاء ويقترح الحل الجذري فوراً',
    icon: Icons.manage_search_rounded,
    color: Color(0xFFDC2626),
  ),
];

class NasaqAgentView extends StatefulWidget {
  const NasaqAgentView({super.key});

  @override
  State<NasaqAgentView> createState() => _NasaqAgentViewState();
}

class _NasaqAgentViewState extends State<NasaqAgentView> {
  int _selectedMissionIndex = 0;
  bool _isSimulating = false;
  int _activeStep = 2;

  final List<Map<String, String>> _sampleMissions = [
    {
      'title': 'بناء نظام مصادقة كامل مع واجهة عربية',
      'tools': 'code_architect + rtl_ui_builder',
      'prompt': 'قم بدور نَسَق إيجنت: خطط ونفذ بناء نظام تسجيل دخول متكامل بهوية عربية أصيلة مع تقسيم الطبقات البرمجية.',
    },
    {
      'title': 'أتمتة بيئة عمل Termux و Ubuntu محلياً',
      'tools': 'terminal_runner + log_inspector',
      'prompt': 'قم بدور نَسَق إيجنت: اكتب سكربت أتمتة كامل يربط Termux بـ Ubuntu ويشغل خادم الويب والجسر المحلي بضغطة واحدة.',
    },
    {
      'title': 'فحص وتحسين أداء الواجهات (60fps Audit)',
      'tools': 'rtl_ui_builder + code_architect',
      'prompt': 'قم بدور نَسَق إيجنت: حلل معمارية واجهات Flutter وقدم خطة عملية لرفع الأداء إلى 60 إطاراً في الثانية.',
    },
  ];

  void _triggerSimulation() async {
    if (_isSimulating) return;
    setState(() {
      _isSimulating = true;
      _activeStep = 0;
    });
    for (int i = 0; i < 4; i++) {
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      setState(() => _activeStep = i);
    }
    if (!mounted) return;
    setState(() => _isSimulating = false);
  }

  @override
  Widget build(BuildContext context) {
    final selectedMission = _sampleMissions[_selectedMissionIndex];

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
      children: [
        // بطاقة التعريف بـ نَسَق إيجنت
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF14110E), Color(0xFF0A3D38)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: NasaqColors.goldArabic.withValues(alpha: 0.5),
              width: 1.3,
            ),
            boxShadow: [
              BoxShadow(
                color: NasaqColors.emeraldRoyal.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: NasaqColors.goldArabic.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: NasaqColors.goldArabic.withValues(alpha: 0.5),
                      ),
                    ),
                    child: const Icon(
                      Icons.hub_rounded,
                      color: NasaqColors.goldMuted,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'نَسَق إيجنت (NASAQ Agent)',
                          style: GoogleFonts.readexPro(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'وكيل ذكي ذاتي التخطيط والتنفيذ',
                          style: GoogleFonts.ibmPlexSansArabic(
                            fontSize: 11.5,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'يقوم باستدعاء أدوات النظام، يقسم الأهداف المعقدة، وينفذ المهام متسلسلة لتقديم مخرجات متكاملة.',
                style: GoogleFonts.ibmPlexSansArabic(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.85),
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 14),

              // مسار عمل الوكيل
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: NasaqColors.goldArabic.withValues(alpha: 0.25),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'مسار عمل الوكيل (Pipeline)',
                          style: GoogleFonts.readexPro(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: NasaqColors.goldMuted,
                          ),
                        ),
                        ScaleTap(
                          onTap: _triggerSimulation,
                          child: Text(
                            _isSimulating ? 'جارٍ الفحص...' : 'محاكاة ↺',
                            style: GoogleFonts.ibmPlexSansArabic(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: NasaqColors.goldMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _PipelineStepNode(label: 'التحليل', isActive: _activeStep >= 0),
                        _PipelineConnector(isActive: _activeStep >= 1),
                        _PipelineStepNode(label: 'الأدوات', isActive: _activeStep >= 1),
                        _PipelineConnector(isActive: _activeStep >= 2),
                        _PipelineStepNode(label: 'البناء', isActive: _activeStep >= 2),
                        _PipelineConnector(isActive: _activeStep >= 3),
                        _PipelineStepNode(label: 'التسليم', isActive: _activeStep >= 3),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms),

        const SizedBox(height: 20),

        Text(
          'أدوات الوكيل (Tools Arsenal)',
          style: GoogleFonts.readexPro(
            fontSize: 15.5,
            fontWeight: FontWeight.bold,
            color: NasaqColors.inkPrimary,
          ),
        ),
        const SizedBox(height: 10),

        // بطاقات الأدوات بمقاسات آمنة لجميع الشاشات
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.05,
          ),
          itemCount: _agentTools.length,
          itemBuilder: (context, index) {
            final tool = _agentTools[index];
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: NasaqColors.paperSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: tool.color.withValues(alpha: 0.35),
                  width: 1.1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: tool.color.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(tool.icon, color: tool.color, size: 18),
                      ),
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tool.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.readexPro(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: NasaqColors.inkPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tool.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.ibmPlexSansArabic(
                          fontSize: 10.5,
                          color: NasaqColors.inkMuted,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 20),

        Text(
          'مهام تجريبية جاهزة',
          style: GoogleFonts.readexPro(
            fontSize: 15.5,
            fontWeight: FontWeight.bold,
            color: NasaqColors.inkPrimary,
          ),
        ),
        const SizedBox(height: 10),

        ...List.generate(_sampleMissions.length, (idx) {
          final mission = _sampleMissions[idx];
          final isSelected = idx == _selectedMissionIndex;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ScaleTap(
              onTap: () => setState(() => _selectedMissionIndex = idx),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFDFBF7) : NasaqColors.paperSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? NasaqColors.emeraldRoyal
                        : NasaqColors.goldArabic.withValues(alpha: 0.3),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      color: isSelected ? NasaqColors.emeraldRoyal : NasaqColors.inkMuted,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mission['title']!,
                            style: GoogleFonts.readexPro(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: NasaqColors.inkPrimary,
                            ),
                          ),
                          Text(
                            mission['tools']!,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              color: NasaqColors.emeraldRoyal,
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
        }),

        const SizedBox(height: 10),

        ScaleTap(
          onTap: () {
            context.push('/chat', extra: {
              'title': 'نَسَق إيجنت • وكيل المهام',
              'subtitle': 'تخطيط ذاتي وتنفيذ متعدد الأدوات',
              'accentColor': NasaqColors.emeraldRoyal,
              'starterPrompts': [selectedMission['prompt']!],
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [NasaqColors.emeraldRoyal, Color(0xFF08423E)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: NasaqColors.goldArabic.withValues(alpha: 0.5),
              ),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.bolt_rounded, color: NasaqColors.goldMuted, size: 20),
                const SizedBox(width: 6),
                Text(
                  'بدء المهمة مع نَسَق إيجنت',
                  style: GoogleFonts.readexPro(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PipelineStepNode extends StatelessWidget {
  final String label;
  final bool isActive;

  const _PipelineStepNode({required this.label, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: isActive ? NasaqColors.emeraldRoyal : Colors.white12,
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive ? NasaqColors.goldMuted : Colors.white24,
              ),
            ),
            child: Icon(
              isActive ? Icons.check_rounded : Icons.circle_outlined,
              size: 12,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.ibmPlexSansArabic(
              fontSize: 9.5,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? Colors.white : Colors.white54,
            ),
          ),
        ],
      ),
    );
  }
}

class _PipelineConnector extends StatelessWidget {
  final bool isActive;
  const _PipelineConnector({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: 2,
      margin: const EdgeInsets.only(bottom: 16),
      color: isActive ? NasaqColors.goldMuted : Colors.white24,
    );
  }
}
