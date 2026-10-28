import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/nasaq_theme.dart';

class NasaqGlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onAvatarTap;

  const NasaqGlassAppBar({
    super.key,
    required this.title,
    required this.subtitle,
    this.onAvatarTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 80,
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: NasaqColors.glassSurface,
            border: Border(
              bottom: BorderSide(
                color: NasaqColors.glassBorderGold,
                width: 1.2,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF14110E).withValues(alpha: 0.03),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Shعار وعنوان الترويسة
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          NasaqColors.paperSurface,
                          NasaqColors.paperSurfaceAlt,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(
                        color: NasaqColors.goldArabic.withValues(alpha: 0.35),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: NasaqColors.goldArabic.withValues(alpha: 0.12),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'ن',
                      style: GoogleFonts.readexPro(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: NasaqColors.emeraldRoyal,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.readexPro(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: NasaqColors.inkPrimary,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.ibmPlexSansArabic(
                          fontSize: 12,
                          color: NasaqColors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // أيقونة الحساب ذات الإطار الزجاجي
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onAvatarTap,
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: NasaqColors.paperSurface,
                      border: Border.all(
                        color: NasaqColors.goldArabic.withValues(alpha: 0.4),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: NasaqColors.inkPrimary.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      color: NasaqColors.emeraldRoyal,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
