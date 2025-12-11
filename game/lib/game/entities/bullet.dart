import 'dart:ui';
import 'package:flame/components.dart';
import 'monster.dart';

import 'package:flame/collisions.dart';

class Bullet extends PositionComponent with CollisionCallbacks {
  final Monster target;
  final double speed = 300.0;
  final double damage;

  Bullet({
    required Vector2 position,
    required this.target,
    required this.damage,
  }) : super(position: position, size: Vector2.all(5), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    add(CircleHitbox());
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()..color = const Color(0xFFFFFF00); // Yellow
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), 3, paint);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (target.isRemoved) {
      removeFromParent(); // Target dead/gone
      return;
    }

    final direction = (target.position - position).normalized();
    position += direction * speed * dt;
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Monster && other == target) {
      other.takeDamage(damage);
      removeFromParent(); // Hit
    }
  }
}
