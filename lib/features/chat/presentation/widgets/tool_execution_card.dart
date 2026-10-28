import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/ai/agent_bridge_service.dart';
import '../../../../core/ai/ai_provider.dart';
import '../../../../core/utils/nasaq_clipboard.dart';
import '../../../../core/widgets/scale_tap.dart';

class ToolExecutionCard extends StatefulWidget {
  final ToolExecutionData tool;

  const ToolExecutionCard({
    super.key,
    required this.tool,
  });

  @override
  State<ToolExecutionCard> createState() => _ToolExecutionCardState();
}

class _ToolExecutionCardState extends State<ToolExecutionCard> {
  late ToolExecutionData _currentTool;
  bool _isCopied = false;
  String _streamedOutput = '';
  Timer? _streamTimer;

  @override
  void initState() {
    super.initState();
    _currentTool = widget.tool;
    _setupOutputStreaming();
  }

  @override
  void didUpdateWidget(covariant ToolExecutionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tool.output != oldWidget.tool.output ||
        widget.tool.isRunning != oldWidget.tool.isRunning ||
        widget.tool.isCompleted != oldWidget.tool.isCompleted) {
      _currentTool = widget.tool;
      _setupOutputStreaming();
    }
  }

  void _setupOutputStreaming() {
    _streamTimer?.cancel();
    final fullOut = _currentTool.output ?? '';
    if (fullOut.isEmpty) {
      _streamedOutput = '';
      return;
    }

    // إذا كانت الأداة مكتملة مسبقاً، نعرض كامل النص
    if (!_currentTool.isRunning && _streamedOutput.length >= fullOut.length) {
      return;
    }

    final lines = fullOut.split('\n');
    int lineIdx = 0;
    _streamedOutput = '';

    _streamTimer = Timer.periodic(const Duration(milliseconds: 35), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (lineIdx < lines.length) {
        setState(() {
          _streamedOutput += (lineIdx == 0 ? '' : '\n') + lines[lineIdx];
          lineIdx++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _streamTimer?.cancel();
    super.dispose();
  }

  Future<void> _rerunManually() async {
    if (_currentTool.isRunning) return;
    setState(() {
      _currentTool = _currentTool.copyWith(isRunning: true, output: null);
      _streamedOutput = '';
    });
    final updated = await AgentBridgeService.executeTool(_currentTool);
    if (!mounted) return;
    setState(() {
      _currentTool = updated;
    });
    _setupOutputStreaming();
  }

  String _getToolLabel() {
    switch (_currentTool.toolName) {
      case 'write_file':
        return 'إنشاء ملف • ${_currentTool.targetPath ?? "workspace"}';
      case 'read_file':
        return 'قراءة ملف • ${_currentTool.targetPath ?? ""}';
      case 'list_files':
        return 'استعراض ملفات مساحة العمل';
      default:
        return 'طرفية Ubuntu PRoot • تنفيذ مباشر';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSuccess = (_currentTool.exitCode ?? 0) == 0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1318),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF28313E),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: const BoxDecoration(
              color: Color(0xFF161C24),
              borderRadius: BorderRadius.vertical(top: Radius.circular(13)),
              border: Border(
                bottom: BorderSide(color: Color(0xFF222A36)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.terminal_rounded,
                        size: 15,
                        color: Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          _getToolLabel(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.ibmPlexSansArabic(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFE2E8F0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _currentTool.isRunning
                        ? const Color(0xFF1E293B)
                        : (isSuccess
                            ? const Color(0xFF132A23)
                            : const Color(0xFF33181B)),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: _currentTool.isRunning
                          ? const Color(0xFF475569)
                          : (isSuccess
                              ? const Color(0xFF1F513F)
                              : const Color(0xFF6B262D)),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_currentTool.isRunning) ...[
                        const SizedBox(
                          width: 8,
                          height: 8,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: Color(0xFFCBD5E1),
                          ),
                        ),
                        const SizedBox(width: 5),
                      ],
                      Text(
                        _currentTool.isRunning
                            ? 'قيد التنفيذ...'
                            : (_currentTool.isCompleted
                                ? (isSuccess ? 'مكتمل (0)' : 'خطأ (${_currentTool.exitCode})')
                                : 'مجدول'),
                        style: GoogleFonts.ibmPlexSansArabic(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _currentTool.isRunning
                              ? const Color(0xFFCBD5E1)
                              : (isSuccess
                                  ? const Color(0xFF6EE7B7)
                                  : const Color(0xFFFCA5A5)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF090C10),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF1E2530)),
                    ),
                    child: SelectableText(
                      _currentTool.commandOrInput,
                      maxLines: 5,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 12,
                        color: const Color(0xFFCBD5E1),
                        height: 1.5,
                      ),
                    ),
                  ),
                ),

                if (_streamedOutput.isNotEmpty || _currentTool.isRunning) ...[
                  const SizedBox(height: 10),
                  Text(
                    'مخرجات الطرفية في Ubuntu (/root/nasaq/workspace):',
                    style: GoogleFonts.ibmPlexSansArabic(
                      fontSize: 10.5,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 180),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF12171F),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF263040)),
                      ),
                      child: SingleChildScrollView(
                        reverse: true,
                        physics: const BouncingScrollPhysics(),
                        child: SelectableText(
                          _streamedOutput.isEmpty ? 'جارٍ التشغيل والتقاط المخرجات...' : _streamedOutput,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11.5,
                            color: const Color(0xFFA7F3D0),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 10),

                Row(
                  children: [
                    ScaleTap(
                      onTap: _rerunManually,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF334155)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.replay_rounded,
                              size: 13,
                              color: Color(0xFFE2E8F0),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'إعادة التشغيل',
                              style: GoogleFonts.ibmPlexSansArabic(
                                fontSize: 11,
                                color: const Color(0xFFE2E8F0),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ScaleTap(
                      onTap: () async {
                        final toCopy = _currentTool.output ?? _currentTool.commandOrInput;
                        await NasaqClipboard.copy(toCopy);
                        setState(() => _isCopied = true);
                        Future.delayed(const Duration(seconds: 2), () {
                          if (mounted) setState(() => _isCopied = false);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Text(
                          _isCopied ? 'تم النسخ' : 'نسخ الناتج',
                          style: GoogleFonts.ibmPlexSansArabic(
                            fontSize: 11,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
