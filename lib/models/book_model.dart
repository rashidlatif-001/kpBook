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
  final String? boardName;
  final String? publisher;
  final String? edition;
  final String? publicationStatus;

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
    this.boardName = 'KPK Textbook Board, Peshawar',
    this.publisher = 'KPK Textbook Board',
    this.edition = '2024–25',
    this.publicationStatus = 'published',
  });

  /// Factory constructor to parse database records from Supabase
  factory Book.fromJson(Map<String, dynamic> json, {List<Chapter>? loadedChapters}) {
    final rawClass = json['class_number'];
    final int classNum = rawClass is int
        ? rawClass
        : int.tryParse(rawClass?.toString() ?? '9') ?? 9;

    final rawType = json['book_type']?.toString().toLowerCase();
    final itemType = rawType == 'guide' ? BookItemType.guide : BookItemType.book;

    // Cover gradients
    Color gradStart = const Color(0xFF005129);
    Color gradEnd = const Color(0xFF0B8F55);
    if (json['cover_gradient_start'] != null) {
      try {
        final hex = json['cover_gradient_start'].toString().replaceAll('#', '');
        gradStart = Color(int.parse('FF$hex', radix: 16));
      } catch (_) {}
    }
    if (json['cover_gradient_end'] != null) {
      try {
        final hex = json['cover_gradient_end'].toString().replaceAll('#', '');
        gradEnd = Color(int.parse('FF$hex', radix: 16));
      } catch (_) {}
    }

    // Subject icon matching
    IconData bookIcon = Icons.menu_book_rounded;
    final subj = (json['subject_name'] ?? json['subject'] ?? '').toString().toLowerCase();
    if (subj.contains('physic')) {
      bookIcon = Icons.electric_bolt_rounded;
    } else if (subj.contains('chem')) {
      bookIcon = Icons.science_rounded;
    } else if (subj.contains('math')) {
      bookIcon = Icons.calculate_rounded;
    } else if (subj.contains('bio')) {
      bookIcon = Icons.biotech_rounded;
    } else if (subj.contains('computer')) {
      bookIcon = Icons.computer_rounded;
    } else if (subj.contains('urdu') || subj.contains('islam')) {
      bookIcon = Icons.auto_stories_rounded;
    }

    return Book(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'KPK Textbook',
      titleUrdu: json['title_urdu']?.toString() ?? '',
      subject: json['subject_name']?.toString() ?? json['subject']?.toString() ?? 'General',
      classNumber: classNum,
      group: json['group_type']?.toString() ?? json['group']?.toString() ?? 'Science',
      type: itemType,
      fileSize: json['file_size']?.toString() ?? '15.0 MB',
      pagesCount: json['total_pages'] is int
          ? json['total_pages']
          : int.tryParse(json['total_pages']?.toString() ?? '100') ?? 100,
      coverGradientStart: gradStart,
      coverGradientEnd: gradEnd,
      icon: bookIcon,
      curriculumYear: json['curriculum_year']?.toString() ?? json['edition']?.toString() ?? '2024–25',
      chapters: loadedChapters ?? const [],
      boardName: json['board_name']?.toString() ?? 'KPK Textbook Board, Peshawar',
      publisher: json['publisher']?.toString() ?? 'KPK Textbook Board',
      edition: json['edition']?.toString() ?? '2024–25',
      publicationStatus: json['publication_status']?.toString() ?? 'published',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'title_urdu': titleUrdu,
      'subject_name': subject,
      'class_number': classNumber,
      'group_type': group,
      'book_type': type == BookItemType.guide ? 'guide' : 'book',
      'file_size': fileSize,
      'total_pages': pagesCount,
      'curriculum_year': curriculumYear,
      'board_name': boardName,
      'publisher': publisher,
      'edition': edition,
      'publication_status': publicationStatus,
      'chapters': chapters.map((c) => c.toJson()).toList(),
    };
  }

  Book copyWith({
    String? id,
    String? title,
    String? titleUrdu,
    String? subject,
    int? classNumber,
    String? group,
    BookItemType? type,
    String? fileSize,
    int? pagesCount,
    Color? coverGradientStart,
    Color? coverGradientEnd,
    IconData? icon,
    String? curriculumYear,
    List<Chapter>? chapters,
    bool? isDownloaded,
    bool? isDownloading,
    double? downloadProgress,
    int? lastReadPage,
    bool? isBookmarked,
    String? localFilePath,
    String? publicationStatus,
  }) {
    final b = Book(
      id: id ?? this.id,
      title: title ?? this.title,
      titleUrdu: titleUrdu ?? this.titleUrdu,
      subject: subject ?? this.subject,
      classNumber: classNumber ?? this.classNumber,
      group: group ?? this.group,
      type: type ?? this.type,
      fileSize: fileSize ?? this.fileSize,
      pagesCount: pagesCount ?? this.pagesCount,
      coverGradientStart: coverGradientStart ?? this.coverGradientStart,
      coverGradientEnd: coverGradientEnd ?? this.coverGradientEnd,
      icon: icon ?? this.icon,
      curriculumYear: curriculumYear ?? this.curriculumYear,
      chapters: chapters ?? this.chapters,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      isDownloading: isDownloading ?? this.isDownloading,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      lastReadPage: lastReadPage ?? this.lastReadPage,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      localFilePath: localFilePath ?? this.localFilePath,
      boardName: boardName,
      publisher: publisher,
      edition: edition,
      publicationStatus: publicationStatus ?? this.publicationStatus,
    );
    return b;
  }

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

  int get currentUnitNumber {
    for (final c in chapters) {
      if (lastReadPage >= c.pageStart && lastReadPage <= c.pageEnd) {
        return c.number;
      }
    }
    return chapters.isNotEmpty ? chapters.first.number : 1;
  }

  Chapter? get currentUnit {
    for (final c in chapters) {
      if (lastReadPage >= c.pageStart && lastReadPage <= c.pageEnd) {
        return c;
      }
    }
    return chapters.isNotEmpty ? chapters.first : null;
  }

  bool get hasStartedReading => lastReadPage > 1;
}
