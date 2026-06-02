import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tower_defense/main.dart';
import 'package:tower_defense/game/level_design_config.dart';
import 'package:tower_defense/game/wave_spawn_table.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight Gameplay Verification Tests for MG-0001
/// Tests core gameplay mechanics without integration overhead
void main() {
  group('MG-0001 Gameplay Core Verification', () {
    testWidgets('CORE-001: Game loop completion - single level progression', (tester) async {
      SharedPreferences.setMockInitialValues({'onboarding_tutorial_completed': true});

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      print('\n🎮 CORE-001: Single Level Progression Test');

      // Start game
      await tester.tap(find.byKey(const ValueKey('start-game')));
      await tester.pumpAndSettle();

      // Verify Level 1 loaded
      expect(find.textContaining('Level 1'), findsOneWidget);
      print('  ✅ Level 1 loaded');

      // Scroll to make button visible and complete first level
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('complete-action')),
        500.0,
        scrollable: find.byType(Scrollable),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('complete-action')));
      await tester.pumpAndSettle();

      // Verify progression to Level 2
      expect(find.textContaining('Level 2'), findsOneWidget);
      print('  ✅ Progressed to Level 2');

      // Verify reward accumulation
      final firstLevelGold = kLevelDesign[0].goldReward;
      final firstLevelXp = kLevelDesign[0].xpReward;
      expect(find.textContaining('$firstLevelGold gold / $firstLevelXp xp'), findsOneWidget);
      print('  ✅ Rewards: $firstLevelGold gold, $firstLevelXp xp');

      print('\n🎉 CORE-001: PASSED - Core loop working');
    });

    testWidgets('CORE-002: Difficulty scaling verification - 3 levels', (tester) async {
      SharedPreferences.setMockInitialValues({'onboarding_tutorial_completed': true});

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      print('\n🎮 CORE-002: Difficulty Scaling Test');

      await tester.tap(find.byKey(const ValueKey('start-game')));
      await tester.pumpAndSettle();

      // Test first 3 levels for difficulty scaling
      for (int i = 0; i < 3; i++) {
        final level = kLevelDesign[i];
        final wave = kWaveSpawnTable[i];

        print('  Level ${level.levelIndex}:');
        print('    Difficulty: ${level.difficulty}');
        print('    Enemies: ${wave.enemyCount}');
        print('    Spawn Rate: ${wave.spawnCadenceSeconds}s');

        // Verify enemy count increases
        if (i > 0) {
          expect(wave.enemyCount, greaterThan(kWaveSpawnTable[i-1].enemyCount));
          expect(level.difficulty, greaterThan(kLevelDesign[i-1].difficulty));
        }

        await tester.scrollUntilVisible(
          find.byKey(const ValueKey('complete-action')),
          500.0,
          scrollable: find.byType(Scrollable),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('complete-action')));
        await tester.pumpAndSettle();
      }

      print('  ✅ Difficulty scales correctly across 3 levels');
      print('\n🎉 CORE-002: PASSED');
    });

    testWidgets('CORE-003: Reward economy verification', (tester) async {
      SharedPreferences.setMockInitialValues({'onboarding_tutorial_completed': true});

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      print('\n🎮 CORE-003: Reward Economy Test');

      await tester.tap(find.byKey(const ValueKey('start-game')));
      await tester.pumpAndSettle();

      // Track cumulative rewards
      int totalGold = 0;
      int totalXp = 0;

      for (int i = 0; i < 3; i++) {
        final level = kLevelDesign[i];

        await tester.scrollUntilVisible(
          find.byKey(const ValueKey('complete-action')),
          500.0,
          scrollable: find.byType(Scrollable),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('complete-action')));
        await tester.pumpAndSettle();

        totalGold += level.goldReward;
        totalXp += level.xpReward;

        print('  Level ${level.levelIndex}: +${level.goldReward} gold, +${level.xpReward} xp');
        print('    Cumulative: $totalGold gold, $totalXp xp');

        // Verify reward display matches expected
        expect(find.textContaining('$totalGold gold / $totalXp xp'), findsOneWidget);
      }

      print('  ✅ Economy system working correctly');
      print('\n🎉 CORE-003: PASSED');
    });

    testWidgets('CORE-004: Game loop pacing verification', (tester) async {
      SharedPreferences.setMockInitialValues({'onboarding_tutorial_completed': true});

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      print('\n🎮 CORE-004: Game Loop Pacing Test');

      await tester.tap(find.byKey(const ValueKey('start-game')));
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      // Measure 3 complete loops
      for (int i = 0; i < 3; i++) {
        final loopStart = stopwatch.elapsedMilliseconds;

        await tester.scrollUntilVisible(
          find.byKey(const ValueKey('complete-action')),
          500.0,
          scrollable: find.byType(Scrollable),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('complete-action')));
        await tester.pumpAndSettle();

        final loopTime = stopwatch.elapsedMilliseconds - loopStart;
        print('  Loop ${i + 1}: ${loopTime}ms');

        // Verify response time is reasonable
        expect(loopTime, lessThan(5000));
      }

      stopwatch.stop();

      print('  ✅ Game loop pacing is acceptable');
      print('\n🎉 CORE-004: PASSED');
    });

    testWidgets('CORE-005: Meta-systems accessibility verification', (tester) async {
      SharedPreferences.setMockInitialValues({'onboarding_tutorial_completed': true});

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      print('\n🎮 CORE-005: Meta-Systems Accessibility Test');

      final systems = {
        'level-roadmap': 'Level Roadmap',
        'rewards': 'Rewards',
        'daily-quests': 'Daily Quests',
        'tournament': 'Tournament',
        'guild-war': 'Guild War',
        'seasonal-event': 'Seasonal Event',
      };

      for (final entry in systems.entries) {
        await tester.tap(find.byKey(ValueKey(entry.key)));
        await tester.pumpAndSettle();

        print('  ✅ ${entry.value} accessible');

        await tester.pageBack();
        await tester.pumpAndSettle();
      }

      print('  ✅ All meta-systems accessible');
      print('\n🎉 CORE-005: PASSED');
    });

    testWidgets('CORE-006: Win condition achievability', (tester) async {
      SharedPreferences.setMockInitialValues({'onboarding_tutorial_completed': true});

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      print('\n🎮 CORE-006: Win Condition Test');

      await tester.tap(find.byKey(const ValueKey('start-game')));
      await tester.pumpAndSettle();

      // Verify complete-action button is available (win condition achievable)
      expect(find.byKey(const ValueKey('complete-action')), findsOneWidget);
      print('  ✅ Win condition button present');

      // Complete first level
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('complete-action')),
        500.0,
        scrollable: find.byType(Scrollable),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('complete-action')));
      await tester.pumpAndSettle();

      // Verify progression
      expect(find.textContaining('Level 2'), findsOneWidget);
      print('  ✅ Level completion successful');

      print('\n🎉 CORE-006: PASSED');
    });
  });

  group('MG-0001 Gameplay Data Verification', () {
    test('DATA-001: Level design configuration integrity', () {
      print('\n🎮 DATA-001: Level Design Integrity Check');

      expect(kLevelDesign.length, equals(8));
      print('  ✅ 8 levels configured');

      // Verify level progression
      for (int i = 0; i < kLevelDesign.length; i++) {
        expect(kLevelDesign[i].levelIndex, equals(i + 1));
        print('  ✅ Level ${i + 1}: ${kLevelDesign[i].stage}');
      }

      // Verify difficulty progression
      for (int i = 1; i < kLevelDesign.length; i++) {
        expect(kLevelDesign[i].difficulty, greaterThan(kLevelDesign[i-1].difficulty));
      }
      print('  ✅ Difficulty progression verified');

      // Verify reward progression
      for (int i = 1; i < kLevelDesign.length; i++) {
        expect(kLevelDesign[i].goldReward, greaterThan(kLevelDesign[i-1].goldReward));
        expect(kLevelDesign[i].xpReward, greaterThan(kLevelDesign[i-1].xpReward));
      }
      print('  ✅ Reward progression verified');

      print('\n🎉 DATA-001: PASSED');
    });

    test('DATA-002: Wave spawn table integrity', () {
      print('\n🎮 DATA-002: Wave Spawn Table Integrity Check');

      expect(kWaveSpawnTable.length, equals(8));
      print('  ✅ 8 wave configurations');

      // Verify enemy count progression
      for (int i = 1; i < kWaveSpawnTable.length; i++) {
        expect(kWaveSpawnTable[i].enemyCount, greaterThan(kWaveSpawnTable[i-1].enemyCount));
        print('  ✅ Wave ${i + 1}: ${kWaveSpawnTable[i].enemyCount} enemies (was ${kWaveSpawnTable[i-1].enemyCount})');
      }

      // Verify spawn cadence decreases (faster spawns)
      for (int i = 1; i < kWaveSpawnTable.length; i++) {
        expect(kWaveSpawnTable[i].spawnCadenceSeconds, lessThan(kWaveSpawnTable[i-1].spawnCadenceSeconds));
      }
      print('  ✅ Spawn cadence acceleration verified');

      print('\n🎉 DATA-002: PASSED');
    });

    test('DATA-003: Progression unlock sequence', () {
      print('\n🎮 DATA-003: Progression Unlock Sequence Check');

      final expectedUnlocks = [
        'tutorial complete',
        'daily quest',
        'upgrade option',
        'booster',
        'collection slot',
        'rank promotion',
        'tournament ticket',
        'season score',
      ];

      expect(kLevelDesign.length, equals(expectedUnlocks.length));

      for (int i = 0; i < kLevelDesign.length; i++) {
        expect(kLevelDesign[i].progressionUnlock, equals(expectedUnlocks[i]));
        print('  ✅ Level ${i + 1}: ${kLevelDesign[i].progressionUnlock}');
      }

      print('\n🎉 DATA-003: PASSED');
    });

    test('DATA-004: Economy balance verification', () {
      print('\n🎮 DATA-004: Economy Balance Check');

      int totalGold = 0;
      int totalXp = 0;

      for (final level in kLevelDesign) {
        totalGold += level.goldReward;
        totalXp += level.xpReward;
      }

      print('  📊 Economy Summary (8 levels):');
      print('    Total Gold: $totalGold');
      print('    Total XP: $totalXp');
      print('    Avg Gold/Level: ${totalGold / kLevelDesign.length}');
      print('    Avg XP/Level: ${totalXp / kLevelDesign.length}');

      // Verify economy is balanced
      expect(totalGold, greaterThan(1000)); // Reasonable total
      expect(totalXp, greaterThan(500));
      expect(totalGold, lessThan(5000)); // Not too much
      expect(totalXp, lessThan(3000));

      print('  ✅ Economy balanced appropriately');

      print('\n🎉 DATA-004: PASSED');
    });
  });
}
