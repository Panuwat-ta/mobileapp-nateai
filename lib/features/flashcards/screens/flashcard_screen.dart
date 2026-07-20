import 'package:flutter/material.dart';
import '../../../app/constants/app_constants.dart';
import '../../../widgets/flashcard_widget.dart';

class FlashcardScreen extends StatelessWidget {
  final int noteId;

  const FlashcardScreen({super.key, required this.noteId});

  @override
  Widget build(BuildContext context) {
    // In real implementation, fetch flashcards from AI or Database
    return Scaffold(
      appBar: AppBar(
        title: const Text('ทบทวนบทเรียน'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: AppConstants.space24),
          Text(
            'แตะที่การ์ดเพื่อดูเฉลย ปัดซ้ายขวาเพื่อเปลี่ยนข้อ',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppConstants.space24),
          Expanded(
            child: PageView(
              controller: PageController(viewportFraction: 0.85),
              children: const [
                FlashcardWidget(
                  question: 'สถาปัตยกรรมแบบ Offline-first คืออะไร?',
                  answer: 'ระบบที่ทำงานบนเครื่องได้ 100% โดยไม่ต้องพึ่งพาอินเทอร์เน็ต เพื่อปกป้อง Privacy',
                ),
                FlashcardWidget(
                  question: 'ข้อดีของ SQLite FTS5 คืออะไร?',
                  answer: 'ความสามารถในการค้นหาข้อความแบบ Full-text Search ได้อย่างรวดเร็ว (Latency < 100ms)',
                ),
                FlashcardWidget(
                  question: 'การออกแบบแบบ Composition over inheritance คืออะไร?',
                  answer: 'การสร้าง UI โดยนำชิ้นส่วนย่อย (Components) มาประกอบเข้าด้วยกัน แทนการใช้คลาสแม่ลูกที่ซับซ้อน',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.space48),
        ],
      ),
    );
  }
}
