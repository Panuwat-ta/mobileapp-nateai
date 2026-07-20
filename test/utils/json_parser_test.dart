import 'package:flutter_test/flutter_test.dart';
import 'package:noteai/utils/json_parser.dart';
import 'package:noteai/utils/result.dart';

void main() {
  group('JsonParser', () {
    test('Should parse pure JSON string correctly', () {
      const input = '{"title": "Test Title", "summary": "Test summary"}';
      
      final result = JsonParser.parseLlmResponse(input);
      
      expect(result is Success, true);
      final data = (result as Success<Map<String, dynamic>>).data;
      expect(data['title'], 'Test Title');
      expect(data['summary'], 'Test summary');
    });

    test('Should extract and parse JSON wrapped in markdown fences', () {
      const input = '''
      Here is your summary:
      ```json
      {
        "title": "Markdown Title",
        "keywords": ["Flutter", "Dart"]
      }
      ```
      Hope this helps!
      ''';
      
      final result = JsonParser.parseLlmResponse(input);
      
      expect(result is Success, true);
      final data = (result as Success<Map<String, dynamic>>).data;
      expect(data['title'], 'Markdown Title');
      expect(data['keywords'], ['Flutter', 'Dart']);
    });

    test('Should return Failure on invalid JSON', () {
      const input = '{"title": "Missing Quote}';
      
      final result = JsonParser.parseLlmResponse(input);
      
      expect(result is Failure, true);
    });
  });
}
