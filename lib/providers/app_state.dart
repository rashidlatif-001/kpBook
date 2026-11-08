import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../models/book_model.dart';
import '../models/chapter_model.dart';
import '../models/notification_model.dart';
import '../services/supabase_service.dart';

class AppState extends ChangeNotifier {
  // Class selection: No class is selected by default
  int? _selectedClass;
  // Type filter for library: 'Books' or 'Guides'
  String _selectedLibraryTab = 'Books';
  String _searchQuery = '';
  final String _currentLanguage = 'en'; // App is English only
  bool _isDarkMode = false;
  bool _wifiOnlyDownload = true;
  String? _customProfileImagePath;

  // Online / Offline Connectivity state
  bool _isOnline = true;
  Timer? _connectivityTimer;

  List<NotificationItem> _notifications = [];

  int? get selectedClass => _selectedClass;
  bool get hasSelectedClass => _selectedClass != null;
  String get selectedLibraryTab => _selectedLibraryTab;
  String get searchQuery => _searchQuery;
  String get currentLanguage => _currentLanguage;
  bool get isDarkMode => _isDarkMode;
  bool get wifiOnlyDownload => _wifiOnlyDownload;
  bool get isOnline => _isOnline;
  String? get profileImagePath => _customProfileImagePath ?? SupabaseService.userAvatarUrl;

  List<NotificationItem> get notifications => _notifications;
  int get unreadNotificationCount => _notifications.where((n) => !n.isRead).length;

  late List<Book> _allBooks;

  AppState() {
    _initializeBooks();
    _initializeNotifications();
    final bool isTestEnv = !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');
    if (!isTestEnv) {
      _initConnectivityListener();
      fetchRemoteUpdates();
    }
  }

  @override
  void dispose() {
    _connectivityTimer?.cancel();
    super.dispose();
  }

