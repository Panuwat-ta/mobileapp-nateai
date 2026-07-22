import '../../models/note.dart';

class FormatHelper {
  static String formatToRequestedText(Note note) {
    final transcript = note.rawTranscript;
    final parsed = note.parsedSummary;
    
    final aiSummary = parsed['full_markdown_summary'] ?? parsed['summary'] ?? 'ไม่มีสรุป';
    
    final StringBuffer buffer = StringBuffer();
    buffer.writeln('**ข้อความที่ถอดเสียงออกมา**');
    buffer.writeln(transcript);
    buffer.writeln('');
    buffer.writeln('**ใช้ ai ทำสรุป**');
    buffer.writeln(aiSummary);
    
    return buffer.toString().trim();
  }
}
