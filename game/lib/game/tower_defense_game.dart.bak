import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/core/engine/core_game.dart';
import 'package:mg_common_game/core/ui/overlays/game_toast.dart';
import 'package:mg_common_game/core/audio/audio_manager.dart';
import 'package:mg_common_game/core/ui/theme/app_colors.dart';
import 'package:mg_common_game/core/ui/components/floating_text_component.dart';
import 'package:mg_common_game/core/economy/gold_manager.dart';
import 'package:mg_common_game/systems/progression/progression_manager.dart';
import 'package:mg_common_game/systems/progression/upgrade_manager.dart';
import 'package:mg_common_game/systems/progression/achievement_manager.dart';
import '../app_logger.dart';
import 'core/map_system.dart';
import 'core/wave_manager.dart';
import 'core/stage_data.dart';
import 'entities/tower.dart';
import 'entities/tower_type.dart';
import 'entities/ghost_tower.dart';

class TowerDefenseGame extends CoreGame with HasCollisionDetection {
  late final MapSystem mapSystem;
  late final WaveManager waveManager;
  final AudioManager audio = GetIt.I<AudioManager>();
  final ProgressionManager progression = GetIt.I<ProgressionManager>();
  final AchievementManager achievements = GetIt.I<AchievementManager>();

  final int stageNumber;
  StageInfo? _stageInfo;

  int lives = 20;
  int _totalGoldEarned = 0;
  bool _buildMode = false;
  bool _isGameOver = false;
  TowerType _selectedTowerType = TowerType.basic;
  Tower? _selectedTower;
  double _gameSpeed = 1.0;

  TowerDefenseGame({this.stageNumber = 1}) {
    _stageInfo = StageData.getStage(stageNumber);
    if (_stageInfo != null) {
      lives = _stageInfo!.startingLives;
    }
  }

  // Getter for stage info
  StageInfo? get stageInfo => _stageInfo;

  // Getters for dialog
  int get totalGoldEarned => _totalGoldEarned;
  Tower? get selectedTower => _selectedTower;

  // Victory condition: Survive all waves in stage
  static const int victoryWaveCount = 10; // Default, overridden by stageInfo
  static const int initialLives = 20; // Default, overridden by stageInfo

  int get maxWaves => _stageInfo?.waves ?? victoryWaveCount;
  int get maxLives => _stageInfo?.startingLives ?? initialLives;

  // Game speed control
  double get gameSpeed => _gameSpeed;

  // Wave status
  bool get isWaveInProgress => waveManager.isWaveActive;

  void toggleSpeed() {
    if (_gameSpeed == 1.0) {
      _gameSpeed = 2.0;
    } else if (_gameSpeed == 2.0) {
      _gameSpeed = 3.0;
    } else {
      _gameSpeed = 1.0;
    }
  }

  void addGoldEarned(int amount) {
    _totalGoldEarned += amount;

    // Check Gold Achievement
    if (_totalGoldEarned >= 1000) {
      if (achievements.unlock('gold_1000')) {
        GetIt.I<ToastManager>().show(
          'Achievement Unlocked: Rich!',
          backgroundColor: Colors.purple,
        );
        audio.playSfx('victory.wav');
      }
    }
  }

  @override
  Color backgroundColor() => AppColors.background;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    logger.i('TowerDefenseGame Loaded!');

    // Initialize Economy with stage starting gold
    final startGoldUpgrade = GetIt.I<UpgradeManager>().getUpgrade('start_gold');
    final bonusGold = startGoldUpgrade?.currentValue.toInt() ?? 0;
    final baseGold = _stageInfo?.startingGold ?? 100;

    GetIt.I<GoldManager>().addGold(
      baseGold + bonusGold,
    ); // Start with stage gold + Upgrade bonus

    GetIt.I<ToastManager>().show(
      'Stage $stageNumber: ${_stageInfo?.name ?? "Unknown"}',
      backgroundColor: AppColors.primary,
    );

    mapSystem = MapSystem();
    add(mapSystem);

    camera.viewfinder.anchor = Anchor.topLeft;

