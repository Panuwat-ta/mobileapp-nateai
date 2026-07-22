class Task {
  final int noteId;
  final String noteTitle;
  final String title;
  final String subtitle;
  final String? dateStr;

  Task({
    required this.noteId,
    required this.noteTitle,
    required this.title,
    required this.subtitle,
    this.dateStr,
  });
}
