import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/nasaq_theme.dart';
import '../../../core/widgets/nasaq_background.dart';
import '../../../core/widgets/nasaq_glass_app_bar.dart';
import '../../../core/widgets/scale_tap.dart';
import '../../agent/presentation/project_studio_view.dart';
import '../../specializations/domain/specialization_model.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;
  int _agentSubTab = 0; // 0 = استوديو تنظيم المشاريع، 1 = المحادثة المباشرة
  String _searchQuery = '';
  String _selectedCategoryFilter = 'الكل';

  final List<String> _categories = [
    'الكل',
    'هندسة وبرمجة',
    'تصميم وواجهات',
    'أعمال وتحليل',
  ];

  String _getTimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'صباح الخير والعمل';
    if (hour >= 12 && hour < 17) return 'طاب يومك بكل عطاء';
    return 'مساء الفكر والإنجاز';
  }

  bool _matchesCategory(SpecializationModel spec) {
    if (_selectedCategoryFilter == 'الكل') return true;
    if (_selectedCategoryFilter == 'هندسة وبرمجة') {
      return spec.id == 'code' || spec.id == 'terminal' || spec.id == 'debug';
    }
    if (_selectedCategoryFilter == 'تصميم وواجهات') {
      return spec.id == 'design' || spec.id == 'writing' || spec.id == 'translation';
    }
    return spec.id == 'business' || spec.id == 'research';
  }

  void _openSpecialization(SpecializationModel spec) {
    context.push('/chat', extra: {
      'title': spec.title,
      'subtitle': spec.subtitle,
      'accentColor': spec.accentColor,
      'slashCommand': spec.slashCommand,
      'starterPrompts': spec.starterPrompts,
    });
  }

  void _openAgentChatDirect() {
    context.push('/chat', extra: {
      'title': 'نَسَق إيجنت (Agent)',
      'subtitle': 'بيئة تنفيذ المهام وأتمتة الأوامر في Ubuntu PRoot',
      'accentColor': const Color(0xFF2C3E50),
      'starterPrompts': [
        'افحص مسار العمل ومحتويات المجلدات الحالية',
        'أنشئ سكربت أتمتة لربط الخادم',
      ],
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(userProgressProvider);
    final filteredSpecs = nasaqSpecializations.where((s) {
      final matchesFilter = _matchesCategory(s);
      if (!matchesFilter) return false;
      if (_searchQuery.trim().isEmpty) return true;
      return s.title.contains(_searchQuery) ||
          s.subtitle.contains(_searchQuery) ||
          s.slashCommand.contains(_searchQuery);
    }).toList();

    return Scaffold(
      extendBody: true,
      bottomNavigationBar: _FloatingCurvedGlassDock(
        currentIndex: _currentIndex,
        onTap: (index) {
          HapticFeedback.selectionClick();
          setState(() => _currentIndex = index);
        },
      ),
      body: NasaqBackground(
        child: Column(
          children: [
            NasaqGlassAppBar(
              title: _currentIndex == 1 ? 'نَسَق إيجنت • بيئة العمل' : _getTimeGreeting(),
              subtitle: _currentIndex == 1
                  ? 'محطة أتمتة وهندسة المشاريع في Ubuntu PRoot'
                  : 'نَسَق • منصة العمل والذكاء المتخصص',
              onAvatarTap: () => setState(() => _currentIndex = 3),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _buildBodyForIndex(progress, filteredSpecs),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyForIndex(
    UserProgressState progress,
    List<SpecializationModel> filteredSpecs,
  ) {
    // تبويب نَسَق إيجنت المتكامل (الزر الثاني)
    if (_currentIndex == 1) {
      return Column(
        children: [
          // شريط التبديل بين: [استوديو المشاريع] و [المحادثة التنفيذية]
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF3ECE0),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFDDD2BC)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ScaleTap(
                    onTap: () => setState(() => _agentSubTab = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _agentSubTab == 0 ? NasaqColors.inkPrimary : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'استوديو تنظيم المشاريع',
                        style: GoogleFonts.ibmPlexSansArabic(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _agentSubTab == 0 ? Colors.white : NasaqColors.inkPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ScaleTap(
                    onTap: () {
                      _openAgentChatDirect();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'المحادثة المباشرة',
                            style: GoogleFonts.ibmPlexSansArabic(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: NasaqColors.inkPrimary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.open_in_new_rounded, size: 14, color: NasaqColors.inkPrimary),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Expanded(child: ProjectStudioView()),
        ],
      );
    }

    if (_currentIndex == 3) {
      return _ProfileAndBadgesView(progress: progress);
    }

    // الصفحة الرئيسية الافتراضية
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ArabesqueDiwanHero(
                  xp: progress.xp,
                  streakDays: progress.streakDays,
                  onGeneralChatTap: () => context.push('/chat', extra: {
                    'title': 'محادثة عامة',
                    'subtitle': 'حوار شامل واستشارات حرة',
                    'accentColor': NasaqColors.emeraldRoyal,
                  }),
                  onAgentTap: () => setState(() => _currentIndex = 1),
                  onLabTap: () => context.push('/terminal-lab'),
                ),
                const SizedBox(height: 18),

                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: NasaqColors.paperSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFDDD2BC),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search_rounded,
                        color: NasaqColors.inkMuted,
                        size: 19,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          onChanged: (val) => setState(() => _searchQuery = val),
                          style: GoogleFonts.ibmPlexSansArabic(fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'ابحث في العقول المتخصصة...',
                            hintStyle: GoogleFonts.ibmPlexSansArabic(
                              color: NasaqColors.inkMuted,
                              fontSize: 12,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ديوان الاختصاصات',
                      style: GoogleFonts.readexPro(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: NasaqColors.inkPrimary,
                      ),
                    ),
                    Text(
                      '${filteredSpecs.length} تخصصات',
                      style: GoogleFonts.ibmPlexSansArabic(
                        fontSize: 11.5,
                        color: NasaqColors.inkMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                SizedBox(
                  height: 34,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, idx) {
                      final cat = _categories[idx];
                      final isSelected = cat == _selectedCategoryFilter;
                      return ScaleTap(
                        onTap: () => setState(() => _selectedCategoryFilter = cat),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? NasaqColors.inkPrimary
                                : const Color(0xFFF7F2E9),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? NasaqColors.inkPrimary
                                  : const Color(0xFFDDD2BC),
                            ),
                          ),
                          child: Text(
                            cat,
                            style: GoogleFonts.ibmPlexSansArabic(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : NasaqColors.inkPrimary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 110),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.84,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final spec = filteredSpecs[index];
                return _ArabianArchitecturalSpecCard(
                  spec: spec,
                  onTap: () => _openSpecialization(spec),
                );
              },
              childCount: filteredSpecs.length,
            ),
          ),
        ),
      ],
    );
  }
}

class _ArabesqueDiwanHero extends StatelessWidget {
  final int xp;
  final int streakDays;
  final VoidCallback onGeneralChatTap;
  final VoidCallback onAgentTap;
  final VoidCallback onLabTap;

  const _ArabesqueDiwanHero({
    required this.xp,
    required this.streakDays,
    required this.onGeneralChatTap,
    required this.onAgentTap,
    required this.onLabTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF13221F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF243B36),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'النشاط: $streakDays أيام متتالية • $xp نقطة',
                style: GoogleFonts.ibmPlexSansArabic(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFB4C7C2),
                ),
              ),
              ScaleTap(
                onTap: onLabTap,
                child: Text(
                  'المختبر البرمجي ←',
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFD4AF37),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'منظومة الفكر العربي والأتمتة',
            style: GoogleFonts.readexPro(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'حوار تحليلي معماري وتنفيذ للمهام البرمجية بدقة وهدوء.',
            style: GoogleFonts.ibmPlexSansArabic(
              fontSize: 12,
              color: const Color(0xFFC7D3D0),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ScaleTap(
                  onTap: onGeneralChatTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'حوار شامل',
                      style: GoogleFonts.readexPro(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF13221F),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ScaleTap(
                  onTap: onAgentTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F3530),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF33544D),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'استوديو الإيجنت ⚡',
                      style: GoogleFonts.readexPro(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ArabianArchitecturalSpecCard extends StatelessWidget {
  final SpecializationModel spec;
  final VoidCallback onTap;

  const _ArabianArchitecturalSpecCard({
    required this.spec,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: NasaqColors.paperSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE2D8C3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(spec.icon, color: NasaqColors.inkPrimary, size: 22),
                Text(
                  spec.slashCommand,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: NasaqColors.inkMuted,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  spec.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.readexPro(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: NasaqColors.inkPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  spec.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 10.5,
                    color: NasaqColors.inkMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingCurvedGlassDock extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _FloatingCurvedGlassDock({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const items = [
      _DockItemData(
        icon: Icons.grid_view_rounded,
        activeIcon: Icons.grid_view_rounded,
        label: 'الرئيسية',
      ),
      _DockItemData(
        icon: Icons.account_tree_outlined,
        activeIcon: Icons.account_tree_rounded,
        label: 'نَسَق إيجنت',
      ),
      _DockItemData(
        icon: Icons.layers_outlined,
        activeIcon: Icons.layers_rounded,
        label: 'الاختصاصات',
      ),
      _DockItemData(
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        label: 'حسابي',
      ),
    ];

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              height: 64,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: const Color(0xF2F7F2E8),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFFDDD2BC),
                  width: 1,
                ),
              ),
              child: Row(
                children: List.generate(items.length, (idx) {
                  final item = items[idx];
                  final isSelected = idx == currentIndex;
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onTap(idx),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? NasaqColors.inkPrimary : null,
                          borderRadius: BorderRadius.circular(19),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isSelected ? item.activeIcon : item.icon,
                              size: 19,
                              color: isSelected ? Colors.white : NasaqColors.inkMuted,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.label,
                              style: GoogleFonts.readexPro(
                                fontSize: 9.5,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? Colors.white : NasaqColors.inkMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DockItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _DockItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class _ProfileAndBadgesView extends StatelessWidget {
  final UserProgressState progress;
  const _ProfileAndBadgesView({required this.progress});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 110),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: NasaqColors.paperSurface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFDDD2BC),
            ),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.person_pin_rounded,
                size: 36,
                color: NasaqColors.inkPrimary,
              ),
              const SizedBox(height: 8),
              Text(
                'الملف الشخصي والأنشطة',
                style: GoogleFonts.readexPro(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: NasaqColors.inkPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'الرصيد التراكمي: ${progress.xp} نقطة عمل',
                style: GoogleFonts.ibmPlexSansArabic(
                  fontSize: 12,
                  color: NasaqColors.inkMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
