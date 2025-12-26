import 'package:flame/components.dart';
import 'dart:math';
import '../tower_defense_game.dart';
import '../entities/monster.dart';
import '../entities/monster_type.dart';
import 'map_system.dart';
import 'stage_data.dart';

class MonsterSpawn {
  final MonsterType type;
  final int count;

  const MonsterSpawn(this.type, this.count);
}

class WaveDefinition {
  final List<MonsterSpawn> spawns;
  final double spawnInterval;

  const WaveDefinition({required this.spawns, this.spawnInterval = 1.0});

  int get totalCount => spawns.fold(0, (sum, spawn) => sum + spawn.count);
}

class WaveManager extends Component with HasGameReference<TowerDefenseGame> {
  final MapSystem mapSystem;
  final StageInfo? stageInfo;

  int _stage = 1;
  List<WaveDefinition> _waves = [];

  WaveManager({required this.mapSystem, this.stageInfo}) {
    if (stageInfo != null) {
      _stage = stageInfo!.stageNumber;
    }
    _generateWavesForStage(_stage);
  }

  void _generateWavesForStage(int stage) {
    _waves.clear();

    // Use stage info if available
    final int waveCount = stageInfo?.waves ?? 10;
    final double difficultyMult = stageInfo?.difficultyMultiplier ?? 1.0;
    final List<MonsterType> allowedMonsters = stageInfo?.monsterTypes ?? [MonsterType.basic];
    final bool hasBoss = stageInfo?.hasBoss ?? false;

    for (int wave = 1; wave <= waveCount; wave++) {
      final List<MonsterSpawn> spawns = [];

      // HP scaling is handled in spawnMonster
      int totalCount = (5 + (wave * 2) * difficultyMult).round();

      // Boss on final wave if hasBoss is true
      if (hasBoss && wave == waveCount) {
        spawns.add(const MonsterSpawn(MonsterType.boss, 1));
        spawns.add(MonsterSpawn(MonsterType.basic, totalCount ~/ 2));
      } else if (wave % 5 == 0 && wave < waveCount) {
        // Mini-boss wave every 5 waves
        spawns.add(MonsterSpawn(MonsterType.tank, 2));
        spawns.add(MonsterSpawn(MonsterType.basic, totalCount ~/ 2));
      } else {
        // Normal Waves - distribute among allowed types
        if (allowedMonsters.isEmpty) {
          spawns.add(MonsterSpawn(MonsterType.basic, totalCount));
        } else {
          // Filter out boss type from normal spawns
          final normalTypes = allowedMonsters.where((t) => t != MonsterType.boss).toList();
          if (normalTypes.isEmpty) {
            spawns.add(MonsterSpawn(MonsterType.basic, totalCount));
          } else {
            int splitCount = totalCount ~/ normalTypes.length;
            int remainder = totalCount % normalTypes.length;

            for (final type in normalTypes) {
              spawns.add(MonsterSpawn(type, splitCount));
            }
            if (remainder > 0) {
              spawns.add(MonsterSpawn(normalTypes.first, remainder));
            }
          }
        }
      }

      // Interval scaling based on difficulty
      double interval = max(0.3, 1.5 - (wave * 0.1) - (difficultyMult * 0.1));

      _waves.add(WaveDefinition(spawns: spawns, spawnInterval: interval));
    }
  }

  int _currentWaveIndex = -1; // -1 means before start
  int _monstersSpawned = 0;
  double _spawnTimer = 0;
  bool _isWaveActive = false;
  final Random _random = Random();
  List<MonsterType> _spawnQueue = [];

  int get currentWave => _currentWaveIndex + 1;
  int get totalWaves => _waves.length;
  bool get isWaveActive => _isWaveActive;
  // Stage getter/setter
  int get currentStage => _stage;

  void setStage(int stage) {
    _stage = stage;
    _generateWavesForStage(_stage);
    _currentWaveIndex = -1;
    _isWaveActive = false;
  }

  void startNextWave() {
    if (_isWaveActive) return; // Already running
    if (_currentWaveIndex >= _waves.length - 1) return; // Max wave reached

    _currentWaveIndex++;
    _monstersSpawned = 0;
    _spawnTimer = 0;
    _isWaveActive = true;

    // Build spawn queue for this wave
    _spawnQueue = [];
    final waveConfig = _waves[_currentWaveIndex];
    for (final spawn in waveConfig.spawns) {
      for (int i = 0; i < spawn.count; i++) {
        _spawnQueue.add(spawn.type);
      }
    }
    // Shuffle for variety
    _spawnQueue.shuffle(_random);

    print('Stage $_stage - Wave $currentWave Started!');
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!_isWaveActive) return;

    final waveConfig = _waves[_currentWaveIndex];

    // Spawning Logic
    if (_monstersSpawned < _spawnQueue.length) {
      _spawnTimer += dt;
      if (_spawnTimer >= waveConfig.spawnInterval) {
        _spawnTimer = 0;
        _spawnMonster(_spawnQueue[_monstersSpawned]);
        _monstersSpawned++;
      }
    } else {
      // All spawned, check if wave is cleared (all monsters dead)
      final activeMonsters = game.children.whereType<Monster>();
      if (activeMonsters.isEmpty) {
        _onWaveComplete();
      }
    }
  }

  void _spawnMonster(MonsterType type) {
    // Calculate Scaled Stats using stage difficulty multiplier
    final stats = MonsterStats.get(type);
    final difficultyMult = stageInfo?.difficultyMultiplier ?? 1.0;
    final hpMultiplier = 1.0 + (_stage * 0.15) * difficultyMult;
    final scaledHp = stats.maxHp * hpMultiplier;

    final monster = Monster(
      path: mapSystem.getPath(),
      monsterType: type,
      maxHp: scaledHp,
    );
    game.add(monster);
  }

  void _onWaveComplete() {
    print('Wave $currentWave Complete!');
    _isWaveActive = false;

    // VFX: Wave complete celebration at center of screen
    final centerPosition = Vector2(game.size.x / 2, game.size.y / 2);
    game.vfxManager.showWaveComplete(centerPosition);

    // Check if Stage Complete (Wave 10 done)
    if (_currentWaveIndex == _waves.length - 1) {
      // Stage Complete!
      game.onStageComplete();
    }
  }

  void reset() {
    _currentWaveIndex = -1;
    _monstersSpawned = 0;
    _spawnTimer = 0;
    _isWaveActive = false;
    _generateWavesForStage(_stage); // Regenerate

    // Clear all monsters
    game.children.whereType<Monster>().toList().forEach(
      (m) => m.removeFromParent(),
    );
  }
}

