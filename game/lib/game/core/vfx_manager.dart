import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:mg_common_game/core/engine/effects/flame_effects.dart';

/// VFX Manager for tower defense specific visual effects
class VfxManager extends Component with HasGameReference {
  VfxManager();

  /// Show tower attack effect - muzzle flash particle
  void showTowerAttack(Vector2 position, Color color) {
    game.add(
      FlameParticleEffect.hit(
        position: position.clone(),
        color: color,
      ),
    );
  }

  /// Show monster death effect - explosion + coins
  void showMonsterDeath(Vector2 position, {int goldReward = 0}) {
    // Explosion effect
    game.add(
      FlameParticleEffect.explosion(
        position: position.clone(),
        color: Colors.orange,
      ),
    );

    // Gold coins effect if there's a reward
    if (goldReward > 0) {
      game.add(
        FlameParticleEffect.sparkle(
          position: position.clone() + Vector2(0, -10),
          color: Colors.amber,
        ),
      );
    }
  }

  /// Show bullet impact effect
  void showBulletImpact(Vector2 position, {bool isSplash = false}) {
    game.add(
      FlameParticleEffect.hit(
        position: position.clone(),
        color: isSplash ? Colors.red : Colors.white,
        isCritical: isSplash,
      ),
    );
  }

  /// Show wave complete celebration effect
  void showWaveComplete(Vector2 position) {
    // Multi-colored celebration particles
    game.add(
      FlameParticleEffect.sparkle(
        position: position.clone(),
        color: Colors.green,
      ),
    );

    // Add secondary burst
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!isMounted) return;
      game.add(
        FlameParticleEffect.sparkle(
          position: position.clone(),
          color: Colors.yellow,
        ),
      );
    });
  }

  /// Show boss kill effect with screen shake
  void showBossKill(Vector2 position) {
    // Large explosion
    game.add(
      FlameParticleEffect.explosion(
        position: position.clone(),
        color: Colors.purple,
        radius: 120,
      ),
    );

    // Screen shake effect
    (game.camera.viewport as Component).add(
      FlameScreenShake(
        intensity: 8.0,
        duration: 0.8,
      ),
    );
  }

  /// Show damage number
  void showDamageNumber(Vector2 position, double damage, {Color? color}) {
    game.add(
      FlameDamageNumber(
        amount: damage.toInt(),
        position: position.clone(),
        color: color,
      ),
    );
  }

  /// Show tower upgrade effect
  void showTowerUpgrade(Vector2 position) {
    game.add(
      FlameParticleEffect.sparkle(
        position: position.clone(),
        color: Colors.yellow,
      ),
    );
  }

  /// Show tower build effect
  void showTowerBuild(Vector2 position) {
    game.add(
      FlameParticleEffect.sparkle(
        position: position.clone(),
        color: Colors.green,
      ),
    );
  }

  /// Show slow effect indicator
  void showSlowEffect(Vector2 position) {
    game.add(
      FlameParticleEffect.sparkle(
        position: position.clone(),
        color: Colors.lightBlue,
      ),
    );
  }
}
