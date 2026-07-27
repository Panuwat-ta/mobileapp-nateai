import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/result.dart';
import '../ai/local_text_processor.dart';
import '../database/database_service.dart';
import '../../utils/json_parser.dart';

final aiPipelineProvider = Provider<AIPipelineManager>((ref) {
  return AIPipelineManager(
    ref.read(localTextProcessorProvider),
    ref.read(databaseProvider),
  );
});

class AIPipelineManager {
  final LocalTextProcessor _localProcessor;
  final DatabaseService _dbService;

  AIPipelineManager(this._localProcessor, this._dbService);

  /// Pass 1 (Immediate Output):
  /// Extract Title, Summary, Homework, Exam.
  Future<Result<String>> executePass1(String transcript) async {
    return await _localProcessor.processTranscript(transcript);
  }

  /// Pass 2 (Background Metadata):
  /// Extract Keywords, Key_Terms and update FTS silently.
  Future<void> executePass2(String transcript, String pass1Json, int noteId) async {
    try {
      Result<String> result = await _localProcessor.extractKeywords(transcript);
      if (result is Success<String>) {
        
        final pass1Result = JsonParser.parseLlmResponse(pass1Json);
        final keywordsResult = JsonParser.parseLlmResponse(result.data);
        
        if (pass1Result is Success<Map<String, dynamic>> && keywordsResult is Success<Map<String, dynamic>>) {
          final pass1Map = pass1Result.data;
          final keywordsMap = keywordsResult.data;
          
          pass1Map['keywords'] = keywordsMap['keywords'] ?? keywordsMap;
          final updatedJson = jsonEncode(pass1Map);
          
          // Update SQLite (triggers will auto-sync FTS)
          final db = await _dbService.database;
          await db.update(
            'notes',
            {'summary_json': updatedJson},
            where: 'id = ?',
            whereArgs: [noteId],
          );
        }
      }
    } catch (e) {
      // Log error silently, do not interrupt UI
      debugPrint('Pass 2 Failed: $e');
    }
  }
}
