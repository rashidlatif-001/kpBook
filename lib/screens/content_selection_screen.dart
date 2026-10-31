import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book_model.dart';
import '../providers/app_state.dart';
import '../theme/app_colors.dart';
import 'pdf_reader_screen.dart';

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
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  book.isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                  color: book.isBookmarked ? AppColors.onTertiaryContainer : Colors.white,
                ),
                onPressed: () => appState.toggleBookmark(book),
              ),
              IconButton(
                icon: const Icon(Icons.share_rounded),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Sharing link for ${book.title}')),
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
                              'CLASS ${book.classNumber} • ${book.group.toUpperCase()}',
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

          // Action Toolbar (Read Now / Download Button, Stats)
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.surfaceContainerLowest,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('Pages', '${book.pagesCount}'),
                      _buildDivider(),
                      _buildStatItem('File Size', book.fileSize),
                      _buildDivider(),
                      _buildStatItem('Curriculum', book.curriculumYear),
                      _buildDivider(),
                      _buildStatItem(
                        'Status',
                        book.isDownloaded ? 'Offline' : 'Online',
                        color: book.isDownloaded ? AppColors.secondary : AppColors.outline,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Big Read CTA
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryContainer,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PdfReaderScreen(
                                  book: book,
                                  initialPage: book.lastReadPage > 1 ? book.lastReadPage : 1,
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

          // Chapter List
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
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: chapter.isCompleted
                                          ? AppColors.secondaryContainer
                                          : AppColors.surfaceContainer,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: chapter.isCompleted
                                          ? const Icon(Icons.check_rounded, size: 18, color: AppColors.onSecondaryContainer)
                                          : Text(
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
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceContainer,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        topic,
                                        style: const TextStyle(
                                          fontSize: 10,
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
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: color ?? AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.outline),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 24,
      color: AppColors.cardBorder,
    );
  }
}

