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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppState>(context, listen: false).fetchRemoteUpdates();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final allNotifs = appState.notifications;

    return Scaffold(
      appBar: AppBar(
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
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.onSurface,
                  size: 19,
                ),
              ),
            ),
          ),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notification',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.onSurface),
            ),
            Text(
              'Alerts',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
      body: allNotifs.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.notifications_none_rounded, size: 48, color: AppColors.outline),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No Notifications Yet',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Official board notices, alerts, and textbook updates will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                await appState.fetchRemoteUpdates();
              },
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: allNotifs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final notif = allNotifs[index];
                  return _buildNotificationCard(context, appState, notif);
                },
              ),
            ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, AppState appState, NotificationItem notif) {
    return InkWell(
      onTap: () {
        appState.markNotificationAsRead(notif.id);
        if (notif.relatedClass != null) {
          appState.setSelectedClass(notif.relatedClass);
          final matchingBook = appState.booksForSelectedClass.isNotEmpty
              ? appState.booksForSelectedClass.first
              : null;
          if (matchingBook != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ContentSelectionScreen(book: matchingBook)),
            );
          }
        }
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notif.isRead ? AppColors.surfaceContainerLowest : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: notif.isRead ? AppColors.cardBorder : AppColors.primaryContainer.withValues(alpha: 0.5),
            width: notif.isRead ? 1 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: notif.isRead
                    ? AppColors.surfaceContainer
                    : AppColors.primaryContainer.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getNotifIcon(notif.type),
                size: 20,
                color: notif.isRead ? AppColors.outline : AppColors.primaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.w800,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                      if (!notif.isRead) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif.message,
                    style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant, height: 1.35),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        notif.timestamp,
                        style: const TextStyle(fontSize: 10, color: AppColors.outline, fontWeight: FontWeight.w500),
                      ),
                      if (notif.actionLabel.isNotEmpty)
                        Text(
                          notif.actionLabel,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryContainer,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getNotifIcon(NotificationType type) {
    switch (type) {
      case NotificationType.curriculum:
        return Icons.edit_note_rounded;
      case NotificationType.exam:
        return Icons.assignment_turned_in_rounded;
      case NotificationType.newBook:
        return Icons.auto_stories_rounded;
      case NotificationType.systemNotice:
        return Icons.campaign_rounded;
    }
  }
}
