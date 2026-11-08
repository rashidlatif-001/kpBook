import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book_model.dart';
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
  int? _selectedClassFilter; // null = All Classes
  String _selectedTypeFilter = 'All'; // 'All', 'Books', 'Guides'

  final List<String> _popularSuggestions = [
    'Physics',
    'Mathematics',
    'Chemistry',
    'Biology',
    'Computer Science',
    'English',
    'Urdu',
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
    final results = appState.searchBooksWithFilters(
      query: _activeQuery,
      classFilter: _selectedClassFilter,
      typeFilter: _selectedTypeFilter,
    );

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: AppColors.surface,
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
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.arrow_back_rounded, color: AppColors.onSurface, size: 19),
              ),
            ),
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Container(
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: TextField(
              controller: _searchCtrl,
              autofocus: false,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search textbooks, guides, subjects...',
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
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter Controls: Class Filter and Type Filter (Books or Guides)
          _buildFilterBar(),

          const Divider(height: 1, color: AppColors.cardBorder),

          // Search results
          Expanded(
            child: _buildBody(results),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      color: AppColors.surfaceContainerLowest,
      child: Column(
        children: [
          // 1. Class Filter Row
          Row(
            children: [
              const Icon(Icons.school_outlined, size: 16, color: AppColors.primaryContainer),
              const SizedBox(width: 6),
              const Text(
                'Class:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.onSurface),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildClassChip(null, 'All Classes'),
                      for (int c = 1; c <= 12; c++)
                        _buildClassChip(c, 'Class $c'),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // 2. Type Filter Row (Books or Guides)
          Row(
            children: [
              const Icon(Icons.category_outlined, size: 16, color: AppColors.secondary),
              const SizedBox(width: 6),
              const Text(
                'Type:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.onSurface),
              ),
              const SizedBox(width: 8),
              _buildTypeChip('All', 'All'),
              const SizedBox(width: 6),
              _buildTypeChip('Books', 'Books Only'),
              const SizedBox(width: 6),
              _buildTypeChip('Guides', 'Guides Only'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClassChip(int? classNum, String label) {
    final isSelected = _selectedClassFilter == classNum;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedClassFilter = selected ? classNum : null;
          });
        },
        selectedColor: AppColors.primaryContainer,
        backgroundColor: AppColors.surfaceContainerLow,
        labelStyle: TextStyle(
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? Colors.white : AppColors.onSurface,
        ),
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      ),
    );
  }

  Widget _buildTypeChip(String typeKey, String label) {
    final isSelected = _selectedTypeFilter.toLowerCase() == typeKey.toLowerCase();
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedTypeFilter = typeKey;
          });
        }
      },
      selectedColor: AppColors.secondary,
      backgroundColor: AppColors.surfaceContainerLow,
      labelStyle: TextStyle(
        fontSize: 11,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? Colors.white : AppColors.onSurface,
      ),
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
    );
  }

  Widget _buildBody(List<Book> results) {
    if (_activeQuery.trim().isEmpty && _selectedClassFilter == null && _selectedTypeFilter == 'All') {
      return _buildSuggestionsView();
    }

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_rounded, size: 56, color: AppColors.outlineVariant),
            const SizedBox(height: 12),
            Text(
              'No textbooks or guides match your filters.',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.onSurface),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try selecting another class or clearing your search term.',
              style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      );
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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'POPULAR SEARCHES',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _popularSuggestions.map((tag) {
            return ActionChip(
              avatar: const Icon(Icons.trending_up_rounded, size: 14, color: AppColors.primaryContainer),
              label: Text(tag, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              backgroundColor: AppColors.surfaceContainerLowest,
              side: const BorderSide(color: AppColors.cardBorder),
              onPressed: () => _applySuggestion(tag),
            );
          }).toList(),
        ),
      ],
    );
  }
}
