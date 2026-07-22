import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/tasks_provider.dart';

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
            Text(
              'Lecture Note AI',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
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
                      onPressed: () {},
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
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: _TaskCard(
                          title: task.title,
                          subtitle: task.noteTitle,
                          description: task.subtitle,
                          timeInfo: 'Upcoming',
                          dateInfo: task.dateStr ?? 'No date',
                          icon: task.title.toLowerCase().contains('exam') ? Icons.menu_book : Icons.event,
                          iconColor: Theme.of(context).colorScheme.secondary,
                          isCompleted: false,
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

class _TaskCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final String timeInfo;
  final String dateInfo;
  final IconData icon;
  final Color iconColor;
  final bool isCompleted;

  const _TaskCard({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.timeInfo,
    required this.dateInfo,
    required this.icon,
    required this.iconColor,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isCompleted ? 0.7 : 1.0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          border: Border.all(color: const Color(0xFFDDE2E5)),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            if (!isCompleted)
              const BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    subtitle,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 20,
                decoration: isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: Color(0xFFDDE2E5)),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  timeInfo,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: isCompleted ? Theme.of(context).colorScheme.onSurfaceVariant : Theme.of(context).colorScheme.primary,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Text(
                  dateInfo,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
