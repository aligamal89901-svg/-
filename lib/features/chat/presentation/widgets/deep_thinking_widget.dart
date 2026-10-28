import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/nasaq_theme.dart';

class DeepThinkingWidget extends StatefulWidget {
  final String? thinkingContent;
  final bool isActive;
  final int durationMs;

  const DeepThinkingWidget({
    super.key,
    required this.thinkingContent,
    required this.isActive,
    required this.durationMs,
  });

  @override
  State<DeepThinkingWidget> createState() => _DeepThinkingWidgetState();
}

class _DeepThinkingWidgetState extends State<DeepThinkingWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final hasContent = widget.thinkingContent != null &&
        widget.thinkingContent!.trim().isNotEmpty;

    if (!widget.isActive && !hasContent) {
      return const SizedBox.shrink();
    }

    final seconds = (widget.durationMs / 1000).toStringAsFixed(1);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF9F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE4DDD0),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Icon(
                    widget.isActive ? Icons.hourglass_empty_rounded : Icons.code_rounded,
                    size: 16,
                    color: NasaqColors.inkMuted,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.isActive
                          ? 'مسار التحليل الهندسي...'
                          : 'اكتمال المعالجة التحليلية ($seconds ثانية)',
                      style: GoogleFonts.ibmPlexSansArabic(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: NasaqColors.inkPrimary,
                      ),
                    ),
                  ),
                  Text(
                    _isExpanded ? 'إخفاء' : 'عرض',
                    style: GoogleFonts.ibmPlexSansArabic(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: NasaqColors.inkMuted,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: NasaqColors.inkMuted,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: Container(
                constraints: const BoxConstraints(maxHeight: 220),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFEAE4D9),
                  ),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: hasContent
                      ? SelectableText(
                          widget.thinkingContent!.trim(),
                          style: GoogleFonts.ibmPlexSansArabic(
                            fontSize: 11.5,
                            color: const Color(0xFF4A443B),
                            height: 1.65,
                          ),
                        )
                      : Text(
                          'تحليل المتطلبات البرمجية والمعمارية...',
                          style: GoogleFonts.ibmPlexSansArabic(
                            fontSize: 11.5,
                            color: NasaqColors.inkMuted,
                          ),
                        ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
