import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/effects.dart';
import '../tower_defense_game.dart';

class Monster extends PositionComponent
    with CollisionCallbacks, HasGameReference<TowerDefenseGame> {
  final List<Vector2> path;
  int _currentPathIndex = 0;
  final double speed;
  double hp;
  final double maxHp;

  Monster({required this.path, this.speed = 100.0, this.maxHp = 100.0})
    : hp = maxHp,
      super(size: Vector2.all(32), anchor: Anchor.center) {
    if (path.isNotEmpty) {
      position = path[0];
    }
  }

  @override
  Future<void> onLoad() async {
    add(CircleHitbox());
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()..color = const Color(0xFFFF0000); // Red
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, paint);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (path.isEmpty || _currentPathIndex >= path.length) return;

    final target = path[_currentPathIndex];
    final direction = (target - position).normalized();
    final movement = direction * speed * dt;

    if (position.distanceTo(target) < speed * dt) {
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

  void takeDamage(double amount) {
    hp -= amount;

    // Visual Feedback: Flash White
    add(
      ColorEffect(
        const Color(0xFFFFFFFF),
        EffectController(duration: 0.1, reverseDuration: 0.1),
        opacityTo: 0.7,
      ),
    );

    if (hp <= 0) {
      removeFromParent(); // Die
    }
  }
}
