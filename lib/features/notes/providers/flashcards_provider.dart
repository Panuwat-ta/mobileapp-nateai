import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'notes_provider.dart';
import '../../../models/flashcard.dart';

final flashcardsProvider = Provider<AsyncValue<List<Flashcard>>>((ref) {
  final notesAsyncValue = ref.watch(notesProvider);

  return notesAsyncValue.whenData((notes) {
    List<Flashcard> flashcards = [];
    for (final note in notes) {
      final summary = note.parsedSummary;
      if (summary.containsKey('flashcards')) {
        final fcData = summary['flashcards'];
        if (fcData is List) {
          for (var item in fcData) {
            flashcards.add(Flashcard(
              noteId: note.id,
              noteTitle: note.title,
              term: item['q'] ?? item['term'] ?? 'Question',
              definition: item['a'] ?? item['definition'] ?? 'Answer',
            ));
          }
        }
      } else if (summary.containsKey('keywords')) {
         final keywords = (summary['keywords'] as String).split(',');
         for(final kw in keywords) {
             if(kw.trim().isNotEmpty) {
                 flashcards.add(Flashcard(
                    noteId: note.id,
                    noteTitle: note.title,
                    term: kw.trim(),
                    definition: 'Definition for ${kw.trim()} from ${note.title}', // Dummy definition if none provided
                 ));
             }
         }
      }
    }
    return flashcards;
  });
});
