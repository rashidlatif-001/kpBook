import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/book_card.dart';
import '../widgets/custom_app_bar.dart';

class ClassScreen extends StatefulWidget {
  final int classNumber;

  const ClassScreen({
    super.key,
    required this.classNumber,
  });

  @override
  State<ClassScreen> createState() => _ClassScreenState();
}

class _ClassScreenState extends State<ClassScreen> {
  String _selectedFilter = 'All'; // 'All', 'Books', 'Guides'
  final TextEditingController _searchCtrl = TextEditingController();
  String _localQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final allClassBooks = appState.getBooksForClass(
      widget.classNumber,
      typeFilter: _selectedFilter,
    );

    final filteredBooks = _localQuery.trim().isEmpty
        ? allClassBooks
        : allClassBooks.where((b) {
            final q = _localQuery.trim().toLowerCase();
            return b.title.toLowerCase().contains(q) ||
                b.subject.toLowerCase().contains(q);
          }).toList();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: CustomAppBar(
        tag: 'Class ${widget.classNumber}',
        title: 'Class ${widget.classNumber} Books',
        subtitle: 'KPK Textbook Board Official Collection',
        showBackButton: true,
        onBackPressed: () => Navigator.pop(context),
      ),
      body: Column(
        children: [
          // Filter Chips & Search Bar Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            color: AppColors.surfaceContainerLow,
            child: Column(
              children: [
                // Search Input within this Class
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (val) => setState(() => _localQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Search Class ${widget.classNumber} subjects...',
                      hintStyle: TextStyle(fontSize: 13, color: AppColors.outline),
                      prefixIcon: Icon(Icons.search_rounded, size: 20, color: AppColors.outline),
                      suffixIcon: _localQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear_rounded, size: 18, color: AppColors.outline),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => _localQuery = '');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Category Filter Segmented Tabs
                Row(
                  children: [
                    _buildFilterChip('All', 'All (${appState.getBooksForClass(widget.classNumber).length})'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Books', 'Textbooks'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Guides', 'Study Guides'),
                  ],
                ),
              ],
            ),
          ),

          Divider(height: 1, color: AppColors.cardBorder),

          // Book Grid for this Class
          Expanded(
            child: filteredBooks.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.menu_book_rounded,
                            size: 56,
                            color: AppColors.outlineVariant,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'No books found',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _localQuery.isNotEmpty
                                ? 'No subjects in Class ${widget.classNumber} match "$_localQuery".'
                                : 'No items available in this category for Class ${widget.classNumber}.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final int crossAxisCount = constraints.maxWidth > 900
                          ? 4
                          : (constraints.maxWidth > 600 ? 3 : 2);
                      final double childAspectRatio = constraints.maxWidth > 600 ? 0.72 : 0.68;

                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: childAspectRatio,
                        ),
                        itemCount: filteredBooks.length,
                        itemBuilder: (context, index) {
                          return BookCard(book: filteredBooks[index]);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _selectedFilter == key;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedFilter = key;
          });
        },
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryContainer : AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.primaryContainer : AppColors.cardBorder,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
