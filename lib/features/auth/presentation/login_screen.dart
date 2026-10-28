import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/nasaq_theme.dart';
import '../../../core/widgets/nasaq_background.dart';
import '../../../core/widgets/scale_tap.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int _shakeGoogleKey = 0;
  int _shakeEmailKey = 0;

  void _showComingSoon(String provider) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: NasaqColors.paperSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: NasaqColors.goldArabic.withValues(alpha: 0.45),
            width: 1.2,
          ),
        ),
        content: Row(
          children: [
            Container(
              padding: const EdgeInsetsDirectional.all(6),
              decoration: BoxDecoration(
                color: NasaqColors.goldArabic.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: NasaqColors.goldArabic,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'هذه الميزة قريباً • الدخول عبر $provider قيد التجهيز',
                style: GoogleFonts.ibmPlexSansArabic(
                  color: NasaqColors.inkPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final words = ['أطلق', 'العنان', 'مع', 'نَسَق'];

    return Scaffold(
      body: NasaqBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Container(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: NasaqColors.paperSurface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: NasaqColors.goldArabic.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: NasaqColors.emeraldRoyal,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'نَسَق • الجيل الجديد من العقول المتخصصة',
                          style: GoogleFonts.ibmPlexSansArabic(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: NasaqColors.inkPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  runSpacing: 4,
                  children: words.asMap().entries.map((entry) {
                    final isNasaq = entry.value == 'نَسَق';
                    return Text(
                      entry.value,
                      style: GoogleFonts.readexPro(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: isNasaq
                            ? NasaqColors.emeraldRoyal
                            : NasaqColors.inkPrimary,
                        height: 1.5,
                      ),
                    )
                        .animate()
                        .fadeIn(
                          duration: const Duration(milliseconds: 420),
                          delay: Duration(milliseconds: 180 * entry.key),
                        )
                        .slideY(begin: 0.28, end: 0);
                  }).toList(),
                ),
                const SizedBox(height: 10),
                Text(
                  'ذكاء بعدة عقول، لكل اختصاص عقله ومعاييره وطابعه البصري المستقل.',
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 15,
                    color: NasaqColors.inkMuted,
                    height: 1.75,
                  ),
                )
                    .animate()
                    .fadeIn(delay: const Duration(milliseconds: 800))
                    .slideY(begin: 0.2, end: 0),
                const SizedBox(height: 36),
                ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Container(
                      padding: const EdgeInsetsDirectional.all(22),
                      decoration: BoxDecoration(
                        color: NasaqColors.glassSurface,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: NasaqColors.goldArabic.withValues(alpha: 0.35),
                          width: 1.3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: NasaqColors.inkPrimary.withValues(alpha: 0.05),
                            blurRadius: 28,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Animate(
                            key: ValueKey('google_$_shakeGoogleKey'),
                            effects: _shakeGoogleKey == 0
                                ? const []
                                : [
                                    ShakeEffect(
                                      duration:
                                          const Duration(milliseconds: 350),
                                      hz: 4,
                                      offset: const Offset(8, 0),
                                    ),
                                  ],
                            child: _PortalAuthButton(
                              icon: Icons.g_mobiledata_rounded,
                              title: 'المتابعة عبر Google',
                              subtitle: 'مزامنة سحابية للمساحات',
                              isSoon: true,
                              onTap: () {
                                setState(() => _shakeGoogleKey++);
                                _showComingSoon('Google');
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          Animate(
                            key: ValueKey('email_$_shakeEmailKey'),
                            effects: _shakeEmailKey == 0
                                ? const []
                                : [
                                    ShakeEffect(
                                      duration:
                                          const Duration(milliseconds: 350),
                                      hz: 4,
                                      offset: const Offset(8, 0),
                                    ),
                                  ],
                            child: _PortalAuthButton(
                              icon: Icons.alternate_email_rounded,
                              title: 'المتابعة بالبريد الإلكتروني',
                              subtitle: 'حساب مخصص للمحترفين',
                              isSoon: true,
                              onTap: () {
                                setState(() => _shakeEmailKey++);
                                _showComingSoon('البريد الإلكتروني');
                              },
                            ),
                          ),
                          const Padding(
                            padding:
                                EdgeInsetsDirectional.symmetric(vertical: 16),
                            child: Divider(
                              color: Color(0x33D9B26A),
                              height: 1,
                            ),
                          ),
                          _PortalAuthButton(
                            icon: Icons.bolt_rounded,
                            title: 'الدخول الفوري كضيف',
                            subtitle: 'عاين العقول الثمانية ومختبر الطرفية الآن',
                            isPrimary: true,
                            onTap: () => context.go('/home'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: const Duration(milliseconds: 950))
                    .slideY(begin: 0.25, end: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PortalAuthButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSoon;
  final bool isPrimary;
  final VoidCallback onTap;

  const _PortalAuthButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isSoon = false,
    this.isPrimary = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          gradient: isPrimary
              ? const LinearGradient(
                  colors: [
                    NasaqColors.emeraldRoyal,
                    Color(0xFF094E49),
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                )
              : null,
          color: isPrimary ? null : NasaqColors.paperSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isPrimary
                ? NasaqColors.goldArabic.withValues(alpha: 0.5)
                : NasaqColors.goldArabic.withValues(alpha: 0.25),
            width: 1.2,
          ),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: NasaqColors.emeraldRoyal.withValues(alpha: 0.28),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isPrimary
                    ? Colors.white.withValues(alpha: 0.16)
                    : NasaqColors.paperSurfaceAlt,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: isPrimary ? Colors.white : NasaqColors.emeraldRoyal,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.readexPro(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: isPrimary ? Colors.white : NasaqColors.inkPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.ibmPlexSansArabic(
                      fontSize: 11.5,
                      color: isPrimary
                          ? Colors.white.withValues(alpha: 0.8)
                          : NasaqColors.inkMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (isSoon)
              Container(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: NasaqColors.goldArabic.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: NasaqColors.goldArabic.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  'قريباً',
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: NasaqColors.goldArabic,
                  ),
                ),
              )
            else
              const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }
}
