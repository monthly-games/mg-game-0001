import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../tower_defense_game.dart';

class GhostTower extends PositionComponent
    with HasGameReference<TowerDefenseGame> {
  final double range;
  bool isValid = true;
  late final Sprite baseSprite;
  late final Sprite turretSprite;

  GhostTower({required Vector2 position, this.range = 150.0})
    : super(position: position, size: Vector2.all(40), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    baseSprite = await game.loadSprite('tower_base.png');
    turretSprite = await game.loadSprite('tower_turret.png');
    await super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw Range Indicator
    final rangePaint = Paint()
      ..color = isValid
          ? Colors.white.withOpacity(0.3)
          : Colors.red.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), range, rangePaint);

    final rangeBorder = Paint()
      ..color = isValid ? Colors.white : Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0; // Thicker border
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), range, rangeBorder);

    // Draw Ghost Body (Polished)
    final ghostPaint = Paint()
      ..color = isValid
          ? Colors.white.withOpacity(0.5)
          : Colors.red.withOpacity(0.5);

    // 1. Draw Base Sprite
    baseSprite.render(
      canvas,
      position: Vector2.zero(),
      size: size,
      overridePaint: ghostPaint,
    );

    // 2. Draw Turret Sprite
    turretSprite.render(
      canvas,
      position: Vector2.zero(),
      size: size,
      overridePaint: ghostPaint,
    );
  }
}
