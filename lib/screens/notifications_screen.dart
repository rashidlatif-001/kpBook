import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/notification_model.dart';
import '../providers/app_state.dart';
import '../theme/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final allNotifs = appState.notifications;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          'Board Announcements',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.onSurface),
        ),
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
                child: Icon(Icons.arrow_back_rounded, color: AppColors.onSurface, size: 19),
              ),
            ),
          ),
        ),
        actions: [
          if (appState.unreadNotificationCount > 0)
            TextButton.icon(
              onPressed: () => appState.markAllNotificationsAsRead(),
              icon: Icon(Icons.done_all_rounded, size: 16, color: AppColors.primaryContainer),
              label: Text(
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
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.notifications_none_rounded, size: 48, color: AppColors.outline),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Notifications Yet',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Official board notices, alerts, and textbook updates will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: allNotifs.length,
              itemBuilder: (context, index) {
                final notif = allNotifs[index];
                return Dismissible(
                  key: Key(notif.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) {
                    appState.deleteNotification(notif.id);
                  },
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                  ),
                  child: _buildNotificationCard(context, notif, appState),
                );
              },
            ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, NotificationItem notif, AppState appState) {
    Color typeColor;
    IconData typeIcon;

    switch (notif.type) {
      case NotificationType.exam:
        typeColor = const Color(0xFFD32F2F);
        typeIcon = Icons.assignment_late_outlined;
        break;
      case NotificationType.curriculum:
        typeColor = AppColors.primary;
        typeIcon = Icons.auto_stories_outlined;
        break;
      case NotificationType.newBook:
        typeColor = AppColors.secondary;
        typeIcon = Icons.menu_book_rounded;
        break;
      case NotificationType.systemNotice:
        typeColor = const Color(0xFFF57C00);
        typeIcon = Icons.info_outline_rounded;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: notif.isRead ? AppColors.surfaceContainerLowest : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: notif.isRead ? AppColors.cardBorder : AppColors.secondary.withValues(alpha: 0.5),
          width: notif.isRead ? 1 : 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            appState.markNotificationAsRead(notif.id);
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Box
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(typeIcon, color: typeColor, size: 20),
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
                                fontSize: 13,
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
                              decoration: BoxDecoration(
                                color: AppColors.secondary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notif.message,
                        style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant, height: 1.35),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            notif.timestamp,
                            style: TextStyle(fontSize: 10, color: AppColors.outline, fontWeight: FontWeight.w500),
                          ),
                          if (notif.actionLabel.isNotEmpty)
                            Text(
                              notif.actionLabel,
                              style: TextStyle(
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
        ),
      ),
    );
  }
}
