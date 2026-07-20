import 'dart:convert';
import 'result.dart';

class JsonParser {
  /// Extracts JSON string from LLM output that might contain markdown fences
  static Result<Map<String, dynamic>> parseLlmResponse(String response) {
    try {
      String jsonString = response;
      // Strip markdown code fences if LLM accidentally adds them
      final regex = RegExp(r'```(?:json)?\s*([\s\S]*?)\s*```');
      final match = regex.firstMatch(response);
      if (match != null && match.group(1) != null) {
        jsonString = match.group(1)!;
      }
      
      final parsed = jsonDecode(jsonString.trim()) as Map<String, dynamic>;
      return Success(parsed);
    } catch (e, st) {
      return Failure('Failed to parse JSON: $e', e, st);
    }
  }
}
