import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'agent_bridge_service.dart';
import 'ai_provider.dart';

class XKiroAiService implements AiProvider {
  static const String _model = 'gemini-3.8-flash';

  @override
  Stream<ChatMessage> streamMessage(
    String prompt, {
    required String messageId,
    String? specialization,
    List<ChatMessage>? history,
  }) async* {
    final startTime = DateTime.now();

    yield ChatMessage(
      id: messageId,
      content: '',
      sender: MessageSender.assistant,
      timestamp: DateTime.now(),
      isStreaming: true,
      isThinkingActive: true,
    );

    final rawHost = Uri.base.host;
    final hostname =
        (rawHost.isEmpty || rawHost == '0.0.0.0') ? '127.0.0.1' : rawHost;
    final proxyUri = Uri.parse('http://$hostname:8081/v1/chat/completions');

    final List<Map<String, String>> conversationPayload = [
      {
        'role': 'system',
        'content': _buildSystemPrompt(specialization, prompt),
      },
    ];

    if (history != null && history.isNotEmpty) {
      final relevantHistory = history.length > 14
          ? history.sublist(history.length - 14)
          : history;

      for (final msg in relevantHistory) {
        if (msg.content.trim().isEmpty) continue;
        conversationPayload.add({
          'role': msg.sender == MessageSender.user ? 'user' : 'assistant',
          'content': msg.content.trim(),
        });
      }
    }

    conversationPayload.add({
      'role': 'user',
      'content': prompt.trim(),
    });

    final client = http.Client();

    try {
      // الدورة الأولى: استلام خطة الوكيل واستدعاءات الأدوات
      final firstPass = await _runSingleStreamPass(
        client: client,
        proxyUri: proxyUri,
        messages: conversationPayload,
        messageId: messageId,
        startTime: startTime,
        existingTools: const [],
        prefixContent: '',
        onProgress: (msg) {},
      );

      // بث الرسالة الأولية
      yield firstPass.lastMessage;

      // إذا استدعى الوكيل أدوات (Tools)، ننفذها فعلياً داخل Ubuntu PRoot
      if (firstPass.parsed.tools.isNotEmpty) {
        final executedTools = <ToolExecutionData>[];

        for (int i = 0; i < firstPass.parsed.tools.length; i++) {
          final pendingTool = firstPass.parsed.tools[i].copyWith(isRunning: true);
          final currentList = [
            ...executedTools,
            pendingTool,
            ...firstPass.parsed.tools.sublist(i + 1),
          ];

          yield firstPass.lastMessage.copyWith(
            isStreaming: true,
            toolExecutions: currentList,
          );

          final completedTool = await AgentBridgeService.executeTool(pendingTool);
          executedTools.add(completedTool);

          yield firstPass.lastMessage.copyWith(
            isStreaming: true,
            toolExecutions: [
              ...executedTools,
              ...firstPass.parsed.tools.sublist(i + 1),
            ],
          );
        }

        // الدورة الثانية التلقائية: إرسال مخرجات Ubuntu الحقيقية للوكيل ليعلق عليها ويكمل المهمة
        final toolSummaryBuffer = StringBuffer();
        toolSummaryBuffer.writeln('تم تنفيذ الأدوات فعلياً في بيئة Ubuntu PRoot وهذه المخرجات الحقيقية:');
        for (final t in executedTools) {
          toolSummaryBuffer.writeln('--- الأداة: ${t.toolName} (${t.targetPath ?? t.commandOrInput}) [Exit: ${t.exitCode}] ---');
          toolSummaryBuffer.writeln(t.output ?? '');
        }
        toolSummaryBuffer.writeln('بناءً على هذه المخرجات الحقيقية من النظام، قدم ملخص النتيجة النهائية للمستخدم بدون تكرار استدعاء نفس الأداة.');

        conversationPayload.add({
          'role': 'assistant',
          'content': firstPass.rawText,
        });
        conversationPayload.add({
          'role': 'user',
          'content': toolSummaryBuffer.toString(),
        });

        final leadContent = firstPass.parsed.cleanContent.isNotEmpty
            ? '${firstPass.parsed.cleanContent}\n\n'
            : '';

        final secondPass = await _runSingleStreamPass(
          client: client,
          proxyUri: proxyUri,
          messages: conversationPayload,
          messageId: messageId,
          startTime: startTime,
          existingTools: executedTools,
          prefixContent: leadContent,
          initialThinking: firstPass.parsed.thinking,
          onProgress: (msg) {},
        );

        yield secondPass.lastMessage.copyWith(
          isStreaming: false,
          isThinkingActive: false,
          toolExecutions: executedTools,
        );
      } else {
        yield firstPass.lastMessage.copyWith(
          isStreaming: false,
          isThinkingActive: false,
        );
      }
    } catch (e) {
      yield ChatMessage(
        id: messageId,
        content: 'تعذر إتمام الاتصال: $e',
        sender: MessageSender.assistant,
        timestamp: DateTime.now(),
        isStreaming: false,
        isThinkingActive: false,
      );
    } finally {
      client.close();
    }
  }

