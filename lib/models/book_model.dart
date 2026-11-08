import 'package:flutter/material.dart';
import 'chapter_model.dart';

enum BookItemType { book, guide }

class Book {
  final String id;
  final String title;
  final String titleUrdu;
  final String subject;
  final int classNumber;
  final String group; // 'Science', 'Arts', 'General', 'Compulsory'
  final BookItemType type; // Book or Guide
  final String fileSize;
  final int pagesCount;
  final Color coverGradientStart;
  final Color coverGradientEnd;
  final IconData icon;
  final String curriculumYear;
  final List<Chapter> chapters;
  bool isDownloaded;
  bool isDownloading;
  double downloadProgress;
  int lastReadPage;
  bool isBookmarked;
  final String? localFilePath;

  Book({
    required this.id,
    required this.title,
    this.titleUrdu = '',
    required this.subject,
    required this.classNumber,
    required this.group,
    this.type = BookItemType.book,
    required this.fileSize,
    required this.pagesCount,
    required this.coverGradientStart,
    required this.coverGradientEnd,
    required this.icon,
    this.curriculumYear = '2024–25',
    this.chapters = const [],
    this.isDownloaded = false,
    this.isDownloading = false,
    this.downloadProgress = 0.0,
    this.lastReadPage = 1,
    this.isBookmarked = false,
    this.localFilePath,
  });

  /// Extracts the numeric megabytes from strings like '18.4 MB'
  double get sizeInMB {
    try {
      final clean = fileSize.replaceAll(RegExp(r'[^0-9.]'), '');
      return double.tryParse(clean) ?? 0.0;
    } catch (_) {
      return 0.0;
    }
  }

  bool get isGuide => type == BookItemType.guide;
}
