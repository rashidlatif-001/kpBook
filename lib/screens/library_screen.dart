import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/book_card.dart';
import 'search_screen.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final books = appState.booksForSelectedClass;

    return Scaffold(
      appBar: CustomAppBar(
        tag: 'Class ${appState.selectedClass}',
        title: 'Class ${appState.selectedClass} Library',
        subtitle: 'Official KPK Textbook Board Collection',
      ),
      body: Column(
        children: [
          // Header banner & Class switcher dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.surfaceContainerLow,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Class ${appState.selectedClass} Curriculum',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Text(
                      '${books.length} Textbooks Available',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                // Class Selector Chip
                PopupMenuButton<int>(
                  initialValue: appState.selectedClass,
                  onSelected: (val) => appState.setSelectedClass(val),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.cardBorder, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.school_rounded, size: 16, color: AppColors.primaryContainer),
                        const SizedBox(width: 6),
                        Text(
                          'Class ${appState.selectedClass}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryContainer,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_drop_down_rounded, size: 20, color: AppColors.outline),
                      ],
                    ),
                  ),
                  itemBuilder: (context) {
                    return List.generate(12, (index) {
                      final c = index + 1;
                      return PopupMenuItem<int>(
                        value: c,
                        child: Text(
                          'Class $c',
                          style: TextStyle(
                            fontWeight: c == appState.selectedClass ? FontWeight.w800 : FontWeight.normal,
                            color: c == appState.selectedClass ? AppColors.primary : AppColors.onSurface,
                          ),
                        ),
                      );
                    });
                  },
                ),
              ],
            ),
          ),

          // Subject Group Filter Tabs (All, Science, Compulsory, Arts)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.surface,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTabChip(context, appState, 'All', 'All Subjects'),
                  const SizedBox(width: 8),
                  _buildTabChip(context, appState, 'Science', 'Science Group'),
                  const SizedBox(width: 8),
                  _buildTabChip(context, appState, 'Compulsory', 'Compulsory'),
                  const SizedBox(width: 8),
                  _buildTabChip(context, appState, 'Arts', 'Arts / Humanities'),
                ],
              ),
            ),
          ),

          const Divider(height: 1, color: AppColors.cardBorder),

          // Books Grid
          Expanded(
            child: books.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.menu_book_rounded, size: 48, color: AppColors.outlineVariant),
                        const SizedBox(height: 12),
                        Text(
                          'No books found in ${appState.selectedLibraryTab} group',
                          style: const TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => appState.setSelectedLibraryTab('All'),
                          child: const Text('Show All Subjects'),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.64,
                    ),
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      return BookCard(book: books[index]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        mini: true,
        backgroundColor: AppColors.primaryContainer,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SearchScreen()),
          );
        },
        child: const Icon(Icons.search_rounded),
      ),
    );
  }

  Widget _buildTabChip(BuildContext context, AppState appState, String tabKey, String label) {
    final isSelected = appState.selectedLibraryTab.toLowerCase() == tabKey.toLowerCase();

    return InkWell(
      onTap: () => appState.setSelectedLibraryTab(tabKey),
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfaceContainerLow : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? AppColors.primaryContainer : AppColors.cardBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.primaryContainer : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
