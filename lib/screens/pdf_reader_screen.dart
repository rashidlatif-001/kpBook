import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/book_model.dart';
import '../models/chapter_model.dart';
import '../models/content_block_model.dart';
import '../providers/app_state.dart';
import '../services/supabase_service.dart';
import '../theme/app_colors.dart';

enum ReaderTheme { light, sepia, dark }

class PdfReaderScreen extends StatefulWidget {
  final Book book;
  final int initialPage;
  final bool isFromResume;

  const PdfReaderScreen({
    super.key,
    required this.book,
    this.initialPage = 1,
    this.isFromResume = false,
  });

  @override
  State<PdfReaderScreen> createState() => _PdfReaderScreenState();
}

class _PdfReaderScreenState extends State<PdfReaderScreen> {
  late int _currentPage;
  ReaderTheme _readerTheme = ReaderTheme.light;
  bool _showControls = true;
  final Map<int, List<ContentBlock>> _loadedChapterBlocks = {};
  bool _isLoadingBlocks = false;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _fetchBlocksForCurrentChapter();
    // Set initial theme according to app state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppState>(context, listen: false);
      if (appState.isDarkMode) {
        setState(() {
          _readerTheme = ReaderTheme.dark;
        });
      }
    });
  }

  void _fetchBlocksForCurrentChapter() async {
    final curCh = _currentChapter;
    if (curCh.contentBlocks.isNotEmpty) {
      _loadedChapterBlocks[curCh.number] = curCh.contentBlocks;
      if (mounted) setState(() {});
      return;
    }

    if (curCh.id.isNotEmpty && !_loadedChapterBlocks.containsKey(curCh.number)) {
      setState(() => _isLoadingBlocks = true);
      final blocks = await SupabaseService.fetchChapterContentBlocks(curCh.id);
      if (mounted) {
        setState(() {
          _loadedChapterBlocks[curCh.number] = blocks;
          _isLoadingBlocks = false;
        });
      }
    }
  }

  void _changePage(int newPage) {
    if (newPage >= 1 && newPage <= widget.book.pagesCount) {
      setState(() {
        _currentPage = newPage;
      });
      Provider.of<AppState>(context, listen: false).updateReadingProgress(widget.book, newPage);
      _fetchBlocksForCurrentChapter();
    }
  }

  Chapter get _currentChapter {
    for (final c in widget.book.chapters) {
      if (_currentPage >= c.pageStart && _currentPage <= c.pageEnd) {
        return c;
      }
    }
    return widget.book.chapters.isNotEmpty
        ? widget.book.chapters.first
        : Chapter(number: 1, title: widget.book.subject, pageStart: 1, pageEnd: widget.book.pagesCount);
  }

  int get _currentChapterIndex {
    for (int i = 0; i < widget.book.chapters.length; i++) {
      final c = widget.book.chapters[i];
      if (_currentPage >= c.pageStart && _currentPage <= c.pageEnd) {
        return i;
      }
    }
    return 0;
  }

  void _goToPreviousUnit() {
    final idx = _currentChapterIndex;
    if (idx > 0) {
      final prev = widget.book.chapters[idx - 1];
      _changePage(prev.pageStart);
    }
  }

  void _goToNextUnit() {
    final idx = _currentChapterIndex;
    if (idx < widget.book.chapters.length - 1) {
      final next = widget.book.chapters[idx + 1];
      _changePage(next.pageStart);
    }
  }

  Color get _canvasBg {
    switch (_readerTheme) {
      case ReaderTheme.light:
        return Colors.white;
      case ReaderTheme.sepia:
        return const Color(0xFFFBF0D9);
      case ReaderTheme.dark:
        return const Color(0xFF1E2621);
    }
  }

  Color get _canvasCardBg {
    switch (_readerTheme) {
      case ReaderTheme.light:
        return const Color(0xFFF4F6F5);
      case ReaderTheme.sepia:
        return const Color(0xFFF0E5CE);
      case ReaderTheme.dark:
        return const Color(0xFF26322B);
    }
  }

  Color get _canvasCardBgSubtle {
    switch (_readerTheme) {
      case ReaderTheme.light:
        return const Color(0xFFFAFBFA);
      case ReaderTheme.sepia:
        return const Color(0xFFF7EBD3);
      case ReaderTheme.dark:
        return const Color(0xFF2B3830);
    }
  }

  Color get _canvasBorder {
    switch (_readerTheme) {
      case ReaderTheme.light:
        return const Color(0xFFE0E5E2);
      case ReaderTheme.sepia:
        return const Color(0xFFDFCBB1);
      case ReaderTheme.dark:
        return const Color(0xFF38473E);
    }
  }

  Color get _textColor {
    switch (_readerTheme) {
      case ReaderTheme.light:
        return const Color(0xFF17231D);
      case ReaderTheme.sepia:
        return const Color(0xFF3E2723);
      case ReaderTheme.dark:
        return const Color(0xFFE8F5E9);
    }
  }

  Color get _textMuted {
    switch (_readerTheme) {
      case ReaderTheme.light:
        return const Color(0xFF5A6660);
      case ReaderTheme.sepia:
        return const Color(0xFF6D4C41);
      case ReaderTheme.dark:
        return const Color(0xFFA5D6A7);
    }
  }

  Color get _accentColor {
    switch (_readerTheme) {
      case ReaderTheme.light:
        return const Color(0xFF005129);
      case ReaderTheme.sepia:
        return const Color(0xFF5D4037);
      case ReaderTheme.dark:
        return const Color(0xFF4CAF50);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final curCh = _currentChapter;
    final curIdx = _currentChapterIndex;

    return Scaffold(
      backgroundColor: _readerTheme == ReaderTheme.dark
          ? const Color(0xFF121815)
          : (_readerTheme == ReaderTheme.sepia
              ? const Color(0xFFEAD8BA)
              : const Color(0xFFE8ECE9)),
      endDrawer: _buildTocDrawer(),
      body: SafeArea(
        child: Stack(
          children: [
            // Center Page Reader Viewport
            GestureDetector(
              onTap: () {
                setState(() {
                  _showControls = !_showControls;
                });
              },
              child: Center(
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 2.5,
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: _canvasBg,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _buildTextbookPageContent(curCh),
                  ),
                ),
              ),
            ),

            // Top Control Bar
            if (_showControls)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest.withValues(alpha: 0.95),
                    border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8),
                    ],
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.cardBorder),
                              ),
                              alignment: Alignment.center,
                              child: Icon(Icons.arrow_back_rounded, color: AppColors.onSurface, size: 19),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.book.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                            ),
                            Text(
                              'Unit ${curCh.number}: ${curCh.title} • Pg $_currentPage of ${widget.book.pagesCount}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      // Theme Switcher (Light / Sepia / Dark)
                      PopupMenuButton<ReaderTheme>(
                        icon: Icon(Icons.palette_outlined, color: AppColors.onSurface),
                        tooltip: 'Display Mode',
                        onSelected: (theme) {
                          setState(() {
                            _readerTheme = theme;
                          });
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: ReaderTheme.light, child: Text('☀️ Light Mode')),
                          const PopupMenuItem(value: ReaderTheme.sepia, child: Text('📖 Sepia Paper Mode')),
                          const PopupMenuItem(value: ReaderTheme.dark, child: Text('🌙 Night Study Mode')),
                        ],
                      ),
                      // Bookmark
                      IconButton(
                        icon: Icon(
                          widget.book.isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                          color: widget.book.isBookmarked
                              ? AppColors.lightOnTertiaryContainer
                              : AppColors.onSurface,
                        ),
                        tooltip: widget.book.isBookmarked ? 'Remove Bookmark' : 'Bookmark Book',
                        onPressed: () => appState.toggleBookmark(widget.book),
                      ),
                      // TOC Drawer
                      Builder(
                        builder: (ctx) => IconButton(
                          icon: Icon(Icons.format_list_bulleted_rounded, color: AppColors.onSurface),
                          tooltip: 'Table of Contents',
                          onPressed: () => Scaffold.of(ctx).openEndDrawer(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Bottom Navigation & Unit Switchers
            if (_showControls)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest.withValues(alpha: 0.96),
                    border: Border(top: BorderSide(color: AppColors.cardBorder)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Unit quick navigation bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton.icon(
                            onPressed: curIdx > 0 ? _goToPreviousUnit : null,
                            icon: const Icon(Icons.arrow_back_ios_rounded, size: 12),
                            label: const Text('Prev Unit', style: TextStyle(fontSize: 12)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Unit ${curCh.number} of ${widget.book.chapters.length}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryContainer,
                              ),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: curIdx < widget.book.chapters.length - 1 ? _goToNextUnit : null,
                            label: const Text('Next Unit', style: TextStyle(fontSize: 12)),
                            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 12),
                          ),
                        ],
                      ),
                      // Page slider
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left_rounded),
                            onPressed: _currentPage > 1 ? () => _changePage(_currentPage - 1) : null,
                          ),
                          Expanded(
                            child: Slider(
                              value: _currentPage.toDouble(),
                              min: 1,
                              max: widget.book.pagesCount.toDouble(),
                              activeColor: AppColors.secondary,
                              inactiveColor: AppColors.surfaceContainer,
                              onChanged: (val) {
                                _changePage(val.toInt());
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right_rounded),
                            onPressed: _currentPage < widget.book.pagesCount ? () => _changePage(_currentPage + 1) : null,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Unit ${curCh.number}: ${curCh.title}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primaryContainer),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '$_currentPage / ${widget.book.pagesCount}',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                            ),
                          ),
                          Row(
                            children: [
                              Icon(Icons.verified_rounded, size: 12, color: AppColors.secondary),
                              const SizedBox(width: 4),
                              Text(
                                'Official PDF',
                                style: TextStyle(fontSize: 11, color: AppColors.outline.withValues(alpha: 0.9)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextbookPageContent(Chapter curCh) {
    final int pageInChapter = _currentPage - curCh.pageStart + 1;
    final int totalPagesInChapter = curCh.pageEnd - curCh.pageStart + 1;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'KPK TEXTBOOK BOARD • PESHAWAR',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: _textMuted,
                ),
              ),
              Text(
                'PAGE $_currentPage OF ${widget.book.pagesCount}',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: _textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Divider(color: _canvasBorder),
          const SizedBox(height: 12),

          // Chapter Header Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _canvasCardBgSubtle,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _canvasBorder),
            ),
            child: Row(
              children: [
                Icon(Icons.menu_book_rounded, size: 16, color: _accentColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Unit ${curCh.number}: ${curCh.title}',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _textColor),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _canvasCardBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Unit Page $pageInChapter / $totalPagesInChapter',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _textMuted),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Main Heading
          Text(
            '${curCh.number}.$pageInChapter ${curCh.title}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _textColor, letterSpacing: -0.2),
          ),
          if (curCh.titleUrdu.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              curCh.titleUrdu,
              textDirection: TextDirection.rtl,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _accentColor),
            ),
          ],

          const SizedBox(height: 14),

          // Core Textbook Learning Objectives (SLOs)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _canvasCardBg,
              borderRadius: BorderRadius.circular(8),
              border: Border(left: BorderSide(color: _accentColor, width: 4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STUDENT LEARNING OBJECTIVES (SLO)',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: _accentColor),
                ),
                const SizedBox(height: 4),
                Text(
                  'By the end of this section, students will understand the fundamental core concepts of ${curCh.title}, analyze practical board problem-solving methods, and apply theoretical principles in KPK examinations.',
                  style: TextStyle(fontSize: 13, height: 1.5, fontWeight: FontWeight.w600, color: _textColor),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Topics Coverage
          if (curCh.keyTopics.isNotEmpty) ...[
            Text(
              'Key Topics in Unit ${curCh.number}:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _textColor),
            ),
            const SizedBox(height: 8),
            ...curCh.keyTopics.map((topic) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle_rounded, size: 16, color: _accentColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        topic,
                        style: TextStyle(fontSize: 13, height: 1.4, color: _textColor),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 12),
          ],

          // Dynamic Content Blocks Rendering (or Fallback if no blocks extracted yet)
          if (_isLoadingBlocks)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 30),
              alignment: Alignment.center,
              child: Column(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2, color: _accentColor),
                  ),
                  const SizedBox(height: 8),
                  Text('Loading verified curriculum blocks...', style: TextStyle(fontSize: 12, color: _textMuted)),
                ],
              ),
            )
          else if (_loadedChapterBlocks.containsKey(curCh.number) && _loadedChapterBlocks[curCh.number]!.isNotEmpty) ...[
            ..._buildDynamicContentBlocks(_loadedChapterBlocks[curCh.number]!),
          ] else ...[
            // Textbook Reading Passage Fallback
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _canvasCardBgSubtle,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _canvasBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Section ${curCh.number}.$pageInChapter: Conceptual Overview',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _accentColor),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'This official digital textbook edition is published by Khyber Pakhtunkhwa Textbook Board for Class ${widget.book.classNumber}. Every unit is designed to follow modern curriculum benchmarks with solved exercises, model board questions, and chapter-wise revisions.',
                    style: TextStyle(fontSize: 13, height: 1.5, color: _textColor.withValues(alpha: 0.95)),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Unit Navigation Shortcut inside reading body
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentChapterIndex > 0)
                OutlinedButton.icon(
                  onPressed: _goToPreviousUnit,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _accentColor,
                    side: BorderSide(color: _canvasBorder),
                  ),
                  icon: const Icon(Icons.arrow_back_rounded, size: 16),
                  label: Text('Unit $_currentChapterIndex'),
                )
              else
                const SizedBox.shrink(),
              if (_currentChapterIndex < widget.book.chapters.length - 1)
                FilledButton.tonalIcon(
                  onPressed: _goToNextUnit,
                  style: FilledButton.styleFrom(
                    backgroundColor: _canvasCardBg,
                    foregroundColor: _accentColor,
                  ),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                  label: Text('Next: Unit ${_currentChapterIndex + 2}'),
                )
              else
                const SizedBox.shrink(),
            ],
          ),

          const SizedBox(height: 50),
        ],
      ),
    );
  }

  List<Widget> _buildDynamicContentBlocks(List<ContentBlock> allBlocks) {
    // Filter by current page if matching blocks exist, otherwise show all chapter blocks
    final pageBlocks = allBlocks.where((b) => b.originalPdfPage == _currentPage).toList();
    final blocksToShow = pageBlocks.isNotEmpty ? pageBlocks : allBlocks;

    return blocksToShow.map((b) {
      if (b.isHeading) {
        return Container(
          margin: const EdgeInsets.only(top: 16, bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _canvasCardBgSubtle,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _canvasBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  b.content,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _textColor),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _canvasCardBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('Pg ${b.originalPdfPage}', style: TextStyle(fontSize: 9, color: _textMuted)),
              ),
            ],
          ),
        );
      } else if (b.isImportantNote) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _canvasCardBg,
            borderRadius: BorderRadius.circular(8),
            border: Border(left: BorderSide(color: _accentColor, width: 4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'STUDENT LEARNING OBJECTIVES (SLO)',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: _accentColor),
                  ),
                  Text('Pg ${b.originalPdfPage}', style: TextStyle(fontSize: 9, color: _textMuted)),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                b.content,
                style: TextStyle(fontSize: 13, height: 1.5, fontWeight: FontWeight.w600, color: _textColor),
              ),
            ],
          ),
        );
      } else if (b.isDefinition) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _readerTheme == ReaderTheme.dark ? const Color(0xFF2E2410) : const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(8),
            border: const Border(left: BorderSide(color: Color(0xFFD97706), width: 4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'DEFINITION',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: Color(0xFFD97706)),
                  ),
                  Text('Pg ${b.originalPdfPage}', style: TextStyle(fontSize: 9, color: _textMuted)),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                b.content,
                style: TextStyle(fontSize: 13, height: 1.5, fontStyle: FontStyle.italic, color: _textColor),
              ),
            ],
          ),
        );
      } else if (b.isFormula) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _canvasCardBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _accentColor.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('MATHEMATICAL FORMULA', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: _accentColor)),
                  Text('Pg ${b.originalPdfPage}', style: TextStyle(fontSize: 9, color: _textMuted)),
                ],
              ),
              const SizedBox(height: 6),
              Center(
                child: Math.tex(
                  b.content,
                  textStyle: TextStyle(fontSize: 17, color: _textColor),
                  onErrorFallback: (err) => Text(
                    b.content,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'monospace', color: _textColor),
                  ),
                ),
              ),
            ],
          ),
        );
      } else if (b.isTable) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _canvasCardBgSubtle,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _canvasBorder),
          ),
          child: MarkdownBody(
            data: b.content,
            styleSheet: MarkdownStyleSheet(
              tableBody: TextStyle(fontSize: 12, color: _textColor),
              tableHead: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _textColor),
            ),
          ),
        );
      } else {
        // Standard Paragraph
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(
            b.content,
            style: TextStyle(fontSize: 13.5, height: 1.55, color: _textColor),
          ),
        );
      }
    }).toList();
  }

  Widget _buildTocDrawer() {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.surfaceContainerLow,
              child: Row(
                children: [
                  Icon(Icons.toc_rounded, color: AppColors.primaryContainer),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Table of Contents / Units',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                        ),
                        Text(
                          widget.book.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: widget.book.chapters.length,
                separatorBuilder: (context, index) => Divider(height: 1, color: AppColors.cardBorder),
                itemBuilder: (context, index) {
                  final ch = widget.book.chapters[index];
                  final isCurrent = _currentPage >= ch.pageStart && _currentPage <= ch.pageEnd;

                  return ListTile(
                    dense: true,
                    selected: isCurrent,
                    selectedTileColor: AppColors.secondaryContainer.withValues(alpha: 0.4),
                    leading: CircleAvatar(
                      radius: 12,
                      backgroundColor: isCurrent ? AppColors.secondary : AppColors.surfaceContainer,
                      child: Text(
                        '${ch.number}',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isCurrent ? Colors.white : AppColors.onSurface),
                      ),
                    ),
                    title: Text(
                      'Unit ${ch.number}: ${ch.title}',
                      style: TextStyle(fontSize: 12, fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500, color: AppColors.onSurface),
                    ),
                    subtitle: ch.titleUrdu.isNotEmpty
                        ? Text(
                            ch.titleUrdu,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                          )
                        : null,
                    trailing: Text(
                      'Pg ${ch.pageStart}',
                      style: TextStyle(fontSize: 11, color: AppColors.outline),
                    ),
                    onTap: () {
                      _changePage(ch.pageStart);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
