import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:llama_cpp_dart/llama_cpp_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/result.dart';

final localTextProcessorProvider = Provider<LocalTextProcessor>((ref) {
  return LocalTextProcessor();
});

class LocalTextProcessor {
  LlamaParent? _llama;

  Future<void> _initLlama() async {
    if (_llama != null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final modelPath = prefs.getString('local_model_path');
      
      if (modelPath == null || modelPath.isEmpty) {
        throw Exception('Model path not set. Please select a model file in Settings.');
      }
      if (!File(modelPath).existsSync()) {
        throw Exception('Model file not found at $modelPath');
      }
      
      final loadCommand = LlamaLoad(
        path: modelPath,
        modelParams: ModelParams(),
        contextParams: ContextParams(),
        samplingParams: SamplerParams(),
      );

      _llama = LlamaParent(loadCommand);
      await _llama!.init();
    } catch (e) {
      debugPrint("Failed to init Llama: $e");
      rethrow;
    }
  }

  Future<Result<String>> processTranscript(String transcript) async {
    try {
      if (transcript.trim().isEmpty) {
        return const Failure('Empty transcript');
      }

      await _initLlama();

      final prompt = '''<|im_start|>system
You are a highly accurate Thai lecture summarizer. Process the transcript and generate a structured summary.
You MUST determine the appropriate headings, topics, and structure based on the raw text itself. Do not restrict yourself to specific headings if they are not relevant.
<|im_end|>
<|im_start|>user
Transcript:
$transcript
<|im_end|>
<|im_start|>assistant
''';

      _llama!.sendPrompt(prompt);
      String resultStr = "";
      await for (final token in _llama!.stream) {
        resultStr += token;
        if (resultStr.contains("<|im_end|>")) {
          resultStr = resultStr.replaceAll("<|im_end|>", "");
          break;
        }
      }

      final result = {
        'title': 'สรุปการเรียน (ออฟไลน์)',
        'full_markdown_summary': resultStr.trim(),
        'summary': resultStr.trim(), // fallback
        'homework': [],
        'exam': [],
        'keywords': '',
        'flashcards': [],
      };

      return Success(jsonEncode(result));
    } catch (e, st) {
      return Failure('Local LLM processing failed: $e', e, st);
    }
  }

  Future<Result<String>> extractKeywords(String transcript) async {
    try {
      await _initLlama();
      final prompt = '''<|im_start|>system
Extract 5 key terms from the following Thai transcript.
Return strictly as JSON:
{
  "keywords": "term1, term2, term3, term4, term5"
}
<|im_end|>
<|im_start|>user
$transcript
<|im_end|>
<|im_start|>assistant
''';

      _llama!.sendPrompt(prompt);
      String resultStr = "";
      await for (final token in _llama!.stream) {
        resultStr += token;
        if (resultStr.contains("<|im_end|>")) {
          resultStr = resultStr.replaceAll("<|im_end|>", "");
          break;
        }
      }
      
      // Attempt to clean JSON
      resultStr = resultStr.replaceAll(RegExp(r'```json|```'), '').trim();
      return Success(resultStr);
    } catch (e, st) {
      return Failure('Keyword extraction failed: $e', e, st);
    }
  }

  Future<Result<String>> generateFlashcards(String transcript) async {
    try {
      await _initLlama();
      final prompt = '''<|im_start|>system
Create 5 flashcards from the following Thai lecture transcript to help the student study.
Return strictly as JSON:
{
  "flashcards": [
    {
      "q": "Question in Thai",
      "a": "Answer in Thai"
    }
  ]
}
<|im_end|>
<|im_start|>user
$transcript
<|im_end|>
<|im_start|>assistant
''';

      _llama!.sendPrompt(prompt);
      String resultStr = "";
      await for (final token in _llama!.stream) {
        resultStr += token;
        if (resultStr.contains("<|im_end|>")) {
          resultStr = resultStr.replaceAll("<|im_end|>", "");
          break;
        }
      }
      
      resultStr = resultStr.replaceAll(RegExp(r'```json|```'), '').trim();
      return Success(resultStr);
    } catch (e, st) {
      return Failure('Flashcard generation failed: $e', e, st);
    }
  }

  void dispose() {
    _llama?.stop();
    _llama = null;
  }
}

