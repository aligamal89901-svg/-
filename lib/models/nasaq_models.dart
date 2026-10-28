import "package:flutter/material.dart";

enum SkillScope {
  general("مهارة عامة"),
  specialized("مهارة متخصصة");

  final String label;
  const SkillScope(this.label);
}

class SkillModel {
  final String id;
  final String name;
  final String description;
  final SkillScope scope;
  final String triggerCondition;
  final List<String> keywords;
  final String instructions;
  final String expectedOutput;
  final bool enabledByDefault;

  const SkillModel({
    required this.id,
    required this.name,
    required this.description,
    required this.scope,
    required this.triggerCondition,
    required this.keywords,
    required this.instructions,
    required this.expectedOutput,
    this.enabledByDefault = true,
  });
}

class AssistantModel {
  final String id;
  final String name;
  final String shortName;
  final String tagline;
  final String title;
  final String summary;
  final IconData icon;
  final Color accentColor;
  final String systemPersona;
  final List<String> allowedTools;
  final List<SkillModel> skills;
  final List<String> starterPrompts;

  const AssistantModel({
    required this.id,
    required this.name,
    required this.shortName,
    required this.tagline,
    required this.title,
    required this.summary,
    required this.icon,
    required this.accentColor,
    required this.systemPersona,
    required this.allowedTools,
    required this.skills,
    required this.starterPrompts,
  });
}

class CompiledPromptPacket {
  final String assistantName;
  final String modelId;
  final String systemPersona;
  final List<SkillModel> selectedSkills;
  final String userMessage;

  const CompiledPromptPacket({
    required this.assistantName,
    required this.modelId,
    required this.systemPersona,
    required this.selectedSkills,
    required this.userMessage,
  });

  String toStructuredPreview() {
    final buffer = StringBuffer();
    buffer.writeln("=== [1] هوية المساعد وتعليماته الأساسية ===");
    buffer.writeln(systemPersona);
    buffer.writeln("\n=== [2] المهارات المختارة لهذه المهمة فقط ===");
    if (selectedSkills.isEmpty) {
      buffer.writeln("لم يتم إرفاق مهارات إضافية (توجيه أساسي فقط).");
    } else {
      for (final skill in selectedSkills) {
        buffer.writeln("• [${skill.name}] (${skill.scope.label}):");
        buffer.writeln("  - الشرط: ${skill.triggerCondition}");
        buffer.writeln("  - التعليمات: ${skill.instructions}");
        buffer.writeln("  - المخرج المتوقع: ${skill.expectedOutput}");
      }
    }
    buffer.writeln("\n=== [3] رسالة المستخدم ===");
    buffer.writeln(userMessage);
    return buffer.toString();
  }
}

class ChatMessage {
  final String id;
  final bool isUser;
  final String content;
  final DateTime timestamp;
  final List<SkillModel> appliedSkills;
  final String modelId;
  final CompiledPromptPacket? promptPacket;
  final bool isError;

  const ChatMessage({
    required this.id,
    required this.isUser,
    required this.content,
    required this.timestamp,
    this.appliedSkills = const [],
    this.modelId = "",
    this.promptPacket,
    this.isError = false,
  });
}

class ApiConnectionConfig {
  final String providerName;
  final String baseUrl;
  final String modelId;
  final bool hasSessionKey;
  final bool simulationMode;

  const ApiConnectionConfig({
    this.providerName = "OpenAI-Compatible API",
    this.baseUrl = "https://api.openai.com/v1",
    this.modelId = "gpt-4o-mini",
    this.hasSessionKey = false,
    this.simulationMode = true,
  });

  ApiConnectionConfig copyWith({
    String? providerName,
    String? baseUrl,
    String? modelId,
    bool? hasSessionKey,
    bool? simulationMode,
  }) {
    return ApiConnectionConfig(
      providerName: providerName ?? this.providerName,
      baseUrl: baseUrl ?? this.baseUrl,
      modelId: modelId ?? this.modelId,
      hasSessionKey: hasSessionKey ?? this.hasSessionKey,
      simulationMode: simulationMode ?? this.simulationMode,
    );
  }
}
