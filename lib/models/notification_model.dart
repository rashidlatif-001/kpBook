import 'package:flutter/material.dart';

enum NotificationType {
  curriculum,
  exam,
  newBook,
  systemNotice,
}

class NotificationItem {
  final String id;
  final String title;
  final String titleUrdu;
  final String message;
  final String timestamp;
  final NotificationType type;
  final String actionLabel;
  final int? relatedClass;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    this.titleUrdu = '',
    required this.message,
    required this.timestamp,
    required this.type,
    this.actionLabel = 'View Details',
    this.relatedClass,
    this.isRead = false,
  });

  IconData get icon {
    switch (type) {
      case NotificationType.curriculum:
        return Icons.auto_stories_rounded;
      case NotificationType.exam:
        return Icons.assignment_turned_in_rounded;
      case NotificationType.newBook:
        return Icons.menu_book_rounded;
      case NotificationType.systemNotice:
        return Icons.campaign_rounded;
    }
  }

  Color get categoryColor {
    switch (type) {
      case NotificationType.curriculum:
        return const Color(0xFF005129); // Primary Deep Green
      case NotificationType.exam:
        return const Color(0xFFB8860B); // Amber / Gold
      case NotificationType.newBook:
        return const Color(0xFF006D3F); // Secondary Emerald
      case NotificationType.systemNotice:
        return const Color(0xFF1E88E5); // Blue
    }
  }

  String get categoryName {
    switch (type) {
      case NotificationType.curriculum:
        return 'Curriculum 2024–25';
      case NotificationType.exam:
        return 'Board Exams';
      case NotificationType.newBook:
        return 'New Textbook';
      case NotificationType.systemNotice:
        return 'Board Notice';
    }
  }
}

