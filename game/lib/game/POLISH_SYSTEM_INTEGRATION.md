# Polish System Integration Guide for MG-0001

This document outlines the changes needed to integrate the polish system (VfxManager) into MG-0001 (Simple Tower Defense).

## Files Created

### 1. VfxManager (`d:/mg-games/repos/mg-game-0001/game/lib/game/core/vfx_manager.dart`)
- Already created with all tower defense specific effects
- Imports FlameParticleEffect, FlameDamageNumber, and FlameScreenShake from mg_common_game

## Files to Modify

### 2. TowerDefenseGame (`d:/mg-games/repos/mg-game-0001/game/lib/game/tower_defense_game.dart`)

#### Add Import:
```dart
import 'core/vfx_manager.dart';
```

#### Add Field:
```dart
class TowerDefenseGame extends CoreGame with HasCollisionDetection {
  late final MapSystem mapSystem;
  late final WaveManager waveManager;
  late final VfxManager vfxManager;  // ADD THIS
  final AudioManager audio = GetIt.I<AudioManager>();
  ...
```

#### Initialize in onLoad():
```dart
@override
Future<void> onLoad() async {
  await super.onLoad();
  logger.i('TowerDefenseGame Loaded!');

  // ... existing code ...

  mapSystem = MapSystem();
  add(mapSystem);

  camera.viewfinder.anchor = Anchor.topLeft;

  // Initialize VFX Manager
  vfxManager = VfxManager();
  add(vfxManager);

  // Wave Manager with stage info
  waveManager = WaveManager(mapSystem: mapSystem, stageInfo: _stageInfo);
  add(waveManager);
}
```

#### Update _tryBuildTower():
```dart
void _tryBuildTower(int gx, int gy) {
  final stats = TowerStats.get(_selectedTowerType);
  final towerCost = stats.cost;

  if (GetIt.I<GoldManager>().trySpendGold(towerCost)) {
    final position = mapSystem.getPosition(gx, gy);

    // Build
    add(
      Tower(
        position: position,
        towerType: _selectedTowerType,
      ),
    );

    // Show build effect
    vfxManager.showTowerBuild(position);  // ADD THIS

    audio.playSfx('build.wav');
    GetIt.I<ToastManager>().show(
      '${stats.name} Built!',
      backgroundColor: Colors.green,
    );
  } else {
    // ... existing error handling ...
  }
}
```

#### Update upgradeTower():
```dart
void upgradeTower() {
  if (_selectedTower == null || !_selectedTower!.canUpgrade()) return;

  final upgradeCost = _selectedTower!.getUpgradeCost();
  if (GetIt.I<GoldManager>().trySpendGold(upgradeCost)) {
    _selectedTower!.upgrade();

    // Show upgrade effect
    vfxManager.showTowerUpgrade(_selectedTower!.position);  // ADD THIS

    audio.playSfx('upgrade.wav');
    // ... rest of the code ...
  }
}
```

#### Update onStageComplete():
```dart
void onStageComplete() {
  int stageReward = 200 + (waveManager.currentStage * 50);
  GetIt.I<GoldManager>().addGold(stageReward);

  // Show wave complete effect
  vfxManager.showWaveComplete(Vector2(size.x / 2, size.y / 2));  // ADD THIS

  GetIt.I<ToastManager>().show(
    'Stage ${waveManager.currentStage} Complete! +${stageReward}g',
    backgroundColor: Colors.purple,
  );
  // ... rest of the code ...
}
```

### 3. Tower (`d:/mg-games/repos/mg-game-0001/game/lib/game/entities/tower.dart`)

#### Add helper method for attack color:
```dart
// Add after the _slowAttack method
Color _getAttackColor() {
  switch (towerType) {
    case TowerType.basic:
      return Colors.yellow;
    case TowerType.splash:
      return Colors.orange;
    case TowerType.slow:
      return Colors.lightBlue;
    case TowerType.sniper:
      return Colors.red;
    case TowerType.air:
      return Colors.cyan;
    default:
      return Colors.white;
  }
}
```

#### Update _tryAttack() method:
```dart
if (target != null) {
  // Show tower attack effect
  game.vfxManager.showTowerAttack(position, _getAttackColor());  // ADD THIS

  // Special behavior based on tower type
  switch (towerType) {
    case TowerType.splash:
      _splashAttack(target);
      break;
    case TowerType.slow:
      _slowAttack(target);
      break;
    default:
      game.add(
        Bullet(position: position.clone(), target: target, damage: damage),
      );
  }

  // ... rest of the existing code ...
}
```

