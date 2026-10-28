import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/nasaq_theme.dart';
import '../../../core/widgets/nasaq_background.dart';
import '../../../core/widgets/scale_tap.dart';
import '../../specializations/domain/specialization_model.dart';

class TerminalLesson {
  final int level;
  final String title;
  final String category;
  final String explanation;
  final String termuxVsUbuntuNote;
  final String targetCommand;
  final String expectedOutput;
  final int xpReward;
  final String badgeReward;

  const TerminalLesson({
    required this.level,
    required this.title,
    required this.category,
    required this.explanation,
    required this.termuxVsUbuntuNote,
    required this.targetCommand,
    required this.expectedOutput,
    required this.xpReward,
    required this.badgeReward,
  });
}

const List<TerminalLesson> _lessons = [
  TerminalLesson(
    level: 1,
    title: 'المستوى 1: استكشاف المسار والتنقل',
    category: 'pwd, ls, cd',
    explanation: 'يعرض الأمر pwd مسارك الحالي في النظام، بينما يعرض ls محتويات المجلد.',
    termuxVsUbuntuNote: 'في Termux مسارك هو /data/data/com.termux/files/home، بينما في Ubuntu هو /root.',
    targetCommand: 'pwd',
    expectedOutput: '/root/nasaq\n[نجاح] أنت الآن داخل المسار المربوط لمشروع نَسَق!',
    xpReward: 50,
    badgeReward: 'ملاح المسارات',
  ),
  TerminalLesson(
    level: 2,
    title: 'المستوى 2: إدارة الملفات والمجلدات',
    category: 'mkdir, cat, cp',
    explanation: 'ينشئ الأمر mkdir-p المجلدات المتداخلة بأمان دون خطأ إن كانت موجودة مسبقاً.',
    termuxVsUbuntuNote: 'عند الربط بـ --bind، أي مجلد تنشئه في Ubuntu يظهر فوراً في Termux.',
    targetCommand: 'mkdir -p assets/skills',
    expectedOutput: 'تم إنشاء المجلد assets/skills بنجاح داخل هيكل المشروع.',
    xpReward: 65,
    badgeReward: 'مهندس الملفات',
  ),
  TerminalLesson(
    level: 3,
    title: 'المستوى 3: البحث والنصوص والأنابيب',
    category: 'grep, find, head',
    explanation: 'يبحث الأمر grep داخل الملفات عن نص محدد بسرعة فائقة.',
    termuxVsUbuntuNote: 'أدوات grep و sed تعمل بنفس الصياغة القياسية في البيئتين.',
    targetCommand: 'grep nasaq pubspec.yaml',
    expectedOutput: 'name: nasaq\ndescription: "NASAQ | نَسَق - منصة الذكاء الاصطناعي"',
    xpReward: 80,
    badgeReward: 'صائد النصوص',
  ),
  TerminalLesson(
    level: 4,
    title: 'المستوى 4: الصلاحيات والعمليات',
    category: 'chmod, ps, top',
    explanation: 'يمنح الأمر chmod +x صلاحية التنفيذ لملفات السكربتات البرمجية.',
    termuxVsUbuntuNote: 'تحذير أمني: تجنب استخدام chmod 777 أو rm -rf / لحماية نظامك.',
    targetCommand: 'chmod +x build.sh',
    expectedOutput: 'تم منح صلاحية التنفيذ للملف build.sh بنجاح.',
    xpReward: 95,
    badgeReward: 'حارس الصلاحيات',
  ),
  TerminalLesson(
    level: 5,
    title: 'المستوى 5: الحزم و proot-distro',
    category: 'pkg, apt, git',
    explanation: 'إدارة الحزم والربط بين بيئة أندرويد وتوزيعة لينكس.',
    termuxVsUbuntuNote: 'قاعدة ذهبية: استخدم pkg install داخل Termux، واستخدم apt install داخل Ubuntu.',
    targetCommand: 'flutter analyze',
    expectedOutput: 'Analyzing nasaq...\nNo issues found! (ran in 1.4s)',
    xpReward: 120,
    badgeReward: 'سيد الطرفية',
  ),
];

class TerminalLabScreen extends ConsumerStatefulWidget {
  const TerminalLabScreen({super.key});

  @override
  ConsumerState<TerminalLabScreen> createState() => _TerminalLabScreenState();
}

class _TerminalLabScreenState extends ConsumerState<TerminalLabScreen> {
  int _selectedLevelIdx = 0;
  final TextEditingController _cmdController = TextEditingController();
  final List<String> _terminalLogs = [
    'NASAQ Safe Virtual Terminal v2.5 [Sandbox Mode]',
    'اكتب الأمر المطلوب في الدرس أو اضغط "تنفيذ فوري" للتجربة الآمنة.',
  ];

  @override
  void dispose() {
    _cmdController.dispose();
    super.dispose();
  }

