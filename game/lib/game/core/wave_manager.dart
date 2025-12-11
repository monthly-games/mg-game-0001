import 'package:flame/components.dart';
import '../tower_defense_game.dart';
import '../entities/monster.dart';
import 'map_system.dart';

class WaveDefinition {
  final int monsterCount;
  final double spawnInterval;
  final double monsterSpeed;
  final double monsterIp; // Todo: HP scaling

  const WaveDefinition({
    required this.monsterCount,
    this.spawnInterval = 1.0,
    this.monsterSpeed = 100.0,
    this.monsterIp = 100.0,
  });
}

class WaveManager extends Component with HasGameReference<TowerDefenseGame> {
  final MapSystem mapSystem;

  // Wave Configs
  final List<WaveDefinition> _waves = [
    const WaveDefinition(
      monsterCount: 5,
      spawnInterval: 1.5,
      monsterSpeed: 80.0,
    ),
    const WaveDefinition(
      monsterCount: 10,
      spawnInterval: 1.0,
      monsterSpeed: 100.0,
    ),
    const WaveDefinition(
      monsterCount: 15,
      spawnInterval: 0.8,
      monsterSpeed: 120.0,
    ),
  ];

  int _currentWaveIndex = -1; // -1 means before start
  int _monstersSpawned = 0;
  double _spawnTimer = 0;
  bool _isWaveActive = false;

  WaveManager({required this.mapSystem});

  int get currentWave => _currentWaveIndex + 1;
  int get totalWaves => _waves.length;

  void startNextWave() {
    if (_isWaveActive) return; // Already running
    if (_currentWaveIndex >= _waves.length - 1) return; // Max wave reached

    _currentWaveIndex++;
    _monstersSpawned = 0;
    _spawnTimer = 0;
    _isWaveActive = true;
    print('Wave ${currentWave} Started!');
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!_isWaveActive) return;

    final waveConfig = _waves[_currentWaveIndex];

    // Spawning Logic
    if (_monstersSpawned < waveConfig.monsterCount) {
      _spawnTimer += dt;
      if (_spawnTimer >= waveConfig.spawnInterval) {
        _spawnTimer = 0;
        _spawnMonster(waveConfig);
        _monstersSpawned++;
      }
    } else {
      // All spawned, check if wave is cleared (all monsters dead)
      // For now, we just auto-end wave when spawning finishes?
      // No, we should wait until all monsters are gone.
      final activeMonsters = game.children.whereType<Monster>();
      if (activeMonsters.isEmpty) {
        _onWaveComplete();
      }
    }
  }

  void _spawnMonster(WaveDefinition config) {
    final monster = Monster(
      path: mapSystem.getPath(),
      speed: config.monsterSpeed,
      maxHp: config.monsterIp,
    );
    game.add(monster);
  }

  void _onWaveComplete() {
    print('Wave ${currentWave} Complete!');
    _isWaveActive = false;
    // Notify Game/HUD (via Game class or callback)
  }
}
