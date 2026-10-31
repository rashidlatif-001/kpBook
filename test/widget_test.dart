import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:kp_book/main.dart';
import 'package:kp_book/providers/app_state.dart';
import 'package:kp_book/screens/main_shell.dart';

void main() {
  setUpAll(() {
    // Disable runtime font fetching to ensure reliable execution in offline/CI environments
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('KPK E-Textbooks splash screen loads and transitions', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppState()),
        ],
        child: const KpkETextbooksApp(),
      ),
    );

    // Initial frame on splash screen
    expect(find.text('KPK E-Textbooks'), findsOneWidget);
    expect(find.text('Tap to Enter'), findsOneWidget);

    // Tap to enter main shell
    await tester.tap(find.text('Tap to Enter'));
    await tester.pumpAndSettle();

    // Verify main shell home screen is rendered
    expect(find.text('Select Class (1 to 12)'), findsOneWidget);
  });

  testWidgets('KPK E-Textbooks MainShell renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppState()),
        ],
        child: const MaterialApp(
          home: MainShell(),
        ),
      ),
    );

    // Verify Home screen content
    expect(find.text('Select Class (1 to 12)'), findsOneWidget);
  });
}
