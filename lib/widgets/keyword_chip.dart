import 'package:flutter/material.dart';

class KeywordChip extends StatelessWidget {
  final String label;

  const KeywordChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFD2E1F3), // secondary-container from Academic Serenity
        borderRadius: BorderRadius.circular(9999), // Pill shape (absolute no sharp corners)
        border: Border.all(color: const Color(0xFFC4C6CD)), // outline-variant
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12, // label-md
          fontWeight: FontWeight.w600,
          color: Color(0xFF556473), // on-secondary-container
        ),
      ),
    );
  }
}
