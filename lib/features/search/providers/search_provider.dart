import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/database/database_service.dart';
import '../../../models/note.dart';

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

final searchResultsProvider = FutureProvider<List<Note>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return [];

  final dbService = ref.read(databaseProvider);
  final results = await dbService.searchNotes(query);
  return results.map((map) => Note.fromMap(map)).toList();
});
