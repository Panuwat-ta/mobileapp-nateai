import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/result.dart';

final geminiTextProcessorProvider = Provider<GeminiTextProcessor>((ref) {
  return GeminiTextProcessor();
});

class GeminiTextProcessor {
  Future<String?> _getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('gemini_api_key');
  }

  Future<Result<String>> processTranscript(String transcript) async {
    try {
      if (transcript.trim().isEmpty) {
        return const Failure('Empty transcript');
      }

      final apiKey = await _getApiKey();
      if (apiKey == null || apiKey.isEmpty) {
        return const Failure('API Key is missing. Please set it in Settings.');
      }

      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          temperature: 0.2,
        ),
      );

      final prompt = '''
You are a highly accurate Thai lecture summarizer. Process the following transcript and generate a structured summary.
You MUST determine the appropriate headings, topics, and structure based on the raw text itself. Do not restrict yourself to specific headings if they are not relevant.

The JSON schema must be:
{
  "title": "String (A short, descriptive title for the note in Thai)",
  "full_markdown_summary": "String (The complete summary formatted with markdown. Use relevant headings, bullet points, or numbered lists depending on what is actually in the transcript)",
  "keywords": "String (5 key terms separated by commas, in Thai)",
  "flashcards": []
}

Transcript:
$transcript
''';

      final response = await model.generateContent([Content.text(prompt)]);
      final text = response.text;
      if (text == null) {
        return const Failure('No response from AI');
      }

      return Success(text);
    } catch (e, st) {
      return Failure('Gemini processing failed: $e', e, st);
    }
  }

  Future<Result<String>> extractKeywords(String transcript) async {
    // This is typically called in background to just get keywords if not present.
    // Since our processTranscript already gets keywords, we can just return a quick extraction.
    try {
      final apiKey = await _getApiKey();
      if (apiKey == null || apiKey.isEmpty) return const Failure('API Key missing');

      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
        ),
      );

      final prompt = '''
Extract 5 key terms from the following Thai transcript.
Return strictly as JSON:
{
  "keywords": "term1, term2, term3, term4, term5"
}

Transcript:
$transcript
''';

      final response = await model.generateContent([Content.text(prompt)]);
      return Success(response.text ?? '{"keywords": ""}');
    } catch (e, st) {
      return Failure('Keyword extraction failed: $e', e, st);
    }
  }

  Future<Result<String>> generateFlashcards(String transcript) async {
    try {
      final apiKey = await _getApiKey();
      if (apiKey == null || apiKey.isEmpty) return const Failure('API Key missing');

      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
        ),
      );

      final prompt = '''
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

Transcript:
$transcript
''';

      final response = await model.generateContent([Content.text(prompt)]);
      return Success(response.text ?? '{"flashcards": []}');
    } catch (e, st) {
      return Failure('Flashcard generation failed: $e', e, st);
    }
  }
}
