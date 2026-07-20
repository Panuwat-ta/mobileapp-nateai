import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/database/database_service.dart';

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void updateQuery(String query) {
    state = query;
  }
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(() {
  return SearchQueryNotifier();
});

final searchResultsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return [];

  final dbService = ref.read(databaseProvider);
  final db = await dbService.database;

  final sanitizedQuery = query.replaceAll("'", "''"); 
  
  final results = await db.rawQuery('''
    SELECT notes.id, notes.title, notes.created_at
    FROM notes
    JOIN notes_fts ON notes.id = notes_fts.rowid
    WHERE notes_fts MATCH '*$sanitizedQuery*'
    ORDER BY rank
    LIMIT 20
  ''');

  return results;
});
