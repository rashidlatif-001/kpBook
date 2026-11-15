import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/offline_sync_banner.dart';
import 'class_screen.dart';
import 'search_screen.dart';
import 'pdf_reader_screen.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatelessWidget {
  final Function(int)? onSwitchTab;

  const HomeScreen({super.key, this.onSwitchTab});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const CustomAppBar(tag: 'Home'),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => appState.fetchRemoteUpdates(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Online/Offline dynamic sync banner
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
                      Expanded(
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
                            const SizedBox(height: 3),
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
                        child: Icon(
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
                      child: Row(
                        children: [
                          Icon(Icons.search_rounded, color: AppColors.outline, size: 22),
                          const SizedBox(width: 10),
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

                  // Quick Study Shortcuts (Resume reading automatically from last read page)
                  _buildQuickJumpSection(context, appState),

                  const SizedBox(height: 24),

                  // Class Selection (1 to 12) - Directly opens ClassScreen
                  _buildClassSelectionSection(context, appState),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
  }

  Widget _buildExamBanner(BuildContext context, AppState appState) {
    final activeNotice = appState.activeBannerNotice;
    final badgeText = (activeNotice != null && activeNotice.actionLabel.isNotEmpty)
        ? activeNotice.actionLabel
        : 'Curriculum 2024–25';
    final titleText = (activeNotice != null && activeNotice.title.isNotEmpty)
        ? activeNotice.title
        : 'Mid-term Exams Preparation Guide';
    final descText = (activeNotice != null && activeNotice.message.isNotEmpty)
        ? activeNotice.message
        : 'Complete syllabus & model papers for all grades now fully available offline with past paper solutions.';

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          if (activeNotice != null && activeNotice.relatedClass != null && activeNotice.relatedClass! > 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ClassScreen(classNumber: activeNotice.relatedClass!),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const NotificationsScreen(),
              ),
            );
          }
        },
        child: Container(
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.lightSecondaryContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified_rounded, size: 13, color: AppColors.lightOnSecondaryContainer),
                        const SizedBox(width: 4),
                        Text(
                          badgeText,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.lightOnSecondaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (activeNotice != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.campaign_rounded, size: 12, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'LIVE NOTICE',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                titleText,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                descText,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: AppColors.lightOnPrimaryContainer.withValues(alpha: 0.95),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickJumpSection(BuildContext context, AppState appState) {
    final recentBook = appState.lastReadBook;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
        if (recentBook != null)
          Row(
            children: [
              // Resume reading card - opens exact page
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PdfReaderScreen(
                          book: recentBook,
                          initialPage: recentBook.lastReadPage,
                          isFromResume: true,
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.cardBorder, width: 1),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: AppColors.primaryFixed,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.bolt_rounded, color: AppColors.onPrimaryFixed, size: 20),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Resume U${recentBook.currentUnitNumber} • P.${recentBook.lastReadPage}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                recentBook.subject,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Offline Mode Shortcut
              Expanded(
                child: InkWell(
                  onTap: () {
                    if (onSwitchTab != null) onSwitchTab!(2);
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.cardBorder, width: 1),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: AppColors.secondaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.download_done_rounded, color: AppColors.onSecondaryContainer, size: 18),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Offline Mode',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.secondary,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                '${appState.downloadedBooks.length} saved',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )
        else
          // Full-width card when no recent book
          InkWell(
            onTap: () {
              if (onSwitchTab != null) onSwitchTab!(2);
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                    child: Icon(Icons.download_done_rounded, color: AppColors.onSecondaryContainer, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Offline Mode',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.secondary,
                          ),
                        ),
                        Text(
                          '${appState.downloadedBooks.length} books saved for offline studying',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.outline),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildClassSelectionSection(BuildContext context, AppState appState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
        const SizedBox(height: 6),
        Text(
          'Tap any class to explore its complete collection of official textbooks and guides.',
          style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: 14),

        // Grid of classes (1 to 12)
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
                // Directly navigate to ClassScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ClassScreen(classNumber: classNum),
                  ),
                );
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
