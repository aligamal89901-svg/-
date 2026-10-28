import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SpecializationModel {
  final String id;
  final String title;
  final String subtitle;
  final String slashCommand;
  final String arabicWatermark;
  final String badgeTag;
  final IconData icon;
  final Color accentColor;
  final List<String> starterPrompts;

  const SpecializationModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.slashCommand,
    required this.arabicWatermark,
    required this.badgeTag,
    required this.icon,
    required this.accentColor,
    required this.starterPrompts,
  });
}

const List<SpecializationModel> nasaqSpecializations = [
  SpecializationModel(
    id: 'design',
    title: 'عقل المصمم',
    subtitle: 'هندسة واجهات UI/UX، سلم الطباعة، وتناسق الألوان',
    slashCommand: '/design',
    arabicWatermark: 'ص',
    badgeTag: 'UI/UX • Tokens',
    icon: Icons.auto_awesome_mosaic_rounded,
    accentColor: Color(0xFF7C3AED),
    starterPrompts: [
      'صمم بطاقة ملف شخصي فاخرة بالثيم الورقي العربي',
      'راجع تباين الألوان وسلم الطباعة في شاشة الدخول',
      'ابنِ نظام Design Tokens لتطبيق مالي عربي',
    ],
  ),
  SpecializationModel(
    id: 'code',
    title: 'البرمجة والمعمارية',
    subtitle: 'كود Flutter نظيف، معمارية Feature-first واختبارات',
    slashCommand: '/code',
    arabicWatermark: 'ب',
    badgeTag: 'Clean Code',
    icon: Icons.developer_mode_rounded,
    accentColor: Color(0xFF2563EB),
    starterPrompts: [
      'ابنِ معمارية Riverpod نظيفة لإدارة حالة السلة',
      'اكتب ويدجت شريط علوي زجاجي بأداء 60fps',
      'كيف أفصل طبقة البيانات عن الواجهة في Flutter؟',
    ],
  ),
  SpecializationModel(
    id: 'terminal',
    title: 'معمل الطرفية',
    subtitle: 'احتراف Termux و Linux Ubuntu وإدارة الحزم والأنابيب',
    slashCommand: '/term',
    arabicWatermark: 'ط',
    badgeTag: 'Termux • Linux',
    icon: Icons.terminal_rounded,
    accentColor: Color(0xFF0D9488),
    starterPrompts: [
      'ما الفرق بين pkg في Termux و apt في Ubuntu؟',
      'اشرح ربط المجلدات بـ --bind في proot-distro',
      'أعطني أوامر فحص العمليات وإغلاق المنافذ العالقة',
    ],
  ),
  SpecializationModel(
    id: 'debug',
    title: 'فاحص الأخطاء',
    subtitle: 'تشخيص السبب الجذري للأخطاء البرمجية وطرق الوقاية',
    slashCommand: '/debug',
    arabicWatermark: 'ف',
    badgeTag: 'Root Cause',
    icon: Icons.troubleshoot_rounded,
    accentColor: Color(0xFFDC2626),
    starterPrompts: [
      'حلل خطأ RenderFlex overflowed في Flutter',
      'لماذا يفشل حل إصدارات الحزم في pubspec.yaml؟',
      'عالج تحذير use_build_context_synchronously',
    ],
  ),
  SpecializationModel(
    id: 'writing',
    title: 'الكتابة العربية',
    subtitle: 'صياغة إبداعية، تدقيق لغوي، وتحويل اللهجة إلى فصحى',
    slashCommand: '/write',
    arabicWatermark: 'ض',
    badgeTag: 'بلاغة وفصاحة',
    icon: Icons.history_edu_rounded,
    accentColor: Color(0xFFD97706),
    starterPrompts: [
      'حول هذه الفكرة العامية إلى نص تسويقي فصيح وفاخر',
      'صغ نصوص Microcopy دافئة لشاشات التطبيق الفارغة',
      'دقق هذا النص لغوياً وحسن إيقاعه البلاغي',
    ],
  ),
  SpecializationModel(
    id: 'translation',
    title: 'الترجمة والتعلم',
    subtitle: 'ترجمة احترافية بسياق ثقافي دقيق وشرح الفروق اللغوية',
    slashCommand: '/lang',
    arabicWatermark: 'ت',
    badgeTag: 'سياق دقيق',
    icon: Icons.translate_rounded,
    accentColor: Color(0xFFDB2777),
    starterPrompts: [
      'ترجم مصطلحات هندسة الواجهات إلى عربية أصيلة',
      'اشرح الفروق الدقيقة بين المصطلحات التقنية الإنجليزية',
    ],
  ),
  SpecializationModel(
    id: 'business',
    title: 'الأعمال والمشاريع',
    subtitle: 'تحليل الأفكار الريادية، خطط الإطلاق، ونماذج الجدوى',
    slashCommand: '/biz',
    arabicWatermark: 'م',
    badgeTag: 'استراتيجية',
    icon: Icons.insights_rounded,
    accentColor: Color(0xFF0284C7),
    starterPrompts: [
      'حلل جدوى إطلاق تطبيق ذكاء اصطناعي عربي متخصص',
      'ضع خطة تسويق وإطلاق أولي MVP في 30 يوماً',
    ],
  ),
  SpecializationModel(
    id: 'research',
    title: 'البحث والتحليل',
    subtitle: 'تلخيص معمق، مقارنات منهجية، وجداول قرارات ذكية',
    slashCommand: '/study',
    arabicWatermark: 'ح',
    badgeTag: 'مقارنات معمقة',
    icon: Icons.manage_search_rounded,
    accentColor: Color(0xFF4F46E5),
    starterPrompts: [
      'قارن بين Riverpod و Bloc في المشاريع الضخمة',
      'لخص أفضل ممارسات الأمان في تطبيقات الويب',
    ],
  ),
];

class UserProgressState {
  final int xp;
  final int streakDays;
  final int completedTerminalLevels;
  final List<String> badges;

  const UserProgressState({
    this.xp = 140,
    this.streakDays = 4,
    this.completedTerminalLevels = 1,
    this.badges = const ['معماري البدايات', 'مستكشف نَسَق'],
  });

  UserProgressState copyWith({
    int? xp,
    int? streakDays,
    int? completedTerminalLevels,
    List<String>? badges,
  }) {
    return UserProgressState(
      xp: xp ?? this.xp,
      streakDays: streakDays ?? this.streakDays,
      completedTerminalLevels:
          completedTerminalLevels ?? this.completedTerminalLevels,
      badges: badges ?? this.badges,
    );
  }
}

class UserProgressNotifier extends StateNotifier<UserProgressState> {
  UserProgressNotifier() : super(const UserProgressState());

  void addXp(int points, {String? newBadge, int? levelCompleted}) {
    final updatedBadges = List<String>.from(state.badges);
    if (newBadge != null && !updatedBadges.contains(newBadge)) {
      updatedBadges.add(newBadge);
    }
    final nextLevel = levelCompleted != null &&
            levelCompleted > state.completedTerminalLevels
        ? levelCompleted
        : state.completedTerminalLevels;

    state = state.copyWith(
      xp: state.xp + points,
      completedTerminalLevels: nextLevel,
      badges: updatedBadges,
    );
  }
}

final userProgressProvider =
    StateNotifierProvider<UserProgressNotifier, UserProgressState>(
  (ref) => UserProgressNotifier(),
);
