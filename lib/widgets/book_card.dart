import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book_model.dart';
import '../providers/app_state.dart';
import '../theme/app_colors.dart';
import '../screens/content_selection_screen.dart';
import '../screens/pdf_reader_screen.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final bool isHorizontal;

  const BookCard({
    super.key,
    required this.book,
    this.isHorizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    if (isHorizontal) {
      return _buildHorizontalCard(context, appState);
    }
    return _buildVerticalCard(context, appState);
  }

  Widget _buildVerticalCard(BuildContext context, AppState appState) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF17231D).withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ContentSelectionScreen(book: book)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Book Cover
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [book.coverGradientStart, book.coverGradientEnd],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: book.coverGradientStart.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(book.icon, size: 44, color: Colors.white),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                book.subject.toUpperCase(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'CLASS ${book.classNumber}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Top badges: Curriculum & Bookmark
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            book.curriculumYear,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: IconButton(
                          iconSize: 20,
                          icon: Icon(
                            book.isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                            color: book.isBookmarked ? AppColors.onTertiaryContainer : Colors.white,
                          ),
                          onPressed: () => appState.toggleBookmark(book),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Subject Tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    book.group.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                      color: AppColors.primaryContainer,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                // Title
                Text(
                  book.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                if (book.titleUrdu.isNotEmpty)
                  Text(
                    book.titleUrdu,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                const SizedBox(height: 8),
                // Meta info & Action
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          book.isDownloaded ? Icons.check_circle_rounded : Icons.cloud_outlined,
                          size: 14,
                          color: book.isDownloaded ? AppColors.secondary : AppColors.outline,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          book.fileSize,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    _buildActionButton(context, appState),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalCard(BuildContext context, AppState appState) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ContentSelectionScreen(book: book)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Cover
                Container(
                  width: 72,
                  height: 96,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [book.coverGradientStart, book.coverGradientEnd],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(book.icon, size: 28, color: Colors.white),
                      const SizedBox(height: 4),
                      Text(
                        'CLASS ${book.classNumber}',
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              book.group.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryContainer,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            book.fileSize,
                            style: const TextStyle(fontSize: 11, color: AppColors.outline),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        book.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                      ),
                      if (book.titleUrdu.isNotEmpty)
                        Text(
                          book.titleUrdu,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            book.isDownloaded ? Icons.check_circle_rounded : Icons.cloud_outlined,
                            size: 14,
                            color: book.isDownloaded ? AppColors.secondary : AppColors.outline,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            book.isDownloaded ? 'Saved Offline' : 'Ready to Download',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: book.isDownloaded ? AppColors.secondary : AppColors.outline,
                            ),
                          ),
                          const Spacer(),
                          _buildActionButton(context, appState),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, AppState appState) {
    if (book.isDownloading) {
      return SizedBox(
        width: 32,
        height: 32,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: book.downloadProgress,
              strokeWidth: 3,
              color: AppColors.secondary,
              backgroundColor: AppColors.surfaceContainer,
            ),
            Text(
              '${(book.downloadProgress * 100).toInt()}%',
              style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.secondary),
            ),
          ],
        ),
      );
    }

    if (book.isDownloaded) {
      return InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PdfReaderScreen(book: book)),
          );
        },
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_stories_rounded, size: 14, color: Colors.white),
              SizedBox(width: 4),
              Text(
                'Read',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: () => appState.startDownload(book),
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.secondaryContainer,
          borderRadius: BorderRadius.circular(999),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.download_rounded, size: 14, color: AppColors.onSecondaryContainer),
            SizedBox(width: 3),
            Text(
              'Download',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.onSecondaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
