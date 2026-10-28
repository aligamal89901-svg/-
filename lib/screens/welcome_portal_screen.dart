import 'package:flutter/material.dart';
import '../core/nasaq_theme.dart';
import '../models/nasaq_models.dart';
import '../widgets/heritage_ornaments.dart';

class WelcomePortalScreen extends StatelessWidget {
  final List<AssistantModel> assistants;
  final VoidCallback onEnterHub;
  final ValueChanged<AssistantModel> onSelectAssistant;

  const WelcomePortalScreen({
    super.key,
    required this.assistants,
    required this.onEnterHub,
    required this.onSelectAssistant,
  });

  AssistantModel _findById(String id) {
    return assistants.firstWhere(
      (a) => a.id == id,
      orElse: () => assistants.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    final coding = _findById('coding_assistant');
    final design = _findById('ui_ux_assistant');
    final accounting = _findById('accounting_assistant');
    final projects = _findById('project_assistant');

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              NasaqColors.sandBackgroundTop,
              NasaqColors.sandBackgroundBottom,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  children: [
                    const Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        'مرحباً بك في',
                        style: TextStyle(
                          fontSize: 15,
                          color: NasaqColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Text(
                            'نَسَق',
                            style: TextStyle(
                              fontSize: 74,
                              height: 1.0,
                              fontWeight: FontWeight.w900,
                              color: NasaqColors.primaryNavy,
                              letterSpacing: -1.5,
                            ),
                          ),
                        ),
                        const Positioned(
                          top: -2,
                          right: 22,
                          child: FourPointStar(
                            size: 26,
                            color: NasaqColors.accentGold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 48,
                          height: 1,
                          color: NasaqColors.accentGold,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 14),
                          child: Text(
                            'N   A   S   A   Q',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: NasaqColors.accentGold,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ),
                        Container(
                          width: 48,
                          height: 1,
                          color: NasaqColors.accentGold,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'مساعدك الذكي .. بتخصص أعمق',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: NasaqColors.primaryNavy,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'منصة ذكاء اصطناعي تجمع لك أفضل المساعدين المتخصصين بمهارات دقيقة وتجربة عربية أصيلة.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.55,
                          color: NasaqColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      height: 285,
                      width: double.infinity,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Positioned(
                            top: 8,
                            child: HeritageArchPortal(),
                          ),
                          Positioned(
                            top: 14,
                            right: 0,
                            child: _FloatingDomainCard(
                              assistant: design,
                              tiltAngle: -0.04,
                              onTap: () => onSelectAssistant(design),
                            ),
                          ),
                          Positioned(
                            top: 14,
                            left: 0,
                            child: _FloatingDomainCard(
                              assistant: coding,
                              tiltAngle: 0.04,
                              onTap: () => onSelectAssistant(coding),
                            ),
                          ),
                          Positioned(
                            bottom: 24,
                            right: 0,
                            child: _FloatingDomainCard(
                              assistant: projects,
                              tiltAngle: -0.02,
                              onTap: () => onSelectAssistant(projects),
                            ),
                          ),
                          Positioned(
                            bottom: 24,
                            left: 0,
                            child: _FloatingDomainCard(
                              assistant: accounting,
                              tiltAngle: 0.02,
                              onTap: () => onSelectAssistant(accounting),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: 240,
                      height: 54,
                      child: FilledButton(
                        onPressed: onEnterHub,
                        style: FilledButton.styleFrom(
                          backgroundColor: NasaqColors.primaryNavy,
                          foregroundColor: Colors.white,
                          elevation: 3,
                          shadowColor:
                              NasaqColors.primaryNavy.withValues(alpha: 0.35),
                          shape: const StadiumBorder(),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'ابدأ الآن',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 12),
                            Icon(Icons.arrow_back_rounded, size: 20),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: onEnterHub,
                      child: const Text(
                        'تخطي',
                        style: TextStyle(
                          fontSize: 14,
                          color: NasaqColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const HeritageRosetteOrnament(size: 36),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 22,
                              height: 6,
                              decoration: BoxDecoration(
                                color: NasaqColors.primaryNavy,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 8,
                              height: 6,
                              decoration: BoxDecoration(
                                color: NasaqColors.textMuted
                                    .withValues(alpha: 0.35),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 8,
                              height: 6,
                              decoration: BoxDecoration(
                                color: NasaqColors.textMuted
                                    .withValues(alpha: 0.35),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'من تراثنا ..',
                              style: TextStyle(
                                fontSize: 11,
                                color: NasaqColors.textMuted,
                              ),
                            ),
                            Text(
                              'نصنع مستقبلاً أذكى',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: NasaqColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FloatingDomainCard extends StatelessWidget {
  final AssistantModel assistant;
  final double tiltAngle;
  final VoidCallback onTap;

  const _FloatingDomainCard({
    required this.assistant,
    required this.tiltAngle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: tiltAngle,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: 132,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            decoration: BoxDecoration(
              color: NasaqColors.cardSurface.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: NasaqColors.cardBorder,
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: NasaqColors.primaryNavy.withValues(alpha: 0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  assistant.icon,
                  color: NasaqColors.iconAzure,
                  size: 24,
                ),
                const SizedBox(height: 6),
                Text(
                  assistant.shortName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: NasaqColors.primaryNavy,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  assistant.tagline,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 10,
                    color: NasaqColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
