import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nasaq/core/services/terminal_link_service.dart';

class TerminalPairingSheet extends StatefulWidget {
  const TerminalPairingSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const TerminalPairingSheet(),
    );
  }

  @override
  State<TerminalPairingSheet> createState() => _TerminalPairingSheetState();
}

class _TerminalPairingSheetState extends State<TerminalPairingSheet> {
  final TextEditingController _pinController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _copied = false;

  void _copyCommand() {
    Clipboard.setData(const ClipboardData(text: TerminalLinkService.selfContainedInstallCommand));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  Future<void> _verifyPin() async {
    final pin = _pinController.text.trim();
    if (pin.isEmpty) {
      setState(() => _errorMessage = 'يرجى إدخال رمز الاقتران');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final key = String.fromCharCodes(base64Decode('QVEuQWI4Uk42THFtcng5M19sSWo5OXhMTktoZ0NsNU9IcTZudUdaVTZ4MTZsQXhob002U2c='));
    final res = await TerminalLinkService.instance.submitPairingCode(pin, apiKey: key);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res['success'] == true) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            res['message'] ?? 'تم الاتصال بنجاح',
            style: GoogleFonts.ibmPlexSansArabic(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF0E6251),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else {
      setState(() => _errorMessage = res['message']);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        padding: EdgeInsets.fromLTRB(18, 16, 18, 18 + bottomInset),
        decoration: BoxDecoration(
          color: const Color(0xFFFBFBFB),
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 25, offset: Offset(0, -4)),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0E6251).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.terminal_rounded, color: Color(0xFF0E6251), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ربط محرك نَسَق الطرفي',
                          style: GoogleFonts.readexPro(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1B262C),
                          ),
                        ),
                        Text(
                          'اقتران ذاتي آمن ومباشر مع جهازك',
                          style: GoogleFonts.ibmPlexSansArabic(fontSize: 11, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // بطاقة الخطوة 1
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '1. تشغيل المحرك في Termux',
                      style: GoogleFonts.readexPro(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1B262C)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'انسخ هذا الأمر والصقه في تطبيق Termux مباشرة (لا يشترط وجود ملفات مسبقة):',
                      style: GoogleFonts.ibmPlexSansArabic(fontSize: 11, color: Colors.black54),
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: _copyCommand,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: _copied ? const Color(0xFF0E6251) : const Color(0xFF1B262C),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(_copied ? Icons.check_circle_outline : Icons.copy_rounded, color: Colors.white, size: 16),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                _copied ? 'تم نسخ الأمر بنجاح!' : 'نسخ أمر الإعداد السريع',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.ibmPlexSansArabic(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // بطاقة الخطوة 2
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '2. إدخال رمز التحقق',
                      style: GoogleFonts.readexPro(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1B262C)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'أدخل الرمز الظاهر في نافذة Termux (مثال: 190-880):',
                      style: GoogleFonts.ibmPlexSansArabic(fontSize: 11, color: Colors.black54),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _pinController,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.text,
                      style: GoogleFonts.jetBrainsMono(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2),
                      decoration: InputDecoration(
                        hintText: 'XXX-XXX',
                        hintStyle: GoogleFonts.jetBrainsMono(color: Colors.grey.shade400, letterSpacing: 2),
                        isDense: true,
                        filled: true,
                        fillColor: const Color(0xFFF9F9FB),
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF0E6251), width: 1.5)),
                      ),
                    ),
                  ],
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.ibmPlexSansArabic(color: const Color(0xFFC62828), fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyPin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0E6251),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('تأكيد واقتران المحرك', style: GoogleFonts.ibmPlexSansArabic(fontSize: 13, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
