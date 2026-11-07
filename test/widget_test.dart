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

  testWidgets('OfflineSyncBanner renders status and description', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: OfflineSyncBanner(),
        ),
      ),
    );

    expect(find.text('Offline-First Enabled • Village Study Mode Ready'), findsOneWidget);
    expect(find.text('No internet needed'), findsOneWidget);
    expect(find.byIcon(Icons.offline_pin_rounded), findsOneWidget);
  });

  group('AppState business logic unit tests', () {
    test('Default state initializes correctly for KPK curriculum', () {
      final state = AppState();
      expect(state.selectedClass, equals(9));
      expect(state.currentLanguage, equals('en'));
      expect(state.booksForSelectedClass.isNotEmpty, isTrue);
      expect(state.unreadNotificationCount, greaterThan(0));
    });

    test('Class selection filters books for the targeted grade', () {
      final state = AppState();
      state.setSelectedClass(10);
      expect(state.selectedClass, equals(10));
      for (final book in state.booksForSelectedClass) {
        expect(book.classNumber, equals(10));
      }
    });

    test('Search query correctly matches textbook titles', () {
      final state = AppState();
      state.setSearchQuery('Physics');
      expect(state.searchQuery, equals('Physics'));
      final results = state.searchBooks('Physics');
      expect(results.isNotEmpty, isTrue);
      expect(results.first.title.toLowerCase().contains('physics'), isTrue);
    });

    test('Notification unread count updates when marked as read', () {
      final state = AppState();
      expect(state.unreadNotificationCount, greaterThan(0));
      state.markAllNotificationsAsRead();
      expect(state.unreadNotificationCount, equals(0));
    });

    test('Book bookmark toggles state correctly', () {
      final state = AppState();
      final book = state.booksForSelectedClass.first;
      final wasBookmarked = book.isBookmarked;
      state.toggleBookmark(book);
      expect(book.isBookmarked, equals(!wasBookmarked));
    });
  });

  group('CustomAppBar UI & Back Button tests', () {
    testWidgets('CustomAppBar renders title, subtitle and tag without overflow', (WidgetTester tester) async {
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
                title: 'Offline Shelf',
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
