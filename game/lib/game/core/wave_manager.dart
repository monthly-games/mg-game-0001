import 'package:flame/components.dart';
import 'dart:math';
import '../tower_defense_game.dart';
import '../entities/monster.dart';
import '../entities/monster_type.dart';
import 'map_system.dart';

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

  int _stage = 1;
  List<WaveDefinition> _waves = [];

  WaveManager({required this.mapSystem}) {
    _generateWavesForStage(_stage);
  }

  void _generateWavesForStage(int stage) {
    _waves.clear();
    // Formula: Monster HP = Base * (1 + Stage * 0.15)

    // Unlock Logic (Section 4.2 Content Progress)
    // Stage 1-5: Basic
    // Stage 6-10: + Fast
    // Stage 11-15: + Tank
    // Stage 16+: + Air

    final bool enableFast = stage >= 6;
    final bool enableTank = stage >= 11;
    final bool enableAir = stage >= 16;
    // Section 4.2 says Boss Enhance 21+, but 1.3 says Boss Wave every 5.
    // let's compromise: Bosses appear every 5 waves but are "Weak" until stage 21?
    // Or just follow 4.2 STRICTLY?
    // "New Element: Boss Enhance". Only implies they get stronger?
    // Let's spawn Bosses at wave 5/10 regardless, but strictly gate types.

    for (int wave = 1; wave <= 10; wave++) {
      final List<MonsterSpawn> spawns = [];

      // HP scaling is handled in spawnMonster
      int totalCount = 5 + (wave * 2) + (stage * 1); // Slight stage scaling

      if (wave % 5 == 0) {
        // Boss Wave (5, 10)
        spawns.add(MonsterSpawn(MonsterType.boss, 1));

        // Minions
        spawns.add(MonsterSpawn(MonsterType.basic, totalCount ~/ 2));
      } else {
        // Normal Waves
        // Distribution Pool
        List<MonsterType> allowedTypes = [MonsterType.basic];
        if (enableFast) allowedTypes.add(MonsterType.fast);
        if (enableTank) allowedTypes.add(MonsterType.tank);
        if (enableAir && wave >= 5)
          allowedTypes.add(MonsterType.air); // Air only later in wave?

        // Distribute count among allowed types
        int splitCount = totalCount ~/ allowedTypes.length;
        int remainder = totalCount % allowedTypes.length;

        for (final type in allowedTypes) {
          spawns.add(MonsterSpawn(type, splitCount));
        }
        if (remainder > 0)
          spawns.add(MonsterSpawn(MonsterType.basic, remainder));
      }

      // Interval scaling
      double interval = max(0.4, 1.5 - (wave * 0.1) - (min(stage, 20) * 0.02));

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
    // Calculate Scaled Stats
    // Monster HP = Base * (1 + Stage * 0.15)
    final stats = MonsterStats.get(type);
    final hpMultiplier = 1.0 + (_stage * 0.15);
    final scaledHp = stats.maxHp * hpMultiplier;
    // Maybe speed increases slightly too?

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
