import 'package:flutter_test/flutter_test.dart';
import 'package:noteai/models/note.dart';
import 'dart:convert';

void main() {
  group('Note Model', () {
    test('should construct properly from map', () {
      final map = {
        'id': 1,
        'title': 'Test Note',
        'raw_transcript': 'This is a test.',
        'summary_json': jsonEncode({'summary': 'Test summary', 'keywords': 'test, note'}),
        'created_at': 1634567890,
      };

      final note = Note.fromMap(map);

      expect(note.id, 1);
      expect(note.title, 'Test Note');
      expect(note.rawTranscript, 'This is a test.');
      expect(note.createdAt, 1634567890);
      expect(note.parsedSummary['summary'], 'Test summary');
    });

    test('should return empty map for invalid JSON', () {
      final note = Note(
        id: 2,
        title: 'Error Note',
        rawTranscript: 'Err',
        summaryJson: 'Invalid JSON',
        createdAt: 12345,
      );

      expect(note.parsedSummary, {});
    });
  });
}
