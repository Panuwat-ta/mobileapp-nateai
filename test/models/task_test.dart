import 'package:flutter_test/flutter_test.dart';
import 'package:noteai/models/task.dart';

void main() {
  group('Task Model', () {
    test('should initialize properly', () {
      final task = Task(
        noteId: 1,
        noteTitle: 'Note Title',
        title: 'Task Title',
        subtitle: 'Task Subtitle',
        dateStr: '2023-10-10',
      );

      expect(task.noteId, 1);
      expect(task.noteTitle, 'Note Title');
      expect(task.title, 'Task Title');
      expect(task.subtitle, 'Task Subtitle');
      expect(task.dateStr, '2023-10-10');
    });
  });
}
