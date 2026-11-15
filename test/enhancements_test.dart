import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kp_book/providers/app_state.dart';
import 'package:kp_book/theme/app_colors.dart';
import 'package:kp_book/screens/class_screen.dart';
import 'package:kp_book/screens/home_screen.dart';
import 'package:kp_book/screens/auth/login_screen.dart';
import 'package:kp_book/screens/auth/forgot_password_screen.dart';
import 'package:kp_book/screens/content_selection_screen.dart';
import 'package:kp_book/screens/pdf_reader_screen.dart';
import 'package:kp_book/models/notification_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('1. Dark Mode UI & Persistence Tests', () {
    test('Theme preference initializes from SharedPreferences and updates dynamic AppColors', () async {
      SharedPreferences.setMockInitialValues({'is_dark_mode': true});
      final state = AppState();
      await Future.delayed(const Duration(milliseconds: 50));

      expect(state.isDarkMode, isTrue);
      expect(AppColors.isDark, isTrue);
      expect(AppColors.surface, equals(AppColors.darkSurface));
      expect(AppColors.onSurface, equals(AppColors.darkOnSurface));

      state.toggleDarkMode(false);
      expect(state.isDarkMode, isFalse);
      expect(AppColors.isDark, isFalse);
      expect(AppColors.surface, equals(AppColors.lightSurface));
      expect(AppColors.onSurface, equals(AppColors.lightOnSurface));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('is_dark_mode'), isFalse);
    });
  });

  group('2. Class & Book Navigation Flow Tests', () {
    testWidgets('Home Screen displays class selector and NO book lists', (WidgetTester tester) async {
      final state = AppState();
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: state),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      // Verify Class Selection header is present
      expect(find.text('Select Class (1 to 12)'), findsOneWidget);

      // Verify Classes 1 through 12 are available in the grid
      expect(find.text('9'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);

      // Verify that the old book listings ("Curriculum Books" / "Official KP Textbooks") are removed from HomeScreen
      expect(find.text('Curriculum Books'), findsNothing);
      expect(find.text('Official KP Textbooks'), findsNothing);
    });

    test('AppState isolates books strictly by selected class', () {
      final state = AppState();

      final class9Books = state.getBooksForClass(9);
      expect(class9Books.isNotEmpty, isTrue);
      for (final book in class9Books) {
        expect(book.classNumber, equals(9));
      }

      final class10Books = state.getBooksForClass(10);
      expect(class10Books.isNotEmpty, isTrue);
      for (final book in class10Books) {
        expect(book.classNumber, equals(10));
      }
    });

    testWidgets('ClassScreen shows only books belonging to that class with filters', (WidgetTester tester) async {
      final state = AppState();
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: state),
          ],
          child: const MaterialApp(
            home: ClassScreen(classNumber: 9),
          ),
        ),
      );

      // Title shows Class 9 Books
      expect(find.text('Class 9 Books'), findsOneWidget);
      expect(find.text('Textbooks'), findsOneWidget);
      expect(find.text('Study Guides'), findsOneWidget);

      // Verify Physics Class 9 appears
      expect(find.text('Physics for Class IX'), findsOneWidget);

      // Filter by Study Guides
      await tester.tap(find.text('Study Guides'));
      await tester.pumpAndSettle();

      // Non-guide textbook shouldn't appear
      expect(find.text('Physics for Class IX'), findsNothing);
      expect(find.text('Physics IX Key Book & Solved SLO Guide'), findsOneWidget);
    });
  });

  group('3. Start Reading and Reading Progress Tests', () {
    test('First visit starts from beginning, next visit resumes from exact page', () async {
      final state = AppState();
      final book = state.allBooks.firstWhere((b) => b.id == 'c9_chemistry');
      book.lastReadPage = 0;

      // First time reading
      expect(book.hasStartedReading, isFalse);
      expect(book.lastReadPage, equals(0));

      // User reads to page 25
      state.updateReadingProgress(book, 25);
      expect(book.hasStartedReading, isTrue);
      expect(book.lastReadPage, equals(25));

      // Reset progress explicitly restarts
      state.restartBookReading(book);
      expect(book.lastReadPage, equals(1));
    });

    testWidgets('ContentSelectionScreen shows Start Reading on first visit and Resume Reading after reading', (WidgetTester tester) async {
      final state = AppState();
      final book = state.allBooks.firstWhere((b) => b.id == 'c9_physics');
      book.lastReadPage = 0;

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: state),
          ],
          child: MaterialApp(
            home: ContentSelectionScreen(book: book),
          ),
        ),
      );

      // First time: Start Reading Textbook
      expect(find.text('Start Reading Textbook'), findsOneWidget);

      // Simulate reading progress update
      state.updateReadingProgress(book, 34);
      await tester.pumpAndSettle();

      // Next visit: Resume Reading button
      expect(find.textContaining('Resume Pg 34'), findsOneWidget);
    });
  });

  group('4. Complete Book Download Functionality Tests', () {
    test('Complete book download downloads all units into book-specific folder structure', () async {
      final state = AppState();
      final book = state.allBooks.firstWhere((b) => b.id == 'c9_biology');
      book.isDownloaded = false;
      book.downloadProgress = 0.0;

      expect(book.isDownloaded, isFalse);

      // Write book units to disk and generate manifest
      await state.writeBookUnitsToDisk(book);

      // Check folder structure and manifest file
      final bookDir = await state.getBookDirectory(book);
      expect(await bookDir.exists(), isTrue);

      final manifestFile = File('${bookDir.path}/manifest.json');
      expect(await manifestFile.exists(), isTrue);
      final manifestContent = await manifestFile.readAsString();
      expect(manifestContent.contains(book.title), isTrue);
      expect(manifestContent.contains('totalUnits'), isTrue);

      // Check unit directories
      for (final chapter in book.chapters) {
        final unitDir = Directory('${bookDir.path}/Unit_${chapter.number.toString().padLeft(2, '0')}');
        expect(await unitDir.exists(), isTrue);
      }
    });
  });

  group('5. Unit-Wise Book Reading Structure Tests', () {
    test('Book is divided into sequential chapters with page counts and numbers', () {
      final state = AppState();
      final book = state.allBooks.firstWhere((b) => b.id == 'c9_physics');

      expect(book.chapters.isNotEmpty, isTrue);
      for (int i = 0; i < book.chapters.length; i++) {
        expect(book.chapters[i].number, equals(i + 1));
      }
    });

    testWidgets('PdfReaderScreen renders unit navigation and tracks unit progress', (WidgetTester tester) async {
      final state = AppState();
      final book = state.allBooks.firstWhere((b) => b.id == 'c9_physics');

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: state),
          ],
          child: MaterialApp(
            home: PdfReaderScreen(
              book: book,
              initialPage: 1,
            ),
          ),
        ),
      );

      // Unit title and header
      expect(find.text(book.title), findsOneWidget);
      expect(find.textContaining('Unit 1:'), findsWidgets);
      expect(find.text('Next Unit'), findsOneWidget);

      // Tap Next Unit
      await tester.tap(find.text('Next Unit'));
      await tester.pumpAndSettle();

      // Should now be on Unit 2
      expect(find.textContaining('Unit 2:'), findsWidgets);
      expect(find.text('Prev Unit'), findsOneWidget);
    });
  });

  group('6. Splash Screen & Post-Splash Screen UI Tests', () {
    testWidgets('LoginScreen is properly centered and responsive', (WidgetTester tester) async {
      final state = AppState();
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: state),
          ],
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      // Verify main content
      expect(find.text('KPK E-Textbooks'), findsOneWidget);
      expect(find.text('Sign In (لاگ ان)'), findsOneWidget);
      expect(find.text('Email Address / ای میل'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
    });
  });

  group('7. Forgot Password Flow Tests', () {
    testWidgets('ForgotPasswordScreen renders input step and handles email entry', (WidgetTester tester) async {
      final state = AppState();
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: state),
          ],
          child: const MaterialApp(
            home: ForgotPasswordScreen(initialEmail: 'student@example.com'),
          ),
        ),
      );

      // Initial step: Forgot Password with email
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Send Recovery Code'), findsOneWidget);
    });
  });

  group('8. Dynamic Home Banner Announcements Tests', () {
    testWidgets('HomeScreen renders default banner when no admin notice is active', (WidgetTester tester) async {
      final appState = AppState();

      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      // Default Banner
      expect(find.text('Mid-term Exams Preparation Guide'), findsOneWidget);
      expect(find.text('Curriculum 2024–25'), findsOneWidget);
      expect(find.textContaining('Complete syllabus & model papers'), findsOneWidget);
    });

    testWidgets('HomeScreen dynamically updates banner when Admin Dashboard notice is published', (WidgetTester tester) async {
      final appState = AppState();

      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      // Simulate Admin broadcasting a new urgent notice
      appState.setActiveBannerNotice(
        NotificationItem(
          id: 'admin_broadcast_101',
          title: 'Annual Board Exam 2025 Schedule Live',
          message: 'Official SLO guidelines and solved model questions are now published for all KPK students.',
          timestamp: 'Just now',
          actionLabel: 'Exam Alert 2025',
          relatedClass: 9,
          type: NotificationType.systemNotice,
          isRead: false,
        ),
      );

      await tester.pump();

      // Verify that the Home Banner dynamically reflects the admin notice!
      expect(find.text('Annual Board Exam 2025 Schedule Live'), findsOneWidget);
      expect(find.text('Exam Alert 2025'), findsOneWidget);
      expect(find.text('LIVE NOTICE'), findsOneWidget);
      expect(find.textContaining('Official SLO guidelines and solved model questions'), findsOneWidget);
    });
  });
}
