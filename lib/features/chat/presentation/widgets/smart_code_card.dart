import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/nasaq_clipboard.dart';
import '../../../../core/widgets/scale_tap.dart';
import 'live_preview_dialog.dart';

class SmartCodeCard extends StatefulWidget {
  final String code;
  final String language;

  const SmartCodeCard({
    super.key,
    required this.code,
    required this.language,
  });

  @override
  State<SmartCodeCard> createState() => _SmartCodeCardState();
}

class _SmartCodeCardState extends State<SmartCodeCard> {
  bool _isCopied = false;

  bool get _isPreviewable {
    final lang = widget.language.toLowerCase().trim();
    final cleanCode = widget.code.trim().toLowerCase();
    return lang == 'html' ||
        lang == 'htm' ||
        lang == 'svg' ||
        lang == 'xml' ||
        lang == 'css' ||
        cleanCode.startsWith('<!doctype') ||
        cleanCode.contains('<html') ||
        cleanCode.contains('<svg') ||
        cleanCode.contains('<style') ||
        (cleanCode.contains('<div') && cleanCode.contains('</'));
  }

  String _getEffectivePreviewCode() {
    final clean = widget.code.trim();
    if (!clean.toLowerCase().contains('<html') &&
        (clean.contains('{') && clean.contains('}'))) {
      return '''<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<style>
$clean
</style>
</head>
<body>
<div class="preview-root">
  <h2>معاينة التصميم</h2>
  <p>تم تحميل التنسيقات بنجاح</p>
</div>
</body>
</html>''';
    }
    return clean;
  }

  void _openLivePreview() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'LivePreview',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, _, __) {
        return LivePreviewDialog(
          code: _getEffectivePreviewCode(),
          language: widget.language,
        );
      },
    );
  }

  Future<void> _executeCopy({bool isTerminal = false}) async {
    final text = widget.code.trim();
    if (text.isEmpty) return;

    final messenger = ScaffoldMessenger.of(context);
    await NasaqClipboard.copy(text);

    if (!mounted) return;
    setState(() => _isCopied = true);

    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1B222C),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        content: Text(
          isTerminal ? 'تم نسخ الأمر للحافظة' : 'تم نسخ الكود للحافظة',
          style: GoogleFonts.ibmPlexSansArabic(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isCopied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.language.isEmpty ? 'CODE' : widget.language.toUpperCase();
    final isTerminalCmd = lang == 'BASH' || lang == 'SH' || lang == 'SHELL';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1318),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF262D38),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // شريط الأدوات العلوي: رصين، بدون نقاط خضراء أو نجوم
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF161C24),
              borderRadius: BorderRadius.vertical(top: Radius.circular(13)),
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFF222A36),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  lang,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
                Row(
                  children: [
                    if (_isPreviewable) ...[
                      ScaleTap(
                        onTap: _openLivePreview,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF222D3D),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFF3B485C),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.remove_red_eye_outlined,
                                size: 14,
                                color: Color(0xFFE2E8F0),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'معاينة',
                                style: GoogleFonts.ibmPlexSansArabic(
                                  fontSize: 11.5,
                                  color: const Color(0xFFE2E8F0),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (isTerminalCmd) ...[
                      ScaleTap(
                        onTap: () => _executeCopy(isTerminal: true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFF334155),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.terminal_outlined, size: 14, color: Color(0xFFCBD5E1)),
                              const SizedBox(width: 6),
                              Text(
                                'نسخ للطرفية',
                                style: GoogleFonts.ibmPlexSansArabic(
                                  fontSize: 11.5,
                                  color: const Color(0xFFCBD5E1),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    ScaleTap(
                      onTap: () => _executeCopy(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _isCopied ? Icons.check_rounded : Icons.copy_rounded,
                              size: 13,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _isCopied ? 'تم النسخ' : 'نسخ',
                              style: GoogleFonts.ibmPlexSansArabic(
                                fontSize: 11.5,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: SelectableText(
                widget.code.trim(),
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12.5,
                  color: const Color(0xFFE2E8F0),
                  height: 1.6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
