import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/constants/app_constants.dart';
import '../../../widgets/flashcard_widget.dart';
import '../../notes/providers/flashcards_provider.dart';

class FlashcardScreen extends ConsumerWidget {
  final int noteId;

  const FlashcardScreen({super.key, required this.noteId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flashcardsAsync = ref.watch(flashcardsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ทบทวนบทเรียน'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: flashcardsAsync.when(
        data: (allCards) {
          final noteCards = allCards.where((fc) => fc.noteId == noteId).toList();
          final cardsToDisplay = noteCards.isNotEmpty ? noteCards : allCards;

          if (cardsToDisplay.isEmpty) {
            return const Center(
              child: Text('ไม่มีแฟลชการ์ดสำหรับโน้ตนี้'),
            );
          }

          return Column(
            children: [
              const SizedBox(height: AppConstants.space24),
              Text(
                'แตะที่การ์ดเพื่อดูเฉลย ปัดซ้ายขวาเพื่อเปลี่ยนข้อ (${cardsToDisplay.length} ข้อ)',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppConstants.space24),
              Expanded(
                child: PageView.builder(
                  controller: PageController(viewportFraction: 0.85),
                  itemCount: cardsToDisplay.length,
                  itemBuilder: (context, index) {
                    final fc = cardsToDisplay[index];
                    return FlashcardWidget(
                      question: fc.term,
                      answer: fc.definition,
                    );
                  },
                ),
              ),
              const SizedBox(height: AppConstants.space48),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
