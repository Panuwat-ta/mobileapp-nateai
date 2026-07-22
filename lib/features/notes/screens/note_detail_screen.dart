import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../utils/pdf_export_helper.dart';
import '../../../models/note.dart';

class NoteDetailScreen extends ConsumerStatefulWidget {
  final Note note;
  const NoteDetailScreen({super.key, required this.note});

  @override
  ConsumerState<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends ConsumerState<NoteDetailScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final note = widget.note;
    final parsedSummary = note.parsedSummary;
    final summaryText = parsedSummary['summary'] ?? 'No summary available.';
    final title = note.title.isEmpty ? 'Untitled Note' : note.title;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurfaceVariant),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/icon.png',
                width: 28,
                height: 28,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Lecture Note AI',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf, color: Theme.of(context).colorScheme.primary),
            tooltip: 'Export to PDF',
            onPressed: () async {
              String exportTitle = title;
              String content = _tabIndex == 0 
                  ? summaryText 
                  : note.rawTranscript;
              await PdfExportHelper.exportTextToPdf(exportTitle, content);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Text(
              title,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Text(
                  DateFormat('MMMM d, yyyy').format(DateTime.fromMillisecondsSinceEpoch(note.createdAt)),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Tab Switcher
            Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFDDE2E5))),
              ),
              child: Row(
                children: [
                  _buildTab('AI Summary', 0),
                  const SizedBox(width: 24),
                  _buildTab('Raw Transcript', 1),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Bento Grid Content
            if (_tabIndex == 0) _buildAISummary(context, note, summaryText, parsedSummary) else _buildRawTranscript(context, note),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        icon: const Icon(Icons.quiz),
        label: const Text('Generate Flashcards'),
      ),
    );
  }

  Widget _buildTab(String text, int index) {
    bool isActive = _tabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _tabIndex = index),
      child: Container(
        padding: const EdgeInsets.only(bottom: 12, left: 4, right: 4),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? Theme.of(context).colorScheme.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: isActive ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildAISummary(BuildContext context, Note note, String summaryText, Map<String, dynamic> parsedSummary) {
    return Column(
      children: [
        // Immediate Summary Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            border: Border.all(color: const Color(0xFFDDE2E5)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.psychology, color: Theme.of(context).colorScheme.primaryContainer),
                      const SizedBox(width: 8),
                      Text(
                        'Immediate Summary',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.content_copy, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 20),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                summaryText,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Key Terms
        if (parsedSummary['keywords'] != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLowest,
              border: Border.all(color: const Color(0xFFDDE2E5)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KEY TERMS',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (parsedSummary['keywords'] as String).split(',').map((term) => _buildTermChip(term.trim())).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Tasks & Deadlines
        if (parsedSummary['homework'] != null || parsedSummary['exam'] != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4E5), // warning-muted
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.assignment, color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.8)),
                    const SizedBox(width: 8),
                    Text(
                      'Tasks & Deadlines',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: const Color(0xFF93000a), // on-error-container
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (parsedSummary['homework'] != null)
                  _buildTaskSection(parsedSummary['homework'], Icons.event, true),
                if (parsedSummary['exam'] != null)
                  _buildTaskSection(parsedSummary['exam'], Icons.menu_book, false),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ],
    );
  }
  
  Widget _buildTaskSection(dynamic taskData, IconData icon, bool isWarning) {
    if (taskData is List) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: taskData.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: _buildTaskItem(item['title'] ?? 'Task', item['description'] ?? '', icon, isWarning),
          );
        }).toList(),
      );
    } else if (taskData is String) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: _buildTaskItem('Task', taskData, icon, isWarning),
      );
    }
    return const SizedBox();
  }

  Widget _buildRawTranscript(BuildContext context, Note note) {
    return Text(
      note.rawTranscript,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildTermChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFe7e8e9), // surface-container-high
        border: Border.all(color: const Color(0xFFDDE2E5)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildTaskItem(String title, String subtitle, IconData icon, bool isWarning) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: false,
            onChanged: (val) {},
            activeColor: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              if (subtitle.isNotEmpty)
                Row(
                  children: [
                    Icon(icon, size: 14, color: isWarning ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        subtitle,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: isWarning ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}
