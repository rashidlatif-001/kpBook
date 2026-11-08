import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:kp_book/main.dart';
import 'package:kp_book/providers/app_state.dart';
import 'package:kp_book/widgets/custom_app_bar.dart';
import 'package:kp_book/widgets/offline_sync_banner.dart';

void main() {
  testWidgets('KPK E-Textbooks app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppState()),
        ],
        child: const KpkETextbooksApp(),
      ),
    );

    // Initial frame on splash screen renders KPK branding elements
    expect(find.text('KPK E-Textbooks'), findsOneWidget);
    expect(find.text('خیبر پختونخوا ای-ٹیکسٹ بکس'), findsOneWidget);
    expect(find.text('Tap to Enter'), findsOneWidget);
  });

  testWidgets('OfflineSyncBanner renders status banner with state', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppState()),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: OfflineSyncBanner(),
          ),
        ),
      ),
    );

    // Banner renders either Online or Offline mode
    expect(
      find.byWidgetPredicate((w) =>
          w is Text &&
          (w.data?.contains('Online • Live Cloud Sync Active') == true ||
              w.data?.contains('Offline Mode • Studying Without Internet') == true)),
      findsOneWidget,
    );
  });

  group('AppState business logic unit tests', () {
    test('Default state initializes correctly: No class selected by default', () {
      final state = AppState();
      expect(state.selectedClass, isNull);
      expect(state.hasSelectedClass, isFalse);
      expect(state.booksForSelectedClass.isEmpty, isTrue);
      expect(state.currentLanguage, equals('en'));
      expect(state.unreadNotificationCount, greaterThan(0));
    });

    test('Class selection filters books for the targeted grade', () {
      final state = AppState();
      state.setSelectedClass(10);
      expect(state.selectedClass, equals(10));
      expect(state.hasSelectedClass, isTrue);
      for (final book in state.booksForSelectedClass) {
        expect(book.classNumber, equals(10));
      }
    });

    test('Search query with class and type filters matches accurately', () {
      final state = AppState();
      final results = state.searchBooksWithFilters(
        query: 'Physics',
        classFilter: 9,
        typeFilter: 'Books',
      );
      expect(results.isNotEmpty, isTrue);
      expect(results.first.classNumber, equals(9));
      expect(results.first.isGuide, isFalse);
    });

    test('Search type filter correctly isolates Guides', () {
      final state = AppState();
      final guides = state.searchBooksWithFilters(
        query: 'Guide',
        classFilter: 9,
        typeFilter: 'Guides',
      );
      expect(guides.isNotEmpty, isTrue);
      expect(guides.first.isGuide, isTrue);
    });

    test('Resume reading tracks exact last read page accurately', () {
      final state = AppState();
      state.setSelectedClass(9);
      final book = state.booksForSelectedClass.first;
      state.updateLastReadPage(book, 45);
      expect(state.lastReadBook?.lastReadPage, equals(45));
    });

    test('Notification unread count updates when marked as read', () {
      final state = AppState();
      expect(state.unreadNotificationCount, greaterThan(0));
      state.markAllNotificationsAsRead();
      expect(state.unreadNotificationCount, equals(0));
    });

    test('Clear temporary cache and downloads empties offline shelf and returns freed MB', () async {
      final state = AppState();
      final freed = await state.clearAllCacheAndDownloads();
      expect(freed, greaterThan(0));
      expect(state.downloadedBooks.isEmpty, isTrue);
    });
  });

  group('CustomAppBar UI & Back Button tests', () {
    testWidgets('CustomAppBar renders title, subtitle, tag, and profile avatar', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AppState()),
          ],
          child: const MaterialApp(
            home: Scaffold(
              appBar: CustomAppBar(
                title: 'Class 10 Library',
                subtitle: 'Official KPK Textbook Board Collection',
                tag: 'Class 10',
                showBackButton: true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Class 10 Library'), findsOneWidget);
      expect(find.text('Official KPK Textbook Board Collection'), findsOneWidget);
      expect(find.text('CLASS 10'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    });

    testWidgets('CustomAppBar back button triggers callback properly', (WidgetTester tester) async {
      bool backPressed = false;
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AppState()),
          ],
          child: MaterialApp(
            home: Scaffold(
              appBar: CustomAppBar(
                title: 'Offline Mode',
                tag: 'Offline',
                showBackButton: true,
                onBackPressed: () {
                  backPressed = true;
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pump();
      expect(backPressed, isTrue);
    });
  });
}