### 4. Bullet (`d:/mg-games/repos/mg-game-0001/game/lib/game/entities/bullet.dart`)

#### Update _applyDamage() method:
```dart
void _applyDamage() {
  if (isSplash) {
    // Show splash impact effect
    game.vfxManager.showBulletImpact(target.position, isSplash: true);  // ADD THIS

    // Splash damage to all monsters in radius
    final monsters = game.children.whereType<Monster>();
    for (final monster in monsters) {
      final dist = target.position.distanceTo(monster.position);
      if (dist <= splashRadius) {
        final splashDamage = damage * (1.0 - dist / splashRadius * 0.5);
        monster.takeDamage(splashDamage);
      }
    }
  } else {
    // Show normal impact effect
    game.vfxManager.showBulletImpact(target.position, isSplash: false);  // ADD THIS
    target.takeDamage(damage);
  }

  if (appliesSlow) {
    target.applySlow(0.5, 2.0); // 50% slow for 2 seconds
  }
}
```

### 5. Monster (`d:/mg-games/repos/mg-game-0001/game/lib/game/entities/monster.dart`)

#### Update takeDamage() method:
```dart
void takeDamage(double amount) {
  hp -= amount;

  // Show damage number using VFX Manager
  game.vfxManager.showDamageNumber(position, amount);  // ADD THIS

  if (hp <= 0) {
    // Check if this is a boss
    final isBoss = monsterType == MonsterType.boss;

    if (isBoss) {
      // Show boss kill effect with screen shake
      game.vfxManager.showBossKill(position);  // ADD THIS
    } else {
      // Show monster death effect with gold reward
      game.vfxManager.showMonsterDeath(position, goldReward: goldReward);  // ADD THIS
    }

    // Reward Gold
    GetIt.I<GoldManager>().addGold(goldReward);
    game.addGoldEarned(goldReward);
    removeFromParent(); // Die
  }
}
```

#### Update applySlow() method:
```dart
void applySlow(double slowMultiplier, double duration) {
  _slowMultiplier = slowMultiplier;
  _slowDuration = duration;

  // Show slow effect using VFX Manager
  game.vfxManager.showSlowEffect(position);  // ADD THIS

  // Keep the floating text for additional feedback
  game.add(
    FloatingTextComponent(
      text: 'SLOW',
      position: position.clone() + Vector2(0, -20),
      color: Colors.lightBlue,
      fontSize: 14,
    ),
  );
}
```

### 6. WaveManager (`d:/mg-games/repos/mg-game-0001/game/lib/game/core/wave_manager.dart`)

#### Update _onWaveComplete() method:
```dart
void _onWaveComplete() {
  print('Wave $currentWave Complete!');
  _isWaveActive = false;

  // Show wave complete effect
  final centerPos = Vector2(
    game.size.x / 2,
    game.size.y / 2,
  );
  game.vfxManager.showWaveComplete(centerPos);  // ADD THIS

  // Check if Stage Complete (Wave 10 done)
  if (_currentWaveIndex == _waves.length - 1) {
    // Stage Complete!
    game.onStageComplete();
  }
}
```

## Summary of Effects Used

1. **FlameParticleEffect** - Used for:
   - Tower attacks (muzzle flash)
   - Monster deaths (explosion + coins)
   - Bullet impacts (splash and normal)
   - Tower build and upgrade celebrations
   - Wave completion celebrations
   - Boss kills
   - Slow effect indicators

2. **FlameDamageNumber** - Used for:
   - Displaying damage dealt to monsters

3. **FlameScreenShake** - Used for:
   - Boss kill dramatic effect

## Testing Checklist

- [ ] Tower attacks show muzzle flash particles
- [ ] Monster deaths show explosion effects
- [ ] Gold rewards show coin particles
- [ ] Boss kills trigger screen shake
- [ ] Bullet impacts show appropriate effects (different for splash vs normal)
- [ ] Damage numbers appear above monsters when hit
- [ ] Tower builds show green celebration particles
- [ ] Tower upgrades show yellow upgrade particles
- [ ] Wave completion shows celebration effect
- [ ] Slow effects show blue particle indicators

## Notes

- All effects use the FlameEffects system from `package:mg_common_game/core/engine/effects/flame_effects.dart`
- Colors are customized per effect type for better gameplay feedback
- Particle counts and durations are tuned for tower defense gameplay feel
- Effects are non-blocking and purely visual - they don't affect gameplay logic
