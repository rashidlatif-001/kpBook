import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book_model.dart';
import '../providers/app_state.dart';
import '../theme/app_colors.dart';
import 'pdf_reader_screen.dart';
import 'offline_shelf_screen.dart';

class ContentSelectionScreen extends StatelessWidget {
  final Book book;

  const ContentSelectionScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with book gradient header
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: book.coverGradientStart,
            foregroundColor: Colors.white,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 19),
                  ),
                ),
              ),
            ),
            actions: [
              // Download Manager / Offline Mode trigger
              IconButton(
                tooltip: 'Offline Mode',
                icon: const Icon(Icons.downloading_rounded, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OfflineShelfScreen()),
                  );
                },
              ),
              // Bookmark save/unsave
              IconButton(
                tooltip: book.isBookmarked ? 'Saved' : 'Save Book',
                icon: Icon(
                  book.isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                  color: book.isBookmarked ? AppColors.onTertiaryContainer : Colors.white,
                ),
                onPressed: () => appState.toggleBookmark(book),
              ),
              // Share App only (Books cannot be shared outside app)
              IconButton(
                tooltip: 'Share App',
                icon: const Icon(Icons.share_rounded, color: Colors.white),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sharing KPK E-Textbooks App link. Textbooks are protected for in-app reading.'),
                    ),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [book.coverGradientStart, book.coverGradientEnd],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Icon Box
                    Container(
                      width: 64,
                      height: 84,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: Center(
                        child: Icon(book.icon, size: 36, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Details
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'CLASS ${book.classNumber} • ${book.isGuide ? 'GUIDE' : 'OFFICIAL BOOK'}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            book.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (book.titleUrdu.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              book.titleUrdu,
                              textDirection: TextDirection.rtl,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Action Toolbar (File Size, Curriculum, and Status removed)
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.surfaceContainerLowest,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.menu_book_rounded, size: 16, color: AppColors.primaryContainer),
                          const SizedBox(width: 6),
                          Text(
                            'Total Book Content: ${book.pagesCount} Pages',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                      if (book.isDownloaded)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.offline_pin_rounded, size: 13, color: AppColors.onSecondaryContainer),
                              SizedBox(width: 4),
                              Text(
                                'Saved Offline',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onSecondaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Dark Resume Reading / Start Reading CTA Button
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E2621), // Dark button as requested
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PdfReaderScreen(
                                  book: book,
                                  initialPage: book.lastReadPage > 1 ? book.lastReadPage : 1,
                                  isFromResume: false, // Save icon remains clickable from listing
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.auto_stories_rounded, size: 20),
                          label: Text(
                            book.lastReadPage > 1 ? 'Resume Reading (Pg ${book.lastReadPage})' : 'Start Reading Textbook',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (!book.isDownloaded)
                        IconButton.filledTonal(
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.secondaryContainer,
                            foregroundColor: AppColors.onSecondaryContainer,
                            padding: const EdgeInsets.all(12),
                          ),
                          onPressed: () => appState.startDownload(book),
                          icon: book.isDownloading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.secondary),
                                )
                              : const Icon(Icons.download_rounded),
                          tooltip: 'Download Offline',
                        )
                      else
                        IconButton.filledTonal(
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.surfaceContainer,
                            foregroundColor: AppColors.error,
                            padding: const EdgeInsets.all(12),
                          ),
                          onPressed: () => appState.deleteDownload(book),
                          icon: const Icon(Icons.delete_outline_rounded),
                          tooltip: 'Remove Download',
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Row(
                children: [
                  Text(
                    'TABLE OF CONTENTS / UNITS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  Spacer(),
                  Text(
                    'Tap unit to read',
                    style: TextStyle(fontSize: 11, color: AppColors.outline),
                  ),
                ],
              ),
            ),
          ),

          // Chapter List (plain numbering 1, 2 without tick marks, correct page numbers)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final chapter = book.chapters[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.cardBorder, width: 1),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PdfReaderScreen(
                                book: book,
                                initialPage: chapter.pageStart,
                                isFromResume: false,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  // Plain numbering (tick mark removed as requested)
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceContainerLow,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: AppColors.cardBorder),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${chapter.number}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.primaryContainer,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Unit ${chapter.number}: ${chapter.title}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.onSurface,
                                          ),
                                        ),
                                        if (chapter.titleUrdu.isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            chapter.titleUrdu,
                                            textDirection: TextDirection.rtl,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  // Accurate page numbering
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceContainerLow,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Pg ${chapter.pageStart}–${chapter.pageEnd}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.outline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (chapter.keyTopics.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: chapter.keyTopics.map((topic) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceContainerLow,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        topic,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
                childCount: book.chapters.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}
