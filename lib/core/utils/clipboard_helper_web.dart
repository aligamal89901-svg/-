import 'package:web/web.dart' as web;

void copyTextToDomFallback(String text) {
  try {
    final textArea = web.document.createElement('textarea') as web.HTMLTextAreaElement;
    textArea.value = text;
    textArea.style.position = 'fixed';
    textArea.style.left = '-9999px';
    textArea.style.top = '-9999px';
    textArea.style.opacity = '0';
    web.document.body?.appendChild(textArea);
    textArea.focus();
    textArea.select();
    web.document.execCommand('copy');
    textArea.remove();
  } catch (_) {}
}
