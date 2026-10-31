import 'dart:async';
import 'package:flutter/material.dart';
import '../models/book_model.dart';
import '../models/chapter_model.dart';
import '../models/notification_model.dart';

class AppState extends ChangeNotifier {
  int _selectedClass = 9;
  String _selectedLibraryTab = 'All'; // 'All', 'Science', 'Arts', 'Compulsory'
  String _searchQuery = '';
  String _currentLanguage = 'en'; // 'en', 'ur', 'ps'
  bool _isDarkMode = false;
  bool _wifiOnlyDownload = true;
  bool _lowDataMode = false;

  List<NotificationItem> _notifications = [];

  int get selectedClass => _selectedClass;
  String get selectedLibraryTab => _selectedLibraryTab;
  String get searchQuery => _searchQuery;
  String get currentLanguage => _currentLanguage;
  bool get isDarkMode => _isDarkMode;
  bool get wifiOnlyDownload => _wifiOnlyDownload;
  bool get lowDataMode => _lowDataMode;
  List<NotificationItem> get notifications => _notifications;
  int get unreadNotificationCount => _notifications.where((n) => !n.isRead).length;

  late List<Book> _allBooks;

  AppState() {
    _initializeBooks();
    _initializeNotifications();
  }

  void _initializeNotifications() {
    _notifications = [
      NotificationItem(
        id: 'notif_1',
        title: 'Mid-term Exams Model Papers 2024–25',
        titleUrdu: 'مڈ ٹرم امتحانات کے ماڈل پیپرز دستیاب ہیں',
        message: 'Official solved model papers and syllabus breakdown for Class 9 & 10 have been uploaded by KPK Textbook Board.',
        timestamp: '10:30 AM Today',
        type: NotificationType.exam,
        actionLabel: 'Explore Class 9 Guides',
        relatedClass: 9,
        isRead: false,
      ),
      NotificationItem(
        id: 'notif_2',
        title: 'Curriculum Update: Class 9 Physics',
        titleUrdu: 'طبیعیات جماعت نہم کے نصاب میں اپڈیٹ',
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
        titleUrdu: 'اردو لازمی جماعت دہم کی نئی ایڈیشن',
        message: 'The newly printed digital edition of Class 10 Urdu Lazmi is now ready for offline download.',
        timestamp: '29 Oct 2026',
        type: NotificationType.newBook,
        actionLabel: 'View in Library',
        relatedClass: 10,
        isRead: false,
      ),
      NotificationItem(
        id: 'notif_4',
        title: 'Village Offline Mode Optimization',
        titleUrdu: 'آف لائن ویلج موڈ کی بہتر کارکردگی',
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
      Book(
        id: 'c9_physics',
        title: 'Physics for Class IX',
        titleUrdu: 'طبیعیات برائے جماعت نہم',
        subject: 'Physics',
        classNumber: 9,
        group: 'Science',
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
          Chapter(
            number: 1,
            title: 'Physical Quantities & Measurement',
            titleUrdu: 'طبعی مقداریں اور پیمائش',
            pageStart: 1,
            pageEnd: 28,
            isCompleted: true,
            keyTopics: ['International System of Units', 'Prefixes', 'Vernier Calipers', 'Screw Gauge', 'Significant Figures'],
          ),
          Chapter(
            number: 2,
            title: 'Kinematics',
            titleUrdu: 'حرکیات',
            pageStart: 29,
            pageEnd: 60,
            isCompleted: true,
            keyTopics: ['Rest & Motion', 'Types of Motion', 'Scalars & Vectors', 'Equations of Motion', 'Free Fall'],
          ),
          Chapter(
            number: 3,
            title: 'Dynamics',
            titleUrdu: 'ڈائنامکس',
            pageStart: 61,
            pageEnd: 92,
            isCompleted: false,
            keyTopics: ["Newton's Laws of Motion", 'Mass & Weight', 'Momentum', 'Friction', 'Centripetal Force'],
          ),
          Chapter(
            number: 4,
            title: 'Turning Effect of Forces',
            titleUrdu: 'قوتوں کا گردشی اثر',
            pageStart: 93,
            pageEnd: 120,
            isCompleted: false,
            keyTopics: ['Like & Unlike Parallel Forces', 'Torque / Moment', 'Equilibrium', 'Center of Gravity'],
          ),
          Chapter(
            number: 5,
            title: 'Gravitation',
            titleUrdu: 'کشش ثقل',
            pageStart: 121,
            pageEnd: 146,
            isCompleted: false,
            keyTopics: ['Law of Gravitation', 'Mass of Earth', 'Artificial Satellites'],
          ),
          Chapter(
            number: 6,
            title: 'Work and Energy',
            titleUrdu: 'کام اور توانائی',
            pageStart: 147,
            pageEnd: 172,
            isCompleted: false,
            keyTopics: ['Kinetic & Potential Energy', 'Major Sources of Energy', 'Efficiency', 'Power'],
          ),
          Chapter(
            number: 7,
            title: 'Properties of Matter',
            titleUrdu: 'مادے کی خصوصیات',
            pageStart: 173,
            pageEnd: 198,
            isCompleted: false,
            keyTopics: ['Kinetic Molecular Model', 'Density', "Pascal's Law", "Hooke's Law"],
          ),
        ],
      ),
      Book(
        id: 'c9_chemistry',
        title: 'Chemistry for Class IX',
        titleUrdu: 'کیمیا برائے جماعت نہم',
        subject: 'Chemistry',
        classNumber: 9,
        group: 'Science',
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
        id: 'c9_biology',
        title: 'Biology for Class IX',
        titleUrdu: 'حیاتیات برائے جماعت نہم',
        subject: 'Biology',
        classNumber: 9,
        group: 'Science',
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
        id: 'c9_mathematics',
        title: 'Mathematics Class IX (Science)',
        titleUrdu: 'ریاضی برائے جماعت نہم',
        subject: 'Mathematics',
        classNumber: 9,
        group: 'Science',
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
        id: 'c9_computer_science',
        title: 'Computer Science IX',
        titleUrdu: 'کمپیوٹر سائنس جماعت نہم',
        subject: 'Computer Science',
        classNumber: 9,
        group: 'Science',
        fileSize: '15.7 MB',
        pagesCount: 168,
        coverGradientStart: const Color(0xFF2E7D32),
        coverGradientEnd: const Color(0xFF00897B),
        icon: Icons.memory_rounded,
        curriculumYear: '2024–25',
        isDownloaded: false,
        chapters: const [
          Chapter(number: 1, title: 'Problem Solving & Flowcharts', pageStart: 1, pageEnd: 30),
          Chapter(number: 2, title: 'Binary Number Systems', pageStart: 31, pageEnd: 54),
          Chapter(number: 3, title: 'Computer Networks', pageStart: 55, pageEnd: 88),
          Chapter(number: 4, title: 'Data Security and Cyber Law', pageStart: 89, pageEnd: 122),
        ],
      ),
      Book(
        id: 'c9_english',
        title: 'English Compulsory IX',
        titleUrdu: 'انگریزی لازمی جماعت نہم',
        subject: 'English',
        classNumber: 9,
        group: 'Compulsory',
        fileSize: '17.3 MB',
        pagesCount: 180,
        coverGradientStart: const Color(0xFF5B4200),
        coverGradientEnd: const Color(0xFF8D6E63),
        icon: Icons.menu_book_rounded,
        curriculumYear: '2024–25',
        isDownloaded: true,
        chapters: const [
          Chapter(number: 1, title: 'The Saviour of Mankind', pageStart: 1, pageEnd: 16),
          Chapter(number: 2, title: 'Patriotism', pageStart: 17, pageEnd: 28),
          Chapter(number: 3, title: 'Media and Its Impact', pageStart: 29, pageEnd: 42),
          Chapter(number: 4, title: 'Hazrat Asma (R.A)', pageStart: 43, pageEnd: 56),
        ],
      ),
      Book(
        id: 'c9_urdu',
        title: 'Urdu Lazmi Class IX',
        titleUrdu: 'اردو لازمی برائے جماعت نہم',
        subject: 'Urdu',
        classNumber: 9,
        group: 'Compulsory',
        fileSize: '19.0 MB',
        pagesCount: 196,
        coverGradientStart: const Color(0xFF4A148C),
        coverGradientEnd: const Color(0xFF7B1FA2),
        icon: Icons.translate_rounded,
        curriculumYear: '2024–25',
        isDownloaded: false,
        chapters: const [
          Chapter(number: 1, title: 'ہجرت نبویؐ', pageStart: 1, pageEnd: 18),
          Chapter(number: 2, title: 'مرزا غالب کے عادات و خصائل', pageStart: 19, pageEnd: 32),
          Chapter(number: 3, title: 'کاہلی', pageStart: 33, pageEnd: 48),
        ],
      ),
      Book(
        id: 'c9_islamiat',
        title: 'Islamiat Lazmi IX',
        titleUrdu: 'اسلامیات لازمی جماعت نہم',
        subject: 'Islamiat',
        classNumber: 9,
        group: 'Compulsory',
        fileSize: '14.8 MB',
        pagesCount: 144,
        coverGradientStart: const Color(0xFF004D40),
        coverGradientEnd: const Color(0xFF00796B),
        icon: Icons.mosque_rounded,
        curriculumYear: '2024–25',
        isDownloaded: true,
        chapters: const [
          Chapter(number: 1, title: 'سورۃ الانفال', pageStart: 1, pageEnd: 40),
          Chapter(number: 2, title: 'حدیث مبارکہ (1 تا 10)', pageStart: 41, pageEnd: 70),
          Chapter(number: 3, title: 'موضوعاتی مطالعہ: قرآن مجید کا تعارف', pageStart: 71, pageEnd: 100),
        ],
      ),
      Book(
        id: 'c9_pak_studies',
        title: 'Mutalia-e-Pakistan IX',
        titleUrdu: 'مطالعہ پاکستان جماعت نہم',
        subject: 'Pakistan Studies',
        classNumber: 9,
        group: 'Compulsory',
        fileSize: '16.5 MB',
        pagesCount: 160,
        coverGradientStart: const Color(0xFF1B5E20),
        coverGradientEnd: const Color(0xFF2E7D32),
        icon: Icons.flag_rounded,
        curriculumYear: '2024–25',
        isDownloaded: false,
        chapters: const [
          Chapter(number: 1, title: 'Ideological Basis of Pakistan', pageStart: 1, pageEnd: 30),
          Chapter(number: 2, title: 'Making of Pakistan (1940-1947)', pageStart: 31, pageEnd: 68),
          Chapter(number: 3, title: 'Land and Environment', pageStart: 69, pageEnd: 110),
        ],
      ),
      Book(
        id: 'c9_general_science',
        title: 'General Science IX (Arts)',
        titleUrdu: 'جنرل سائنس برائے جماعت نہم (آرٹس)',
        subject: 'General Science',
        classNumber: 9,
        group: 'Arts',
        fileSize: '16.1 MB',
        pagesCount: 172,
        coverGradientStart: const Color(0xFFBF360C),
        coverGradientEnd: const Color(0xFFD84315),
        icon: Icons.psychology_rounded,
        curriculumYear: '2024–25',
        isDownloaded: false,
        chapters: const [
          Chapter(number: 1, title: 'Introduction and Role of Science', pageStart: 1, pageEnd: 28),
          Chapter(number: 2, title: 'Our Life and Chemistry', pageStart: 29, pageEnd: 60),
          Chapter(number: 3, title: 'Biochemistry and Biotechnology', pageStart: 61, pageEnd: 92),
        ],
      ),
      Book(
        id: 'c9_general_math',
        title: 'General Mathematics IX (Arts)',
        titleUrdu: 'جنرل ریاضی برائے جماعت نہم',
        subject: 'General Math',
        classNumber: 9,
        group: 'Arts',
        fileSize: '18.9 MB',
        pagesCount: 220,
        coverGradientStart: const Color(0xFF3E2723),
        coverGradientEnd: const Color(0xFF5D4037),
        icon: Icons.percent_rounded,
        curriculumYear: '2024–25',
        isDownloaded: false,
        chapters: const [
          Chapter(number: 1, title: 'Percentage, Ratio and Proportion', pageStart: 1, pageEnd: 36),
          Chapter(number: 2, title: 'Zakat, Ushr and Inheritance', pageStart: 37, pageEnd: 64),
          Chapter(number: 3, title: 'Business Mathematics', pageStart: 65, pageEnd: 96),
        ],
      ),
      Book(
        id: 'c10_physics',
        title: 'Physics for Class X',
        titleUrdu: 'طبیعیات برائے جماعت دہم',
        subject: 'Physics',
        classNumber: 10,
        group: 'Science',
        fileSize: '20.2 MB',
        pagesCount: 210,
        coverGradientStart: const Color(0xFF005129),
        coverGradientEnd: const Color(0xFF0B8F55),
        icon: Icons.electric_bolt_rounded,
        curriculumYear: '2024–25',
        isDownloaded: false,
      ),
      Book(
        id: 'c10_maths',
        title: 'Mathematics Class X (Science)',
        titleUrdu: 'ریاضی برائے جماعت دہم',
        subject: 'Mathematics',
        classNumber: 10,
        group: 'Science',
        fileSize: '34.5 MB',
        pagesCount: 340,
        coverGradientStart: const Color(0xFF0D47A1),
        coverGradientEnd: const Color(0xFF1976D2),
        icon: Icons.calculate_rounded,
        curriculumYear: '2024–25',
        isDownloaded: false,
      ),
    ];
  }

  List<Book> get booksForSelectedClass {
    return _allBooks.where((b) {
      if (b.classNumber != _selectedClass) return false;
      if (_selectedLibraryTab == 'All') return true;
      return b.group.toLowerCase() == _selectedLibraryTab.toLowerCase();
    }).toList();
  }

  List<Book> get downloadedBooks {
    return _allBooks.where((b) => b.isDownloaded).toList();
  }

  List<Book> get activeDownloadingBooks {
    return _allBooks.where((b) => b.isDownloading).toList();
  }

  List<Book> get recentReads {
    return _allBooks.where((b) => b.lastReadPage > 1).toList();
  }

  List<Book> searchBooks(String query) {
    if (query.trim().isEmpty) return [];
    final q = query.trim().toLowerCase();
    return _allBooks.where((b) {
      return b.title.toLowerCase().contains(q) ||
          b.subject.toLowerCase().contains(q) ||
          b.titleUrdu.contains(q) ||
          'class ${b.classNumber}'.contains(q) ||
          b.group.toLowerCase().contains(q);
    }).toList();
  }

  void setSelectedClass(int classNum) {
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

  void setLanguage(String lang) {
    _currentLanguage = lang;
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

  void toggleLowData(bool val) {
    _lowDataMode = val;
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

