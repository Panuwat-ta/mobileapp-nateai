import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noteai/models/note.dart';
import 'package:noteai/features/notes/providers/notes_provider.dart';
import 'package:noteai/features/notes/providers/tasks_provider.dart';
import 'dart:convert';

void main() {
  group('Tasks Provider', () {
    test('extracts tasks from notes correctly', () async {
      final mockNotes = [
        Note(
          id: 1,
          title: 'Math',
          rawTranscript: '',
          summaryJson: jsonEncode({
            'homework': [
              {'title': 'HW1', 'description': 'Do math', 'due_date': '2023-10-10'}
            ],
            'exam': 'Final exam tomorrow'
          }),
          createdAt: 0,
        )
      ];

      final container = ProviderContainer(
        overrides: [
          notesProvider.overrideWith((ref) => mockNotes),
        ],
      );

      final asyncTasks = container.read(tasksProvider);
      
      expect(asyncTasks, isA<AsyncData>());
      final tasks = asyncTasks.value!;
      
      expect(tasks.length, 2);
      expect(tasks[0].title, 'HW1');
      expect(tasks[1].title, 'Exam');
      expect(tasks[1].subtitle, 'Final exam tomorrow');
    });
  });
}
