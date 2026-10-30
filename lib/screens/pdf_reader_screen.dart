import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book_model.dart';
import '../providers/app_state.dart';
import '../theme/app_colors.dart';

enum ReaderTheme { light, sepia, dark }

class PdfReaderScreen extends StatefulWidget {
  final Book book;
  final int initialPage;

  const PdfReaderScreen({
    super.key,
    required this.book,
    this.initialPage = 1,
  });

  @override
  State<PdfReaderScreen> createState() => _PdfReaderScreenState();
}

class _PdfReaderScreenState extends State<PdfReaderScreen> {
  late int _currentPage;
  ReaderTheme _readerTheme = ReaderTheme.light;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
  }

  void _changePage(int newPage) {
    if (newPage >= 1 && newPage <= widget.book.pagesCount) {
      setState(() {
        _currentPage = newPage;
      });
      Provider.of<AppState>(context, listen: false).updateLastReadPage(widget.book, newPage);
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

  Color get _textColor {
    switch (_readerTheme) {
      case ReaderTheme.light:
        return const Color(0xFF17231D);
      case ReaderTheme.sepia:
        return const Color(0xFF3F301D);
      case ReaderTheme.dark:
        return const Color(0xFFE8F5E9);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      backgroundColor: _readerTheme == ReaderTheme.dark ? const Color(0xFF121815) : const Color(0xFFE8ECE9),
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
                    child: _buildTextbookPageContent(),
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
                    border: const Border(bottom: BorderSide(color: AppColors.cardBorder)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8),
                    ],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded, color: AppColors.onSurface),
                        onPressed: () => Navigator.pop(context),
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
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                            ),
                            Text(
                              'Page $_currentPage of ${widget.book.pagesCount} • KPK Textbook Board',
                              style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      // Theme Switcher (Light / Sepia / Dark)
                      PopupMenuButton<ReaderTheme>(
                        icon: const Icon(Icons.palette_outlined, color: AppColors.onSurface),
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
                          color: widget.book.isBookmarked ? AppColors.onTertiaryContainer : AppColors.onSurface,
                        ),
                        onPressed: () => appState.toggleBookmark(widget.book),
                      ),
                      // TOC Drawer
                      Builder(
                        builder: (ctx) => IconButton(
                          icon: const Icon(Icons.format_list_bulleted_rounded, color: AppColors.onSurface),
                          tooltip: 'Table of Contents',
                          onPressed: () => Scaffold.of(ctx).openEndDrawer(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Bottom Navigation & Page Slider
            if (_showControls)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest.withValues(alpha: 0.96),
                    border: const Border(top: BorderSide(color: AppColors.cardBorder)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                            'Unit ${_getCurrentChapterNumber()}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primaryContainer),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '$_currentPage / ${widget.book.pagesCount}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.verified_rounded, size: 12, color: AppColors.secondary),
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

  int _getCurrentChapterNumber() {
    for (final c in widget.book.chapters) {
      if (_currentPage >= c.pageStart && _currentPage <= c.pageEnd) {
        return c.number;
      }
    }
    return 1;
  }

  Widget _buildTextbookPageContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'KPK TEXTBOOK BOARD, PESHAWAR',
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: _textColor.withValues(alpha: 0.6)),
              ),
              Text(
                'PAGE $_currentPage',
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: _textColor.withValues(alpha: 0.6)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Divider(color: _textColor.withValues(alpha: 0.15)),
          const SizedBox(height: 12),

          // Chapter Header Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.primaryContainer.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.menu_book_rounded, size: 16, color: AppColors.primaryContainer),
                const SizedBox(width: 8),
                Text(
                  'Unit 3: Dynamics (Newton’s Laws of Motion)',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _textColor),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Main Heading
          Text(
            '3.2 Newton’s Second Law of Motion',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _textColor, letterSpacing: -0.2),
          ),
          const SizedBox(height: 4),
          Text(
            'نیوٹن کا قانون حرکت دوم',
            textDirection: TextDirection.rtl,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primaryContainer.withValues(alpha: 0.9)),
          ),

          const SizedBox(height: 12),

          // Formal Definition Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(8),
              border: const Border(left: BorderSide(color: AppColors.secondary, width: 4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'LAW STATEMENT',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: AppColors.secondary),
                ),
                const SizedBox(height: 4),
                Text(
                  'When a net external force acts on a body, it produces an acceleration in the body in the direction of the force. The magnitude of this acceleration is directly proportional to the applied force and inversely proportional to the mass of the body.',
                  style: TextStyle(fontSize: 13, height: 1.5, fontWeight: FontWeight.w600, color: _textColor),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Mathematical Derivation
          Text(
            'Mathematical Formulation:',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _textColor),
          ),
          const SizedBox(height: 6),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Text(
                'F = m × a',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1.2, color: AppColors.primaryContainer),
              ),
            ),
          ),

          const SizedBox(height: 14),

          Text(
            'Where:\n• F is the net force measured in Newtons (N)\n• m is the mass of the object measured in kilograms (kg)\n• a is the acceleration produced measured in m/s²',
            style: TextStyle(fontSize: 12, height: 1.6, color: _textColor.withValues(alpha: 0.9)),
          ),

          const SizedBox(height: 16),

          // Real World Example
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb_outline_rounded, size: 20, color: AppColors.tertiary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Key Takeaway for Exam:',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '1 Newton is that force which produces an acceleration of 1 m/s² in a body of mass 1 kg. (1 N = 1 kg·m/s²). Often asked as a short question in KPK Board examinations.',
                        style: TextStyle(fontSize: 11, height: 1.4, color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildTocDrawer() {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.surfaceContainerLow,
              child: Row(
                children: [
                  const Icon(Icons.toc_rounded, color: AppColors.primaryContainer),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Table of Contents',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                        ),
                        Text(
                          widget.book.title,
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
            Expanded(
              child: ListView.separated(
                itemCount: widget.book.chapters.length,
                separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.cardBorder),
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
                      style: TextStyle(fontSize: 12, fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500),
                    ),
                    trailing: Text(
                      'Pg ${ch.pageStart}',
                      style: const TextStyle(fontSize: 11, color: AppColors.outline),
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
