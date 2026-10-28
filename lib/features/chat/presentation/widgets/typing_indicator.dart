import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/nasaq_theme.dart';

class PulsatingCursor extends StatelessWidget {
  const PulsatingCursor({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 15,
      margin: const EdgeInsetsDirectional.only(start: 4),
      decoration: BoxDecoration(
        color: NasaqColors.emeraldRoyal,
        borderRadius: BorderRadius.circular(2),
      ),
    )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .fadeIn(duration: const Duration(milliseconds: 400))
        .fadeOut(duration: const Duration(milliseconds: 400));
  }
}
