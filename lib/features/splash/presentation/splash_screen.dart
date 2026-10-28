import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/nasaq_theme.dart';
import '../../../core/widgets/nasaq_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..forward();

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        context.go('/auth');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NasaqBackground(
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final fade = CurvedAnimation(
                parent: _controller,
                curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
              ).value;
              final scale = Tween<double>(begin: 0.82, end: 1.0)
                  .animate(CurvedAnimation(
                    parent: _controller,
                    curve: Curves.easeOutBack,
                  ))
                  .value;

              return Opacity(
                opacity: fade,
                child: Transform.scale(
                  scale: scale,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // شعار النجمة الثمانية الأندلسية المتحركة
                      SizedBox(
                        width: 126,
                        height: 126,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Transform.rotate(
                              angle: _controller.value * math.pi * 0.5,
                              child: CustomPaint(
                                size: const Size(126, 126),
                                painter: _OctagramSealPainter(
                                  progress: _controller.value,
                                ),
                              ),
                            ),
                            Container(
                              width: 78,
                              height: 78,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    NasaqColors.paperSurface,
                                    NasaqColors.paperSurfaceAlt,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: NasaqColors.goldArabic
                                      .withValues(alpha: 0.55),
                                  width: 1.6,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: NasaqColors.emeraldRoyal
                                        .withValues(alpha: 0.16),
                                    blurRadius: 28,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'ن',
                                style: GoogleFonts.readexPro(
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                  color: NasaqColors.emeraldRoyal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 26),
                      Text(
                        'نَسَق',
                        style: GoogleFonts.readexPro(
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                          color: NasaqColors.inkPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: 14,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: NasaqColors.goldArabic.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color:
                                NasaqColors.goldArabic.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Text(
                          'NASAQ • AI STUDIO',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 11,
                            letterSpacing: 3,
                            fontWeight: FontWeight.w700,
                            color: NasaqColors.goldArabic,
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),
                      SizedBox(
                        width: 90,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: _controller.value,
                            minHeight: 3.5,
                            backgroundColor: NasaqColors.paperSurfaceAlt,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              NasaqColors.emeraldRoyal,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _OctagramSealPainter extends CustomPainter {
  final double progress;
  const _OctagramSealPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = NasaqColors.goldArabic.withValues(alpha: 0.35 * progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCenter(
      center: center,
      width: size.width * 0.78,
      height: size.height * 0.78,
    );

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.shift(-center),
        const Radius.circular(18),
      ),
      paint,
    );
    canvas.rotate(math.pi / 4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.shift(-center),
        const Radius.circular(18),
      ),
      paint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _OctagramSealPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
