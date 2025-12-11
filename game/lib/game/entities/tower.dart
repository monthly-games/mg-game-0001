import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/core/audio/audio_manager.dart';
import '../tower_defense_game.dart';
import 'bullet.dart';
import 'monster.dart';

class Tower extends PositionComponent with HasGameReference<TowerDefenseGame> {
  final double range;
  final double damage;
  final double attackSpeed; // Cooldown in seconds
  double _cooldown = 0;

  Tower({
    required Vector2 position,
    this.range = 150.0,
    this.damage = 25.0,
    this.attackSpeed = 1.0,
  }) : super(position: position, size: Vector2.all(40), anchor: Anchor.center);

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw Range (Debug) - Faint
    final rangePaint = Paint()
      ..color = const Color(0x22FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), range, rangePaint);

    // Draw Turret Body
    final bodyPaint = Paint()..color = const Color(0xFF00AAFF); // Blue
    canvas.drawRect(size.toRect(), bodyPaint);

    // Draw Cooldown Indicator (Red line if on cooldown)
    if (_cooldown > 0) {
      canvas.drawRect(
        Rect.fromLTWH(0, size.y - 5, size.x * (_cooldown / attackSpeed), 5),
        Paint()..color = const Color(0xFFFF0000),
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
      final dist = position.distanceTo(monster.position);
      if (dist <= range && dist < closestDist) {
        closestDist = dist;
        target = monster;
      }
    }

    if (target != null) {
      game.add(
        Bullet(position: position.clone(), target: target, damage: damage),
      );

      // Audio: Shoot
      try {
        GetIt.I<AudioManager>().playSfx('sfx_shoot.wav');
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
}
