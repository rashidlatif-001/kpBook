import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/offline_sync_banner.dart';
import '../widgets/book_card.dart';
import 'search_screen.dart';
import 'pdf_reader_screen.dart';

class HomeScreen extends StatelessWidget {
  final Function(int)? onSwitchTab;

  const HomeScreen({super.key, this.onSwitchTab});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final popularBooks = appState.booksForSelectedClass;

    return Scaffold(
      appBar: const CustomAppBar(tag: 'Home'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const OfflineSyncBanner(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting & Student Name
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Assalam-o-Alaikum! 👋',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                                color: AppColors.onSurface,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Ready to learn today? What would you like to study?',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.secondaryContainer.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.auto_stories_rounded,
                          color: AppColors.onSecondaryContainer,
                          size: 22,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Search Bar Trigger
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SearchScreen()),
                      );
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.cardBorder, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF17231D).withValues(alpha: 0.03),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.search_rounded, color: AppColors.outline, size: 22),
                          SizedBox(width: 10),
                          Text(
                            'Search classes, books, subjects, or notes...',
                            style: TextStyle(
                              color: AppColors.outline,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Featured Exam Preparation Banner
                  _buildExamBanner(context, appState),

                  const SizedBox(height: 20),

                  // Quick Study Shortcuts
                  _buildQuickJumpSection(context, appState),

                  const SizedBox(height: 24),

                  // Class Selection (1 to 12)
                  _buildClassSelectionSection(context, appState),

                  const SizedBox(height: 24),

                  // Featured Class 9 Books
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Class ${appState.selectedClass} Official Textbooks',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          if (onSwitchTab != null) {
                            onSwitchTab!(1); // Go to library
                          }
                        },
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'View All',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryContainer,
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.primaryContainer),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Books Grid for Class
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.68,
                    ),
                    itemCount: popularBooks.length > 4 ? 4 : popularBooks.length,
                    itemBuilder: (context, index) {
                      return BookCard(book: popularBooks[index]);
                    },
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExamBanner(BuildContext context, AppState appState) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF086B3A),
            Color(0xFF005129),
            Color(0xFF00381B),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF005129).withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer,
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_rounded, size: 13, color: AppColors.onSecondaryContainer),
                SizedBox(width: 4),
                Text(
                  'Curriculum 2024–25',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSecondaryContainer,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Mid-term Exams Preparation Guide',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Complete syllabus & model papers for Class 9 & 10 now fully available offline with past paper solutions.',
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              color: AppColors.onPrimaryContainer.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  minimumSize: const Size(0, 36),
                ),
                onPressed: () {
                  if (onSwitchTab != null) onSwitchTab!(1);
                },
                icon: const Icon(Icons.arrow_forward_rounded, size: 15),
                label: const Text('Explore Guides', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              ),
              const Row(
                children: [
                  Icon(Icons.cloud_done_rounded, size: 14, color: AppColors.onPrimaryContainer),
                  SizedBox(width: 4),
                  Text(
                    'Free Offline Sync',
                    style: TextStyle(fontSize: 11, color: AppColors.onPrimaryContainer, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickJumpSection(BuildContext context, AppState appState) {
    final recentBook = appState.recentReads.isNotEmpty ? appState.recentReads.first : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'QUICK JUMP',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            Text(
              'Active Session',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // Resume reading card
              if (recentBook != null)
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => PdfReaderScreen(book: recentBook)),
                    );
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.cardBorder, width: 1),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primaryFixed,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.bolt_rounded, color: AppColors.onPrimaryFixed, size: 22),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Resume',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '• Pg ${recentBook.lastReadPage}',
                                  style: const TextStyle(fontSize: 11, color: AppColors.outline),
                                ),
                              ],
                            ),
                            Text(
                              recentBook.subject,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurface),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

              // Offline Shelf Shortcut
              InkWell(
                onTap: () {
                  if (onSwitchTab != null) onSwitchTab!(2);
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.cardBorder, width: 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.secondaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.download_done_rounded, color: AppColors.onSecondaryContainer, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Offline Shelf',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.secondary),
                          ),
                          Text(
                            '${appState.downloadedBooks.length} books saved',
                            style: const TextStyle(fontSize: 11, color: AppColors.outline),
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
      ],
    );
  }

  Widget _buildClassSelectionSection(BuildContext context, AppState appState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Select Class (1 to 12)',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            Text(
              'KPK Board',
              style: TextStyle(fontSize: 12, color: AppColors.outlineVariant),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Grid of classes
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.15,
          ),
          itemCount: 12,
          itemBuilder: (context, index) {
            final classNum = index + 1;
            final isSelected = appState.selectedClass == classNum;

            return InkWell(
              onTap: () {
                appState.setSelectedClass(classNum);
                if (onSwitchTab != null) {
                  onSwitchTab!(1); // Go to library with that class
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryContainer : AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryContainer : AppColors.cardBorder,
                    width: isSelected ? 1.5 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Class',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white.withValues(alpha: 0.8) : AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$classNum',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? Colors.white : AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
