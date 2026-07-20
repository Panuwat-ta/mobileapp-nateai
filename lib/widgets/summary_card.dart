import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app/constants/app_constants.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback? onExport;

  const SummaryCard({
    super.key,
    required this.title,
    required this.content,
    this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    // 20dp radius, 1px border (Inherited from AppTheme)
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.space16, vertical: AppConstants.space8),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppConstants.space16),
            Text(
              content,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.6, // Readability first (generous line height)
                color: const Color(0xFF191C1D),
              ),
            ),
            const SizedBox(height: AppConstants.space24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: content));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('คัดลอกลงคลิปบอร์ดแล้ว')),
                    );
                  },
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  label: const Text('คัดลอก'),
                ),
                if (onExport != null) ...[
                  const SizedBox(width: AppConstants.space8),
                  OutlinedButton.icon(
                    onPressed: onExport,
                    icon: const Icon(Icons.ios_share_rounded, size: 18),
                    label: const Text('ส่งออก'),
                  ),
                ],
              ],
            )
          ],
        ),
      ),
    );
  }
}
