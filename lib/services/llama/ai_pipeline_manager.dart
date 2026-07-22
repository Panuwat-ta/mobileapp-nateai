import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/result.dart';
import 'llama_service.dart';
import '../database/database_service.dart';
import '../../utils/json_parser.dart'; // Assume we have JsonParser

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
  Future<Result<String>> executePass1(String transcript) async {
    return await _llamaService.generateSummary(transcript);
  }

  /// Pass 2 (Background Metadata):
  /// Extract Keywords, Key_Terms and update FTS5 silently.
  Future<void> executePass2(String transcript, String pass1Json, int noteId) async {
    try {
      final result = await _llamaService.generateKeywords(transcript);
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

  /// Pass 3 (On-Demand):
  /// Generate Flashcards or Quiz when user clicks the button.
  Future<Result<String>> executePass3(String transcript) async {
    return await _llamaService.generateFlashcards(transcript);
  }
}
