import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/core/audio/audio_manager.dart';
import 'package:mg_common_game/core/audio/audio_settings.dart';
import 'package:mg_common_game/core/economy/gold_manager.dart';
import 'package:mg_common_game/core/engine/event_bus.dart';
import 'package:mg_common_game/core/engine/game_manager.dart';
import 'package:mg_common_game/core/engine/input_manager.dart';
import 'package:mg_common_game/core/systems/save_system.dart';
import 'package:mg_common_game/core/ui/overlays/game_toast.dart';
import 'package:mg_common_game/systems/progression/achievement_manager.dart';
import 'package:mg_common_game/systems/progression/progression_manager.dart';
import 'package:mg_common_game/systems/progression/upgrade_manager.dart';
import 'package:tower_defense/game/core/challenge_mode.dart';
import 'package:tower_defense/game/core/map_system.dart';
import 'package:tower_defense/game/core/stage_data.dart';
import 'package:tower_defense/game/core/vfx_manager.dart';
import 'package:tower_defense/game/core/wave_manager.dart';
import 'package:tower_defense/game/entities/bullet.dart';
import 'package:tower_defense/game/entities/ghost_tower.dart';
import 'package:tower_defense/game/entities/monster.dart';
import 'package:tower_defense/game/entities/monster_type.dart';
import 'package:tower_defense/game/entities/tower.dart';
import 'package:tower_defense/game/entities/tower_type.dart';
import 'package:tower_defense/game/tower_defense_game.dart';

/// Mock SaveSystem for testing
class MockSaveSystem implements SaveSystem {
  final Map<String, Map<String, dynamic>> _storage = {};

  @override
  Future<void> init() async {}

  @override
  Future<void> save(String key, Map<String, dynamic> data) async {
    _storage[key] = data;
  }

  @override
  Future<Map<String, dynamic>?> load(String key) async {
    return _storage[key];
  }
}

/// Mock InputManager for testing
class MockInputManager extends InputManager {
  MockInputManager(super.eventBus);
}

/// Mock AudioManager that avoids native plugin calls
class MockAudioManager extends AudioManager {
  AudioSettings _testSettings = const AudioSettings(isMuted: true);

  MockAudioManager() : super();

  @override
  AudioSettings get settings => _testSettings;

  @override
  Future<void> initialize() async {
    // Skip native initialization in tests
  }

  @override
  Future<void> toggleMute() async {
    _testSettings = AudioSettings(
      isMuted: !_testSettings.isMuted,
      masterVolume: _testSettings.masterVolume,
      bgmVolume: _testSettings.bgmVolume,
      sfxVolume: _testSettings.sfxVolume,
    );
    notifyListeners();
  }

  @override
  Future<void> setMuted(bool muted) async {
    if (_testSettings.isMuted == muted) return;
    _testSettings = AudioSettings(
      isMuted: muted,
      masterVolume: _testSettings.masterVolume,
      bgmVolume: _testSettings.bgmVolume,
      sfxVolume: _testSettings.sfxVolume,
    );
    notifyListeners();
  }

  @override
  Future<void> applySettings(AudioSettings newSettings) async {
    _testSettings = newSettings;
    notifyListeners();
  }

  // Override play methods to be no-ops in tests
  @override
  void playBgm(String fileName, {double volume = 1.0}) {
    // No-op in tests
  }

  @override
  void stopBgm() {
    // No-op in tests
  }

  @override
  void pauseBgm() {
    // No-op in tests
  }

  @override
  void resumeBgm() {
    // No-op in tests
  }

