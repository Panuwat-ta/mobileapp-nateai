import 'package:flutter/material.dart';
import '../app/constants/app_constants.dart';

class FlashcardWidget extends StatefulWidget {
  final String question;
  final String answer;

  const FlashcardWidget({
    super.key,
    required this.question,
    required this.answer,
  });

  @override
  State<FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<FlashcardWidget> {
  bool _isFlipped = false;

  @override
  Widget build(BuildContext context) {
    // Tapping flips the card
    return GestureDetector(
      onTap: () {
        setState(() {
          _isFlipped = !_isFlipped;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250), // Maximum duration 250ms per mobile.md
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(horizontal: AppConstants.space8, vertical: AppConstants.space24),
        padding: const EdgeInsets.all(AppConstants.space32),
        decoration: BoxDecoration(
          color: _isFlipped ? Theme.of(context).colorScheme.primaryContainer : Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusCard),
          border: Border.all(
            color: _isFlipped 
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3) 
                : const Color(0xFFDDE2E5),
          ),
        ),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _isFlipped ? 'เฉลย' : 'คำถาม',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: _isFlipped 
                      ? Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.7) 
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppConstants.space16),
              Text(
                _isFlipped ? widget.answer : widget.question,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _isFlipped 
                      ? Theme.of(context).colorScheme.onPrimaryContainer 
                      : Theme.of(context).colorScheme.onSurface,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
