import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../utils/pdf_export_helper.dart';
import '../../../utils/result.dart';
import '../../../models/note.dart';
import '../../../services/llama/ai_pipeline_manager.dart';
import '../../../services/database/database_service.dart';
import '../../../widgets/keyword_chip.dart';
import '../../../widgets/summary_card.dart';
import '../providers/notes_provider.dart';
import '../../flashcards/screens/flashcard_screen.dart';
import '../../../utils/format_helper.dart';

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
    final summaryText = parsedSummary['full_markdown_summary'] ?? parsedSummary['summary'] ?? 'No summary available.';
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
            Expanded(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
            tooltip: 'Delete Note',
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Note'),
                  content: const Text('Are you sure you want to delete this note permanently?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                    FilledButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirmed == true && context.mounted) {
                final dbService = ref.read(databaseProvider);
                await dbService.deleteNote(note.id);
                ref.invalidate(notesProvider);
                if (context.mounted) Navigator.of(context).pop();
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.picture_as_pdf, color: Theme.of(context).colorScheme.primary),
            tooltip: 'Export to PDF',
            onPressed: () async {
              String exportTitle = title;
              String content = FormatHelper.formatToRequestedText(note);
              await PdfExportHelper.exportTextToPdf(exportTitle, content);
            },
          ),
          IconButton(
            icon: Icon(Icons.quiz_outlined, color: Theme.of(context).colorScheme.primary),
            tooltip: 'View Flashcards',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => FlashcardScreen(noteId: note.id)),
              );
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
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTab('AI Summary', 0),
                    const SizedBox(width: 24),
                    _buildTab('Raw Transcript', 1),
                    const SizedBox(width: 24),
                    _buildTab('Final Output', 2),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Bento Grid Content
            if (_tabIndex == 0) 
              _buildAISummary(context, note, summaryText, parsedSummary) 
            else if (_tabIndex == 1)
              _buildRawTranscript(context, note)
            else
              _buildFinalOutput(context, note),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator()),
          );
          
          try {
            final pipeline = ref.read(aiPipelineProvider);
            final result = await pipeline.executePass3(note.rawTranscript);
            
            if (result is Success<String> && context.mounted) {
              Navigator.of(context).pop(); // Close loading
              
              try {
                final parsed = jsonDecode(result.data);
                final flashcards = parsed['flashcards'] as List?;
                final count = flashcards?.length ?? 0;
                
                final existingSummary = note.parsedSummary;
                existingSummary['flashcards'] = flashcards;
                
                final dbService = ref.read(databaseProvider);
                await dbService.updateNote(note.id, {
                  'summary_json': jsonEncode(existingSummary),
                });
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Generated $count flashcards! Check the Flashcards tab.'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                  ref.invalidate(notesProvider);
                }
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Flashcards generated! Check the Flashcards tab.')),
                  );
                }
              }
            } else {
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to generate flashcards')),
                );
              }
            }
          } catch (e) {
            if (context.mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e')),
              );
            }
          }
        },
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
        SummaryCard(
          title: 'Immediate Summary',
          content: summaryText,
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
                    children: (parsedSummary['keywords'] as String).split(',').map((term) => KeywordChip(label: term.trim())).toList(),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
  
  Widget _buildRawTranscript(BuildContext context, Note note) {
    return Text(
      note.rawTranscript,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildFinalOutput(BuildContext context, Note note) {
    final text = FormatHelper.formatToRequestedText(note);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        border: Border.all(color: const Color(0xFFDDE2E5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SelectableText(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
