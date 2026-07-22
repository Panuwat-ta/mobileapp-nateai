import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/constants/app_constants.dart';
import '../../../widgets/search_bar_widget.dart';
import '../providers/search_provider.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchResultsAsync = ref.watch(searchResultsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ค้นหาโน้ต'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.space16),
            child: SearchBarWidget(
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).updateQuery(value);
              },
            ),
          ),
          Expanded(
            child: searchResultsAsync.when(
              data: (results) {
                if (results.isEmpty) {
                  final query = ref.read(searchQueryProvider);
                  if (query.isEmpty) {
                    return _buildEmptyState(context, 'พิมพ์เพื่อค้นหาจากเนื้อหาทั้งหมด', Icons.search_rounded);
                  }
                  return _buildEmptyState(context, 'ไม่พบผลลัพธ์ที่ตรงกับ "$query"', Icons.search_off_rounded);
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(AppConstants.space16),
                  itemCount: results.length,
                  separatorBuilder: (context, index) => const SizedBox(height: AppConstants.space8),
                  itemBuilder: (context, index) {
                    final note = results[index];
                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
                        side: const BorderSide(color: Color(0xFFDDE2E5)),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: AppConstants.space16, vertical: AppConstants.space8),
                        title: Text(note['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('ID: ${note['id']} - พบคำตรงกันจาก AI สรุป'),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                        onTap: () {
                          // Action is handled by onChangedDetailScreen
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, st) => _buildEmptyState(context, 'เกิดข้อผิดพลาดในการค้นหา', Icons.error_outline_rounded),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message, IconData icon) {
    // Empty state with Illustration/Icon, Explanation, no dead ends
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Theme.of(context).colorScheme.outlineVariant),
          const SizedBox(height: AppConstants.space16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
