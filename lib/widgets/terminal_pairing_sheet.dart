import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      setState(() => _errorMessage = 'يرجى إدخال رمز التحقق');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final res = await TerminalLinkService.instance.submitPairingCode(
      pin,
      apiKey: String.fromCharCodes(base64Decode('QVEuQWI4Uk42THFtcng5M19sSWo5OXhMTktoZ0NsNU9IcTZudUdaVTZ4MTZsQXhob002U2c=')),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res['success'] == true) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'تم الاتصال بنجاح'),
          backgroundColor: const Color(0xFF0E6251),
        ),
      );
    } else {
      setState(() => _errorMessage = res['message']);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      margin: const EdgeInsets.all(12),
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF8F5),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, -2))
        ],
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0E6251).withAlpha(30),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.terminal, color: Color(0xFF0E6251), size: 26),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ربط محرك نَسَق الطرفي',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B262C)),
                        ),
                        Text(
                          'تفعيل بيئة Termux لتنفيذ الأوامر والوكلاء',
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('الخطوة 1: تشغيل المحرك في Termux', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    const Text(
                      'انسخ هذا الأمر المستقل والصقه في Termux لتجهيز البيئة وتشغيل المحرك تلقائياً دون أي إعداد يدوي:',
                      style: TextStyle(fontSize: 11, color: Colors.black87),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: _copyCommand,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _copied ? Colors.teal.shade800 : const Color(0xFF0E6251),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: Icon(_copied ? Icons.check : Icons.copy, size: 18),
                      label: Text(_copied ? 'تم نسخ الأمر بنجاح!' : 'نسخ أمر الإعداد السريع'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('الخطوة 2: إدخال رمز التحقق', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    const Text('اكتب الرمز المكون من 6 أرقام الظاهر في نافذة Termux:', style: TextStyle(fontSize: 11, color: Colors.black87)),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _pinController,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.text,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 4),
                      decoration: InputDecoration(
                        hintText: 'XXX-XXX',
                        hintStyle: TextStyle(color: Colors.grey.shade400, letterSpacing: 2),
                        filled: true,
                        fillColor: const Color(0xFFFAF8F5),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 10),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: _isLoading ? null : _verifyPin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B262C),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isLoading
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('تأكيد واقتران المحرك', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