  void _initConnectivityListener() {
    // Initial check
    checkConnectivity();
    // Periodic poll every 10 seconds to detect network drops or recoveries
    _connectivityTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      checkConnectivity();
    });
  }

  Future<void> checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      final bool nowOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      if (nowOnline != _isOnline) {
        _isOnline = nowOnline;
        notifyListeners();
        if (_isOnline) {
          // Sync with backend when connectivity is restored
          fetchRemoteUpdates();
        }
      }
    } catch (_) {
      if (_isOnline) {
        _isOnline = false;
        notifyListeners();
      }
    }
  }

  Future<void> fetchRemoteUpdates() async {
    try {
      final remoteList = await SupabaseService.fetchAppUpdates();
      if (remoteList.isNotEmpty) {
        for (final row in remoteList) {
          final id = row['id']?.toString() ?? UniqueKey().toString();
          if (!_notifications.any((n) => n.id == id)) {
            _notifications.insert(
              0,
              NotificationItem(
                id: id,
                title: row['title'] ?? 'Notice',
                message: row['message'] ?? '',
                timestamp: 'Just now',
                type: NotificationType.systemNotice,
                actionLabel: row['action_label'] ?? 'View Alert',
                relatedClass: row['related_class'],
                isRead: false,
              ),
            );
          }
        }
        notifyListeners();
      }
    } catch (_) {}
  }

  void _initializeNotifications() {
    _notifications = [
      NotificationItem(
        id: 'notif_1',
        title: 'Mid-term Exams Model Papers 2024–25',
        message: 'Official solved model papers and syllabus breakdown for Class 9 & 10 have been uploaded by KPK Textbook Board.',
        timestamp: '10:30 AM Today',
        type: NotificationType.exam,
        actionLabel: 'Explore Guides',
        relatedClass: 9,
        isRead: false,
      ),
      NotificationItem(
        id: 'notif_2',
        title: 'Curriculum Update: Class 9 Physics',
        message: 'Unit 3: Dynamics key definitions and formula sheet updated in accordance with the 2024–25 SLO guidelines.',
        timestamp: 'Yesterday, 4:15 PM',
        type: NotificationType.curriculum,
        actionLabel: 'Read Unit 3',
        relatedClass: 9,
        isRead: false,
      ),
      NotificationItem(
        id: 'notif_3',
        title: 'New Textbook Edition: Class 10 Urdu Lazmi',
        message: 'The newly printed digital edition of Class 10 Urdu Lazmi is now ready for offline download.',
        timestamp: '29 Oct 2026',
        type: NotificationType.newBook,
        actionLabel: 'View in Library',
        relatedClass: 10,
        isRead: false,
      ),
      NotificationItem(
        id: 'notif_4',
        title: 'Offline Mode Optimization',
        message: 'Storage compression improved by 25%. Download once to read without cellular reception across all regions of KP.',
        timestamp: '27 Oct 2026',
        type: NotificationType.systemNotice,
        actionLabel: 'Check Offline Shelf',
        isRead: true,
      ),
    ];
  }

  void _initializeBooks() {
    _allBooks = [
      // ---------------- CLASS 9 BOOKS ----------------
      Book(
        id: 'c9_physics',
        title: 'Physics for Class IX',
        subject: 'Physics',
        classNumber: 9,
        group: 'Science',
        type: BookItemType.book,
        fileSize: '18.4 MB',
        pagesCount: 198,
        coverGradientStart: const Color(0xFF005129),
        coverGradientEnd: const Color(0xFF0B8F55),
        icon: Icons.electric_bolt_rounded,
        curriculumYear: '2024–25',
        isDownloaded: true,
        lastReadPage: 82,
        isBookmarked: true,
        chapters: const [
          Chapter(number: 1, title: 'Physical Quantities & Measurement', pageStart: 1, pageEnd: 28, isCompleted: true),
          Chapter(number: 2, title: 'Kinematics', pageStart: 29, pageEnd: 60, isCompleted: true),
          Chapter(number: 3, title: 'Dynamics', pageStart: 61, pageEnd: 92, isCompleted: false),
          Chapter(number: 4, title: 'Turning Effect of Forces', pageStart: 93, pageEnd: 120, isCompleted: false),
          Chapter(number: 5, title: 'Gravitation', pageStart: 121, pageEnd: 146, isCompleted: false),
          Chapter(number: 6, title: 'Work and Energy', pageStart: 147, pageEnd: 172, isCompleted: false),
          Chapter(number: 7, title: 'Properties of Matter', pageStart: 173, pageEnd: 198, isCompleted: false),
        ],
      ),
      Book(
        id: 'c9_physics_guide',
        title: 'Physics IX Key Book & Solved SLO Guide',
        subject: 'Physics Guide',
        classNumber: 9,
        group: 'Science',
        type: BookItemType.guide,
        fileSize: '12.6 MB',
        pagesCount: 142,
        coverGradientStart: const Color(0xFF1B5E20),
        coverGradientEnd: const Color(0xFF388E3C),
        icon: Icons.menu_book_rounded,
        curriculumYear: '2024–25',
        isDownloaded: false,
        lastReadPage: 1,
        chapters: const [
          Chapter(number: 1, title: 'Solved MCQs & Numerical Problems', pageStart: 1, pageEnd: 45),
          Chapter(number: 2, title: 'Short & Conceptual Questions', pageStart: 46, pageEnd: 95),
          Chapter(number: 3, title: 'Board Exam Past Paper Solutions', pageStart: 96, pageEnd: 142),
        ],
      ),
      Book(
        id: 'c9_chemistry',
        title: 'Chemistry for Class IX',
        subject: 'Chemistry',
        classNumber: 9,
        group: 'Science',
        type: BookItemType.book,
        fileSize: '22.1 MB',
        pagesCount: 214,
        coverGradientStart: const Color(0xFF006D3F),
        coverGradientEnd: const Color(0xFF388E3C),
        icon: Icons.science_rounded,
        curriculumYear: '2024–25',
        isDownloaded: true,
        lastReadPage: 34,
        isBookmarked: false,
        chapters: const [
          Chapter(number: 1, title: 'Fundamentals of Chemistry', pageStart: 1, pageEnd: 32, isCompleted: true),
          Chapter(number: 2, title: 'Structure of Atoms', pageStart: 33, pageEnd: 58, isCompleted: false),
          Chapter(number: 3, title: 'Periodic Table & Periodicity', pageStart: 59, pageEnd: 86, isCompleted: false),
          Chapter(number: 4, title: 'Structure of Molecules', pageStart: 87, pageEnd: 118, isCompleted: false),
          Chapter(number: 5, title: 'Physical States of Matter', pageStart: 119, pageEnd: 148, isCompleted: false),
        ],
      ),
      Book(
        id: 'c9_chemistry_guide',
        title: 'Chemistry IX Practical & Study Guide',
        subject: 'Chemistry Guide',
        classNumber: 9,
        group: 'Science',
        type: BookItemType.guide,
        fileSize: '14.2 MB',
        pagesCount: 160,
        coverGradientStart: const Color(0xFF004D40),
        coverGradientEnd: const Color(0xFF00796B),
        icon: Icons.auto_stories_rounded,
        curriculumYear: '2024–25',
        isDownloaded: false,
        lastReadPage: 1,
        chapters: const [
          Chapter(number: 1, title: 'Laboratory Safety & Experiments', pageStart: 1, pageEnd: 60),
          Chapter(number: 2, title: 'Formulae & Chemical Equations', pageStart: 61, pageEnd: 110),
          Chapter(number: 3, title: 'Model Test Papers', pageStart: 111, pageEnd: 160),
        ],
      ),
      Book(
        id: 'c9_mathematics',
        title: 'Mathematics Class IX (Science)',
        subject: 'Mathematics',
        classNumber: 9,
        group: 'Science',
        type: BookItemType.book,
        fileSize: '31.2 MB',
        pagesCount: 310,
        coverGradientStart: const Color(0xFF0D47A1),
        coverGradientEnd: const Color(0xFF1976D2),
        icon: Icons.calculate_rounded,
        curriculumYear: '2024–25',
        isDownloaded: true,
        lastReadPage: 12,
        chapters: const [
          Chapter(number: 1, title: 'Matrices and Determinants', pageStart: 1, pageEnd: 34),
          Chapter(number: 2, title: 'Real and Complex Numbers', pageStart: 35, pageEnd: 62),
          Chapter(number: 3, title: 'Logarithms', pageStart: 63, pageEnd: 90),
          Chapter(number: 4, title: 'Algebraic Expressions & Formulas', pageStart: 91, pageEnd: 128),
        ],
      ),
      Book(
        id: 'c9_math_guide',
        title: 'Mathematics IX Solved Exercises & Key Guide',
        subject: 'Mathematics Guide',
        classNumber: 9,
        group: 'Science',
        type: BookItemType.guide,
        fileSize: '19.8 MB',
        pagesCount: 220,
        coverGradientStart: const Color(0xFF1565C0),
        coverGradientEnd: const Color(0xFF42A5F5),
        icon: Icons.menu_book_rounded,
        curriculumYear: '2024–25',
        isDownloaded: false,
        lastReadPage: 1,
        chapters: const [
          Chapter(number: 1, title: 'Step-by-step Exercise Solutions', pageStart: 1, pageEnd: 110),
          Chapter(number: 2, title: 'Important Theorems & Proofs', pageStart: 111, pageEnd: 220),
        ],
      ),
      Book(
        id: 'c9_biology',
        title: 'Biology for Class IX',
        subject: 'Biology',
        classNumber: 9,
        group: 'Science',
        type: BookItemType.book,
        fileSize: '26.8 MB',
        pagesCount: 236,
        coverGradientStart: const Color(0xFF1B5E20),
        coverGradientEnd: const Color(0xFF4CAF50),
        icon: Icons.eco_rounded,
        curriculumYear: '2024–25',
        isDownloaded: false,
        chapters: const [
          Chapter(number: 1, title: 'Introduction to Biology', pageStart: 1, pageEnd: 24),
          Chapter(number: 2, title: 'Solving a Biological Problem', pageStart: 25, pageEnd: 42),
          Chapter(number: 3, title: 'Biodiversity', pageStart: 43, pageEnd: 70),
          Chapter(number: 4, title: 'Cells and Tissues', pageStart: 71, pageEnd: 110),
        ],
      ),
      Book(
        id: 'c9_english',
        title: 'English Compulsory IX',
        subject: 'English',
        classNumber: 9,
        group: 'Compulsory',
        type: BookItemType.book,
        fileSize: '21.0 MB',
        pagesCount: 184,
        coverGradientStart: const Color(0xFF4A148C),
        coverGradientEnd: const Color(0xFF7B1FA2),
        icon: Icons.menu_book_rounded,
        curriculumYear: '2024–25',
        isDownloaded: false,
        chapters: const [
          Chapter(number: 1, title: 'The Saviour of Mankind', pageStart: 1, pageEnd: 18),
          Chapter(number: 2, title: 'Patriotism', pageStart: 19, pageEnd: 36),
          Chapter(number: 3, title: 'Media and Its Impact', pageStart: 37, pageEnd: 54),
        ],
      ),
      Book(
        id: 'c9_urdu',
        title: 'Urdu Lazmi for Class IX',
        subject: 'Urdu',
        classNumber: 9,
        group: 'Compulsory',
        type: BookItemType.book,
        fileSize: '19.5 MB',
        pagesCount: 176,
        coverGradientStart: const Color(0xFFB71C1C),
        coverGradientEnd: const Color(0xFFD32F2F),
        icon: Icons.library_books_rounded,
        curriculumYear: '2024–25',
        isDownloaded: false,
        chapters: const [
          Chapter(number: 1, title: 'Hijrat-e-Nabwi (PBUH)', pageStart: 1, pageEnd: 20),
          Chapter(number: 2, title: 'Mirza Ghalib ke Aadaat-o-Khasail', pageStart: 21, pageEnd: 42),
        ],
      ),

      // ---------------- CLASS 10 BOOKS ----------------
      Book(
        id: 'c10_physics',
        title: 'Physics for Class X',
        subject: 'Physics',
        classNumber: 10,
        group: 'Science',
        type: BookItemType.book,
        fileSize: '20.2 MB',
        pagesCount: 210,
        coverGradientStart: const Color(0xFF005129),
        coverGradientEnd: const Color(0xFF0B8F55),
        icon: Icons.electric_bolt_rounded,
        curriculumYear: '2024–25',
        isDownloaded: false,
        chapters: const [
          Chapter(number: 1, title: 'Simple Harmonic Motion and Waves', pageStart: 1, pageEnd: 32),
          Chapter(number: 2, title: 'Sound', pageStart: 33, pageEnd: 60),
          Chapter(number: 3, title: 'Geometrical Optics', pageStart: 61, pageEnd: 98),
          Chapter(number: 4, title: 'Electrostatics', pageStart: 99, pageEnd: 134),
        ],
      ),
      Book(
        id: 'c10_physics_guide',
        title: 'Physics X SLO Model Key & Solution Guide',
        subject: 'Physics Guide',
        classNumber: 10,
        group: 'Science',
        type: BookItemType.guide,
        fileSize: '15.1 MB',
        pagesCount: 155,
        coverGradientStart: const Color(0xFF1B5E20),
        coverGradientEnd: const Color(0xFF388E3C),
        icon: Icons.menu_book_rounded,
        curriculumYear: '2024–25',
        isDownloaded: false,
        chapters: const [
          Chapter(number: 1, title: 'Optics & Wave Numerical Solved', pageStart: 1, pageEnd: 75),
          Chapter(number: 2, title: 'Board Exam Expected Questions', pageStart: 76, pageEnd: 155),
        ],
      ),
      Book(
        id: 'c10_chemistry',
        title: 'Chemistry for Class X',
        subject: 'Chemistry',
        classNumber: 10,
        group: 'Science',
        type: BookItemType.book,
        fileSize: '24.0 MB',
        pagesCount: 228,
        coverGradientStart: const Color(0xFF006D3F),
        coverGradientEnd: const Color(0xFF388E3C),
        icon: Icons.science_rounded,
        curriculumYear: '2024–25',
        isDownloaded: false,
        chapters: const [
          Chapter(number: 1, title: 'Chemical Equilibrium', pageStart: 1, pageEnd: 30),
          Chapter(number: 2, title: 'Acids, Bases and Salts', pageStart: 31, pageEnd: 64),
          Chapter(number: 3, title: 'Organic Chemistry', pageStart: 65, pageEnd: 102),
        ],
      ),
      Book(
        id: 'c10_maths',
        title: 'Mathematics Class X (Science)',
        subject: 'Mathematics',
        classNumber: 10,
        group: 'Science',
        type: BookItemType.book,
        fileSize: '34.5 MB',
        pagesCount: 340,
        coverGradientStart: const Color(0xFF0D47A1),
        coverGradientEnd: const Color(0xFF1976D2),
        icon: Icons.calculate_rounded,
        curriculumYear: '2024–25',
        isDownloaded: false,
        chapters: const [
          Chapter(number: 1, title: 'Quadratic Equations', pageStart: 1, pageEnd: 38),
          Chapter(number: 2, title: 'Theory of Quadratic Equations', pageStart: 39, pageEnd: 76),
          Chapter(number: 3, title: 'Variations', pageStart: 77, pageEnd: 112),
        ],
      ),
      Book(
        id: 'c10_math_guide',
        title: 'Mathematics X Solved Comprehensive Guide',
        subject: 'Mathematics Guide',
        classNumber: 10,
        group: 'Science',
        type: BookItemType.guide,
        fileSize: '22.4 MB',
        pagesCount: 260,
        coverGradientStart: const Color(0xFF1565C0),
        coverGradientEnd: const Color(0xFF42A5F5),
        icon: Icons.auto_stories_rounded,
        curriculumYear: '2024–25',
        isDownloaded: false,
        chapters: const [
          Chapter(number: 1, title: 'Quadratic & Variation Solved Exercises', pageStart: 1, pageEnd: 130),
          Chapter(number: 2, title: 'Practical Geometry & Circle Theorems', pageStart: 131, pageEnd: 260),
        ],
      ),

      // ---------------- CLASSES 1 TO 8 & 11-12 BOOKS ----------------
      for (int c in [1, 2, 3, 4, 5, 6, 7, 8, 11, 12]) ...[
        Book(
          id: 'c${c}_maths',
          title: 'Mathematics for Grade $c',
          subject: 'Mathematics',
          classNumber: c,
          group: 'Science',
          type: BookItemType.book,
          fileSize: '${14 + (c * 1.5).round()} MB',
          pagesCount: 120 + (c * 15),
          coverGradientStart: const Color(0xFF0D47A1),
          coverGradientEnd: const Color(0xFF1976D2),
          icon: Icons.calculate_rounded,
          curriculumYear: '2024–25',
          isDownloaded: false,
          chapters: [
            Chapter(number: 1, title: 'Number Sense & Operations (Grade $c)', pageStart: 1, pageEnd: 30),
            Chapter(number: 2, title: 'Geometry & Measurements', pageStart: 31, pageEnd: 65),
            Chapter(number: 3, title: 'Applied Mathematical Problems', pageStart: 66, pageEnd: 110),
          ],
        ),
        Book(
          id: 'c${c}_maths_guide',
          title: 'Grade $c Mathematics Teacher & Study Guide',
          subject: 'Mathematics Guide',
          classNumber: c,
          group: 'Science',
          type: BookItemType.guide,
          fileSize: '${10 + (c * 1.1).round()} MB',
          pagesCount: 90 + (c * 10),
          coverGradientStart: const Color(0xFF1565C0),
          coverGradientEnd: const Color(0xFF42A5F5),
          icon: Icons.menu_book_rounded,
          curriculumYear: '2024–25',
          isDownloaded: false,
          chapters: [
            Chapter(number: 1, title: 'Curriculum SLO Guidelines & Solutions', pageStart: 1, pageEnd: 50),
            Chapter(number: 2, title: 'Diagnostic Assessments & Model Tests', pageStart: 51, pageEnd: 95),
          ],
        ),
        Book(
          id: 'c${c}_general_science',
          title: c <= 8 ? 'General Science Grade $c' : 'Science & Laboratory Studies $c',
          subject: 'Science',
          classNumber: c,
          group: 'Science',
          type: BookItemType.book,
          fileSize: '${12 + (c * 1.3).round()} MB',
          pagesCount: 110 + (c * 12),
          coverGradientStart: const Color(0xFF006D3F),
          coverGradientEnd: const Color(0xFF388E3C),
          icon: Icons.science_rounded,
          curriculumYear: '2024–25',
          isDownloaded: false,
          chapters: [
            Chapter(number: 1, title: 'Living Things and Environment (Grade $c)', pageStart: 1, pageEnd: 35),
            Chapter(number: 2, title: 'Matter and Energy Principles', pageStart: 36, pageEnd: 75),
          ],
        ),
        Book(
          id: 'c${c}_english',
          title: 'English Textbook Grade $c',
          subject: 'English',
          classNumber: c,
          group: 'Compulsory',
          type: BookItemType.book,
          fileSize: '${11 + (c * 1.2).round()} MB',
          pagesCount: 100 + (c * 10),
          coverGradientStart: const Color(0xFF4A148C),
          coverGradientEnd: const Color(0xFF7B1FA2),
          icon: Icons.auto_stories_rounded,
          curriculumYear: '2024–25',
          isDownloaded: false,
          chapters: [
            Chapter(number: 1, title: 'Reading Comprehension & Vocabulary', pageStart: 1, pageEnd: 30),
            Chapter(number: 2, title: 'Grammar and Sentence Structure', pageStart: 31, pageEnd: 60),
          ],
        ),
      ],
    ];
  }

  /// Returns books for the selected class filtered by 'Books' or 'Guides'
  List<Book> get booksForSelectedClass {
    if (_selectedClass == null) return [];
    return _allBooks.where((b) {
      if (b.classNumber != _selectedClass) return false;
      if (_selectedLibraryTab.toLowerCase() == 'guides') {
        return b.isGuide;
      }
      // Defaults to Books
      return !b.isGuide;
    }).toList();
  }

  /// Returns all books (both Books & Guides) for the selected class
  List<Book> get allItemsForSelectedClass {
    if (_selectedClass == null) return [];
    return _allBooks.where((b) => b.classNumber == _selectedClass).toList();
  }

  List<Book> get downloadedBooks {
    return _allBooks.where((b) => b.isDownloaded).toList();
  }

  /// Calculates dynamic storage usage in MB from the actual sizes of downloaded books
  double get totalStorageUsedMB {
    double total = 0.0;
    for (var b in downloadedBooks) {
      total += b.sizeInMB;
    }
    return total;
  }

  String get totalStorageUsedFormatted {
    final mb = totalStorageUsedMB;
    if (mb <= 0) return '0 MB Used';
    return '${mb.toStringAsFixed(1)} MB Used';
  }

  List<Book> get activeDownloadingBooks {
    return _allBooks.where((b) => b.isDownloading).toList();
  }

  List<Book> get recentReads {
    final reads = _allBooks.where((b) => b.lastReadPage > 1).toList();
    reads.sort((a, b) => b.lastReadPage.compareTo(a.lastReadPage));
    return reads;
  }

  Book? get lastReadBook {
    final list = recentReads;
    return list.isNotEmpty ? list.first : null;
  }

  /// Multi-filter search method matching query, optional class, and type (Books vs Guides)
  List<Book> searchBooksWithFilters({
    required String query,
    int? classFilter,
    String? typeFilter, // 'All', 'Books', 'Guides'
  }) {
    final q = query.trim().toLowerCase();

    return _allBooks.where((b) {
      // 1. Class filter
      if (classFilter != null && b.classNumber != classFilter) {
        return false;
      }

      // 2. Type filter (Books vs Guides)
      if (typeFilter != null && typeFilter.isNotEmpty && typeFilter != 'All') {
        if (typeFilter.toLowerCase() == 'guides' && !b.isGuide) return false;
        if (typeFilter.toLowerCase() == 'books' && b.isGuide) return false;
      }

      // 3. Query matching (if empty query, return all matching class/type)
      if (q.isEmpty) return true;

      return b.title.toLowerCase().contains(q) ||
          b.subject.toLowerCase().contains(q) ||
          'class ${b.classNumber}'.contains(q) ||
          'grade ${b.classNumber}'.contains(q);
    }).toList();
  }

  List<Book> searchBooks(String query) {
    return searchBooksWithFilters(query: query);
  }

  void setSelectedClass(int? classNum) {
    _selectedClass = classNum;
    notifyListeners();
  }

  void setSelectedLibraryTab(String tab) {
    _selectedLibraryTab = tab;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setProfileImagePath(String? path) {
    _customProfileImagePath = path;
    notifyListeners();
  }

  void toggleDarkMode(bool val) {
    _isDarkMode = val;
    notifyListeners();
  }

  void toggleWifiOnly(bool val) {
    _wifiOnlyDownload = val;
    notifyListeners();
  }

  void toggleBookmark(Book book) {
    book.isBookmarked = !book.isBookmarked;
    notifyListeners();
  }

  void updateLastReadPage(Book book, int page) {
    book.lastReadPage = page;
    notifyListeners();
  }

  void startDownload(Book book) {
    if (book.isDownloaded || book.isDownloading) return;

    book.isDownloading = true;
    book.downloadProgress = 0.05;
    notifyListeners();

    Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (!book.isDownloading) {
        timer.cancel();
        return;
      }
      book.downloadProgress += 0.15;
      if (book.downloadProgress >= 1.0) {
        book.downloadProgress = 1.0;
        book.isDownloading = false;
        book.isDownloaded = true;
        timer.cancel();
      }
      notifyListeners();
    });
  }

  void pauseDownload(Book book) {
    book.isDownloading = false;
    notifyListeners();
  }

  void deleteDownload(Book book) {
    book.isDownloaded = false;
    book.isDownloading = false;
    book.downloadProgress = 0.0;
    notifyListeners();
  }

  /// Clears temporary reader cache and all downloaded content
  Future<double> clearAllCacheAndDownloads() async {
    final double freedMB = totalStorageUsedMB + 12.4; // downloaded files + temp cache
    for (var b in _allBooks) {
      b.isDownloaded = false;
      b.isDownloading = false;
      b.downloadProgress = 0.0;
    }
    notifyListeners();
    return freedMB;
  }

  void markAllNotificationsAsRead() {
    for (var n in _notifications) {
      n.isRead = true;
    }
    notifyListeners();
  }

  void markNotificationAsRead(String id) {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _notifications[idx].isRead = true;
      notifyListeners();
    }
  }

  void deleteNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }
}
