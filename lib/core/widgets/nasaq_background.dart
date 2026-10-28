import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/nasaq_theme.dart';

class NasaqBackground extends StatelessWidget {
  final Widget child;
  const NasaqBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // خلفية الورق الدافئ الأساسية
        Container(color: NasaqColors.paperBackground),

        // تدرج أورورا دافئ ذهبي في الزاوية العلوية
        Positioned(
          top: -100,
          right: -80,
          child: Container(
            width: 340,
            height: 340,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  NasaqColors.goldMuted.withValues(alpha: 0.18),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // تدرج أورورا زمردي ناعم في الزاوية السفلية
        Positioned(
          bottom: -120,
          left: -70,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  NasaqColors.emeraldLight.withValues(alpha: 0.12),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // الزخرفة الهندسية الإسلامية بلون حبري ذهبي خافت جداً
        const Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(
              painter: IslamicLuxuryPatternPainter(),
            ),
          ),
        ),

        SafeArea(child: child),
      ],
    );
  }
}

class IslamicLuxuryPatternPainter extends CustomPainter {
  const IslamicLuxuryPatternPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = NasaqColors.goldArabic.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const double step = 68.0;
    for (double x = 0; x < size.width + step; x += step) {
      for (double y = 0; y < size.height + step; y += step) {
        final path = Path();
        path.moveTo(x, y - 18);
        path.lineTo(x + 18, y);
        path.lineTo(x, y + 18);
        path.lineTo(x - 18, y);
        path.close();

        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(math.pi / 4);
        canvas.drawRect(
          const Rect.fromLTWH(-14, -14, 28, 28),
          linePaint,
        );
        canvas.restore();
        canvas.drawPath(path, linePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
