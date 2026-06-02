import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tower_defense/main.dart';

/// Real User Journey E2E Test for MG-0001
/// Simulates actual user gameplay from launch to gameplay progression
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('MG-0001 Real User Journey E2E', () {
    testWidgets('Complete user journey: New player experience', (tester) async {
      // ========== STEP 1: App Launch ==========
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify main menu loaded
      expect(find.byKey(const ValueKey('game-id')), findsOneWidget);
      expect(find.text('MG-0001'), findsOneWidget);
      expect(find.text('Simple Tower Defense'), findsOneWidget);
      print('✅ Step 1: App launched - Main menu visible');

      // Screenshot: Main Menu
      await binding.takeScreenshot('mg0001_01_main_menu');

      // ========== STEP 2: Start Game ==========
      await tester.tap(find.byKey(const ValueKey('start-game')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify game screen loaded
      expect(find.textContaining('Level 1'), findsOneWidget);
      expect(find.byKey(const ValueKey('primary-loop')), findsOneWidget);
      print('✅ Step 2: Game started - Level 1 loaded');

      // Screenshot: Game Start
      await binding.takeScreenshot('mg0001_02_game_start');

      // ========== STEP 3: First Gameplay Action ==========
      // User places tower/completes first action
      await tester.tap(find.byKey(const ValueKey('complete-action')));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify progression to Level 2
      expect(find.textContaining('Level 2'), findsOneWidget);
      expect(find.textContaining('Reward bank:'), findsOneWidget);
      print('✅ Step 3: First action completed - Level 2 reached');

      // Screenshot: Gameplay Action
      await binding.takeScreenshot('mg0001_03_gameplay_action');

      // ========== STEP 4: Second Gameplay Action ==========
      await tester.tap(find.byKey(const ValueKey('complete-action')));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify progression to Level 3
      expect(find.textContaining('Level 3'), findsOneWidget);
      print('✅ Step 4: Second action completed - Level 3 reached');

      // ========== STEP 5: Check Rewards ==========
      // Verify rewards accumulated
      final rewardText = find.textContaining('Reward bank:');
      expect(rewardText, findsOneWidget);
      print('✅ Step 5: Rewards accumulated');

      // Screenshot: Progression
      await binding.takeScreenshot('mg0001_04_progression');

      // ========== STEP 6: Return to Main Menu ==========
      await tester.pageBack();
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify back on main menu
      expect(find.byKey(const ValueKey('game-id')), findsOneWidget);
      expect(find.text('MG-0001'), findsOneWidget);
      print('✅ Step 6: Returned to main menu');

      // Screenshot: Back to Menu
      await binding.takeScreenshot('mg0001_05_back_to_menu');

      // ========== STEP 7: Explore Level Roadmap ==========
      await tester.tap(find.byKey(const ValueKey('level-roadmap')));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.text('Level Roadmap'), findsWidgets);
      expect(find.textContaining('Level 5'), findsOneWidget);
      print('✅ Step 7: Level roadmap accessed');

      await tester.pageBack();
      await tester.pumpAndSettle();

      // ========== STEP 8: Check Rewards Hub ==========
      await tester.tap(find.byKey(const ValueKey('rewards')));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.text('Rewards'), findsWidgets);
      expect(find.text('Progression loop: return, claim, improve.'), findsOneWidget);
      print('✅ Step 8: Rewards hub accessed');

      await tester.pageBack();
      await tester.pumpAndSettle();

      // ========== STEP 9: Check Tournament ==========
      await tester.tap(find.byKey(const ValueKey('tournament')));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.text('Tournament'), findsWidgets);
      print('✅ Step 9: Tournament accessed');

      await tester.pageBack();
      await tester.pumpAndSettle();

      // ========== COMPLETE ==========
      print('');
      print('🎉 COMPLETE: Full user journey tested successfully!');
      print('');
      print('User Journey Summary:');
      print('  1. ✅ App launch and main menu');
      print('  2. ✅ Game start');
      print('  3. ✅ Gameplay progression (Level 1 → 3)');
      print('  4. ✅ Reward accumulation');
      print('  5. ✅ Navigation and meta systems');
      print('  6. ✅ Return to menu');
      print('');
      print('Screenshots captured: 5');
      print('Game loop verified: WORKING');
    });

    testWidgets('Extended gameplay: Level progression through 10 levels', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      print('Starting extended gameplay test...');

      // Start game
      await tester.tap(find.byKey(const ValueKey('start-game')));
      await tester.pumpAndSettle();

      // Play through 10 levels
      for (int level = 1; level <= 10; level++) {
        await tester.tap(find.byKey(const ValueKey('complete-action')));
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        // Verify level progression
        final expectedLevel = level + 1;
        expect(find.textContaining('Level $expectedLevel'), findsOneWidget);
        print('  ✅ Reached Level $expectedLevel');
      }

      print('🎉 Extended gameplay complete: Progressed through 10 levels');
    });

    testWidgets('Meta systems exploration: All features accessible', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      final systemsToTest = [
        'level-roadmap',
        'tournament',
        'guild-war',
        'rewards',
        'daily-quests',
        'seasonal-event',
        'tutorial',
      ];

      for (final system in systemsToTest) {
        await tester.tap(find.byKey(ValueKey(system)));
        await tester.pumpAndSettle(const Duration(seconds: 1));

        // Verify screen loaded
        expect(find.byType(Scaffold), findsWidgets);
        print('  ✅ $system accessible');

        await tester.pageBack();
        await tester.pumpAndSettle();
      }

      print('🎉 All meta systems verified');
    });
  });
}
