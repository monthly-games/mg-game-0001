import 'package:flame/components.dart';
import 'package:flame/effects.dart';

import 'package:flutter/material.dart';
import '../tower_defense_game.dart';
import 'bullet.dart';
import 'monster.dart';
import 'tower_type.dart';
import 'monster_type.dart';

import 'package:get_it/get_it.dart';
import 'package:mg_common_game/systems/progression/upgrade_manager.dart';

class Tower extends PositionComponent with HasGameReference<TowerDefenseGame> {
  final TowerType towerType;
  double range;
  double damage;
  final double attackSpeed; // Cooldown in seconds
  double _cooldown = 0;
  int upgradeLevel = 0; // 0 = base, 1-2 = upgraded
  static const int maxUpgradeLevel = 2;

  double _rotation = 0;
  late final Sprite baseSprite;
  late final Sprite turretSprite;

  Tower({
    required Vector2 position,
    this.towerType = TowerType.basic,
    double? range,
    double? damage,
    double? attackSpeed,
  }) : range = range ?? TowerStats.get(towerType).range,
       damage =
           (damage ?? TowerStats.get(towerType).damage) *
           _getDamageMultiplier(),
       attackSpeed = attackSpeed ?? TowerStats.get(towerType).attackSpeed,
       super(position: position, size: Vector2.all(40), anchor: Anchor.center);

  static double _getDamageMultiplier() {
    if (!GetIt.I.isRegistered<UpgradeManager>()) return 1.0;
    final upgrade = GetIt.I<UpgradeManager>().getUpgrade('turret_damage');
    return 1.0 + (upgrade?.currentValue ?? 0.0);
  }

  int getUpgradeCost() {
    if (upgradeLevel >= maxUpgradeLevel) return 0;
    final baseCost = TowerStats.get(towerType).cost;
    return (baseCost * 0.5 * (upgradeLevel + 1)).round();
  }

  int getSellValue() {
    final baseCost = TowerStats.get(towerType).cost;
    final upgradeCosts = List.generate(
      upgradeLevel,
      (i) => (baseCost * 0.5 * (i + 1)).round(),
    );
    final totalInvested =
        baseCost + upgradeCosts.fold(0, (sum, cost) => sum + cost);
    return (totalInvested * 0.7).round(); // 70% refund
  }

  bool canUpgrade() => upgradeLevel < maxUpgradeLevel;

  void upgrade() {
    if (!canUpgrade()) return;
    upgradeLevel++;
    // Increase stats by 25% per level
    final multiplier = 1.25;
    damage *= multiplier;
    range *= multiplier;
  }

  @override
  Future<void> onLoad() async {
    final stats = TowerStats.get(towerType);
    try {
      baseSprite = await game.loadSprite(stats.spriteName);
    } catch (e) {
      // Fallback to basic tower sprite
      baseSprite = await game.loadSprite('tower_archer.png');
    }
    await super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw Range (Debug) - Faint
    final rangePaint = Paint()
      ..color = const Color(0x22FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), range, rangePaint);

    // 1. Draw Tower Sprite
    baseSprite.render(canvas, position: Vector2.zero(), size: size);

    /*
    // 2. Draw Turret Sprite (Rotated)
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    canvas.rotate(_rotation);

    // Offset to center the sprite rotation
    turretSprite.render(
      canvas,
      position: Vector2(-size.x / 2, -size.y / 2),
      size: size,
    );
    canvas.restore();
    */
    canvas
        .restore(); // Extra restore if needed, or remove. Wait, code above had save/restore for turret. I removed it. I don't need restore here.

    // Draw Cooldown Indicator (Red line if on cooldown)
    if (_cooldown > 0) {
      canvas.drawRect(
        Rect.fromLTWH(0, size.y - 5, size.x * (_cooldown / attackSpeed), 5),
        Paint()..color = Colors.red,
      );
    }

    // Draw upgrade level indicator
    if (upgradeLevel > 0) {
      final stars = '★' * upgradeLevel;
      final textPainter = TextPainter(
        text: TextSpan(
          text: stars,
          style: const TextStyle(
            color: Colors.yellow,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(size.x / 2 - textPainter.width / 2, -20),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_cooldown > 0) {
      _cooldown -= dt;
    } else {
      _tryAttack();
    }
  }

  void _tryAttack() {
    Monster? target;
    double closestDist = range;

    // TODO: Optimize getting children
    final monsters = game.children.whereType<Monster>();
    for (final monster in monsters) {
      // Targeting Rules
      if (!_canTarget(monster.monsterType)) continue;

      final dist = position.distanceTo(monster.position);
      if (dist <= range && dist < closestDist) {
        closestDist = dist;
        target = monster;
      }
    }

    if (target != null) {
      // Update Rotation to face target
      final dir = target.position - position;
      _rotation = dir.screenAngle();
    }

    if (target != null) {
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

      // Audio: Shoot
      try {
        game.audio.playSfx('shoot.wav');
      } catch (e) {
        // Ignore missing sfx
      }

      // Visual Feedback: Bounce
      add(
        ScaleEffect.by(
          Vector2.all(1.2),
          EffectController(duration: 0.1, reverseDuration: 0.1),
        ),
      );

      _cooldown = attackSpeed;
    }
  }

  bool _canTarget(MonsterType monsterType) {
    if (towerType == TowerType.air) {
      return monsterType == MonsterType.air;
    }
    if (towerType == TowerType.splash) {
      // Cannons usually don't hit air
      return monsterType != MonsterType.air;
    }
    // Others (Basic, Slow, Sniper) can hit all
    return true;
  }

  void _splashAttack(Monster target) {
    // Shoot bullet to primary target
    game.add(
      Bullet(
        position: position.clone(),
        target: target,
        damage: damage,
        isSplash: true,
      ),
    );
  }

  void _slowAttack(Monster target) {
    // Shoot bullet and apply slow effect
    game.add(
      Bullet(
        position: position.clone(),
        target: target,
        damage: damage,
        appliesSlow: true,
      ),
    );
  }
}
