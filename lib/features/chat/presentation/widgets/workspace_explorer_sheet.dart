import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/ai/agent_bridge_service.dart';
import '../../../../core/theme/nasaq_theme.dart';
import '../../../../core/utils/nasaq_clipboard.dart';
import '../../../../core/widgets/scale_tap.dart';
import 'live_preview_dialog.dart';

class WorkspaceExplorerSheet extends StatefulWidget {
  const WorkspaceExplorerSheet({super.key});

  @override
  State<WorkspaceExplorerSheet> createState() => _WorkspaceExplorerSheetState();
}

class _WorkspaceExplorerSheetState extends State<WorkspaceExplorerSheet> {
  List<WorkspaceFileItem> _files = [];
  bool _isLoading = true;
  String? _selectedFilePath;
  String? _selectedFileContent;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    setState(() => _isLoading = true);
    final items = await AgentBridgeService.listWorkspaceFiles();
    if (!mounted) return;
    setState(() {
      _files = items;
      _isLoading = false;
    });
  }

  Future<void> _openFile(WorkspaceFileItem item) async {
    final content = await AgentBridgeService.readWorkspaceFile(item.relativePath);
    if (!mounted) return;
    setState(() {
      _selectedFilePath = item.relativePath;
      _selectedFileContent = content;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: const BoxDecoration(
        color: Color(0xFFFAF6EE),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // الرأس ومعلومات المسار المزدوج (Ubuntu PRoot + Termux)
          Container(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
            decoration: const BoxDecoration(
              color: Color(0xFFF3ECE0),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(
                bottom: BorderSide(color: Color(0xFFDDD2BC)),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'مساحة عمل نَسَق المشتركة (Ubuntu PRoot)',
                      style: GoogleFonts.readexPro(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: NasaqColors.inkPrimary,
                      ),
                    ),
                    Row(
                      children: [
                        ScaleTap(
                          onTap: _loadFiles,
                          child: const Padding(
                            padding: EdgeInsets.all(6),
                            child: Icon(Icons.refresh_rounded, size: 19, color: NasaqColors.inkPrimary),
                          ),
                        ),
                        const SizedBox(width: 4),
                        ScaleTap(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Padding(
                            padding: EdgeInsets.all(6),
                            child: Icon(Icons.close_rounded, size: 19, color: NasaqColors.inkPrimary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2D8C3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '• مسار Ubuntu PRoot الداخلي: /root/nasaq/workspace',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          color: const Color(0xFF13221F),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '• مسار الوصول من Termux والبرامج: ~/nasaq/workspace',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          color: NasaqColors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _selectedFileContent != null
                    ? _buildFileViewer()
                    : _files.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                'لا توجد ملفات منشأة بعد في مساحة العمل.\nاطلب من نَسَق إيجنت إنشاء مشروع أو ملف ليظهر هنا فوراً.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.ibmPlexSansArabic(
                                  fontSize: 13,
                                  color: NasaqColors.inkMuted,
                                  height: 1.6,
                                ),
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: _files.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, idx) {
                              final f = _files[idx];
                              final isHtml = f.name.endsWith('.html') || f.name.endsWith('.htm');
                              return ScaleTap(
                                onTap: () => _openFile(f),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFE2D8C3)),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isHtml ? Icons.web_rounded : Icons.description_outlined,
                                        color: NasaqColors.inkPrimary,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              f.relativePath,
                                              style: GoogleFonts.jetBrainsMono(
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w600,
                                                color: NasaqColors.inkPrimary,
                                              ),
                                            ),
                                            Text(
                                              'الحجم: ${f.sizeBytes} بايت • ${f.termuxPath}',
                                              style: GoogleFonts.ibmPlexSansArabic(
                                                fontSize: 10.5,
                                                color: NasaqColors.inkMuted,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.chevron_left_rounded,
                                        color: NasaqColors.inkMuted,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileViewer() {
    final isHtml = (_selectedFilePath ?? '').endsWith('.html');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: const Color(0xFFEAE2D3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ScaleTap(
                onTap: () => setState(() {
                  _selectedFileContent = null;
                  _selectedFilePath = null;
                }),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_forward_rounded, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'عودة لقائمة الملفات (${_selectedFilePath ?? ""})',
                      style: GoogleFonts.ibmPlexSansArabic(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  if (isHtml)
                    ScaleTap(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => LivePreviewDialog(
                            code: _selectedFileContent ?? '',
                            language: 'html',
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: NasaqColors.emeraldRoyal,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'معاينة حية',
                          style: GoogleFonts.ibmPlexSansArabic(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  ScaleTap(
                    onTap: () {
                      NasaqClipboard.copy(_selectedFileContent ?? '');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'نسخ المحتوى',
                        style: GoogleFonts.ibmPlexSansArabic(fontSize: 11),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            color: const Color(0xFF0F1318),
            padding: const EdgeInsets.all(14),
            child: SingleChildScrollView(
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: SelectableText(
                  _selectedFileContent ?? '',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 12,
                    color: const Color(0xFFE2E8F0),
                    height: 1.55,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
