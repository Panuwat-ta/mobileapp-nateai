import 'package:flutter/material.dart';
import '../app/constants/app_constants.dart';

class SearchBarWidget extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  final String hintText;

  const SearchBarWidget({
    super.key,
    this.onChanged,
    this.hintText = 'ค้นหาจากสรุปหรือคำสำคัญ...',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusTextField),
        border: Border.all(color: const Color(0xFFDDE2E5)), // surface-border
      ),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF51606F)), // secondary
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: AppConstants.space16, vertical: 14),
        ),
      ),
    );
  }
}
