import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/book_card.dart';

class OfflineShelfScreen extends StatelessWidget {
  final Function(int)? onSwitchTab;

  const OfflineShelfScreen({super.key, this.onSwitchTab});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final offlineBooks = appState.downloadedBooks;

    return Scaffold(
      appBar: const CustomAppBar(
        tag: 'Offline',
        title: 'Offline Study Shelf',
        subtitle: 'Saved Textbooks • Zero Internet Required',
      ),
      body: Column(
        children: [
          // Storage & Village Mode Summary Header
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.surfaceContainerLow,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.offline_pin_rounded, color: AppColors.onSecondaryContainer, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Village Offline Mode',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                            ),
                            Text(
                              '${offlineBooks.length} books ready for uninterrupted study',
                              style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.sd_storage_rounded, size: 14, color: AppColors.primaryContainer),
                          SizedBox(width: 4),
                          Text(
                            '71.5 MB Used',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryContainer),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.cardBorder),

          // Content
          Expanded(
            child: offlineBooks.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.cloud_download_outlined, size: 48, color: AppColors.primaryContainer),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No Offline Books Yet',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Download your textbooks once, then study anywhere without an internet connection.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () {
                              if (onSwitchTab != null) onSwitchTab!(1);
                            },
                            icon: const Icon(Icons.library_books_rounded, size: 18),
                            label: const Text('Browse Official Library'),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: offlineBooks.length,
                    itemBuilder: (context, index) {
                      return BookCard(book: offlineBooks[index], isHorizontal: true);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
