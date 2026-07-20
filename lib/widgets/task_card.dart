import 'package:flutter/material.dart';
import '../app/constants/app_constants.dart';

enum TaskType { homework, exam }

class TaskCard extends StatelessWidget {
  final String title;
  final DateTime date;
  final TaskType type;
  final VoidCallback? onAddToCalendar;

  const TaskCard({
    super.key,
    required this.title,
    required this.date,
    required this.type,
    this.onAddToCalendar,
  });

  @override
  Widget build(BuildContext context) {
    final isExam = type == TaskType.exam;
    final bgColor = isExam ? const Color(0xFFFFF4E5) : const Color(0xFFE7F3EF); // warning-muted vs success-muted
    final iconColor = isExam ? const Color(0xFFE65100) : const Color(0xFF1B5E20);
    final icon = isExam ? Icons.event_rounded : Icons.assignment_rounded;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.space16, vertical: AppConstants.space8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        border: Border.all(color: iconColor.withOpacity(0.2)), // Prefer borders over shadows
      ),
      padding: const EdgeInsets.all(AppConstants.space16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.space12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: AppConstants.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF191C1D),
                  ),
                ),
                const SizedBox(height: AppConstants.space4),
                Text(
                  '${date.day}/${date.month}/${date.year}',
                  style: TextStyle(
                    fontSize: 14,
                    color: iconColor.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (onAddToCalendar != null)
            IconButton(
              icon: Icon(Icons.edit_calendar_rounded, color: iconColor),
              onPressed: onAddToCalendar,
              tooltip: 'บันทึกลงปฏิทิน',
            )
        ],
      ),
    );
  }
}
