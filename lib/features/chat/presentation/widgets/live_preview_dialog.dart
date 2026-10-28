import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/nasaq_theme.dart';
import '../../../../core/utils/nasaq_clipboard.dart';
import '../../../../core/widgets/scale_tap.dart';
import '../../../../core/widgets/sandbox/live_html_sandbox.dart';

enum PreviewViewport { phone, tablet, full }

class LivePreviewDialog extends StatefulWidget {
  final String code;
  final String language;

  const LivePreviewDialog({
    super.key,
    required this.code,
    required this.language,
  });

  @override
  State<LivePreviewDialog> createState() => _LivePreviewDialogState();
}

class _LivePreviewDialogState extends State<LivePreviewDialog> {
  PreviewViewport _viewport = PreviewViewport.phone;
  bool _showCodeSource = false;
  int _refreshSeed = 0;

  @override
  Widget build(BuildContext context) {
    final sandboxKey = '${widget.code.hashCode}_$_refreshSeed';

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.90,
            decoration: BoxDecoration(
              color: const Color(0xF514110E),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: NasaqColors.goldArabic.withValues(alpha: 0.5),
                width: 1.3,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black87,
                  blurRadius: 30,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              children: [
                // الشريط العلوي المدمج (خالٍ من الـ Overflow تماماً)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      ScaleTap(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 17,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                _showCodeSource ? 'فحص الكود' : 'معاينة حية',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.readexPro(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // مبدل المقاسات الذكي
                      if (!_showCodeSource) ...[
                        _buildCompactViewportBtn(
                          icon: Icons.phone_android_rounded,
                          isSelected: _viewport == PreviewViewport.phone,
                          onTap: () => setState(() => _viewport = PreviewViewport.phone),
                        ),
                        const SizedBox(width: 4),
                        _buildCompactViewportBtn(
                          icon: Icons.tablet_mac_rounded,
                          isSelected: _viewport == PreviewViewport.tablet,
                          onTap: () => setState(() => _viewport = PreviewViewport.tablet),
                        ),
                        const SizedBox(width: 4),
                        _buildCompactViewportBtn(
                          icon: Icons.fullscreen_rounded,
                          isSelected: _viewport == PreviewViewport.full,
                          onTap: () => setState(() => _viewport = PreviewViewport.full),
                        ),
                        const SizedBox(width: 6),
                      ],

                      // زر التحديث
                      ScaleTap(
                        onTap: () => setState(() => _refreshSeed++),
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.refresh_rounded,
                            size: 15,
                            color: NasaqColors.goldMuted,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),

                      // زر التبديل بين الواجهة والكود
                      ScaleTap(
                        onTap: () => setState(() => _showCodeSource = !_showCodeSource),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                          decoration: BoxDecoration(
                            color: _showCodeSource
                                ? NasaqColors.emeraldRoyal
                                : NasaqColors.goldArabic.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(
                              color: NasaqColors.goldArabic.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _showCodeSource ? Icons.remove_red_eye_rounded : Icons.code_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _showCodeSource ? 'الواجهة' : 'الكود',
                                style: GoogleFonts.ibmPlexSansArabic(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // مساحة المحاكاة الحية الآمنة رياضياً
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final maxW = constraints.maxWidth;
                      final maxH = constraints.maxHeight;

                      // ضمان أن تكون جميع الأبعاد قيماً رقمية محدودة (Finite) دائماً لمنع خطأ Lerp
                      double targetWidth = maxW;
                      double? frameHeight;

                      if (_viewport == PreviewViewport.phone) {
                        targetWidth = math.min(375.0, maxW - 20);
                        frameHeight = math.min(680.0, maxH - 24);
                      } else if (_viewport == PreviewViewport.tablet) {
                        targetWidth = math.min(720.0, maxW - 20);
                        frameHeight = math.min(760.0, maxH - 24);
                      } else {
                        targetWidth = maxW;
                        frameHeight = maxH;
                      }

                      return Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: const Color(0xFF090B0E),
                        alignment: Alignment.center,
                        child: _showCodeSource
                            ? Container(
                                width: double.infinity,
                                height: double.infinity,
                                padding: const EdgeInsets.all(16),
                                child: SingleChildScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  child: SelectableText(
                                    widget.code.trim(),
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 12,
                                      color: const Color(0xFFE2E8F0),
                                      height: 1.6,
                                    ),
                                  ),
                                ),
                              )
                            : AnimatedContainer(
                                duration: const Duration(milliseconds: 240),
                                curve: Curves.easeOutCubic,
                                width: targetWidth,
                                height: frameHeight,
                                margin: _viewport != PreviewViewport.full
                                    ? const EdgeInsets.symmetric(vertical: 12)
                                    : EdgeInsets.zero,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: _viewport != PreviewViewport.full
                                      ? BorderRadius.circular(28)
                                      : BorderRadius.zero,
                                  border: _viewport != PreviewViewport.full
                                      ? Border.all(
                                          color: const Color(0xFF333D4D),
                                          width: 3.5,
                                        )
                                      : null,
                                  boxShadow: _viewport != PreviewViewport.full
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.6),
                                            blurRadius: 24,
                                            offset: const Offset(0, 10),
                                          ),
                                        ]
                                      : null,
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: LiveHtmlSandbox(
                                  code: widget.code,
                                  sandboxId: sandboxKey,
                                ),
                              ),
                      );
                    },
                  ),
                ),

                // شريط معلومات سفلي
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'المعاينة تعمل في بيئة منعزلة داخل التطبيق',
                        style: GoogleFonts.ibmPlexSansArabic(
                          fontSize: 10.5,
                          color: Colors.white54,
                        ),
                      ),
                      ScaleTap(
                        onTap: () async {
                          await NasaqClipboard.copy(widget.code);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('تم نسخ الكود بنجاح'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          }
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.copy_rounded, size: 13, color: NasaqColors.goldMuted),
                            const SizedBox(width: 5),
                            Text(
                              'نسخ الكود',
                              style: GoogleFonts.ibmPlexSansArabic(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: NasaqColors.goldMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactViewportBtn({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ScaleTap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isSelected
              ? NasaqColors.goldArabic.withValues(alpha: 0.28)
              : Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? NasaqColors.goldArabic : Colors.transparent,
          ),
        ),
        child: Icon(
          icon,
          size: 15,
          color: isSelected ? Colors.white : Colors.white60,
        ),
      ),
    );
  }
}