  void _runCommand(String rawCmd) {
    final cmd = rawCmd.trim();
    if (cmd.isEmpty) return;

    final lesson = _lessons[_selectedLevelIdx];
    setState(() {
      _terminalLogs.add('root@nasaq-lab:~/nasaq# $cmd');
    });

    if (cmd.contains('rm -rf /')) {
      setState(() {
        _terminalLogs.add(
          '[تحذير أمني حرج!] هذا الأمر يدمر النظام بالكامل. تم حظره بواسطة درع نَسَق الآمن.',
        );
      });
      _cmdController.clear();
      return;
    }

    if (cmd == lesson.targetCommand || cmd.startsWith(lesson.targetCommand.split(' ').first)) {
      setState(() {
        _terminalLogs.add(lesson.expectedOutput);
        _terminalLogs.add('✨ أحسنت! ربحت +${lesson.xpReward} XP ووسام "${lesson.badgeReward}"');
      });
      ref.read(userProgressProvider.notifier).addXp(
            lesson.xpReward,
            newBadge: lesson.badgeReward,
            levelCompleted: lesson.level,
          );
    } else if (cmd == 'help') {
      setState(() {
        _terminalLogs.add('الأوامر المتاحة: pwd, ls, mkdir, grep, chmod, flutter analyze, clear');
      });
    } else if (cmd == 'clear') {
      setState(() {
        _terminalLogs.clear();
      });
    } else {
      setState(() {
        _terminalLogs.add(
          'تلميح: جرب كتابة الأمر المخصص لهذا المستوى: ${lesson.targetCommand}',
        );
      });
    }
    _cmdController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(userProgressProvider);
    final currentLesson = _lessons[_selectedLevelIdx];

    return Scaffold(
      body: NasaqBackground(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 16, 14),
              decoration: BoxDecoration(
                color: NasaqColors.glassSurface,
                border: Border(
                  bottom: BorderSide(color: NasaqColors.glassBorderGold),
                ),
              ),
              child: Row(
                children: [
                  ScaleTap(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: NasaqColors.paperSurface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: NasaqColors.goldArabic.withValues(alpha: 0.35),
                        ),
                      ),
                      child: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'مختبر الطرفية التفاعلي',
                          style: GoogleFonts.readexPro(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: NasaqColors.inkPrimary,
                          ),
                        ),
                        Text(
                          'بيئة محاكاة آمنة • Termux & Ubuntu Linux',
                          style: GoogleFonts.ibmPlexSansArabic(
                            fontSize: 11.5,
                            color: NasaqColors.inkMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: NasaqColors.emeraldRoyal,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.bolt_rounded, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${progress.xp} XP',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsetsDirectional.all(16),
                physics: const BouncingScrollPhysics(),
                children: [
                  // شريط المستويات الخمسة
                  SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _lessons.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, idx) {
                        final isSelected = idx == _selectedLevelIdx;
                        return ScaleTap(
                          onTap: () => setState(() => _selectedLevelIdx = idx),
                          child: Container(
                            padding: const EdgeInsetsDirectional.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? NasaqColors.emeraldRoyal
                                  : NasaqColors.paperSurface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.transparent
                                    : NasaqColors.goldArabic.withValues(alpha: 0.35),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'مستوى ${idx + 1}',
                              style: GoogleFonts.readexPro(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : NasaqColors.inkPrimary,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // بطاقة شرح الدرس والفرق بين Termux و Ubuntu
                  Container(
                    padding: const EdgeInsetsDirectional.all(18),
                    decoration: BoxDecoration(
                      color: NasaqColors.paperSurface,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: NasaqColors.goldArabic.withValues(alpha: 0.35),
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                currentLesson.title,
                                style: GoogleFonts.readexPro(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.bold,
                                  color: NasaqColors.inkPrimary,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsetsDirectional.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: NasaqColors.emeraldRoyal.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                currentLesson.category,
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: NasaqColors.emeraldRoyal,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currentLesson.explanation,
                          style: GoogleFonts.ibmPlexSansArabic(
                            fontSize: 13.5,
                            color: NasaqColors.inkPrimary,
                            height: 1.65,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsetsDirectional.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9F5EB),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: NasaqColors.goldArabic.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.compare_arrows_rounded,
                                color: NasaqColors.goldArabic,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  currentLesson.termuxVsUbuntuNote,
                                  style: GoogleFonts.ibmPlexSansArabic(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: NasaqColors.inkPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'الأمر المطلوب: ${currentLesson.targetCommand}',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: NasaqColors.emeraldRoyal,
                              ),
                            ),
                            ScaleTap(
                              onTap: () => _runCommand(currentLesson.targetCommand),
                              child: Container(
                                padding: const EdgeInsetsDirectional.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: NasaqColors.emeraldRoyal,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'جرب بنفسك الآن (+${currentLesson.xpReward} XP)',
                                  style: GoogleFonts.ibmPlexSansArabic(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // شاشة محاكي الطرفية المظلمة
                  Container(
                    height: 230,
                    padding: const EdgeInsetsDirectional.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D1117),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: NasaqColors.goldArabic.withValues(alpha: 0.35),
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'root@nasaq-sandbox:~/nasaq',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 11.5,
                                color: NasaqColors.goldMuted,
                              ),
                            ),
                          ],
                        ),
                        const Divider(color: Colors.white12, height: 18),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _terminalLogs.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsetsDirectional.only(bottom: 6),
                                child: Text(
                                  _terminalLogs[index],
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 12.5,
                                    color: const Color(0xFFE2E8F0),
                                    height: 1.5,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              '# ',
                              style: GoogleFonts.jetBrainsMono(
                                color: NasaqColors.emeraldLight,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _cmdController,
                                onSubmitted: _runCommand,
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 13,
                                  color: Colors.white,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'اكتب الأمر هنا مثل: ${currentLesson.targetCommand}',
                                  hintStyle: GoogleFonts.ibmPlexSansArabic(
                                    fontSize: 12,
                                    color: Colors.white38,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => _runCommand(_cmdController.text),
                              icon: const Icon(
                                Icons.play_circle_fill_rounded,
                                color: NasaqColors.emeraldLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
