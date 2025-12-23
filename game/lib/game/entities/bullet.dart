import 'dart:ui';
import 'package:flame/components.dart';
import 'monster.dart';

import 'package:flame/collisions.dart';

// Assuming HasGameRef is needed for gameRef.loadSprite

import '../tower_defense_game.dart';

class Bullet extends SpriteComponent
    with CollisionCallbacks, HasGameReference<TowerDefenseGame> {
  final Monster target;
  final double speed = 300.0;
  final double damage;
  final bool isSplash;
  final bool appliesSlow;
  final double splashRadius;

  Bullet({
    required Vector2 position,
    required this.target,
    required this.damage,
    this.isSplash = false,
    this.appliesSlow = false,
    this.splashRadius = 80.0,
  }) : super(position: position, size: Vector2.all(32), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    sprite = await game.loadSprite('projectile_arrow.png');
    add(CircleHitbox(radius: 5, position: size / 2, anchor: Anchor.center));
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (target.isRemoved) {
      removeFromParent(); // Target dead/gone
      return;
    }

    final direction = (target.position - position).normalized();
    final distanceToTarget = position.distanceTo(target.position);
    final step = speed * dt;

    if (distanceToTarget <= step || distanceToTarget < 10.0) {
      // Manual collision check to prevent tunneling or "stopping"
      _applyDamage();
      removeFromParent();
      return;
    }

    position += direction * step;
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Monster && other == target) {
      _applyDamage();
      removeFromParent(); // Hit
    }
  }

  void _applyDamage() {
    if (isSplash) {
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
      target.takeDamage(damage);
    }

    if (appliesSlow) {
      target.applySlow(0.5, 2.0); // 50% slow for 2 seconds
    }
  }
}
