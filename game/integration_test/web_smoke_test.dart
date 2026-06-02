import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tower_defense/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Simple smoke test for web - verifies basic app functionality
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('MG-0001 Web Smoke Test', () {
    testWidgets('Web app loads and displays main menu', (tester) async {
      // Skip tutorial for smoke test
      SharedPreferences.setMockInitialValues({'onboarding_tutorial_completed': true});

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify main menu loads
      expect(find.byKey(const ValueKey('game-id')), findsOneWidget);
      expect(find.text('MG-0001'), findsOneWidget);
      expect(find.text('Simple Tower Defense'), findsOneWidget);

      print('✅ Web smoke test: App loads successfully');
      print('✅ Main menu displayed correctly');
    });

    testWidgets('Web navigation works', (tester) async {
      SharedPreferences.setMockInitialValues({'onboarding_tutorial_completed': true});

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Test game start
      await tester.tap(find.byKey(const ValueKey('start-game')));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.text('Live Run'), findsOneWidget);
      print('✅ Game navigation works');

      // Return to menu
      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('game-id')), findsOneWidget);
      print('✅ Navigation back to menu works');
    });

    testWidgets('Web responsive design elements present', (tester) async {
      SharedPreferences.setMockInitialValues({'onboarding_tutorial_completed': true});

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Check for key UI elements
      expect(find.byType(Scaffold), findsWidgets);
      expect(find.byType(Column), findsWidgets);
      print('✅ Responsive layout structure present');
    });
  });
}
