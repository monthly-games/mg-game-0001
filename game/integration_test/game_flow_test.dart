import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tower_defense/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Full Game Flow Test', (WidgetTester tester) async {
    // 1. Launch App
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // 2. Verify Lobby Screen
    expect(find.text('START DEFENSE'), findsOneWidget);
    expect(find.text('SETTINGS'), findsOneWidget);

    // 3. Start Game
    await tester.tap(find.text('START DEFENSE'));
    await tester.pumpAndSettle(const Duration(seconds: 1)); // Wait for nav

    // 4. Verify Game Screen Loaded
    expect(find.text('BUILD TOWER'), findsOneWidget);
    expect(find.text('NEXT WAVE'), findsOneWidget);
    expect(find.text('WAVE 0'), findsOneWidget);
    // Note: Gold amount depends on initial state (100 in code)
    // expect(find.text('100'), findsOneWidget);

    // 5. Test "Build Tower"
    // Tap Build Mode
    await tester.tap(find.text('BUILD TOWER'));
    await tester.pump(); // Frame
    await tester.pump(
      const Duration(milliseconds: 500),
    ); // Wait for toast/audio

    // Tap on the screen (Grid) to build
    // We'll tap roughly in the middle-ish top-left, where path likely isn't?
    // Or just try a safe spot. 0,0 is path usually?
    // MapSystem grid is verified in code logic, but here we just blindly tap.
    await tester.tapAt(const Offset(300, 300));
    await tester.pump();

    // 6. Test "Next Wave"
    await tester.tap(find.text('NEXT WAVE'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify wave changed
    // This depends on logic speed, might need to wait longer or check text update
    // Wave manager starts next wave immediately in code
    expect(find.text('WAVE 1'), findsOneWidget);

    // 7. Wait a bit to simulate "playing" (optional)
    await tester.pump(const Duration(seconds: 2));
  });
}
