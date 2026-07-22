import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/result.dart';
import '../ai/local_text_processor.dart';
import '../ai/gemini_text_processor.dart';
import '../database/database_service.dart';
import '../../utils/json_parser.dart';

final aiPipelineProvider = Provider<AIPipelineManager>((ref) {
  return AIPipelineManager(
    ref.read(geminiTextProcessorProvider),
    ref.read(localTextProcessorProvider),
    ref.read(databaseProvider),
  );
});

class AIPipelineManager {
  final GeminiTextProcessor _geminiProcessor;
  final LocalTextProcessor _localProcessor;
  final DatabaseService _dbService;

  AIPipelineManager(this._geminiProcessor, this._localProcessor, this._dbService);

  /// Pass 1 (Immediate Output):
  /// Extract Title, Summary, Homework, Exam.
  Future<Result<String>> executePass1(String transcript) async {
    final geminiResult = await _geminiProcessor.processTranscript(transcript);
    if (geminiResult is Success<String>) {
      return geminiResult;
    }
    // Fallback to local
    return await _localProcessor.processTranscript(transcript);
  }

  /// Pass 2 (Background Metadata):
  /// Extract Keywords, Key_Terms and update FTS silently.
  Future<void> executePass2(String transcript, String pass1Json, int noteId) async {
    try {
      Result<String> result = await _geminiProcessor.extractKeywords(transcript);
      if (result is Failure) {
        result = await _localProcessor.extractKeywords(transcript);
      }
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
    final result = await _geminiProcessor.generateFlashcards(transcript);
    if (result is Success<String>) {
      return result;
    }
    return await _localProcessor.generateFlashcards(transcript);
  }
}
