import 'package:flutter_test/flutter_test.dart';
import 'package:noteai/models/flashcard.dart';

void main() {
  group('Flashcard Model', () {
    test('should initialize properly', () {
      final fc = Flashcard(
        noteId: 1,
        noteTitle: 'Note Title',
        term: 'Term',
        definition: 'Definition',
      );

      expect(fc.noteId, 1);
      expect(fc.noteTitle, 'Note Title');
      expect(fc.term, 'Term');
      expect(fc.definition, 'Definition');
    });
  });
}
