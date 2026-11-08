import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/book_card.dart';
import 'search_screen.dart';

class LibraryScreen extends StatelessWidget {
  final Function(int)? onSwitchTab;

  const LibraryScreen({super.key, this.onSwitchTab});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final books = appState.booksForSelectedClass;
    final className = appState.hasSelectedClass ? 'Class ${appState.selectedClass}' : 'All Classes';

    return Scaffold(
      appBar: CustomAppBar(
        tag: className,
        title: appState.hasSelectedClass ? 'Class ${appState.selectedClass} Library' : 'Textbook Library',
        subtitle: 'Official KPK Textbook Board Collection',
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
                      appState.hasSelectedClass
                          ? 'Class ${appState.selectedClass} Curriculum'
                          : 'Select a Class to View Content',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Text(
                      appState.hasSelectedClass
                          ? '${books.length} ${appState.selectedLibraryTab} Available'
                          : 'Classes 1 through 12',
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
                          appState.hasSelectedClass ? 'Class ${appState.selectedClass}' : 'Select Class',
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

          // Content Type Tabs: Only 'Books' and 'Guides'
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.surface,
            child: Row(
              children: [
                Expanded(
                  child: _buildTypeSegment(
                    context: context,
                    appState: appState,
                    key: 'Books',
                    label: 'Books',
                    icon: Icons.menu_book_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTypeSegment(
                    context: context,
                    appState: appState,
                    key: 'Guides',
                    label: 'Guides',
                    icon: Icons.auto_stories_rounded,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.cardBorder),

          // Content Grid
          Expanded(
            child: !appState.hasSelectedClass
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.school_outlined, size: 48, color: AppColors.primaryContainer),
                          const SizedBox(height: 12),
                          const Text(
                            'Please select a class',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Choose a class from the top selector or home screen to view its official textbooks and guides.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                          ),
                          const SizedBox(height: 16),
                          FilledButton.tonal(
                            onPressed: () {
                              if (onSwitchTab != null) onSwitchTab!(0);
                            },
                            child: const Text('Go to Class Selection'),
                          ),
                        ],
                      ),
                    ),
                  )
                : (books.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.menu_book_rounded, size: 48, color: AppColors.outlineVariant),
                            const SizedBox(height: 12),
                            Text(
                              'No ${appState.selectedLibraryTab.toLowerCase()} found for Class ${appState.selectedClass}.',
                              style: const TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
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
                      )),
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

  Widget _buildTypeSegment({
    required BuildContext context,
    required AppState appState,
    required String key,
    required String label,
    required IconData icon,
  }) {
    final isSelected = appState.selectedLibraryTab.toLowerCase() == key.toLowerCase();

    return InkWell(
      onTap: () => appState.setSelectedLibraryTab(key),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryContainer : AppColors.cardBorder,
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
