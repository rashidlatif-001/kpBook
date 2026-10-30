import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_colors.dart';
import 'pdf_reader_screen.dart';

class DownloadManagerScreen extends StatelessWidget {
  const DownloadManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final activeDownloads = appState.activeDownloadingBooks;
    final completedDownloads = appState.downloadedBooks;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Download Manager',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.onSurface),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Internal Storage Bar Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Device Storage Allocation',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                      ),
                      Text(
                        '71.5 MB / 32 GB',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryContainer),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: SizedBox(
                      height: 8,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(color: AppColors.secondary),
                          ),
                          Expanded(
                            flex: 12,
                            child: Container(color: AppColors.outlineVariant),
                          ),
                          Expanded(
                            flex: 20,
                            child: Container(color: AppColors.surfaceContainer),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.circle, size: 8, color: AppColors.secondary),
                          SizedBox(width: 4),
                          Text('E-Books (71.5 MB)', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.circle, size: 8, color: AppColors.outlineVariant),
                          SizedBox(width: 4),
                          Text('System Files (8.4 GB)', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.circle, size: 8, color: AppColors.outline),
                          SizedBox(width: 4),
                          Text('Free Space (23.5 GB)', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Wi-Fi Only Preference Tile
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.wifi_rounded, color: AppColors.primaryContainer, size: 20),
                ),
                title: const Text(
                  'Download via Wi-Fi only',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurface),
                ),
                subtitle: const Text(
                  'Prevents mobile data consumption',
                  style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                ),
                value: appState.wifiOnlyDownload,
                activeThumbColor: AppColors.secondary,
                activeTrackColor: AppColors.secondaryContainer,
                onChanged: (val) => appState.toggleWifiOnly(val),
              ),
            ),

            const SizedBox(height: 24),

            // Active Downloads
            if (activeDownloads.isNotEmpty) ...[
              const Text(
                'ACTIVE DOWNLOADS',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 10),
              ...activeDownloads.map((book) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(book.icon, color: AppColors.primaryContainer, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  book.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  'Class ${book.classNumber} • ${(book.downloadProgress * 100).toInt()}% • 1.4 MB/s',
                                  style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.pause_circle_outline_rounded, color: AppColors.outline),
                            onPressed: () => appState.pauseDownload(book),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: AppColors.error),
                            onPressed: () => appState.deleteDownload(book),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: book.downloadProgress,
                          minHeight: 6,
                          color: AppColors.secondary,
                          backgroundColor: AppColors.surfaceContainer,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],

            // Completed Downloads
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'COMPLETED DOWNLOADS',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.onSurfaceVariant),
                ),
                Text(
                  '${completedDownloads.length} Books',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.outline),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (completedDownloads.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: const Text('No completed downloads yet.', style: TextStyle(color: AppColors.onSurfaceVariant)),
              )
            else
              ...completedDownloads.map((book) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          gradient: LinearGradient(
                            colors: [book.coverGradientStart, book.coverGradientEnd],
                          ),
                        ),
                        child: Center(child: Icon(book.icon, size: 20, color: Colors.white)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              book.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              '${book.fileSize} • Class ${book.classNumber} • Verified Offline',
                              style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryContainer,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          minimumSize: const Size(0, 32),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => PdfReaderScreen(book: book)),
                          );
                        },
                        child: const Text('Read', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: AppColors.outline, size: 20),
                        tooltip: 'Delete',
                        onPressed: () => appState.deleteDownload(book),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
