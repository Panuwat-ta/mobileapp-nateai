import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noteai/models/note.dart';
import 'package:noteai/features/notes/providers/notes_provider.dart';
import 'package:noteai/features/notes/providers/flashcards_provider.dart';
import 'dart:convert';

void main() {
  group('Flashcards Provider', () {
    test('extracts flashcards from notes correctly', () async {
      final mockNotes = [
        Note(
          id: 1,
          title: 'Science',
          rawTranscript: '',
          summaryJson: jsonEncode({
            'flashcards': [
              {'q': 'What is H2O?', 'a': 'Water'}
            ],
            'keywords': 'Biology, Chemistry'
          }),
          createdAt: 0,
        )
      ];

      final container = ProviderContainer(
        overrides: [
          notesProvider.overrideWith((ref) => mockNotes),
        ],
      );

      final asyncCards = container.read(flashcardsProvider);
      
      expect(asyncCards, isA<AsyncData>());
      final cards = asyncCards.value!;
      
      expect(cards.length, 1); // Because flashcards key takes precedence over keywords
      expect(cards[0].term, 'What is H2O?');
      expect(cards[0].definition, 'Water');
    });

    test('extracts keywords when no flashcards', () async {
      final mockNotes = [
        Note(
          id: 2,
          title: 'History',
          rawTranscript: '',
          summaryJson: jsonEncode({
            'keywords': 'WW2, Europe'
          }),
          createdAt: 0,
        )
      ];

      final container = ProviderContainer(
        overrides: [
          notesProvider.overrideWith((ref) => mockNotes),
        ],
      );

      final asyncCards = container.read(flashcardsProvider);
      
      final cards = asyncCards.value!;
      
      expect(cards.length, 2);
      expect(cards[0].term, 'WW2');
      expect(cards[1].term, 'Europe');
    });
  });
}
