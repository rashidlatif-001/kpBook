import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/book_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _activeQuery = '';

  final List<String> _popularSuggestions = [
    'Physics',
    'Mathematics',
    'Chemistry',
    'Biology',
    'Computer Science',
    'Class 9',
    'Urdu Lazmi',
    'Islamiat',
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String val) {
    setState(() {
      _activeQuery = val;
    });
  }

  void _applySuggestion(String tag) {
    _searchCtrl.text = tag;
    _onSearchChanged(tag);
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final results = appState.searchBooks(_activeQuery);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: TextField(
              controller: _searchCtrl,
              autofocus: true,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search textbooks, subjects, classes...',
                hintStyle: const TextStyle(fontSize: 13, color: AppColors.outline),
                prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.outline),
                suffixIcon: _activeQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18, color: AppColors.outline),
                        onPressed: () {
                          _searchCtrl.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
      ),
      body: _buildBody(results),
    );
  }

  Widget _buildBody(List results) {
    if (_activeQuery.trim().isEmpty) {
      return _buildSuggestionsView();
    }

    if (results.isEmpty) {
      return _buildZeroResultsView();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        return BookCard(book: results[index], isHorizontal: true);
      },
    );
  }

  Widget _buildSuggestionsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'POPULAR SEARCHES & SUBJECTS',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _popularSuggestions.map((tag) {
              return InkWell(
                onTap: () => _applySuggestion(tag),
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.trending_up_rounded, size: 14, color: AppColors.primaryContainer),
                      const SizedBox(width: 6),
                      Text(
                        tag,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurface),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded, color: AppColors.primaryContainer, size: 22),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'You can search by subject name in English or Urdu, or by typing class number (e.g. "Class 9").',
                    style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZeroResultsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          children: [
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.errorContainer.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search_off_rounded, size: 48, color: AppColors.error),
            ),
            const SizedBox(height: 20),
            Text(
              'No results for "$_activeQuery"',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.onSurface),
            ),
            const SizedBox(height: 8),
            const Text(
              'We couldn’t find any official textbook matching that exact keyword. Please check your spelling or try broader terms.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, height: 1.4, color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            const Text(
              'Try one of these instead:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryContainer),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: ['Physics', 'Mathematics', 'Biology', 'Chemistry'].map((tag) {
                return ActionChip(
                  label: Text(tag),
                  backgroundColor: AppColors.surfaceContainerLowest,
                  side: const BorderSide(color: AppColors.cardBorder),
                  onPressed: () => _applySuggestion(tag),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
