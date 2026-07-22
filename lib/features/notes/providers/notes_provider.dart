import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/database/database_service.dart';
import '../../../models/note.dart';

final notesProvider = FutureProvider<List<Note>>((ref) async {
  final dbService = ref.watch(databaseProvider);
  final db = await dbService.database;
  final List<Map<String, dynamic>> maps = await db.query(
    'notes',
    orderBy: 'created_at DESC',
  );
  return maps.map((map) => Note.fromMap(map)).toList();
});

final notesSearchProvider = FutureProvider.family<List<Note>, String>((ref, query) async {
  if (query.isEmpty) {
    return ref.watch(notesProvider.future);
  }
  
  final dbService = ref.watch(databaseProvider);
  final results = await dbService.searchNotes(query);
  return results.map((map) => Note.fromMap(map)).toList();
});

/// Library-specific search query (renamed to avoid collision with search_provider.dart)
class LibrarySearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void updateQuery(String query) {
    state = query;
  }
}

final librarySearchQueryProvider = NotifierProvider<LibrarySearchQueryNotifier, String>(() {
  return LibrarySearchQueryNotifier();
});
