import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mg_common_game/core/engine/effects/flame_effects.dart';
import 'package:tower_defense/game/core/map_system.dart';
import 'package:tower_defense/game/core/stage_data.dart';
import 'package:tower_defense/game/core/tower_synergy.dart';
import 'package:tower_defense/game/core/vfx_manager.dart';
import 'package:tower_defense/game/core/wave_manager.dart';
import 'package:tower_defense/game/entities/bullet.dart';
import 'package:tower_defense/game/entities/ghost_tower.dart';
import 'package:tower_defense/game/entities/monster.dart';
import 'package:tower_defense/game/entities/monster_type.dart';
import 'package:tower_defense/game/entities/tower.dart';
import 'package:tower_defense/game/entities/tower_type.dart';

void main() {
  group('Monster component', () {
    test('uses monster stat defaults and ignores updates with no path', () {
      final monster = Monster(path: const [], monsterType: MonsterType.fast);
      final stats = MonsterStats.get(MonsterType.fast);

      expect(monster.speed, stats.speed);
      expect(monster.maxHp, stats.maxHp);
      expect(monster.hp, stats.maxHp);
      expect(monster.goldReward, stats.goldReward);
      expect(monster.currentSpeed, stats.speed);

      monster.update(1);

      expect(monster.position, Vector2.zero());
    });

    test('moves toward the next waypoint without overshooting', () {
      final monster = Monster(
        path: [Vector2.zero(), Vector2(100, 0)],
        speed: 50,
        maxHp: 80,
        goldReward: 7,
      );

      monster.update(0.01);
      expect(monster.position, Vector2.zero());

      monster.update(1);

      expect(monster.position.x, closeTo(50, 0.001));
      expect(monster.position.y, closeTo(0, 0.001));
      expect(monster.hp, 80);
      expect(monster.goldReward, 7);
    });
  });

  group('Bullet and ghost tower components', () {
    test('bullet advances toward a live target', () {
      final target = Monster(path: [Vector2(100, 0)], maxHp: 100);
      final bullet = Bullet(
        position: Vector2.zero(),
        target: target,
        damage: 12,
        isSplash: true,
        appliesSlow: true,
        splashRadius: 90,
      );

      bullet.update(0.1);

      expect(bullet.position.x, closeTo(30, 0.001));
      expect(bullet.position.y, closeTo(0, 0.001));
      expect(bullet.damage, 12);
      expect(bullet.isSplash, isTrue);
      expect(bullet.appliesSlow, isTrue);
      expect(bullet.splashRadius, 90);
    });

    test(
      'ghost tower defaults to a valid preview with expected dimensions',
      () {
        final ghost = GhostTower(position: Vector2(64, 128));

        expect(ghost.position, Vector2(64, 128));
        expect(ghost.size, Vector2.all(40));
        expect(ghost.anchor, Anchor.center);
        expect(ghost.range, 150);
        expect(ghost.isValid, isTrue);

        ghost.isValid = false;
        expect(ghost.isValid, isFalse);
      },
    );
  });

  group('Tower upgrade and synergy behavior', () {
    test('upgrade stops at max level and sell value includes all upgrades', () {
      final tower = Tower(position: Vector2.zero(), towerType: TowerType.basic);

      tower.upgrade();
      tower.upgrade();
      tower.upgrade();

      expect(tower.upgradeLevel, Tower.maxUpgradeLevel);
      expect(tower.canUpgrade(), isFalse);
      expect(tower.getUpgradeCost(), 0);
      expect(tower.damage, closeTo(39.0625, 0.001));
      expect(tower.range, closeTo(234.375, 0.001));
      expect(tower.getSellValue(), 88);
    });

    test('clearing synergy restores upgraded base stats', () {
      final tower = Tower(
        position: Vector2.zero(),
        towerType: TowerType.sniper,
      );
      tower.upgrade();
      final upgradedDamage = tower.damage;
      final upgradedRange = tower.range;

      tower.applySynergyBonus(
        SynergyBonus(
          damageMultiplier: 1.3,
          rangeMultiplier: 1.2,
          attackSpeedMultiplier: 1.0,
          specialEffects: const [],
          towerCount: 5,
        ),
      );

      expect(tower.damage, closeTo(upgradedDamage * 1.3, 0.001));
      expect(tower.range, closeTo(upgradedRange * 1.2, 0.001));

      tower.clearSynergyBonus();

      expect(tower.synergyBonus, isNull);
      expect(tower.damage, closeTo(upgradedDamage, 0.001));
      expect(tower.range, closeTo(upgradedRange, 0.001));
    });

    test(
      'synergy display colors cover weak, medium, strong, and special bonuses',
      () {
        final weak = SynergyBonus(
          damageMultiplier: 1.05,
          rangeMultiplier: 1.0,
          attackSpeedMultiplier: 1.0,
          specialEffects: const [],
          towerCount: 1,
        );
        final medium = SynergyBonus(
          damageMultiplier: 1.2,
          rangeMultiplier: 1.0,
          attackSpeedMultiplier: 1.0,
          specialEffects: const [],
          towerCount: 3,
        );
        final strong = SynergyBonus(
          damageMultiplier: 1.3,
          rangeMultiplier: 1.0,
          attackSpeedMultiplier: 1.0,
          specialEffects: const [],
          towerCount: 5,
        );
        final special = SynergyBonus(
          damageMultiplier: 1.0,
          rangeMultiplier: 1.0,
          attackSpeedMultiplier: 1.0,
          specialEffects: const ['Chain Lightning'],
          towerCount: 3,
        );

        expect(weak.getBonusColor(), Colors.green);
        expect(medium.getBonusColor(), Colors.yellow);
        expect(strong.getBonusColor(), Colors.orange);
        expect(special.getBonusColor(), Colors.purple);
        expect(
          SynergyBonus(
            damageMultiplier: 1.0,
            rangeMultiplier: 1.0,
            attackSpeedMultiplier: 1.0,
            specialEffects: const [],
            towerCount: 0,
          ).getDisplayText(),
          'No Synergy',
        );
      },
    );

    test('synergy info describes empty and mixed nearby tower summaries', () {
      final empty = SynergyInfo(
        nearbyTowers: 0,
        typeBreakdown: const {},
        potentialBonus: SynergyBonus(
          damageMultiplier: 1.0,
          rangeMultiplier: 1.0,
          attackSpeedMultiplier: 1.0,
          specialEffects: const [],
          towerCount: 0,
        ),
      );
      final mixed = SynergyInfo(
        nearbyTowers: 3,
        typeBreakdown: const {
          TowerType.slow: 1,
          TowerType.splash: 1,
          TowerType.air: 1,
        },
        potentialBonus: SynergyBonus(
          damageMultiplier: 1.0,
          rangeMultiplier: 1.0,
          attackSpeedMultiplier: 1.0,
          specialEffects: const [],
          towerCount: 0,
        ),
      );

      expect(empty.getDescription(), 'No adjacent towers');
      expect(mixed.getDescription(), contains('Frost: 1'));
      expect(mixed.getDescription(), contains('Cannon: 1'));
      expect(mixed.getDescription(), contains('Sky: 1'));
    });
  });

  group('Wave generation', () {
    test('constructs wave plans for early, air, and boss stages', () {
      for (final stageNumber in [1, 16, 30]) {
        final stage = StageData.getStage(stageNumber)!;
        final manager = WaveManager(mapSystem: MapSystem(), stageInfo: stage);

        expect(manager.currentStage, stageNumber);
        expect(manager.totalWaves, stage.waves);
        expect(manager.currentWave, 0);
        expect(manager.isWaveActive, isFalse);
      }
    });

    test('endless waves append normal, tank, and boss variants', () {
      final manager = WaveManager(mapSystem: MapSystem());
      final initialWaveCount = manager.totalWaves;

      manager.generateEndlessWaves(1, 0.15);
      manager.generateEndlessWaves(5, 0.15);
      manager.generateEndlessWaves(10, 0.15);

      expect(manager.totalWaves, initialWaveCount + 3);
    });
  });

  group('VfxManager', () {
    Future<(FlameGame, VfxManager)> attachedVfxManager() async {
      final game = FlameGame();
      final vfx = VfxManager();

      game.add(vfx);
      await game.ready();

      return (game, vfx);
    }

    test('adds immediate particle and damage components to the game', () async {
      final (game, vfx) = await attachedVfxManager();

      vfx.showTowerAttack(Vector2(10, 20), Colors.red);
      vfx.showMonsterDeath(Vector2(20, 30), goldReward: 5);
      vfx.showBulletImpact(Vector2(30, 40), isSplash: true);
      vfx.showDamageNumber(Vector2(40, 50), 42.7);
      vfx.showTowerUpgrade(Vector2(50, 60));
      vfx.showTowerBuild(Vector2(60, 70));
      vfx.showSlowEffect(Vector2(70, 80));
      await game.ready();

      expect(game.children.whereType<FlameParticleEffect>(), hasLength(7));
      expect(game.children.whereType<FlameDamageNumber>(), hasLength(1));
      expect(game.children.whereType<FlameDamageNumber>().single.amount, 42);
    });

    test('delayed callbacks are guarded when not widget-mounted', () async {
      final (game, vfx) = await attachedVfxManager();

      vfx.showWaveComplete(Vector2(100, 100));
      vfx.showSynergyActivated(
        Vector2(120, 120),
        SynergyBonus(
          damageMultiplier: 1.2,
          rangeMultiplier: 1.0,
          attackSpeedMultiplier: 1.0,
          specialEffects: const [],
          towerCount: 3,
        ),
      );
      await game.ready();
      final immediateParticles = game.children
          .whereType<FlameParticleEffect>()
          .length;

      await Future<void>.delayed(const Duration(milliseconds: 260));
      await game.ready();

      expect(vfx.isMounted, isFalse);
      expect(immediateParticles, greaterThanOrEqualTo(2));
      expect(
        game.children.whereType<FlameParticleEffect>().length,
        immediateParticles,
      );
    });

    test('boss kill adds explosion and screen shake components', () async {
      final (game, vfx) = await attachedVfxManager();

      vfx.showBossKill(Vector2(200, 200));
      await game.ready();

      expect(game.children.whereType<FlameParticleEffect>(), hasLength(1));
      expect(
        game.camera.viewport.children.whereType<FlameScreenShake>(),
        hasLength(1),
      );
    });
  });
}
