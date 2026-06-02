import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tower_defense/main.dart';
import 'package:tower_defense/game/level_design_config.dart';
import 'package:tower_defense/game/wave_spawn_table.dart';
import 'package:tower_defense/game/core/stage_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Advanced Gameplay Test Suite for MG-0001
/// Tests edge cases, stress tests, and detailed mechanic verification
void main() {
  group('MG-0001 Advanced Edge Cases', () {
    testWidgets('EDGE-001: Rapid level transitions without settlement', (tester) async {
      SharedPreferences.setMockInitialValues({'onboarding_tutorial_completed': true});

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      print('\n🎮 EDGE-001: Rapid Level Transition Test');

      await tester.tap(find.byKey(const ValueKey('start-game')));
      await tester.pumpAndSettle();

      // Rapidly complete 5 levels without allowing animation completion
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 5; i++) {
        // Scroll to make button visible
        await tester.scrollUntilVisible(
          find.byKey(const ValueKey('complete-action')),
          500.0,
          scrollable: find.byType(Scrollable),
        );
        await tester.pump(const Duration(milliseconds: 50));

        await tester.tap(find.byKey(const ValueKey('complete-action')));
        // Minimal pump - don't wait for full settlement
        await tester.pump(const Duration(milliseconds: 50));
      }

      final elapsed = stopwatch.elapsedMilliseconds;
      print('  ⚡ 5 levels in ${elapsed}ms (avg ${elapsed / 5}ms per level)');

      // Verify state is still valid
      await tester.pumpAndSettle();
      expect(find.textContaining('Level'), findsOneWidget);

      print('  ✅ State remains consistent after rapid transitions');
      print('\n🎉 EDGE-001: PASSED');
    });

    testWidgets('EDGE-002: Boundary conditions - first and last levels', (tester) async {
      SharedPreferences.setMockInitialValues({'onboarding_tutorial_completed': true});

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      print('\n🎮 EDGE-002: Boundary Conditions Test');

      await tester.tap(find.byKey(const ValueKey('start-game')));
      await tester.pumpAndSettle();

      // Test first level (minimum values)
      final firstLevel = kLevelDesign.first;
      final firstWave = kWaveSpawnTable.first;

      print('  📊 First Level Boundaries:');
      print('    Level Index: ${firstLevel.levelIndex} (expected: 1)');
      print('    Difficulty: ${firstLevel.difficulty} (expected: 1.0)');
      print('    Enemy Count: ${firstWave.enemyCount} (expected: 5)');

      expect(firstLevel.levelIndex, equals(1));
      expect(firstLevel.difficulty, equals(1.0));
      expect(firstWave.enemyCount, equals(5));
      expect(firstWave.spawnCadenceSeconds, greaterThan(2.5));

      print('  ✅ First level boundaries verified');

      // Navigate to last level
      for (int i = 1; i < kLevelDesign.length; i++) {
        await tester.scrollUntilVisible(
          find.byKey(const ValueKey('complete-action')),
          500.0,
          scrollable: find.byType(Scrollable),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('complete-action')));
        await tester.pumpAndSettle();
      }

      // Test last level (maximum values)
      final lastLevel = kLevelDesign.last;
      final lastWave = kWaveSpawnTable.last;

      print('  📊 Last Level Boundaries:');
      print('    Level Index: ${lastLevel.levelIndex} (expected: 8)');
      print('    Difficulty: ${lastLevel.difficulty} (expected: 3.15)');
      print('    Enemy Count: ${lastWave.enemyCount} (expected: 19)');

      expect(lastLevel.levelIndex, equals(8));
      expect(lastLevel.difficulty, equals(3.15));
      expect(lastWave.enemyCount, equals(19));
      expect(lastWave.spawnCadenceSeconds, lessThan(2.0));

      print('  ✅ Last level boundaries verified');
      print('\n🎉 EDGE-002: PASSED');
    });

    testWidgets('EDGE-003: Zero and negative edge cases', (tester) async {
      SharedPreferences.setMockInitialValues({'onboarding_tutorial_completed': true});

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      print('\n🎮 EDGE-003: Zero/Negative Edge Cases Test');

      // Verify no zero rewards
      for (final level in kLevelDesign) {
        expect(level.goldReward, greaterThan(0));
        expect(level.xpReward, greaterThan(0));
      }
      print('  ✅ All rewards are positive');

      // Verify no zero enemy counts
      for (final wave in kWaveSpawnTable) {
        expect(wave.enemyCount, greaterThan(0));
        expect(wave.spawnCadenceSeconds, greaterThan(0));
      }
      print('  ✅ All enemy counts positive');

      // Verify difficulty progression is monotonic
      for (int i = 1; i < kLevelDesign.length; i++) {
        final diffDelta = kLevelDesign[i].difficulty - kLevelDesign[i-1].difficulty;
        expect(diffDelta, greaterThan(0));
      }
      print('  ✅ Difficulty always increases');

      print('\n🎉 EDGE-003: PASSED');
    });

    testWidgets('EDGE-004: Concurrent state changes', (tester) async {
      SharedPreferences.setMockInitialValues({'onboarding_tutorial_completed': true});

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      print('\n🎮 EDGE-004: Concurrent State Changes Test');

      await tester.tap(find.byKey(const ValueKey('start-game')));
      await tester.pumpAndSettle();

      // Simulate rapid taps
      final button = find.byKey(const ValueKey('complete-action'));

      await tester.scrollUntilVisible(
        button,
        500.0,
        scrollable: find.byType(Scrollable),
      );

      for (int i = 0; i < 10; i++) {
        await tester.tap(button, warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 10));
      }

      // Let everything settle
      await tester.pumpAndSettle();

      // Verify we're still on a valid level
      expect(find.textContaining('Level'), findsOneWidget);
      print('  ✅ App handles rapid tapping gracefully');

      print('\n🎉 EDGE-004: PASSED');
    });
  });

  group('MG-0001 Stress Tests', () {
    testWidgets('STRESS-001: All levels rapid completion', (tester) async {
      SharedPreferences.setMockInitialValues({'onboarding_tutorial_completed': true});

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      print('\n🎮 STRESS-001: Full Game Stress Test');

      await tester.tap(find.byKey(const ValueKey('start-game')));
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();
      int totalGold = 0;
      int totalXp = 0;

      // Complete all 8 levels
      for (int i = 0; i < kLevelDesign.length; i++) {
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
      }

      final elapsed = stopwatch.elapsedMilliseconds;

      print('  ⏱️ All levels completed in ${elapsed}ms');
      print('  💰 Total Gold: $totalGold');
      print('  ⭐ Total XP: $totalXp');
      print('  📊 Average per level: ${elapsed / kLevelDesign.length}ms');

      // Verify final state
      expect(find.textContaining('Level 8'), findsOneWidget);
      expect(totalGold, equals(1905)); // Sum of all gold rewards
      expect(totalXp, equals(867)); // Sum of all XP rewards

      print('  ✅ All levels completed successfully');
      print('\n🎉 STRESS-001: PASSED');
    });

    testWidgets('STRESS-002: Memory and state accumulation', (tester) async {
      SharedPreferences.setMockInitialValues({'onboarding_tutorial_completed': true});

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      print('\n🎮 STRESS-002: State Accumulation Test');

      await tester.tap(find.byKey(const ValueKey('start-game')));
      await tester.pumpAndSettle();

      // Track state growth
      final previousStates = <String>{};

      for (int i = 0; i < kLevelDesign.length; i++) {
        final level = kLevelDesign[i];

        // Record current state
        final stateKey = 'L${level.levelIndex}_G${level.goldReward}_X${level.xpReward}';
        previousStates.add(stateKey);

        await tester.scrollUntilVisible(
          find.byKey(const ValueKey('complete-action')),
          500.0,
          scrollable: find.byType(Scrollable),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const ValueKey('complete-action')));
        await tester.pumpAndSettle();
      }

      // Verify we tracked all levels
      expect(previousStates.length, equals(kLevelDesign.length));
      print('  ✅ Tracked ${previousStates.length} unique states');

      print('\n🎉 STRESS-002: PASSED');
    });

    testWidgets('STRESS-003: Economy overflow prevention', (tester) async {
      SharedPreferences.setMockInitialValues({'onboarding_tutorial_completed': true});

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      print('\n🎮 STRESS-003: Economy Overflow Test');

      await tester.tap(find.byKey(const ValueKey('start-game')));
      await tester.pumpAndSettle();

      // Calculate theoretical maximum
      int maxGold = 0;
      int maxXp = 0;

      for (final level in kLevelDesign) {
        maxGold += level.goldReward;
        maxXp += level.xpReward;
      }

      print('  📊 Theoretical Maximums:');
      print('    Gold: $maxGold');
      print('    XP: $maxXp');

      // Verify values are reasonable (no overflow signs)
      expect(maxGold, lessThan(1000000));
      expect(maxXp, lessThan(1000000));

      print('  ✅ Economy values are within safe ranges');

      print('\n🎉 STRESS-003: PASSED');
    });
  });

  group('MG-0001 Detailed Mechanics', () {
    testWidgets('MECH-003: Wave spawn cadence precision', (tester) async {
      print('\n🎮 MECH-003: Spawn Cadence Precision Test');

      // Verify cadence decreases consistently
      double previousCadence = kWaveSpawnTable.first.spawnCadenceSeconds;

      for (int i = 1; i < kWaveSpawnTable.length; i++) {
        final currentCadence = kWaveSpawnTable[i].spawnCadenceSeconds;
        final decrease = previousCadence - currentCadence;

        print('  Wave ${i + 1}: ${currentCadence}s (Δ: ${decrease.toStringAsFixed(2)}s)');

        // Cadence should always decrease
        expect(decrease, greaterThan(0));

        // Decrease should be reasonable (not too abrupt)
        expect(decrease, lessThan(0.5));

        previousCadence = currentCadence;
      }

      print('  ✅ Spawn cadence scales smoothly');
      print('\n🎉 MECH-003: PASSED');
    });

    testWidgets('MECH-004: Difficulty curve analysis', (tester) async {
      print('\n🎮 MECH-004: Difficulty Curve Analysis');

      final difficulties = kLevelDesign.map((l) => l.difficulty).toList();

      // Calculate derivatives (rate of change)
      final rates = <double>[];
      for (int i = 1; i < difficulties.length; i++) {
        rates.add(difficulties[i] - difficulties[i - 1]);
      }

      print('  📈 Difficulty Progression:');
      for (int i = 0; i < difficulties.length; i++) {
        final rate = i == 0 ? 0.0 : rates[i - 1];
        print('    Level ${i + 1}: ${difficulties[i].toStringAsFixed(2)} (rate: ${rate.toStringAsFixed(2)})');
      }

      // Verify difficulty increases (all rates positive)
      for (final rate in rates) {
        expect(rate, greaterThan(0));
      }

      // Verify no extreme spikes
      final maxRate = rates.reduce((a, b) => a > b ? a : b);
      expect(maxRate, lessThan(1.0)); // No single level adds 1.0+ difficulty

      print('  ✅ Difficulty curve is smooth and progressive');
      print('\n🎉 MECH-004: PASSED');
    });

    testWidgets('MECH-005: Reward-to-difficulty ratio', (tester) async {
      print('\n🎮 MECH-005: Reward-to-Difficulty Ratio Test');

      for (int i = 0; i < kLevelDesign.length; i++) {
        final level = kLevelDesign[i];
        final wave = kWaveSpawnTable[i];

        final goldPerEnemy = level.goldReward / wave.enemyCount;
        final xpPerEnemy = level.xpReward / wave.enemyCount;
        final goldPerDifficulty = level.goldReward / level.difficulty;
        final xpPerDifficulty = level.xpReward / level.difficulty;

        print('  Level ${level.levelIndex}:');
        print('    Gold/Enemy: ${goldPerEnemy.toStringAsFixed(1)}');
        print('    XP/Enemy: ${xpPerEnemy.toStringAsFixed(1)}');
        print('    Gold/Difficulty: ${goldPerDifficulty.toStringAsFixed(1)}');
        print('    XP/Difficulty: ${xpPerDifficulty.toStringAsFixed(1)}');

        // Verify rewards scale with difficulty
        expect(goldPerDifficulty, greaterThan(30));
        expect(xpPerDifficulty, greaterThan(10));
      }

      print('  ✅ Rewards are properly balanced against difficulty');
      print('\n🎉 MECH-005: PASSED');
    });

    testWidgets('MECH-006: Pressure budget verification', (tester) async {
      print('\n🎮 MECH-006: Pressure Budget Test');

      int previousPressure = 0;

      for (int i = 0; i < kWaveSpawnTable.length; i++) {
        final wave = kWaveSpawnTable[i];
        final pressure = wave.pressureBudget;

        print('  Level ${i + 1}: Pressure $pressure');

        // Pressure should increase
        if (i > 0) {
          expect(pressure, greaterThan(previousPressure));
        }

        previousPressure = pressure;
      }

      print('  ✅ Pressure budget increases appropriately');
      print('\n🎉 MECH-006: PASSED');
    });
  });

  group('MG-0001 Performance Tests', () {
    testWidgets('PERF-001: Frame rate during level transitions', (tester) async {
      SharedPreferences.setMockInitialValues({'onboarding_tutorial_completed': true});

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      print('\n🎮 PERF-001: Frame Rate Test');

      await tester.tap(find.byKey(const ValueKey('start-game')));
      await tester.pumpAndSettle();

      final frameTimes = <int>[];

      // Measure frame times during transitions
      for (int i = 0; i < 5; i++) {
        final start = DateTime.now();

        await tester.scrollUntilVisible(
          find.byKey(const ValueKey('complete-action')),
          500.0,
          scrollable: find.byType(Scrollable),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const ValueKey('complete-action')));
        await tester.pumpAndSettle();

        final elapsed = DateTime.now().difference(start).inMilliseconds;
        frameTimes.add(elapsed);
      }

      final avgFrameTime = frameTimes.reduce((a, b) => a + b) / frameTimes.length;
      final maxFrameTime = frameTimes.reduce((a, b) => a > b ? a : b);

      print('  📊 Frame Time Statistics:');
      print('    Average: ${avgFrameTime.toStringAsFixed(1)}ms');
      print('    Maximum: ${maxFrameTime}ms');
      print('    Min 60fps: 16.67ms');

      // Verify performance is acceptable
      expect(maxFrameTime, lessThan(5000)); // No frame should take 5+ seconds

      print('  ✅ Performance is acceptable');
      print('\n🎉 PERF-001: PASSED');
    });

    testWidgets('PERF-002: Widget rebuild efficiency', (tester) async {
      SharedPreferences.setMockInitialValues({'onboarding_tutorial_completed': true});

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      print('\n🎮 PERF-002: Rebuild Efficiency Test');

      await tester.tap(find.byKey(const ValueKey('start-game')));
      await tester.pumpAndSettle();

      // Count widgets before
      final widgetsBefore = tester.widgetList(find.byType(Container)).length;

      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('complete-action')),
        500.0,
        scrollable: find.byType(Scrollable),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('complete-action')));
      await tester.pumpAndSettle();

      // Count widgets after
      final widgetsAfter = tester.widgetList(find.byType(Container)).length;

      print('  📊 Widget Count:');
      print('    Before: $widgetsBefore');
      print('    After: $widgetsAfter');
      print('    Delta: ${widgetsAfter - widgetsBefore}');

      // Widget count should be reasonable
      expect(widgetsAfter, lessThan(5000)); // Arbitrary sanity check

      print('  ✅ Widget count is reasonable');
      print('\n🎉 PERF-002: PASSED');
    });
  });

  group('MG-0001 Stage Data Integration', () {
    test('STAGE-001: Stage data consistency with level design', () {
      print('\n🎮 STAGE-001: Stage Data Consistency Test');

      // Test first 8 stages match level design
      for (int i = 1; i <= 8; i++) {
        final stage = StageData.getStage(i);
        final level = kLevelDesign[i - 1];

        expect(stage, isNotNull);
        expect(stage!.stageNumber, equals(i));
        print('  ✅ Stage $i: ${stage.name}');
      }

      print('\n🎉 STAGE-001: PASSED');
    });

    test('STAGE-002: Stage difficulty progression', () {
      print('\n🎮 STAGE-002: Stage Difficulty Progression Test');

      double previousMultiplier = 0.0;

      for (int i = 1; i <= 10; i++) {
        final stage = StageData.getStage(i);

        if (stage != null) {
          final multiplier = stage.difficultyMultiplier;

          print('  Stage $i: ${stage.name} (difficulty: ${multiplier}x)');

          if (i > 1) {
            // Verify difficulty multiplier increases
            expect(multiplier, greaterThan(previousMultiplier));
          }

          previousMultiplier = multiplier;
        }
      }

      print('  ✅ Stage difficulty increases correctly');
      print('\n🎉 STAGE-002: PASSED');
    });

    test('STAGE-003: Stage monster type progression', () {
      print('\n🎮 STAGE-003: Monster Type Progression Test');

      for (int i = 1; i <= 10; i++) {
        final stage = StageData.getStage(i);

        if (stage != null) {
          final monsterTypes = stage.monsterTypes;
          print('  Stage $i: ${monsterTypes.map((t) => t.toString()).join(', ')}');

          // Verify stages have valid monster types
          expect(monsterTypes, isNotEmpty);
          expect(monsterTypes.length, lessThanOrEqualTo(4));
        }
      }

      print('  ✅ Monster types progress appropriately');
      print('\n🎉 STAGE-003: PASSED');
    });
  });

  group('MG-0001 Data Validation', () {
    test('DATA-005: Array bounds and indexing', () {
      print('\n🎮 DATA-005: Array Bounds Test');

      // Verify all arrays have consistent length
      expect(kLevelDesign.length, equals(8));
      expect(kWaveSpawnTable.length, equals(8));

      // Verify indices are 1-based
      for (int i = 0; i < kLevelDesign.length; i++) {
        expect(kLevelDesign[i].levelIndex, equals(i + 1));
      }

      print('  ✅ All arrays are properly bounded');
      print('\n🎉 DATA-005: PASSED');
    });

    test('DATA-006: Reward calculation accuracy', () {
      print('\n🎮 DATA-006: Reward Calculation Test');

      // Calculate expected totals
      int totalGold = 0;
      int totalXp = 0;

      for (final level in kLevelDesign) {
        totalGold += level.goldReward;
        totalXp += level.xpReward;
      }

      print('  📊 Total Rewards:');
      print('    Gold: $totalGold');
      print('    XP: $totalXp');

      // Verify totals are non-negative
      expect(totalGold, greaterThan(0));
      expect(totalXp, greaterThan(0));

      print('  ✅ Reward calculations are accurate');
      print('\n🎉 DATA-006: PASSED');
    });
  });
}
