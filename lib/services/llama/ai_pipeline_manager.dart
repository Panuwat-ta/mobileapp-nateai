import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/result.dart';
import 'llama_service.dart';
import '../database/database_service.dart';

final aiPipelineProvider = Provider<AIPipelineManager>((ref) {
  return AIPipelineManager(
    ref.read(llamaServiceProvider),
    ref.read(databaseProvider),
  );
});

class AIPipelineManager {
  final LlamaService _llamaService;
  final DatabaseService _dbService;

  AIPipelineManager(this._llamaService, this._dbService);

  /// Pass 1 (Immediate Output):
  /// Extract Title, Summary, Homework, Exam.
  /// Unblocks the UI as fast as possible (< 15s).
  Future<Result<String>> executePass1(String transcript) async {
    return await _llamaService.generateSummary(transcript);
  }

  /// Pass 2 (Background Metadata):
  /// Extract Keywords, Key_Terms and update FTS5 silently.
  Future<void> executePass2(String transcript, String pass1Json, int noteId) async {
    try {
      // Mock keyword extraction
      await Future.delayed(const Duration(seconds: 3));
      final keywords = 'study, AI, app design';
      
      // Update SQLite FTS5 index silently
      final db = await _dbService.database;
      await db.update(
        'notes_fts',
        {'summary_json': '$pass1Json, "keywords": "$keywords"'},
        where: 'rowid = ?',
        whereArgs: [noteId],
      );
    } catch (e) {
      // Log error silently, do not interrupt UI
      print('Pass 2 Failed: $e');
    }
  }

  /// Pass 3 (On-Demand):
  /// Generate Flashcards or Quiz when user clicks the button.
  Future<Result<String>> executePass3(String transcript) async {
    try {
      // Mock flashcard generation
      await Future.delayed(const Duration(seconds: 2));
      return const Success('{"flashcards": [{"q": "What is AI?", "a": "Artificial Intelligence"}]}');
    } catch (e, st) {
      return Failure('Failed to generate flashcards', e, st);
    }
  }
}
