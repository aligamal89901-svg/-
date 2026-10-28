import "../models/nasaq_models.dart";

class NasaqCoordinator {
  static List<SkillModel> selectRelevantSkills({
    required AssistantModel assistant,
    required Set<String> enabledSkillIds,
    required String userPrompt,
  }) {
    final activeSkills = assistant.skills
        .where((s) => enabledSkillIds.contains(s.id))
        .toList();

    if (activeSkills.isEmpty) return const [];

    final normalizedPrompt = userPrompt.toLowerCase();
    final matched = <SkillModel>[];

    for (final skill in activeSkills) {
      final hasKeywordMatch = skill.keywords.any(
        (kw) => normalizedPrompt.contains(kw.toLowerCase()),
      );
      if (hasKeywordMatch || skill.scope == SkillScope.general) {
        matched.add(skill);
      }
    }

    if (matched.isEmpty && activeSkills.isNotEmpty) {
      matched.add(activeSkills.first);
    }

    return matched;
  }

  static CompiledPromptPacket buildPacket({
    required AssistantModel assistant,
    required Set<String> enabledSkillIds,
    required String userPrompt,
    required String modelId,
  }) {
    final chosenSkills = selectRelevantSkills(
      assistant: assistant,
      enabledSkillIds: enabledSkillIds,
      userPrompt: userPrompt,
    );

    return CompiledPromptPacket(
      assistantName: assistant.name,
      modelId: modelId,
      systemPersona: assistant.systemPersona,
      selectedSkills: chosenSkills,
      userMessage: userPrompt,
    );
  }

  static String generateArchitecturalPreviewResponse(
    AssistantModel assistant,
    CompiledPromptPacket packet,
  ) {
    final skillNames = packet.selectedSkills.isEmpty
        ? "بدون مهارات فرعية (التعليمات الأساسية فقط)"
        : packet.selectedSkills.map((s) => "«${s.name}»").join(" + ");

    return "تم استلام طلبك في مساحة عمل **${assistant.name}**.\n\n"
        "• **قرار منسّق المهام (Coordinator):** تم انتقاء وتفعيل: $skillNames فقط لهذه الرسالة.\n"
        "• **النموذج المحدد:** `${packet.modelId}` (وضع المحاكاة المعمارية المحلية).\n"
        "• **الأدوات المسموحة:** ${assistant.allowedTools.join("، ")}.\n\n"
        "اضغط على زر **«فحص حزمة التوجيه»** بالأسفل لمعاينة الحزمة المركّبة.";
  }
}