  Future<_PassResult> _runSingleStreamPass({
    required http.Client client,
    required Uri proxyUri,
    required List<Map<String, String>> messages,
    required String messageId,
    required DateTime startTime,
    required List<ToolExecutionData> existingTools,
    required String prefixContent,
    String? initialThinking,
    required void Function(ChatMessage) onProgress,
  }) async {
    final rawBuffer = StringBuffer();
    final reasoningBuffer = StringBuffer();
    if (initialThinking != null && initialThinking.isNotEmpty) {
      reasoningBuffer.write('$initialThinking\n');
    }

    final request = http.Request('POST', proxyUri)
      ..headers.addAll({'Content-Type': 'application/json; charset=utf-8'})
      ..body = jsonEncode({
        'model': _model,
        'stream': true,
        'temperature': 0.55,
        'messages': messages,
      });

    final response = await client.send(request);
    if (response.statusCode != 200) {
      final errBody = await response.stream.bytesToString();
      final errMsg = ChatMessage(
        id: messageId,
        content: 'تعذر الاتصال بالخادم.\n($errBody)',
        sender: MessageSender.assistant,
        timestamp: DateTime.now(),
        isStreaming: false,
        isThinkingActive: false,
        toolExecutions: existingTools,
      );
      return _PassResult(
        rawText: '',
        parsed: _ParsedStream(
          cleanContent: errMsg.content,
          thinking: null,
          isThinkingActive: false,
          suggestions: const [],
          tools: existingTools,
        ),
        lastMessage: errMsg,
      );
    }

    await for (final line in response.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      if (trimmed.contains('[DONE]')) break;

      if (trimmed.startsWith('data: ')) {
        final payload = trimmed.substring(6);
        try {
          final json = jsonDecode(payload) as Map<String, dynamic>;
          final choices = json['choices'] as List<dynamic>?;
          if (choices != null && choices.isNotEmpty) {
            final choice = choices[0] as Map<String, dynamic>;
            final finishReason = choice['finish_reason'] as String?;
            final delta = choice['delta'] as Map<String, dynamic>?;

            final reasoningPiece =
                (delta?['reasoning_content'] ?? delta?['reasoning']) as String?;
            if (reasoningPiece != null && reasoningPiece.isNotEmpty) {
              reasoningBuffer.write(reasoningPiece);
            }

            final contentPiece = delta?['content'] as String?;
            if (contentPiece != null && contentPiece.isNotEmpty) {
              rawBuffer.write(contentPiece);
            }

            if (finishReason != null &&
                finishReason != 'null' &&
                finishReason.isNotEmpty) {
              break;
            }
          }
        } catch (_) {}
      }
    }

    final fullRaw = rawBuffer.toString();
    final parsed = _parsePayload(fullRaw, reasoningBuffer.toString());
    final combinedContent = '$prefixContent${parsed.cleanContent}'.trim();
    final elapsedMs = DateTime.now().difference(startTime).inMilliseconds;

    final finalMsg = ChatMessage(
      id: messageId,
      content: combinedContent.isNotEmpty ? combinedContent : 'تم تنفيذ العملية.',
      sender: MessageSender.assistant,
      timestamp: DateTime.now(),
      isStreaming: false,
      realThinking: parsed.thinking,
      isThinkingActive: false,
      thinkingDurationMs: elapsedMs,
      suggestions: parsed.suggestions,
      toolExecutions: existingTools.isNotEmpty ? existingTools : parsed.tools,
    );

    return _PassResult(
      rawText: fullRaw,
      parsed: parsed,
      lastMessage: finalMsg,
    );
  }

  _ParsedStream _parsePayload(String raw, String rawReasoning) {
    String working = raw;
    String? extractedThinking;
    bool thinkingActive = false;

    if (rawReasoning.isNotEmpty) {
      extractedThinking = rawReasoning.trim();
      thinkingActive = working.trim().isEmpty;
    } else if (working.contains('<think>')) {
      final startIdx = working.indexOf('<think>') + 7;
      if (working.contains('</think>')) {
        final endIdx = working.indexOf('</think>');
        extractedThinking = working.substring(startIdx, endIdx).trim();
        working = working.substring(endIdx + 8).trimLeft();
        thinkingActive = false;
      } else {
        extractedThinking = working.substring(startIdx).trim();
        working = '';
        thinkingActive = true;
      }
    }

    final tools = <ToolExecutionData>[];
    final toolRegex = RegExp(
      r'<tool_call(?:\s+name="([^"]*)")?(?:\s+path="([^"]*)")?>([\s\S]*?)(?:</tool_call>|$)',
    );
    for (final match in toolRegex.allMatches(working)) {
      final name = match.group(1) ?? 'terminal_exec';
      final path = match.group(2);
      final body = (match.group(3) ?? '').trim();
      if (body.isNotEmpty || name == 'list_files') {
        tools.add(ToolExecutionData(
          toolName: name,
          targetPath: path,
          commandOrInput: body.isNotEmpty ? body : 'ls -la /root/nasaq/workspace',
        ));
      }
    }
    working = working.replaceAll(RegExp(r'<tool_call[\s\S]*?(?:</tool_call>|$)'), '').trim();

    final suggestions = <String>[];
    final sugRegex = RegExp(r'<suggestions>([\s\S]*?)(?:</suggestions>|$)');
    final sugMatch = sugRegex.firstMatch(working);
    if (sugMatch != null) {
      final block = sugMatch.group(1) ?? '';
      for (final line in block.split('\n')) {
        final cleaned = line.replaceAll(RegExp(r'^[\s*\-•\d.]+\s*'), '').trim();
        if (cleaned.isNotEmpty && cleaned.length < 55) {
          suggestions.add(cleaned);
        }
      }
      working = working.replaceAll(RegExp(r'<suggestions>[\s\S]*?(?:</suggestions>|$)'), '').trim();
    }

    return _ParsedStream(
      cleanContent: working,
      thinking: extractedThinking,
      isThinkingActive: thinkingActive,
      suggestions: suggestions,
      tools: tools,
    );
  }