    // Wave Manager with stage info
    waveManager = WaveManager(mapSystem: mapSystem, stageInfo: _stageInfo);
    add(waveManager);
  }

  int get currentWave => waveManager.currentWave;

  // Grid Helper
  bool _isTileBuildable(int x, int y) {
    if (y < 0 || y >= mapSystem.grid.length) return false;
    if (x < 0 || x >= mapSystem.grid[y].length) return false;
    return mapSystem.grid[y][x] == 0; // 0 is empty
  }

  bool _hasTowerAt(int x, int y) {
    return children.whereType<Tower>().any((t) {
      final tx = (t.position.x - MapSystem.tileSize / 2) ~/ MapSystem.tileSize;
      final ty = (t.position.y - MapSystem.tileSize / 2) ~/ MapSystem.tileSize;
      return tx == x && ty == y;
    });
  }

  Tower? _getTowerAt(int x, int y) {
    try {
      return children.whereType<Tower>().firstWhere((t) {
        final tx =
            (t.position.x - MapSystem.tileSize / 2) ~/ MapSystem.tileSize;
        final ty =
            (t.position.y - MapSystem.tileSize / 2) ~/ MapSystem.tileSize;
        return tx == x && ty == y;
      });
    } catch (e) {
      return null;
    }
  }

  @override
  void onTapUp(TapUpInfo info) {
    final pos = info.eventPosition.widget;
    final gx = (pos.x / MapSystem.tileSize).floor();
    final gy = (pos.y / MapSystem.tileSize).floor();

    // Check if tapping on existing tower first
    if (!_buildMode) {
      final tappedTower = _getTowerAt(gx, gy);
      if (tappedTower != null) {
        _selectedTower = tappedTower;
        overlays.add('TowerManage');
        return;
      }
      return;
    }

    // Update Ghost Tower Position first to show where we tapped
    final targetPos = mapSystem.getPosition(gx, gy);

    // Check validity
    final buildable = _isTileBuildable(gx, gy);
    final hasTower = _hasTowerAt(gx, gy);
    final canBuild = buildable && !hasTower;

    // Show/Update Ghost
    // Note: Since we don't have mouse hover, we use Tap to place ghost,
    // and maybe a double tap or "Confirm" button to build?
    // Or just "Tap to Build" but showing the ghost briefly?
    // Let's stick to "Tap to Build" but adding the Ghost *Visual* is tricky without hover.
    // user asked for "Preview".
    // workaround:
    // If we click, we build. The ghost is useful if we had hover.
    // For now, let's spawn the ghost at the tapped location for a split second before building?
    // OR: Change interaction: 1st tap: Show Ghost (Select). 2nd tap: Build.

    if (_buildMode) {
      // Logic: If ghost exists and is at this location, try to build.
      // Else, move ghost here.
      final existingGhost = children.whereType<GhostTower>().firstOrNull;

      if (existingGhost != null && existingGhost.position == targetPos) {
        // Confirm Build
        if (canBuild) {
          _tryBuildTower(gx, gy);
          existingGhost.removeFromParent(); // Remove ghost after build
          _buildMode = false; // Exit build mode
          GetIt.I<ToastManager>().show('Build Mode OFF');
        } else {
          audio.playSfx('error.wav');
          GetIt.I<ToastManager>().show(
            'Cannot build here!',
            backgroundColor: Colors.red,
          );
        }
      } else {
        // Move/Create Ghost
        if (existingGhost != null) {
          existingGhost.position = targetPos;
          existingGhost.isValid = canBuild;
        } else {
          add(GhostTower(position: targetPos)..isValid = canBuild);
        }
        audio.playSfx('ui_click.wav'); // Feedback for selection
      }
    }
  }

  void _tryBuildTower(int gx, int gy) {
    // Cost check
    final stats = TowerStats.get(_selectedTowerType);
    final towerCost = stats.cost;

    if (GetIt.I<GoldManager>().trySpendGold(towerCost)) {
      // Build
      add(
        Tower(
          position: mapSystem.getPosition(gx, gy),
          towerType: _selectedTowerType,
        ),
      );
      audio.playSfx('build.wav');
      GetIt.I<ToastManager>().show(
        '${stats.name} Built!',
        backgroundColor: Colors.green,
      );
    } else {
      GetIt.I<ToastManager>().show(
        'Not enough Gold! Need $towerCost',
        backgroundColor: Colors.red,
      );
      audio.playSfx('error.wav');
    }
  }

  void selectTower(TowerType type) {
    _selectedTowerType = type;
    logger.d('Tower type selected: $type');
  }

  void decreaseLives(int amount) {
    if (_isGameOver) return;

    lives -= amount;

    // Floating Text
    add(
      FloatingTextComponent(
        text: "-$amount ❤️",
        position: Vector2(size.x / 2, size.y / 2),
        color: Colors.redAccent,
        fontSize: 24,
      ),
    );

    if (lives <= 0) {
      lives = 0;
      _triggerGameOver(false);
      logger.w('GAME OVER - Player lost all lives');
    } else {
      GetIt.I<ToastManager>().show(
        'Lives: $lives',
        backgroundColor: Colors.orange,
      );
      audio.playSfx('hit.wav');
      logger.d('Player hit. Lives remaining: $lives');
    }
  }

  void _triggerGameOver(bool isVictory) {
    if (_isGameOver) return;

    _isGameOver = true;
    pauseEngine();

    if (isVictory) {
      GetIt.I<ToastManager>().show('VICTORY!', backgroundColor: Colors.green);
      audio.playSfx('victory.wav');
    } else {
      GetIt.I<ToastManager>().show('GAME OVER', backgroundColor: Colors.red);
      audio.playSfx('game_over.wav');
    }

    // Show dialog will be handled by overlay
    overlays.add('GameOver');
  }

  void onStageComplete() {
    // Stage Complete Reward
    // 2.3 Meta Loop: Stage Clear -> Gems (Gems not in GoldManager? Maybe just Gold for now)
    int stageReward = 200 + (waveManager.currentStage * 50);
    GetIt.I<GoldManager>().addGold(stageReward);

    GetIt.I<ToastManager>().show(
      'Stage ${waveManager.currentStage} Complete! +${stageReward}g',
      backgroundColor: Colors.purple,
    );
    audio.playSfx('victory.wav');

    // Progress to next stage automatically
    int nextStage = waveManager.currentStage + 1;
    if (nextStage > 30) {
      // Real Victory after 30 stages
      _triggerGameOver(true);
    } else {
      waveManager.setStage(nextStage);
      // Optional: Pause here or let user start next wave?
      // Design Doc 2.2 says: [Stage Select] -> [Wave 1~10] -> [Result] -> [Reward] -> [Next Stage Unlock]
      // Simulating "Next Stage Unlock" by just incrementing for now, as we lack Stage Select Screen.
      // We will stop the auto-start, so user has to press "Start Wave 1" again.
    }
  }

  void checkVictoryCondition() {
    if (_isGameOver) return;
    // Victory handled by WaveManager calling onStageComplete
    // But if we want Game Over on Life 0, that's in decreaseLives.
  }

  void restart() {
    _isGameOver = false;
    lives = 20;
    _totalGoldEarned = 0;

    // Reset gold by spending all then adding 100
    final goldManager = GetIt.I<GoldManager>();
    goldManager.trySpendGold(goldManager.currentGold);
    goldManager.addGold(100);

    // Clear all entities
    children.whereType<Tower>().toList().forEach((t) => t.removeFromParent());
    children.whereType<GhostTower>().toList().forEach(
      (g) => g.removeFromParent(),
    );

    // Reset wave manager
    waveManager.reset();

    overlays.remove('GameOver');
    resumeEngine();

    logger.i('Game restarted');
  }

  void buildTower() {
    // Open tower selection dialog instead of direct toggle
    overlays.add('TowerSelect');
    audio.playSfx('ui_click.wav');
  }

  void startBuildMode(TowerType type) {
    _selectedTowerType = type;
    _buildMode = true;
    overlays.remove('TowerSelect');

    final stats = TowerStats.get(type);
    logger.d('Build Mode: $_buildMode, Tower: $type');
    GetIt.I<ToastManager>().show(
      'Build Mode ON - ${stats.name} (${stats.cost}g)',
      backgroundColor: AppColors.primary,
    );
  }

  void cancelBuildMode() {
    _buildMode = false;
    overlays.remove('TowerSelect');

    // Remove ghost tower
    children.whereType<GhostTower>().toList().forEach(
      (g) => g.removeFromParent(),
    );

    GetIt.I<ToastManager>().show('Build Mode OFF');
    audio.playSfx('ui_click.wav');
  }

  void upgradeTower() {
    if (_selectedTower == null || !_selectedTower!.canUpgrade()) return;

    final upgradeCost = _selectedTower!.getUpgradeCost();
    if (GetIt.I<GoldManager>().trySpendGold(upgradeCost)) {
      _selectedTower!.upgrade();
      audio.playSfx('upgrade.wav');
      GetIt.I<ToastManager>().show(
        'Tower Upgraded! ★${_selectedTower!.upgradeLevel}',
        backgroundColor: Colors.green,
      );
      overlays.remove('TowerManage');
      _selectedTower = null;
    } else {
      GetIt.I<ToastManager>().show(
        'Not enough Gold! Need $upgradeCost',
        backgroundColor: Colors.red,
      );
      audio.playSfx('error.wav');
    }
  }

  void sellTower() {
    if (_selectedTower == null) return;

    final sellValue = _selectedTower!.getSellValue();
    GetIt.I<GoldManager>().addGold(sellValue);
    _selectedTower!.removeFromParent();
    audio.playSfx('sell.wav');
    GetIt.I<ToastManager>().show(
      'Tower Sold! +${sellValue}g',
      backgroundColor: Colors.orange,
    );
    overlays.remove('TowerManage');
    _selectedTower = null;
  }

  void closeTowerManage() {
    overlays.remove('TowerManage');
    _selectedTower = null;
  }

  void startNextWave() {
    logger.i('Next Wave Pressed. Starting wave ${waveManager.currentWave + 1}');
    waveManager.startNextWave();
    GetIt.I<ToastManager>().show('Wave ${waveManager.currentWave} Started!');
    audio.playSfx('wave_start.wav');

    // XP for starting a wave
    progression.addXp(10 * waveManager.currentWave);

    // Check Wave Achievement
    if (waveManager.currentWave == 5) {
      if (achievements.unlock('wave_5')) {
        GetIt.I<ToastManager>().show(
          'Achievement Unlocked: Survivor!',
          backgroundColor: Colors.purple,
        );
        audio.playSfx('victory.wav');
      }
    }
  }
}
