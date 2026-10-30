import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:kp_book/main.dart';
import 'package:kp_book/providers/app_state.dart';

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

    // Initial frame on splash screen
    expect(find.text('KPK E-Textbooks'), findsOneWidget);

    // Fast-forward past the splash timer and animations
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    // Verify main shell home screen is rendered
    expect(find.text('Home'), findsWidgets);
  });
}
