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
      appBar: CustomAppBar(
        tag: 'Offline',
        title: 'Offline Mode',
        subtitle: 'Saved Textbooks & Guides • Zero Internet Required',
        showBackButton: true,
        onBackPressed: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else if (onSwitchTab != null) {
            onSwitchTab!(0); // Return to Home screen
          }
        },
      ),
      body: Column(
        children: [
          // Storage & Offline Mode Summary Header
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.surfaceContainerLow,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Offline Mode',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                                ),
                                Text(
                                  '${offlineBooks.length} items saved in app-private storage',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Real calculated storage from downloaded files
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.sd_storage_rounded, size: 14, color: AppColors.primaryContainer),
                          const SizedBox(width: 4),
                          Text(
                            appState.totalStorageUsedFormatted,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryContainer),
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
                            child: const Icon(
                              Icons.cloud_download_outlined,
                              size: 48,
                              color: AppColors.outlineVariant,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No Offline Books Saved',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Download any textbook or guide while connected to read anytime without internet.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 16),
                          FilledButton.tonal(
                            onPressed: () {
                              if (onSwitchTab != null) onSwitchTab!(1);
                            },
                            child: const Text('Browse Textbooks to Download'),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: offlineBooks.length,
                    itemBuilder: (context, index) {
                      return BookCard(
                        book: offlineBooks[index],
                        isHorizontal: true,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
