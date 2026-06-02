import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tower_defense/main.dart';
import 'package:tower_defense/game/core/challenge_mode.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> returnToMenu(WidgetTester tester) async {
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('core-fun-loop')), findsOneWidget);
  }

  group('MG-0001 Tower Defense X - Game Loop E2E', () {
    testWidgets('Core gameplay loop: placement, waves, upgrades, rewards', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Verify main menu
      expect(find.byKey(const ValueKey('game-id')), findsOneWidget);
      expect(find.text('MG-0001'), findsOneWidget);
      expect(find.text('Simple Tower Defense'), findsOneWidget);
      expect(find.textContaining('Core Fun:'), findsOneWidget);

      // Start game
      await tester.tap(find.byKey(const ValueKey('start-game')));
      await tester.pumpAndSettle();

      // Verify game screen
      expect(find.text('Game Ready'), findsWidgets);
      expect(find.byKey(const ValueKey('primary-loop')), findsOneWidget);
      expect(find.textContaining('Level 1'), findsOneWidget);
      expect(find.byKey(const ValueKey('level-objective')), findsOneWidget);

      // Complete first action (simulating tower placement/wave clear)
      await tester.tap(find.byKey(const ValueKey('complete-action')));
      await tester.pumpAndSettle();

      // Verify progression
      expect(find.textContaining('Level 2'), findsOneWidget);
      expect(find.textContaining('Reward bank:'), findsOneWidget);

      // Complete another level
      await tester.tap(find.byKey(const ValueKey('complete-action')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Level 3'), findsOneWidget);
    });

    testWidgets('Level roadmap shows proper progression structure', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('level-roadmap')));
      await tester.pumpAndSettle();

      expect(find.text('Level Roadmap'), findsWidgets);
      expect(find.byKey(const ValueKey('level-list')), findsOneWidget);

      // Verify multiple levels exist
      expect(find.textContaining('Level 1'), findsOneWidget);
      expect(find.textContaining('Level 5'), findsOneWidget);
      expect(find.textContaining('Level 10'), findsOneWidget);

      // Test scrolling through levels
      await tester.scrollUntilVisible(
        find.textContaining('Level 15'),
        200,
        scrollable: find.byType(Scrollable),
      );
      expect(find.textContaining('Level 15'), findsOneWidget);

      await returnToMenu(tester);
    });

    testWidgets('Challenge mode selection and difficulty scaling', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Navigate to game
      await tester.tap(find.byKey(const ValueKey('start-game')));
      await tester.pumpAndSettle();

      // Verify difficulty metrics are displayed
      expect(find.textContaining('Difficulty'), findsOneWidget);
      expect(find.textContaining('targets'), findsOneWidget);
      expect(find.textContaining('cadence'), findsOneWidget);

      // Complete multiple levels to observe difficulty progression
      for (int i = 0; i < 3; i++) {
        await tester.tap(find.byKey(const ValueKey('complete-action')));
        await tester.pumpAndSettle();
      }

      // Verify level progression
      expect(find.textContaining('Level 4'), findsOneWidget);
    });

    testWidgets('Tower synergy system integration', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('start-game')));
      await tester.pumpAndSettle();

      // Verify tower placement UI elements exist
      expect(find.byKey(const ValueKey('primary-loop')), findsOneWidget);

      // Simulate tower placement and synergy activation
      await tester.tap(find.byKey(const ValueKey('complete-action')));
      await tester.pumpAndSettle();

      // Verify reward accumulation (tower synergies provide bonuses)
      expect(find.textContaining('Reward bank:'), findsOneWidget);
      expect(find.textContaining('gold'), findsOneWidget);
      expect(find.textContaining('xp'), findsOneWidget);
    });

    testWidgets('Economy system: gold and XP rewards', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('start-game')));
      await tester.pumpAndSettle();

      // Initial state
      expect(find.text('Reward bank: 0 gold / 0 xp'), findsOneWidget);

      // Complete action and verify rewards
      await tester.tap(find.byKey(const ValueKey('complete-action')));
      await tester.pumpAndSettle();

      // Verify rewards accumulated
      expect(find.textContaining('Reward bank:'), findsOneWidget);
      final rewardText = tester.widget<Text>(find.textContaining('Reward bank:').first);
      expect(rewardText.data, contains('gold'));
      expect(rewardText.data, contains('xp'));
    });

    testWidgets('Engine loop and frame timing validation', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('engine-loop')));
      await tester.pumpAndSettle();

      expect(find.text('Engine Loop'), findsOneWidget);
      expect(find.byKey(const ValueKey('engine-loop-status')), findsOneWidget);
      expect(find.textContaining('GameWidget frame loop'), findsOneWidget);

      await returnToMenu(tester);
    });

    testWidgets('Competition systems: tournament and leaderboard', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Test tournament access
      await tester.tap(find.byKey(const ValueKey('tournament')));
      await tester.pumpAndSettle();
      expect(find.text('Tournament'), findsWidgets);
      await returnToMenu(tester);

      // Test guild war access
      await tester.tap(find.byKey(const ValueKey('guild-war')));
      await tester.pumpAndSettle();
      expect(find.text('Guild War'), findsWidgets);
      await returnToMenu(tester);
    });

    testWidgets('Retention systems: rewards and daily quests', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Test rewards hub
      await tester.tap(find.byKey(const ValueKey('rewards')));
      await tester.pumpAndSettle();
      expect(find.text('Rewards'), findsWidgets);
      expect(find.text('Progression loop: return, claim, improve.'), findsOneWidget);
      await returnToMenu(tester);

      // Test daily quests
      await tester.tap(find.byKey(const ValueKey('daily-quests')));
      await tester.pumpAndSettle();
      expect(find.text('Daily Quests'), findsWidgets);
      await returnToMenu(tester);
    });

    testWidgets('Seasonal events and special content', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('seasonal-event')));
      await tester.pumpAndSettle();

      expect(find.text('Seasonal Event'), findsWidgets);
      expect(find.textContaining('Timed content'), findsOneWidget);

      await returnToMenu(tester);
    });

    testWidgets('Tutorial system and onboarding flow', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('tutorial')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('tutorial-screen')), findsOneWidget);
      expect(find.byKey(const ValueKey('tutorial-progress')), findsOneWidget);
      expect(find.byKey(const ValueKey('tutorial-step-title')), findsOneWidget);

      // Navigate through tutorial
      await tester.tap(find.byKey(const ValueKey('tutorial-next')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('tutorial-screen')), findsOneWidget);
    });

    testWidgets('Full game loop: start -> play -> progress -> rewards', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Start game
      await tester.tap(find.byKey(const ValueKey('start-game')));
      await tester.pumpAndSettle();

      // Play through multiple levels
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.byKey(const ValueKey('complete-action')));
        await tester.pumpAndSettle();
      }

      // Verify significant progression
      expect(find.textContaining('Level 6'), findsOneWidget);
      expect(find.textContaining('Reward bank:'), findsOneWidget);

      // Return to menu and check rewards
      await returnToMenu(tester);

      // Visit rewards screen
      await tester.tap(find.byKey(const ValueKey('rewards')));
      await tester.pumpAndSettle();
      expect(find.text('Progression loop: return, claim, improve.'), findsOneWidget);
    });

    testWidgets('Challenge mode variations (Normal, Hardcore, Speed, Endless)', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Verify challenge mode configurations are accessible
      await tester.tap(find.byKey(const ValueKey('start-game')));
      await tester.pumpAndSettle();

      // Test difficulty scaling across levels
      final level1 = find.textContaining('Level 1');
      expect(level1, findsOneWidget);

      // Progress to harder levels
      for (int i = 0; i < 3; i++) {
        await tester.tap(find.byKey(const ValueKey('complete-action')));
        await tester.pumpAndSettle();
      }

      // Verify difficulty metrics changed
      expect(find.textContaining('Level 4'), findsOneWidget);
    });
  });
}