import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/notification_model.dart';
import '../providers/app_state.dart';
import '../theme/app_colors.dart';
import 'content_selection_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedFilter = 'All'; // 'All', 'Curriculum', 'Exams', 'New Books'

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final allNotifs = appState.notifications;

    final filteredNotifs = allNotifs.where((n) {
      if (_selectedFilter == 'All') return true;
      if (_selectedFilter == 'Curriculum') return n.type == NotificationType.curriculum;
      if (_selectedFilter == 'Exams') return n.type == NotificationType.exam;
      if (_selectedFilter == 'New Books') return n.type == NotificationType.newBook;
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.onSurface),
          tooltip: 'Back to Previous Screen',
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Board Notifications',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.onSurface),
            ),
            Text(
              'KPK Textbook Board Alerts',
              style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
        actions: [
          if (appState.unreadNotificationCount > 0)
            TextButton.icon(
              onPressed: () => appState.markAllNotificationsAsRead(),
              icon: const Icon(Icons.done_all_rounded, size: 16, color: AppColors.primaryContainer),
              label: const Text(
                'Mark All Read',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryContainer),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.surfaceContainerLow,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', 'All Notices (${allNotifs.length})'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Curriculum', 'Curriculum'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Exams', 'Exams & Guides'),
                  const SizedBox(width: 8),
                  _buildFilterChip('New Books', 'New Textbooks'),
                ],
              ),
            ),
          ),

          const Divider(height: 1, color: AppColors.cardBorder),

          // Notifications List
          Expanded(
            child: filteredNotifs.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.notifications_off_outlined, size: 44, color: AppColors.outline),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No Notifications Found',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'You are completely caught up with all official syllabus notices and board circulars.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredNotifs.length,
                    itemBuilder: (context, index) {
                      final item = filteredNotifs[index];
                      return _buildNotificationCard(context, appState, item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _selectedFilter == key;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilter = key;
        });
      },
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfaceContainerLowest : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? AppColors.primaryContainer : AppColors.cardBorder,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                  )
                ]
              : null,
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

  Widget _buildNotificationCard(BuildContext context, AppState appState, NotificationItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: item.isRead ? AppColors.surfaceContainerLowest : const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.isRead ? AppColors.cardBorder : AppColors.secondary.withValues(alpha: 0.4),
          width: item.isRead ? 1 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF17231D).withValues(alpha: 0.03),
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
          onTap: () => appState.markNotificationAsRead(item.id),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Tag & Timestamp & Unread Dot
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: item.categoryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(item.icon, size: 13, color: item.categoryColor),
                          const SizedBox(width: 4),
                          Text(
                            item.categoryName.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: item.categoryColor,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.timestamp,
                      style: const TextStyle(fontSize: 11, color: AppColors.outline),
                    ),
                    const Spacer(),
                    if (!item.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                // Title
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: item.isRead ? FontWeight.w700 : FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                ),
                if (item.titleUrdu.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.titleUrdu,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryContainer,
                    ),
                  ),
                ],
                const SizedBox(height: 6),

                // Message Body
                Text(
                  item.message,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),

                // Action Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryContainer,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        minimumSize: const Size(0, 32),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        appState.markNotificationAsRead(item.id);
                        _handleNotificationAction(context, appState, item);
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(item.actionLabel, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward_rounded, size: 13),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.outline),
                      tooltip: 'Dismiss',
                      onPressed: () => appState.deleteNotification(item.id),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleNotificationAction(BuildContext context, AppState appState, NotificationItem item) {
    if (item.relatedClass != null) {
      appState.setSelectedClass(item.relatedClass!);
    }

    if (item.id == 'notif_2') {
      // Find Physics Class 9 and open
      final physics = appState.booksForSelectedClass.firstWhere(
        (b) => b.id == 'c9_physics',
        orElse: () => appState.booksForSelectedClass.first,
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ContentSelectionScreen(book: physics)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Opening ${item.actionLabel}...'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}