  String _buildSystemPrompt(String? spec, String userPrompt) {
    final isAgentMode = spec != null && (spec.contains('إيجنت') || spec.contains('Agent'));
    final isDesigner = spec != null && (spec.contains('المصمم') || spec.contains('design'));

    const thinkingRule =
        'قاعدة التفكير: افتح وسم <think> واكتب خطتك الهندسية بإيجاز، ثم أغلق الوسم بـ </think>.';

    const ubuntuToolsRule = [
      'بيئة التنفيذ الحقيقية (Ubuntu PRoot Environment):',
      'أنت متصل فعلياً ببيئة `proot-distro login ubuntu` والمسار الافتراضي المشترك هو `/root/nasaq/workspace` (وهو مربوط في Termux على المسار `~/nasaq/workspace`).',
      'تملك صلاحية التنفيذ المباشر عبر الأوسمة التالية (سيقوم النظام بتشغيلها تلقائياً وإعطائك النتيجة الفعلية):',
      '1. لتنفيذ أي أمر في طرفية Ubuntu PRoot (مثل فحص النظام، إنشاء مشروع flutter create، أو تشغيل سكربت):',
      '<tool_call name="terminal_exec">',
      'الأمر البرمجي هنا',
      '</tool_call>',
      '2. لإنشاء أو تعديل ملف داخل المسار المشترك `/root/nasaq/workspace`:',
      '<tool_call name="write_file" path="اسم_المجلد_أو_الملف">',
      'محتوى الملف الكامل هنا',
      '</tool_call>',
      '3. لقراءة ملف موجود:',
      '<tool_call name="read_file" path="مسار_الملف">read</tool_call>',
      '4. لاستعراض الملفات في مساحة العمل:',
      '<tool_call name="list_files">ls -la</tool_call>',
    ];

    const suggestionRule = [
      'في نهاية ردك دائماً، اقترح من 2 إلى 3 خطوات عملية تالية مرتبطة بالسياق داخل:',
      '<suggestions>',
      '- الاقتراح الأول',
      '- الاقتراح الثاني',
      '</suggestions>',
    ];

    if (isAgentMode) {
      return [
        'أنت «نَسَق إيجنت» (NASAQ Agent)؛ مهندس أتمتة ووكيل ذكي يعمل داخل بيئة Ubuntu PRoot.',
        thinkingRule,
        ...ubuntuToolsRule,
        ...suggestionRule,
        'عندما يطلب المستخدم إنشاء مشروع فلاتر أو ملف أو فحص أداة، نفذ ذلك فوراً باستدعاء <tool_call> داخل `/root/nasaq/workspace` ولا تكتفِ بالشرح النظري.',
      ].join('\n');
    }

    if (isDesigner) {
      return [
        'أنت «عقل المصمم» في منصة نَسَق (NASAQ).',
        thinkingRule,
        ...ubuntuToolsRule,
        ...suggestionRule,
        'صمم واجهات حداثية متكاملة داخل ```html مع دعم RTL للعربية، ويمكنك حفظ التصميم في ملف داخل مساحة العمل عبر write_file إذا طلب المستخدم.',
      ].join('\n');
    }

    return [
      'أنت «نَسَق» (NASAQ)؛ منصة الذكاء الاصطناعي العربية المتقدمة.',
      thinkingRule,
      ...ubuntuToolsRule,
      ...suggestionRule,
      'تحدث بلغة المستخدم وتذكر سياق المحادثة بالكامل.',
    ].join('\n');
  }
}

class _ParsedStream {
  final String cleanContent;
  final String? thinking;
  final bool isThinkingActive;
  final List<String> suggestions;
  final List<ToolExecutionData> tools;

  _ParsedStream({
    required this.cleanContent,
    required this.thinking,
    required this.isThinkingActive,
    required this.suggestions,
    required this.tools,
  });
}

class _PassResult {
  final String rawText;
  final _ParsedStream parsed;
  final ChatMessage lastMessage;

  _PassResult({
    required this.rawText,
    required this.parsed,
    required this.lastMessage,
  });
}
