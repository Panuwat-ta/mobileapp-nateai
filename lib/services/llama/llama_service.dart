import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fllama/fllama.dart'; // Assume fllama provides FLlama
import '../../utils/result.dart';

final llamaServiceProvider = Provider<LlamaService>((ref) {
  return LlamaService();
});

class LlamaService {
  double? _contextId;

  /// โหลดโมเดล 1 ครั้งลงใน Isolate 
  Future<Result<bool>> initializeModel() async {
    if (_contextId != null) return const Success(true);
    
    try {
      // 1. Copy model from assets to app directory for fllama to access
      final dir = await getApplicationDocumentsDirectory();
      final modelFile = File('${dir.path}/Qwen3-1.7B-Q8_0.gguf');
      
      if (!await modelFile.exists()) {
        final byteData = await rootBundle.load('assets/models/Qwen3-1.7B-Q8_0.gguf');
        await modelFile.writeAsBytes(byteData.buffer.asUint8List(), flush: true);
      }

      // 2. Initialize FLlama
      final result = await Fllama.instance()!.initContext(modelFile.path, nCtx: 2048); 
      _contextId = result?['contextId'] as double?;
      
      if (_contextId != null) {
        return const Success(true);
      } else {
        return const Failure('Failed to get contextId from Fllama', null, StackTrace.empty);
      }
    } catch (e, st) {
      return Failure('Failed to load LLM model: $e', e, st);
    }
  }

  Future<Result<String>> generateSummary(String transcript) async {
    try {
      await initializeModel();
      if (_contextId == null) return const Failure('Model not initialized', null, StackTrace.empty);
      
      final prompt = '''
      You are an AI assistant. Extract information from the text below.
      Output ONLY valid JSON format with keys: "title", "summary", "homework", "exam".
      Do not explain or add markdown.
      Text: $transcript
      ''';
      
      // Request inference
      final result = await Fllama.instance()!.completion(
        _contextId!,
        prompt: prompt,
        temperature: 0.1,
        topP: 0.85,
      );
      
      final text = result?['text'] as String? ?? '{}';
      return Success(text);
    } catch (e, st) {
      return Failure('Inference failed', e, st);
    }
  }

  Future<Result<String>> generateKeywords(String transcript) async {
    try {
      await initializeModel();
      if (_contextId == null) return const Failure('Model not initialized', null, StackTrace.empty);
      
      final prompt = '''
      Extract maximum 5 keywords from the text.
      Output ONLY valid JSON format: {"keywords": "keyword1, keyword2"}
      Text: $transcript
      ''';
      
      final result = await Fllama.instance()!.completion(
        _contextId!,
        prompt: prompt,
        temperature: 0.1,
      );
      final text = result?['text'] as String? ?? '{}';
      return Success(text);
    } catch (e, st) {
      return Failure('Keyword extraction failed', e, st);
    }
  }

  Future<Result<String>> generateFlashcards(String transcript) async {
    try {
      await initializeModel();
      if (_contextId == null) return const Failure('Model not initialized', null, StackTrace.empty);
      
      final prompt = '''
      Generate 3 flashcards from the text.
      Output ONLY valid JSON format: {"flashcards": [{"q": "Question", "a": "Answer"}]}
      Text: $transcript
      ''';
      
      final result = await Fllama.instance()!.completion(
        _contextId!,
        prompt: prompt,
        temperature: 0.2,
      );
      final text = result?['text'] as String? ?? '{}';
      return Success(text);
    } catch (e, st) {
      return Failure('Flashcard generation failed', e, st);
    }
  }

  void dispose() {
    // Free LLM resources if fllama supports it
    if (_contextId != null) {
      Fllama.instance()!.releaseContext(_contextId!);
      _contextId = null;
    }
  }
}
