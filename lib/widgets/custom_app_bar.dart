import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/supabase_service.dart';
import '../theme/app_colors.dart';
import '../screens/download_manager_screen.dart';
import '../screens/notifications_screen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String subtitle;
  final String tag;
  final bool showNotification;
  final bool showDownloadManager;
  final bool showBackButton;
  final bool showAvatar;
  final VoidCallback? onBackPressed;

  const CustomAppBar({
    super.key,
    this.title = 'KPK E-Textbooks',
    this.subtitle = 'Govt. of Khyber Pakhtunkhwa',
    this.tag = 'Home',
    this.showNotification = true,
    this.showDownloadManager = true,
    this.showBackButton = false,
    this.showAvatar = true,
    this.onBackPressed,
  });

  Widget _buildInitialAvatar(String initial) {
    return Center(
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: AppColors.primaryContainer,
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(BuildContext context, AppState appState) {
    final avatarPath = appState.profileImagePath;
    final userName = SupabaseService.userName;
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : 'S';

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primaryContainer.withValues(alpha: 0.12),
        border: Border.all(
          color: AppColors.primaryContainer.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: avatarPath != null && avatarPath.isNotEmpty
            ? (avatarPath.startsWith('http')
                ? Image.network(
                    avatarPath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildInitialAvatar(initial),
                  )
                : Image.file(
                    File(avatarPath),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildInitialAvatar(initial),
                  ))
            : _buildInitialAvatar(initial),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final unreadCount = appState.unreadNotificationCount;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.98),
        border: const Border(
          bottom: BorderSide(color: AppColors.cardBorder, width: 0.8),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Back Button with visible background color & properly sized icon
              if (showBackButton) ...[
                Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: onBackPressed ?? () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.cardBorder,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
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
                const SizedBox(width: 10),
              ],

              // 2. User Profile Image / Avatar (replaces the old top logo)
              if (showAvatar) ...[
                _buildProfileAvatar(context, appState),
                const SizedBox(width: 10),
              ],

              // 3. Title & Subtitle (realigned to sit correctly alongside back button & avatar)
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ),
                        if (tag.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Flexible(
                            flex: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: AppColors.secondaryContainer,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                tag.toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                  color: AppColors.onSecondaryContainer,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 1.5),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // 4. Download Manager Button
              if (showDownloadManager)
                IconButton(
                  tooltip: 'Download Manager',
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.all(7),
                  constraints: const BoxConstraints(),
                  icon: const Icon(
                    Icons.downloading_rounded,
                    color: AppColors.primaryContainer,
                    size: 22,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DownloadManagerScreen()),
                    );
                  },
                ),

              if (showDownloadManager && showNotification)
                const SizedBox(width: 6),

              // 5. Notifications Button with unread counter
              if (showNotification)
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      tooltip: 'Official Notifications',
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.all(7),
                      constraints: const BoxConstraints(),
                      icon: const Icon(
                        Icons.notifications_none_rounded,
                        color: AppColors.onSurfaceVariant,
                        size: 22,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                        );
                      },
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        top: 2,
                        right: 2,
                        child: Container(
                          padding: const EdgeInsets.all(2.5),
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 15,
                            minHeight: 15,
                          ),
                          child: Text(
                            '$unreadCount',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(66);
}
