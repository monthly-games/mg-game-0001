import 'dart:ui';
import 'package:flame/components.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/core/economy/gold_manager.dart';
import 'package:flame/collisions.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart'; // For Colors
import 'package:mg_common_game/core/ui/components/floating_text_component.dart';
import '../tower_defense_game.dart';
import 'monster_type.dart';

class Monster extends PositionComponent
    with CollisionCallbacks, HasGameReference<TowerDefenseGame> {
  final List<Vector2> path;
  int _currentPathIndex = 0;
  final MonsterType monsterType;
  final double speed;
  double hp;
  final double maxHp;
  final int goldReward;
  late final Sprite monsterSprite;

  // Slow effect
  double _slowMultiplier = 1.0;
  double _slowDuration = 0.0;

  Monster({
    required this.path,
    this.monsterType = MonsterType.basic,
    double? speed,
    double? maxHp,
    int? goldReward,
  })  : speed = speed ?? MonsterStats.get(monsterType).speed,
        maxHp = maxHp ?? MonsterStats.get(monsterType).maxHp,
        goldReward = goldReward ?? MonsterStats.get(monsterType).goldReward,
        hp = maxHp ?? MonsterStats.get(monsterType).maxHp,
        super(size: Vector2.all(32), anchor: Anchor.center) {
    if (path.isNotEmpty) {
      position = path[0];
    }
  }

  double get currentSpeed => speed * _slowMultiplier;

  @override
  Future<void> onLoad() async {
    final stats = MonsterStats.get(monsterType);
    try {
      monsterSprite = await game.loadSprite(stats.spriteName);
    } catch (e) {
      // Fallback to basic monster sprite
      monsterSprite = await game.loadSprite('monster_orc.png');
    }
    add(CircleHitbox());
  }

  @override
  void render(Canvas canvas) {
    // Shadow
    canvas.drawOval(
      Rect.fromLTWH(0, size.y - 4, size.x, 8),
      Paint()..color = Colors.black.withOpacity(0.3),
    );

    super.render(canvas);

    // Body Sprite (tint blue if slowed)
    if (_slowDuration > 0) {
      final paint = Paint()..colorFilter = const ColorFilter.mode(
        Colors.lightBlue,
        BlendMode.modulate,
      );
      canvas.saveLayer(Rect.fromLTWH(0, 0, size.x, size.y), paint);
      monsterSprite.render(canvas, position: Vector2.zero(), size: size);
      canvas.restore();
    } else {
      monsterSprite.render(canvas, position: Vector2.zero(), size: size);
    }

    // HP Bar
    if (hp < maxHp) {
      final barWidth = size.x + 10;
      final barHeight = 4.0;
      final barX = (size.x - barWidth) / 2;
      final barY = -8.0;

      // Background (Red/Empty)
      canvas.drawRect(
        Rect.fromLTWH(barX, barY, barWidth, barHeight),
        Paint()..color = Colors.red.withOpacity(0.8),
      );

      // Foreground (Green/Current)
      final hpPercent = hp / maxHp;
      canvas.drawRect(
        Rect.fromLTWH(barX, barY, barWidth * hpPercent, barHeight),
        Paint()..color = Colors.green,
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update slow effect
    if (_slowDuration > 0) {
      _slowDuration -= dt;
      if (_slowDuration <= 0) {
        _slowMultiplier = 1.0;
      }
    }

    if (path.isEmpty || _currentPathIndex >= path.length) return;

    final target = path[_currentPathIndex];
    final direction = (target - position).normalized();
    final effectiveSpeed = currentSpeed;
    final movement = direction * effectiveSpeed * dt;

    if (position.distanceTo(target) < effectiveSpeed * dt) {
      position = target;
      _currentPathIndex++;
    } else {
      position += movement;
    }

    if (_currentPathIndex >= path.length) {
      // Reached end - Leak
      game.decreaseLives(1);
      removeFromParent();
    }
  }

  void applySlow(double slowMultiplier, double duration) {
    _slowMultiplier = slowMultiplier;
    _slowDuration = duration;

    // Visual feedback
    game.add(
      FloatingTextComponent(
        text: 'SLOW',
        position: position.clone() + Vector2(0, -20),
        color: Colors.lightBlue,
        fontSize: 14,
      ),
    );
  }

  void takeDamage(double amount) {
    hp -= amount;

    // Visual Feedback: Flash White (Removed due to crash - needs HasPaint)
    // add(
    //   ColorEffect(
    //     const Color(0xFFFFFFFF),
    //     EffectController(duration: 0.1, reverseDuration: 0.1),
    //     opacityTo: 0.7,
    //   ),
    // );

    // Visual Feedback: Damage Text
    game.add(
      FloatingTextComponent(
        text: '-${amount.toInt()}',
        position: position.clone() + Vector2(0, -10), // Spawn above monster
        color: Colors.white,
        fontSize: 16,
      ),
    );

    if (hp <= 0) {
      // Reward Gold
      GetIt.I<GoldManager>().addGold(goldReward);
      game.addGoldEarned(goldReward);
      removeFromParent(); // Die
    }
  }
}
