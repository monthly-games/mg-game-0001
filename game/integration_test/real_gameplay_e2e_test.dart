import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tower_defense/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Real Gameplay E2E Test for MG-0001
/// Simulates actual user playing the game from start to finish
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('MG-0001 Real Gameplay E2E', () {
    testWidgets('Complete gameplay session: New player to level 10', (tester) async {
      // Clear any previous tutorial completion
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('onboarding_tutorial_completed');

      // ========== STEP 1: App Launch & Tutorial ==========
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should see tutorial first
      expect(find.text('Welcome'), findsOneWidget);
      print('✅ Step 1: Tutorial started - Welcome screen');

      // Complete all tutorial steps
      for (int i = 0; i < 4; i++) {
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        final nextButton = find.byKey(const ValueKey('tutorial-next'));
        expect(nextButton, findsOneWidget);
        await tester.tap(nextButton);
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
      }
      print('✅ Step 2: Tutorial completed - All 4 steps');

      // Verify tutorial completion saved
      final completed = prefs.getBool('onboarding_tutorial_completed');
      expect(completed, true);
      print('✅ Tutorial completion saved to SharedPreferences');

      // ========== STEP 3: Main Menu ==========
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify main menu elements
      expect(find.byKey(const ValueKey('game-id')), findsOneWidget);
      expect(find.text('MG-0001'), findsOneWidget);
      expect(find.text('Simple Tower Defense'), findsOneWidget);
      expect(find.textContaining('Action → Feedback → Reward'), findsOneWidget);
      print('✅ Step 3: Main menu verified with all elements');

      // Take screenshot equivalent
      await tester.pumpAndSettle();

      // ========== STEP 4: Start Game ==========
      final startButton = find.byKey(const ValueKey('start-game'));
      expect(startButton, findsOneWidget);
      await tester.tap(startButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.textContaining('Level 1'), findsOneWidget);
      print('✅ Step 4: Game started - Level 1 loaded');

      // ========== STEP 5: Core Gameplay Loop (Play 10 levels) ==========
      for (int level = 1; level <= 10; level++) {
        // Verify current level
        expect(find.textContaining('Level $level'), findsOneWidget);
        print('  📍 Level $level: Started');

        // Complete the action
        final actionButton = find.byKey(const ValueKey('complete-action'));
        expect(actionButton, findsOneWidget);
        await tester.tap(actionButton);
        await tester.pumpAndSettle(const Duration(milliseconds: 800));

        // Verify level progression
        final nextLevel = level + 1;
        if (nextLevel <= 10) {
          expect(find.textContaining('Level $nextLevel'), findsOneWidget);
          print('  ✅ Level $level: Completed → Level $nextLevel');
        }

        // Small delay to simulate gameplay pacing
        await tester.pump(const Duration(milliseconds: 200));
      }

      print('✅ Step 5: Core gameplay loop - Progressed through 10 levels');

      // ========== STEP 6: Verify Rewards Accumulated ==========
      final rewardText = find.textContaining('Reward bank:');
      expect(rewardText, findsOneWidget);
      final rewardWidget = tester.widget<Text>(rewardText);
      print('✅ Step 6: Rewards accumulated: ${rewardWidget.data}');

      // ========== STEP 7: Return to Main Menu ==========
      await tester.pageBack();
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify back on main menu
      expect(find.byKey(const ValueKey('game-id')), findsOneWidget);
      expect(find.text('MG-0001'), findsOneWidget);
      print('✅ Step 7: Returned to main menu');

      // ========== STEP 8: Explore Level Roadmap ==========
      final roadmapButton = find.byKey(const ValueKey('level-roadmap'));
      expect(roadmapButton, findsOneWidget);
      await tester.tap(roadmapButton);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.text('Level Roadmap'), findsWidgets);
      print('✅ Step 8: Level roadmap accessed');

      await tester.pageBack();
      await tester.pumpAndSettle();

      // ========== STEP 9: Check Rewards Hub ==========
      final rewardsButton = find.byKey(const ValueKey('rewards'));
      expect(rewardsButton, findsOneWidget);
      await tester.tap(rewardsButton);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.text('Rewards'), findsWidgets);
      expect(find.text('Progression loop: return, claim, improve.'), findsOneWidget);
      print('✅ Step 9: Rewards hub accessed');

      await tester.pageBack();
      await tester.pumpAndSettle();

      // ========== STEP 10: Check Tournament ==========
      final tournamentButton = find.byKey(const ValueKey('tournament'));
      expect(tournamentButton, findsOneWidget);
      await tester.tap(tournamentButton);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.text('Tournament'), findsWidgets);
      print('✅ Step 10: Tournament accessed');

      await tester.pageBack();
      await tester.pumpAndSettle();

      // ========== COMPLETE ==========
      print('');
      print('🎉 COMPLETE: Full gameplay session tested successfully!');
      print('');
      print('Gameplay Summary:');
      print('  1. ✅ Tutorial completed (4 steps)');
      print('  2. ✅ Main menu navigation');
      print('  3. ✅ Core gameplay loop (10 levels played)');
      print('  4. ✅ Rewards accumulated');
      print('  5. ✅ Meta systems explored');
      print('  6. ✅ Return to menu');
      print('');
      print('Game Loop Verified: WORKING ✅');
      print('Action → Feedback → Reward → Progression ✅');
    });

    testWidgets('Speed run: Quick gameplay validation', (tester) async {
      // Fast test for quick validation
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Skip tutorial if present
      final skipButton = find.byKey(const ValueKey('tutorial-skip'));
      if (tester.any(skipButton)) {
        await tester.tap(skipButton);
        await tester.pumpAndSettle();
      }

      // Start game
      await tester.tap(find.byKey(const ValueKey('start-game')));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Play 3 levels
      for (int i = 0; i < 3; i++) {
        await tester.tap(find.byKey(const ValueKey('complete-action')));
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
      }

      expect(find.textContaining('Level 4'), findsOneWidget);
      print('✅ Speed run: 3 levels completed quickly');
    });
  });
}
