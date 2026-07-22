import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/tasks_provider.dart';
import '../../../services/calendar/calendar_service.dart';
import '../../../utils/result.dart';
import '../../../widgets/task_card.dart';

class TasksScreen extends ConsumerWidget {

  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsyncValue = ref.watch(tasksProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        toolbarHeight: 48,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/icon.png',
                width: 28,
                height: 28,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Lecture Note AI',
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tasks',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Aggregated deadlines from all lectures.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final tasksValue = ref.read(tasksProvider);
                        final tasksList = tasksValue.value ?? [];
                        if (tasksList.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('No tasks to export')),
                          );
                          return;
                        }
                        
                        final calendarService = ref.read(calendarServiceProvider);
                        int exported = 0;
                        
                        for (final task in tasksList) {
                          final now = DateTime.now();
                          DateTime startDate = now.add(const Duration(days: 1));
                          
                          final result = await calendarService.addEvent(
                            title: task.title,
                            description: '${task.noteTitle}: ${task.subtitle}',
                            startDate: startDate,
                            endDate: startDate.add(const Duration(hours: 1)),
                          );
                          if (result is Success) exported++;
                        }
                        
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Exported $exported task(s) to calendar'),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.calendar_today),
                      label: const Text('Export to Calendar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          tasksAsyncValue.when(
            data: (tasks) {
              if (tasks.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                    child: Center(
                      child: Text('No tasks found.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    ),
                  ),
                );
              }
              
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final task = tasks[index];
                      DateTime taskDate = DateTime.now().add(const Duration(days: 1));
                      if (task.dateStr != null) {
                        try {
                          final parts = task.dateStr!.split(RegExp(r'[/\-]'));
                          if (parts.length >= 3) {
                            taskDate = DateTime(
                              int.parse(parts[2].length == 2 ? '20${parts[2]}' : parts[2]),
                              int.parse(parts[1]),
                              int.parse(parts[0]),
                            );
                          }
                        } catch (_) {}
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: TaskCard(
                          title: '${task.title} - ${task.noteTitle}',
                          date: taskDate,
                          type: task.title.toLowerCase().contains('exam') ? TaskType.exam : TaskType.homework,
                        ),
                      );
                    },
                    childCount: tasks.length,
                  ),
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, stack) => SliverToBoxAdapter(
              child: Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
