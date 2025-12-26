# Quick Apply Guide for Polish System

## Step 1: Import VfxManager in tower_defense_game.dart

Add this import after line 17:
```dart
import 'core/vfx_manager.dart';
```

Add this field after line 24 (after `late final WaveManager waveManager;`):
```dart
late final VfxManager vfxManager;
```

In `onLoad()` method, after line 117 (after `camera.viewfinder.anchor = Anchor.topLeft;`), add:
```dart
// Initialize VFX Manager
vfxManager = VfxManager();
add(vfxManager);
```

In `_tryBuildTower()` method, after the tower is added (after line 235), add:
```dart
// Show build effect
vfxManager.showTowerBuild(position);
```

In `upgradeTower()` method, after `_selectedTower!.upgrade();` (after line 396), add:
```dart
// Show upgrade effect
vfxManager.showTowerUpgrade(_selectedTower!.position);
```

In `onStageComplete()` method, after `GetIt.I<GoldManager>().addGold(stageReward);` (after line 306), add:
```dart
// Show wave complete effect
vfxManager.showWaveComplete(Vector2(size.x / 2, size.y / 2));
```

## Step 2: Update tower.dart

Add this method at the end of the Tower class (before the closing brace):
```dart
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

In `_tryAttack()` method, after `if (target != null) {` (line 180), add:
```dart
// Show tower attack effect
game.vfxManager.showTowerAttack(position, _getAttackColor());
```

## Step 3: Update bullet.dart

In `_applyDamage()` method:

After `if (isSplash) {` (line 70), add:
```dart
// Show splash impact effect
game.vfxManager.showBulletImpact(target.position, isSplash: true);
```

In the else block (line 80), after `} else {`, add:
```dart
// Show normal impact effect
game.vfxManager.showBulletImpact(target.position, isSplash: false);
```

## Step 4: Update monster.dart

In `takeDamage()` method, replace lines 148-176 with:
```dart
void takeDamage(double amount) {
  hp -= amount;

  // Show damage number using VFX Manager
  game.vfxManager.showDamageNumber(position, amount);

  if (hp <= 0) {
    // Check if this is a boss
    final isBoss = monsterType == MonsterType.boss;

    if (isBoss) {
      // Show boss kill effect with screen shake
      game.vfxManager.showBossKill(position);
    } else {
      // Show monster death effect with gold reward
      game.vfxManager.showMonsterDeath(position, goldReward: goldReward);
    }

    // Reward Gold
    GetIt.I<GoldManager>().addGold(goldReward);
    game.addGoldEarned(goldReward);
    removeFromParent(); // Die
  }
}
```

In `applySlow()` method, after `_slowDuration = duration;` (line 135), add:
```dart
// Show slow effect using VFX Manager
game.vfxManager.showSlowEffect(position);
```

## Step 5: Update wave_manager.dart

In `_onWaveComplete()` method, after `_isWaveActive = false;` (line 177), add:
```dart
// Show wave complete effect
final centerPos = Vector2(
  game.size.x / 2,
  game.size.y / 2,
);
game.vfxManager.showWaveComplete(centerPos);
```

## Files Modified Summary:
1. ✓ `core/vfx_manager.dart` - CREATED
2. `tower_defense_game.dart` - 5 changes
3. `entities/tower.dart` - 2 changes
4. `entities/bullet.dart` - 2 changes
5. `entities/monster.dart` - 3 changes
6. `core/wave_manager.dart` - 1 change

Total: 13 code additions across 5 files
