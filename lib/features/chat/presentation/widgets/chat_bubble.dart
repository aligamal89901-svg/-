import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/ai/ai_provider.dart';
import '../../../../core/theme/nasaq_theme.dart';
import '../../../../core/utils/nasaq_clipboard.dart';
import '../../../../core/widgets/scale_tap.dart';
import 'deep_thinking_widget.dart';
import 'smart_code_card.dart';
import 'tool_execution_card.dart';
import 'typing_indicator.dart';

class ChatBubble extends StatefulWidget {
  final ChatMessage message;
  final String specializationTitle;
  final Color accentColor;
  final VoidCallback? onRegenerate;

  const ChatBubble({
    super.key,
    required this.message,
    required this.specializationTitle,
    required this.accentColor,
    this.onRegenerate,
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  bool _isCopiedAll = false;

  String _buildFullTextToCopy() {
    final buffer = StringBuffer();
    if (widget.message.content.isNotEmpty) {
      buffer.writeln(widget.message.content.trim());
    }
    if (widget.message.toolExecutions.isNotEmpty) {
      buffer.writeln('\n--- أوامر الأدوات المنفذة ---');
      for (final t in widget.message.toolExecutions) {
        buffer.writeln('[${t.toolName}]: ${t.commandOrInput}');
        if (t.output != null && t.output!.trim().isNotEmpty) {
          buffer.writeln('المخرجات:\n${t.output!.trim()}');
        }
      }
    }
    return buffer.toString().trim();
  }

  Future<void> _copyFullMessage() async {
    final full = _buildFullTextToCopy();
    if (full.isEmpty) return;
    await NasaqClipboard.copy(full);
    if (!mounted) return;
    setState(() => _isCopiedAll = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم نسخ كامل الرد ومخرجاته للحافظة',
          style: GoogleFonts.ibmPlexSansArabic(),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isCopiedAll = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isUser = widget.message.sender == MessageSender.user;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF3ECE0),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFDDD2BC),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                'ن',
                style: GoogleFonts.readexPro(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: NasaqColors.emeraldRoyal,
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.86,
              ),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUser ? NasaqColors.emeraldRoyal : NasaqColors.paperSurface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isUser
                      ? Colors.transparent
                      : const Color(0xFFE4DDD0),
                ),
              ),
              child: isUser
                  ? Directionality(
                      textDirection: _detectTextDirection(widget.message.content),
                      child: Text(
                        widget.message.content,
                        style: GoogleFonts.ibmPlexSansArabic(
                          fontSize: 14,
                          height: 1.7,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: widget.accentColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'نَسَق • ${widget.specializationTitle}',
                              style: GoogleFonts.readexPro(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: widget.accentColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        if (widget.message.isThinkingActive ||
                            (widget.message.realThinking != null &&
                                widget.message.realThinking!.isNotEmpty))
                          DeepThinkingWidget(
                            thinkingContent: widget.message.realThinking,
                            isActive: widget.message.isThinkingActive,
                            durationMs: widget.message.thinkingDurationMs,
                          ),

                        if (widget.message.toolExecutions.isNotEmpty)
                          ...widget.message.toolExecutions.map(
                            (tool) => ToolExecutionCard(tool: tool),
                          ),

                        if (widget.message.content.isNotEmpty)
                          _AssistantContentRenderer(
                            content: widget.message.content,
                            isStreaming: widget.message.isStreaming,
                          ),

                        if (widget.message.content.isEmpty &&
                            widget.message.isStreaming &&
                            !widget.message.isThinkingActive)
                          const PulsatingCursor(),

                        // شريط أدوات الرسالة السفلي: نسخ الرد بالكامل + إعادة التوليد
                        if (!widget.message.isStreaming &&
                            (widget.message.content.isNotEmpty ||
                                widget.message.toolExecutions.isNotEmpty)) ...[
                          const SizedBox(height: 12),
                          const Divider(color: Color(0xFFEAE3D5), height: 1),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              ScaleTap(
                                onTap: _copyFullMessage,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF7F2E8),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFFDDD3BE)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _isCopiedAll ? Icons.check_rounded : Icons.copy_rounded,
                                        size: 13,
                                        color: NasaqColors.inkMuted,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _isCopiedAll ? 'تم النسخ' : 'نسخ الرد كاملاً',
                                        style: GoogleFonts.ibmPlexSansArabic(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: NasaqColors.inkMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (widget.onRegenerate != null) ...[
                                const SizedBox(width: 8),
                                ScaleTap(
                                  onTap: widget.onRegenerate,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF7F2E8),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFFDDD3BE)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.autorenew_rounded,
                                          size: 14,
                                          color: NasaqColors.inkMuted,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'إعادة المحاولة',
                                          style: GoogleFonts.ibmPlexSansArabic(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: NasaqColors.inkMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ],
                    ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  static TextDirection _detectTextDirection(String text) {
    for (final rune in text.runes) {
      if ((rune >= 0x0600 && rune <= 0x06FF) ||
          (rune >= 0x0750 && rune <= 0x077F) ||
          (rune >= 0x08A0 && rune <= 0x08FF)) {
        return TextDirection.rtl;
      }
      if ((rune >= 0x0041 && rune <= 0x005A) ||
          (rune >= 0x0061 && rune <= 0x007A)) {
        return TextDirection.ltr;
      }
    }
    return TextDirection.rtl;
  }
}

class _AssistantContentRenderer extends StatelessWidget {
  final String content;
  final bool isStreaming;

  const _AssistantContentRenderer({
    required this.content,
    required this.isStreaming,
  });

  List<_ParsedPart> _splitStreamingMarkdownCode(String text) {
    final parts = <_ParsedPart>[];
    if (text.isEmpty) return parts;

    final openRegex = RegExp(r'```([a-zA-Z0-9_\-\+]*)[^\S\r\n]*\r?\n?');
    int cursor = 0;

    while (cursor < text.length) {
      final match = openRegex.firstMatch(text.substring(cursor));
      if (match == null) {
        final remaining = text.substring(cursor);
        if (remaining.isNotEmpty) {
          parts.add(_ParsedPart(isCode: false, text: remaining));
        }
        break;
      }

      final startPos = cursor + match.start;
      final codeStartPos = cursor + match.end;
      final lang = match.group(1);

      if (startPos > cursor) {
        final leadingText = text.substring(cursor, startPos);
        if (leadingText.trim().isNotEmpty) {
          parts.add(_ParsedPart(isCode: false, text: leadingText));
        }
      }

      final closePos = text.indexOf('```', codeStartPos);
      if (closePos != -1) {
        final codeSnippet = text.substring(codeStartPos, closePos);
        parts.add(_ParsedPart(isCode: true, text: codeSnippet, lang: lang));
        cursor = closePos + 3;
      } else {
        final codeSnippet = text.substring(codeStartPos);
        parts.add(_ParsedPart(isCode: true, text: codeSnippet, lang: lang));
        cursor = text.length;
      }
    }

    return parts;
  }

  TextDirection _detectPartDirection(String t) {
    for (final rune in t.runes) {
      if ((rune >= 0x0600 && rune <= 0x06FF) ||
          (rune >= 0x0750 && rune <= 0x077F) ||
          (rune >= 0x08A0 && rune <= 0x08FF)) {
        return TextDirection.rtl;
      }
      if ((rune >= 0x0041 && rune <= 0x005A) ||
          (rune >= 0x0061 && rune <= 0x007A)) {
        return TextDirection.ltr;
      }
    }
    return TextDirection.rtl;
  }

  @override
  Widget build(BuildContext context) {
    final parts = _splitStreamingMarkdownCode(content);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...parts.map((p) {
          if (p.isCode) {
            return Directionality(
              textDirection: TextDirection.ltr,
              child: SmartCodeCard(
                code: p.text,
                language: p.lang ?? '',
              ),
            );
          }
          final dir = _detectPartDirection(p.text);
          return Directionality(
            textDirection: dir,
            child: MarkdownBody(
              data: p.text,
              selectable: true,
              styleSheet: MarkdownStyleSheet(
                p: GoogleFonts.ibmPlexSansArabic(
                  fontSize: 14,
                  height: 1.75,
                  color: NasaqColors.inkPrimary,
                ),
                h3: GoogleFonts.readexPro(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: NasaqColors.emeraldRoyal,
                  height: 1.75,
                ),
                strong: GoogleFonts.ibmPlexSansArabic(
                  fontWeight: FontWeight.bold,
                  color: NasaqColors.inkPrimary,
                ),
              ),
            ),
          );
        }),
        if (isStreaming) const PulsatingCursor(),
      ],
    );
  }
}

class _ParsedPart {
  final bool isCode;
  final String text;
  final String? lang;

  _ParsedPart({required this.isCode, required this.text, this.lang});
}
