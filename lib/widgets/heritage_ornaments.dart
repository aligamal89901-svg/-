import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/nasaq_theme.dart';

class FourPointStar extends StatelessWidget {
  final double size;
  final Color color;

  const FourPointStar({
    super.key,
    this.size = 22,
    this.color = NasaqColors.accentGold,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _FourPointStarPainter(color),
    );
  }
}

class _FourPointStarPainter extends CustomPainter {
  final Color color;
  const _FourPointStarPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final outer = size.width / 2;
    final inner = size.width * 0.16;

    final path = Path()
      ..moveTo(cx, cy - outer)
      ..quadraticBezierTo(cx + inner, cy - inner, cx + outer, cy)
      ..quadraticBezierTo(cx + inner, cy + inner, cx, cy + outer)
      ..quadraticBezierTo(cx - inner, cy + inner, cx - outer, cy)
      ..quadraticBezierTo(cx - inner, cy - inner, cx, cy - outer)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HeritageRosetteOrnament extends StatelessWidget {
  final double size;
  const HeritageRosetteOrnament({super.key, this.size = 36});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _RosettePainter(),
    );
  }
}

class _RosettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = NasaqColors.accentGold.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.42;

    for (int i = 0; i < 8; i++) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate((i * math.pi) / 4);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: radius * 0.75,
          height: radius * 1.85,
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HeritageArchPortal extends StatelessWidget {
  const HeritageArchPortal({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 260,
      child: CustomPaint(painter: _ArchPortalPainter()),
    );
  }
}

class _ArchPortalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final left = w * 0.14;
    final right = w * 0.86;
    final top = h * 0.05;
    final bottom = h * 0.78;
    final cx = w / 2;

    Path buildArch(double l, double r, double t, double b) {
      final shoulder = t + (b - t) * 0.34;
      return Path()
        ..moveTo(l, b)
        ..lineTo(l, shoulder)
        ..quadraticBezierTo(l, t + 16, cx, t)
        ..quadraticBezierTo(r, t + 16, r, shoulder)
        ..lineTo(r, b)
        ..close();
    }

    final outerArch = buildArch(left - 8, right + 8, top - 8, bottom);
    final innerArch = buildArch(left, right, top, bottom);

    canvas.drawPath(outerArch, Paint()..color = const Color(0xFFFDFBF7));
    final borderPaint = Paint()
      ..color = NasaqColors.accentGold.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(outerArch, borderPaint);

    canvas.save();
    canvas.clipPath(innerArch);
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF3A6B8C), Color(0xFFD5C6A9), Color(0xFFF3E6CE)],
      ).createShader(Rect.fromLTWH(0, 0, w, bottom));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), skyPaint);

    final castlePaint = Paint()..color = const Color(0xFFC9AC82);
    canvas.drawRect(
      Rect.fromLTWH(w * 0.32, h * 0.48, w * 0.36, h * 0.24),
      castlePaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.41, h * 0.40, w * 0.18, h * 0.12),
      castlePaint,
    );
    canvas.restore();
    canvas.drawPath(innerArch, borderPaint);

    final podiumPaint = Paint()..color = const Color(0xFFFDFBF6);
    for (int i = 0; i < 3; i++) {
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, h * (0.85 - i * 0.055)),
          width: w * (0.86 - i * 0.18),
          height: 14,
        ),
        const Radius.circular(6),
      );
      canvas.drawRRect(rect, podiumPaint);
      canvas.drawRRect(rect, borderPaint);
    }

    final ribbon = Path()
      ..moveTo(w * 0.52, h * 0.62)
      ..cubicTo(w * 0.38, h * 0.70, w * 0.42, h * 0.78, w * 0.60, h * 0.84)
      ..cubicTo(w * 0.74, h * 0.89, w * 0.65, h * 0.95, w * 0.40, h * 0.98);
    canvas.drawPath(
      ribbon,
      Paint()
        ..color = NasaqColors.iconAzure
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
