import 'package:flutter/services.dart';
import 'clipboard_helper_stub.dart'
    if (dart.library.html) 'clipboard_helper_web.dart';

class NasaqClipboard {
  static Future<bool> copy(String text) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return false;

    bool didCopy = false;

    // 1. استخدام DOM Fallback المباشر لمتصفحات الجوال
    try {
      copyTextToDomFallback(cleanText);
      didCopy = true;
    } catch (_) {}

    // 2. استخدام واجهة Flutter الرسمية
    try {
      await Clipboard.setData(ClipboardData(text: cleanText));
      didCopy = true;
    } catch (_) {}

    // 3. اهتزاز لمسي خفيف مع حماية من أخطاء الويب
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {}

    return didCopy;
  }
}
