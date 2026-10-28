import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ai_provider.dart';

class WorkspaceFileItem {
  final String name;
  final String relativePath;
  final String ubuntuPath;
  final String termuxPath;
  final int sizeBytes;

  const WorkspaceFileItem({
    required this.name,
    required this.relativePath,
    required this.ubuntuPath,
    required this.termuxPath,
    required this.sizeBytes,
  });

  factory WorkspaceFileItem.fromJson(Map<String, dynamic> json) {
    return WorkspaceFileItem(
      name: json['name'] as String? ?? '',
      relativePath: json['path'] as String? ?? '',
      ubuntuPath: json['ubuntu_path'] as String? ?? '',
      termuxPath: json['termux_path'] as String? ?? '',
      sizeBytes: json['size'] as int? ?? 0,
    );
  }
}

class AgentBridgeService {
  static String _resolveHost() {
    final rawHost = Uri.base.host;
    return (rawHost.isEmpty || rawHost == '0.0.0.0') ? '127.0.0.1' : rawHost;
  }

  static Future<ToolExecutionData> executeTool(ToolExecutionData tool) async {
    final uri = Uri.parse('http://${_resolveHost()}:8081/v1/agent/exec');
    try {
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json; charset=utf-8'},
            body: jsonEncode({
              'tool': tool.toolName,
              'command': tool.commandOrInput,
              'path': tool.targetPath ?? '',
            }),
          )
          .timeout(const Duration(seconds: 125));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        return tool.copyWith(
          output: data['output'] as String? ?? '',
          exitCode: data['exit_code'] as int? ?? 0,
          isRunning: false,
          isCompleted: true,
        );
      }
      return tool.copyWith(
        output: 'تعذر التنفيذ (HTTP ${response.statusCode})',
        exitCode: 1,
        isRunning: false,
        isCompleted: true,
      );
    } catch (e) {
      return tool.copyWith(
        output: 'خطأ اتصال بمحرك Ubuntu PRoot: $e',
        exitCode: 1,
        isRunning: false,
        isCompleted: true,
      );
    }
  }

  static Future<List<WorkspaceFileItem>> listWorkspaceFiles() async {
    final uri = Uri.parse('http://${_resolveHost()}:8081/v1/agent/fs');
    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode({'action': 'list'}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final list = data['files'] as List<dynamic>? ?? [];
        return list
            .map((e) => WorkspaceFileItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<String> readWorkspaceFile(String relativePath) async {
    final uri = Uri.parse('http://${_resolveHost()}:8081/v1/agent/fs');
    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode({'action': 'read', 'path': relativePath}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        return data['content'] as String? ?? '';
      }
    } catch (e) {
      return 'تعذر قراءة الملف: $e';
    }
    return '';
  }
}