  @override
  Future<void> playSfx(String fileName, {double volume = 1.0, double pitch = 1.0}) async {
    // No-op in tests
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final getIt = GetIt.I;

  Future<void> loadGame(TowerDefenseGame game) async {
    game.onGameResize(Vector2(800, 600));
    for (final overlayName in ['GameOver', 'TowerSelect', 'TowerManage']) {
      game.overlays.addEntry(overlayName, (_, _) => const SizedBox.shrink());
    }
    await game.onLoad();
  }

  Future<void> tapGame(TowerDefenseGame game, Offset position) async {
    await game.ready();
    // Convert pixel offset to grid coordinates (tileSize = 64)
    final gx = (position.dx / 64).floor();
    final gy = (position.dy / 64).floor();
    game.tapAtGrid(gx, gy);
  }

  setUp(() async {
    await getIt.reset();

    // Register core dependencies first (required by CoreGame)
    final eventBus = EventBus();
    final saveSystem = MockSaveSystem();
    final gameManager = GameManager(eventBus, saveSystem);
    final inputManager = MockInputManager(eventBus);

    // Use MockAudioManager to avoid native plugin calls
    final audio = MockAudioManager()..toggleMute(); // Start muted

    getIt
      ..registerSingleton<EventBus>(eventBus)
      ..registerSingleton<SaveSystem>(saveSystem)
      ..registerSingleton<GameManager>(gameManager)
      ..registerSingleton<InputManager>(inputManager)
      ..registerSingleton<AudioManager>(audio)
      ..registerSingleton<ProgressionManager>(ProgressionManager())
      ..registerSingleton<AchievementManager>(AchievementManager())
      ..registerSingleton<UpgradeManager>(UpgradeManager())
      ..registerSingleton<GoldManager>(GoldManager())
      ..registerSingleton<ToastManager>(ToastManager());
  });

  tearDown(() async {
    if (getIt.isRegistered<ToastManager>()) {
      getIt<ToastManager>().dispose();
    }
    await getIt.reset();
  });

  group('TowerDefenseGame setup', () {
    test('constructor applies stage and challenge mode constraints', () {
      final normal = TowerDefenseGame(stageNumber: 30);
      final hardcore = TowerDefenseGame(
        stageNumber: 30,
        challengeMode: ChallengeMode.hardcore,
      );

      expect(normal.stageInfo, StageData.getStage(30));
      expect(normal.lives, StageData.getStage(30)!.startingLives);
      expect(normal.maxWaves, StageData.getStage(30)!.waves);
      expect(normal.maxLives, StageData.getStage(30)!.startingLives);

      expect(hardcore.challengeMode, ChallengeMode.hardcore);
      expect(hardcore.lives, 1);
      expect(hardcore.challengeConfig.displayName, 'Hardcore Mode');
    });

    test(
      'onLoad wires map, vfx, synergy, wave, gold, and speed state',
      () async {
        final upgrades = getIt<UpgradeManager>();
        upgrades.registerUpgrade(
          Upgrade(
            id: 'start_gold',
            name: 'Start Gold',
            description: 'Extra starting gold',
            maxLevel: 5,
            baseCost: 100,
            valuePerLevel: 25,
          )..setLevel(2),
        );
        final stage = StageData.getStage(6)!;
        final game = TowerDefenseGame(
          stageNumber: stage.stageNumber,
          challengeMode: ChallengeMode.speed,
        );

        await loadGame(game);

        expect(game.mapSystem, isA<MapSystem>());
        expect(game.vfxManager, isA<VfxManager>());
        expect(game.waveManager, isA<WaveManager>());
        expect(game.currentWave, 0);
        expect(game.isWaveInProgress, isFalse);
        expect(game.gameSpeed, 2.0);
        expect(getIt<GoldManager>().currentGold, stage.startingGold + 50);
      },
    );
  });

  group('TowerDefenseGame public flow', () {
    test('normal speed cycles and locked speed mode refuses changes', () async {
      final normal = TowerDefenseGame();

      normal.toggleSpeed();
      expect(normal.gameSpeed, 2.0);
      normal.toggleSpeed();
      expect(normal.gameSpeed, 3.0);
      normal.toggleSpeed();
      expect(normal.gameSpeed, 1.0);

      final speedRun = TowerDefenseGame(challengeMode: ChallengeMode.speed);
      await loadGame(speedRun);

      speedRun.toggleSpeed();

      expect(speedRun.gameSpeed, 2.0);
    });

    test(
      'startNextWave activates wave state and grants progression xp',
      () async {
        final progression = getIt<ProgressionManager>();
        final game = TowerDefenseGame();
        await loadGame(game);

        game.startNextWave();

        expect(game.currentWave, 1);
        expect(game.isWaveInProgress, isTrue);
        expect(progression.currentXp, 10);
      },
    );

    test('decreaseLives clamps game over state and opens overlay', () async {
      final game = TowerDefenseGame();
      await loadGame(game);

      game.decreaseLives(3);
      expect(game.lives, 17);
      expect(game.overlays.isActive('GameOver'), isFalse);

      game.decreaseLives(99);

      expect(game.lives, 0);
      expect(game.overlays.isActive('GameOver'), isTrue);
    });

    test('stage completion rewards gold and advances normal stages', () async {
      final game = TowerDefenseGame(stageNumber: 1);
      await loadGame(game);
      final goldBefore = getIt<GoldManager>().currentGold;

      game.onStageComplete();

      expect(getIt<GoldManager>().currentGold, goldBefore + 250);
      expect(game.waveManager.currentStage, 2);
      expect(game.overlays.isActive('GameOver'), isFalse);
    });

    test(
      'speed stage completion after a wave advances with timer branch',
      () async {
        final game = TowerDefenseGame(challengeMode: ChallengeMode.speed);
        await loadGame(game);

        game.startNextWave();
        game.onStageComplete();

        expect(game.waveManager.currentStage, 2);
        expect(game.gameSpeed, 2.0);
        expect(game.overlays.isActive('GameOver'), isFalse);
      },
    );

    test(
      'endless stage completion appends waves without advancing stage',
      () async {
        final game = TowerDefenseGame(challengeMode: ChallengeMode.endless);
        await loadGame(game);
        final initialWaveCount = game.waveManager.totalWaves;

        game.onStageComplete();

        expect(game.waveManager.currentStage, 1);
        expect(game.waveManager.totalWaves, initialWaveCount + 1);
        expect(game.overlays.isActive('GameOver'), isFalse);
      },
    );

    test('final stage completion triggers victory game over', () async {
      final game = TowerDefenseGame(stageNumber: 30);
      await loadGame(game);

      game.onStageComplete();

      expect(game.waveManager.currentStage, 30);
      expect(game.overlays.isActive('GameOver'), isTrue);
    });

    test('build mode selection and cancellation manage overlays', () async {
      final game = TowerDefenseGame();
      await loadGame(game);

      game.buildTower();
      expect(game.overlays.isActive('TowerSelect'), isTrue);

      game.startBuildMode(TowerType.splash);
      expect(game.overlays.isActive('TowerSelect'), isFalse);

      game.cancelBuildMode();

      expect(game.overlays.isActive('TowerSelect'), isFalse);
    });

    test('tap build flow previews then builds valid tower positions', () async {
      final game = TowerDefenseGame();
      await loadGame(game);
      final goldBefore = getIt<GoldManager>().currentGold;

      game.startBuildMode(TowerType.basic);
      await tapGame(game, const Offset(32, 32));

      final ghost = game.children.whereType<GhostTower>().single;
      expect(ghost.isValid, isTrue);
      expect(game.children.whereType<Tower>(), isEmpty);

      await tapGame(game, const Offset(32, 32));

      expect(game.children.whereType<GhostTower>(), isEmpty);
      expect(game.children.whereType<Tower>(), hasLength(1));
      expect(getIt<GoldManager>().currentGold, goldBefore - 50);
    });

    test(
      'tap build flow marks path tiles invalid and refuses construction',
      () async {
        final game = TowerDefenseGame();
        await loadGame(game);
        final goldBefore = getIt<GoldManager>().currentGold;

        game.startBuildMode(TowerType.basic);
        await tapGame(game, const Offset(32, 96));

        final ghost = game.children.whereType<GhostTower>().single;
        expect(ghost.isValid, isFalse);

        await tapGame(game, const Offset(32, 96));

        expect(game.children.whereType<Tower>(), isEmpty);
        expect(game.children.whereType<GhostTower>(), hasLength(1));
        expect(getIt<GoldManager>().currentGold, goldBefore);
      },
    );

    test('tap build flow refuses occupied tiles', () async {
      final game = TowerDefenseGame();
      await loadGame(game);

      game.startBuildMode(TowerType.basic);
      await tapGame(game, const Offset(32, 32));
      await tapGame(game, const Offset(32, 32));
      expect(game.children.whereType<Tower>(), hasLength(1));

      game.startBuildMode(TowerType.basic);
      await tapGame(game, const Offset(32, 32));

      expect(game.children.whereType<GhostTower>().single.isValid, isFalse);
    });

    test('selected towers can be upgraded, closed, and sold', () async {
      final game = TowerDefenseGame();
      await loadGame(game);
      getIt<GoldManager>().addGold(500);

      game.startBuildMode(TowerType.basic);
      await tapGame(game, const Offset(32, 32));
      await tapGame(game, const Offset(32, 32));

      await tapGame(game, const Offset(32, 32));
      expect(game.selectedTower, isA<Tower>());
      expect(game.overlays.isActive('TowerManage'), isTrue);

      game.closeTowerManage();
      expect(game.selectedTower, isNull);
      expect(game.overlays.isActive('TowerManage'), isFalse);

      await tapGame(game, const Offset(32, 32));
      game.upgradeTower();
      final tower = game.children.whereType<Tower>().single;
      expect(tower.upgradeLevel, 1);
      expect(game.selectedTower, isNull);

      await tapGame(game, const Offset(32, 32));
      final goldBeforeSell = getIt<GoldManager>().currentGold;
      game.sellTower();

      expect(game.children.whereType<Tower>(), isEmpty);
      expect(getIt<GoldManager>().currentGold, greaterThan(goldBeforeSell));
      expect(game.selectedTower, isNull);
    });

    test('restart clears combat state and restores base gold', () async {
      final game = TowerDefenseGame();
      await loadGame(game);
      getIt<GoldManager>().addGold(250);

      game.startBuildMode(TowerType.basic);
      await tapGame(game, const Offset(32, 32));
      await tapGame(game, const Offset(32, 32));
      game.startNextWave();
      game.decreaseLives(99);
      expect(game.overlays.isActive('GameOver'), isTrue);

      game.restart();

      expect(game.lives, 20);
      expect(game.currentWave, 0);
      expect(game.children.whereType<Tower>(), isEmpty);
      expect(game.overlays.isActive('GameOver'), isFalse);
      expect(getIt<GoldManager>().currentGold, 100);
    });

    test('gold earned unlocks registered gold achievement once', () async {
      final achievements = getIt<AchievementManager>();
      achievements.registerAchievement(
        Achievement(
          id: 'gold_1000',
          title: 'Rich',
          description: 'Earn 1000 gold',
          iconAsset: 'gold.png',
        ),
      );
      final game = TowerDefenseGame();

      game.addGoldEarned(999);
      expect(game.totalGoldEarned, 999);
      expect(achievements.isUnlocked('gold_1000'), isFalse);

      game.addGoldEarned(1);
      expect(game.totalGoldEarned, 1000);
      expect(achievements.isUnlocked('gold_1000'), isTrue);

      game.addGoldEarned(100);
      expect(achievements.unlockedCount, 1);
    });
  });

  group('TowerDefenseGame combat components', () {
    test(
      'basic towers target the closest monster and enter cooldown',
      () async {
        final game = TowerDefenseGame();
        await loadGame(game);
        final farMonster = Monster(path: [Vector2(180, 32)], maxHp: 100)
          ..position = Vector2(180, 32);
        final nearMonster = Monster(path: [Vector2(96, 32)], maxHp: 100)
          ..position = Vector2(96, 32);
        final tower = Tower(
          position: Vector2(32, 32),
          towerType: TowerType.basic,
          damage: 10,
          range: 200,
          attackSpeed: 1,
        );

        game.addAll([farMonster, nearMonster, tower]);
        await game.ready();

        tower.update(0.01);
        await game.ready();

        final bullet = game.children.whereType<Bullet>().single;
        expect(bullet.target, same(nearMonster));
        expect(bullet.damage, 10);
        expect(bullet.isSplash, isFalse);
        expect(bullet.appliesSlow, isFalse);
        expect(tower.angle, closeTo(1.5707963267948966, 0.001));

        tower.update(0.5);

        expect(game.children.whereType<Bullet>(), hasLength(1));
      },
    );

    test('specialized towers apply targeting rules and bullet flags', () async {
      final game = TowerDefenseGame();
      await loadGame(game);
      final airMonster = Monster(
        path: [Vector2(80, 32)],
        monsterType: MonsterType.air,
        maxHp: 100,
      )..position = Vector2(80, 32);
      final groundMonster = Monster(path: [Vector2(120, 32)], maxHp: 100)
        ..position = Vector2(120, 32);
      final airTower = Tower(
        position: Vector2(32, 32),
        towerType: TowerType.air,
        damage: 7,
        range: 200,
        attackSpeed: 1,
      );
      final splashTower = Tower(
        position: Vector2(32, 96),
        towerType: TowerType.splash,
        damage: 9,
        range: 200,
        attackSpeed: 1,
      );
      final slowTower = Tower(
        position: Vector2(32, 160),
        towerType: TowerType.slow,
        damage: 5,
        range: 200,
        attackSpeed: 1,
      );
      final sniperTower = Tower(
        position: Vector2(32, 224),
        towerType: TowerType.sniper,
        damage: 12,
        range: 250,
        attackSpeed: 1,
      );

      game.addAll([
        airMonster,
        groundMonster,
        airTower,
        splashTower,
        slowTower,
        sniperTower,
      ]);
      await game.ready();

      airTower.update(0.01);
      splashTower.update(0.01);
      slowTower.update(0.01);
      sniperTower.update(0.01);
      await game.ready();

      final bullets = game.children.whereType<Bullet>().toList();
      expect(bullets, hasLength(4));
      expect(
        bullets.singleWhere((bullet) => bullet.damage == 7).target,
        same(airMonster),
      );
      expect(
        bullets.singleWhere((bullet) => bullet.isSplash).target,
        same(groundMonster),
      );
      expect(bullets.singleWhere((bullet) => bullet.appliesSlow).damage, 5);
      expect(bullets.singleWhere((bullet) => bullet.damage == 12), isNotNull);
    });

    test('tower render covers cooldown and upgrade indicators', () async {
      final game = TowerDefenseGame();
      await loadGame(game);
      final monster = Monster(path: [Vector2(96, 32)], maxHp: 100)
        ..position = Vector2(96, 32);
      final tower = Tower(
        position: Vector2(32, 32),
        towerType: TowerType.basic,
        damage: 10,
        range: 200,
        attackSpeed: 1,
      )..upgrade();

      game.addAll([monster, tower]);
      await game.ready();
      tower.update(0.01);
      await game.ready();

      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
      tower.render(canvas);
      final picture = recorder.endRecording();
      picture.dispose();

      expect(tower.upgradeLevel, 1);
    });

    test('monsters leak lives at the end of the path', () async {
      final game = TowerDefenseGame();
      await loadGame(game);
      final monster = Monster(path: [Vector2.zero()], speed: 50);
      final livesBefore = game.lives;

      game.add(monster);
      await game.ready();

      monster.update(0.1);

      expect(game.lives, livesBefore - 1);
    });

    test(
      'monsters apply slow effects and reset speed after duration',
      () async {
        final game = TowerDefenseGame();
        await loadGame(game);
        final monster = Monster(
          path: [Vector2.zero(), Vector2(100, 0)],
          speed: 80,
          maxHp: 100,
        );

        game.add(monster);
        await game.ready();

        monster.applySlow(0.25, 0.1);
        expect(monster.currentSpeed, 20);

        monster.update(0.2);

        expect(monster.currentSpeed, 80);
      },
    );

    test(
      'monster death grants gold and boss death triggers bonus effects',
      () async {
        final game = TowerDefenseGame();
        await loadGame(game);
        final gold = getIt<GoldManager>();
        final goldBefore = gold.currentGold;
        final boss = Monster(
          path: [Vector2.zero(), Vector2(100, 0)],
          monsterType: MonsterType.boss,
          maxHp: 20,
          goldReward: 13,
        );

        game.add(boss);
        await game.ready();

        boss.takeDamage(8);
        expect(boss.hp, 12);

        boss.takeDamage(12);
        await game.ready();

        expect(boss.hp, 0);
        expect(gold.currentGold, goldBefore + 13);
        expect(game.totalGoldEarned, 13);
      },
    );
  });
}
