import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tower_defense/game/core/challenge_mode.dart';
import 'package:tower_defense/game/core/map_system.dart';
import 'package:tower_defense/game/core/stage_data.dart';
import 'package:tower_defense/game/core/tower_synergy.dart';
import 'package:tower_defense/game/core/wave_manager.dart';
import 'package:tower_defense/game/entities/monster_type.dart';
import 'package:tower_defense/game/entities/tower.dart';
import 'package:tower_defense/game/entities/tower_type.dart';

void main() {
  group('ChallengeModeConfig', () {
    test('hardcore reduces starting gold and locks lives to one', () {
      final config = ChallengeModeConfig.get(ChallengeMode.hardcore);

      expect(config.startingLives, 1);
      expect(config.calculateStartingGold(200), 100);
      expect(config.canChangeSpeed(), isTrue);
    });

    test('speed mode locks game speed', () {
      final config = ChallengeModeConfig.get(ChallengeMode.speed);

      expect(config.canChangeSpeed(), isFalse);
      expect(config.lockedGameSpeed, 2.0);
      expect(config.getWaveDifficultyMultiplier(10), 1.0);
    });

    test('endless mode scales wave difficulty', () {
      final config = ChallengeModeConfig.get(ChallengeMode.endless);

      expect(config.infiniteWaves, isTrue);
      expect(config.getWaveDifficultyMultiplier(10), closeTo(2.5, 0.001));
    });
  });

  group('StageData', () {
    test('contains thirty ordered stages across six chapters', () {
      final stages = StageData.chapters
          .expand((chapter) => chapter.stages)
          .toList();

      expect(StageData.chapters, hasLength(6));
      expect(StageData.totalStages, 30);
      expect(
        stages.map((stage) => stage.stageNumber),
        orderedEquals(List.generate(30, (i) => i + 1)),
      );
    });

    test('unlocks tower and monster variety over progression', () {
      expect(StageData.getStage(1)!.availableTowers, [TowerType.basic]);
      expect(
        StageData.getStage(6)!.availableTowers,
        contains(TowerType.splash),
      );
      expect(StageData.getStage(11)!.availableTowers, contains(TowerType.slow));
      expect(StageData.getStage(16)!.monsterTypes, contains(MonsterType.air));
      expect(StageData.getStage(30)!.hasBoss, isTrue);
      expect(StageData.getStage(31), isNull);
    });
  });

  group('MapSystem and WaveManager', () {
    test('map positions point to the center of each tile', () {
      final map = MapSystem();

      expect(map.getPosition(0, 0), Vector2.all(MapSystem.tileSize / 2));
      expect(map.getPosition(2, 3), Vector2(160, 224));
      expect(map.getPath().first, map.getPosition(0, 1));
      expect(map.getPath().last, map.getPosition(2, 5));
    });

    test('wave manager uses stage data and blocks duplicate starts', () {
      final stage = StageData.getStage(1)!;
      final manager = WaveManager(mapSystem: MapSystem(), stageInfo: stage);

      expect(manager.currentStage, stage.stageNumber);
      expect(manager.totalWaves, stage.waves);
      expect(manager.currentWave, 0);
      expect(manager.isWaveActive, isFalse);

      manager.startNextWave();
      expect(manager.currentWave, 1);
      expect(manager.isWaveActive, isTrue);

      manager.startNextWave();
      expect(manager.currentWave, 1);
    });

    test('setStage regenerates wave metadata and resets active state', () {
      final manager = WaveManager(
        mapSystem: MapSystem(),
        stageInfo: StageData.getStage(1),
      );

      manager.startNextWave();
      manager.setStage(6);

      expect(manager.currentStage, 6);
      expect(manager.currentWave, 0);
      expect(manager.isWaveActive, isFalse);
      expect(manager.totalWaves, StageData.getStage(6)!.waves);
    });
  });

  group('Tower and monster stats', () {
    test('tower upgrade and sell values scale from invested cost', () {
      final tower = Tower(position: Vector2.zero(), towerType: TowerType.basic);

      expect(tower.damage, 25);
      expect(tower.range, 150);
      expect(tower.getUpgradeCost(), 25);
      expect(tower.getSellValue(), 35);

      tower.upgrade();

      expect(tower.upgradeLevel, 1);
      expect(tower.damage, closeTo(31.25, 0.001));
      expect(tower.range, closeTo(187.5, 0.001));
      expect(tower.getUpgradeCost(), 50);
      expect(tower.getSellValue(), 53);
    });

    test('synergy bonus display exposes active stat gains', () {
      final bonus = SynergyBonus(
        damageMultiplier: 1.3,
        rangeMultiplier: 1.1,
        attackSpeedMultiplier: 1.15,
        specialEffects: const ['Master Synergy'],
        towerCount: 7,
      );

      expect(bonus.getDisplayText(), contains('+30% DMG'));
      expect(bonus.getDisplayText(), contains('+10% RNG'));
      expect(bonus.getDisplayText(), contains('+14% SPD'));
      expect(bonus.getDisplayText(), contains('Master Synergy'));
      expect(bonus.getBonusColor(), Colors.purple);
    });

    test('synergy info counts adjacent towers by type', () {
      final manager = TowerSynergyManager();
      final first = Tower(
        position: Vector2(20, 20),
        towerType: TowerType.basic,
      );
      final second = Tower(
        position: Vector2(60, 20),
        towerType: TowerType.basic,
      );

      manager.registerTower(first);
      manager.registerTower(second);

      final info = manager.getSynergyInfo(first);

      expect(info, isNotNull);
      expect(info!.nearbyTowers, 1);
      expect(info.typeBreakdown[TowerType.basic], 1);
      expect(info.getDescription(), contains('Basic: 1'));
    });

    test('tower stats define required unlock and asset metadata', () {
      for (final type in TowerType.values) {
        final stats = TowerStats.get(type);

        expect(stats.cost, greaterThan(0));
        expect(stats.range, greaterThan(0));
        expect(stats.damage, greaterThan(0));
        expect(stats.attackSpeed, greaterThan(0));
        expect(stats.spriteName, endsWith('.png'));
      }
    });

    test('monster stats define positive combat rewards', () {
      for (final type in MonsterType.values) {
        final stats = MonsterStats.get(type);

        expect(stats.speed, greaterThan(0));
        expect(stats.maxHp, greaterThan(0));
        expect(stats.goldReward, greaterThan(0));
        expect(stats.spriteName, endsWith('.png'));
      }
    });
  });

  group('SpeedRunData', () {
    test('round-trips through json without losing precision', () {
      final timestamp = DateTime.utc(2026, 5, 22, 1, 2, 3);
      final data = SpeedRunData(
        stageNumber: 12,
        mode: ChallengeMode.speed,
        clearTime: const Duration(minutes: 3, milliseconds: 250),
        timestamp: timestamp,
      );

      final parsed = SpeedRunData.fromJson(data.toJson());

      expect(parsed.stageNumber, data.stageNumber);
      expect(parsed.mode, data.mode);
      expect(parsed.clearTime, data.clearTime);
      expect(parsed.timestamp, timestamp);
    });
  });
}
