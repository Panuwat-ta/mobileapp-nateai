import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'notes_provider.dart';
import '../../../models/task.dart';

final tasksProvider = Provider<AsyncValue<List<Task>>>((ref) {
  final notesAsyncValue = ref.watch(notesProvider);

  return notesAsyncValue.whenData((notes) {
    List<Task> tasks = [];
    for (final note in notes) {
      final summary = note.parsedSummary;
      if (summary.containsKey('homework')) {
        final homework = summary['homework'];
        if (homework is List) {
          for (var item in homework) {
            tasks.add(Task(
              noteId: note.id,
              noteTitle: note.title,
              title: item['title'] ?? 'Homework',
              subtitle: item['description'] ?? 'No description',
              dateStr: item['due_date'],
            ));
          }
        } else if (homework is String) {
          tasks.add(Task(
            noteId: note.id,
            noteTitle: note.title,
            title: 'Homework',
            subtitle: homework,
          ));
        }
      }
      
      if (summary.containsKey('exam')) {
        final exam = summary['exam'];
        if (exam is List) {
          for (var item in exam) {
            tasks.add(Task(
              noteId: note.id,
              noteTitle: note.title,
              title: item['title'] ?? 'Exam',
              subtitle: item['description'] ?? 'No description',
              dateStr: item['date'],
            ));
          }
        } else if (exam is String) {
          tasks.add(Task(
            noteId: note.id,
            noteTitle: note.title,
            title: 'Exam',
            subtitle: exam,
          ));
        }
      }
    }
    return tasks;
  });
});
