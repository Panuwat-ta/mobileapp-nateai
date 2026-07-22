import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/flashcards_provider.dart';
import '../../../models/flashcard.dart';

class FlashcardsScreen extends ConsumerStatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  ConsumerState<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends ConsumerState<FlashcardsScreen> {
  bool _isFlipped = false;
  int _currentIndex = 0;

  void _flipCard() {
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  void _nextCard(String status, int totalCards) {
    setState(() {
      _isFlipped = false;
      if (_currentIndex < totalCards - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0; // loop back or show completion
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final flashcardsAsyncValue = ref.watch(flashcardsProvider);

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
      body: flashcardsAsyncValue.when(
        data: (flashcards) {
          if (flashcards.isEmpty) {
            return Center(
              child: Text('No flashcards available.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            );
          }
          final currentCard = flashcards[_currentIndex];
          
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                children: [
                  // Progress Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                currentCard.noteTitle,
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Review',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Card ${_currentIndex + 1} of ${flashcards.length}',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Flashcard Area
                  Expanded(
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          if (!_isFlipped) _flipCard();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: double.infinity,
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: TweenAnimationBuilder(
                            tween: Tween<double>(begin: 0, end: _isFlipped ? pi : 0),
                            duration: const Duration(milliseconds: 400),
                            builder: (context, double value, child) {
                              bool isBack = value > pi / 2;
                              return Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()
                                  ..setEntry(3, 2, 0.001)
                                  ..rotateY(value),
                                child: isBack
                                    ? Transform(
                                        alignment: Alignment.center,
                                        transform: Matrix4.identity()..rotateY(pi),
                                        child: _buildBackCard(context, currentCard),
                                      )
                                    : _buildFrontCard(context, currentCard),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Action Buttons
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: !_isFlipped
                          ? ElevatedButton(
                              key: const ValueKey('show_answer'),
                              onPressed: _flipCard,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                minimumSize: const Size(double.infinity, 56),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text('Show Answer'),
                                  SizedBox(width: 8),
                                  Icon(Icons.visibility),
                                ],
                              ),
                            )
                          : Row(
                              key: const ValueKey('actions'),
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => _nextCard('learning', flashcards.length),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 20),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      side: const BorderSide(color: Color(0xFFDDE2E5)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.close, color: Theme.of(context).colorScheme.error),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Still Learning',
                                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () => _nextCard('mastered', flashcards.length),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context).colorScheme.primary,
                                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                      padding: const EdgeInsets.symmetric(vertical: 20),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Icon(Icons.check),
                                        SizedBox(width: 8),
                                        Text('Mastered'),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildFrontCard(BuildContext context, Flashcard card) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDDE2E5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 24,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TERM',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  letterSpacing: 1.5,
                ),
              ),
              Icon(Icons.bookmark_border, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ],
          ),
          const Spacer(),
          Text(
            card.term,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.touch_app, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(
                'Tap card to flip',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackCard(BuildContext context, Flashcard card) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDDE2E5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 24,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DEFINITION',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.definition,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
