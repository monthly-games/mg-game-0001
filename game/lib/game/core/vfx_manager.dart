import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:mg_common_game/core/engine/effects/flame_effects.dart';
import '../tower_defense_game.dart';

/// VFX Manager for tower defense specific visual effects
class VfxManager extends Component with HasGameReference<TowerDefenseGame> {
  VfxManager();

  /// Show tower attack effect - muzzle flash particle
  void showTowerAttack(Vector2 position, Color color) {
    game.add(
      FlameParticleEffect(
        position: position.clone(),
        color: color,
        particleCount: 8,
        duration: 0.3,
        spreadRadius: 20.0,
      ),
    );
  }

  /// Show monster death effect - explosion + coins
  void showMonsterDeath(Vector2 position, {int goldReward = 0}) {
    // Explosion effect
    game.add(
      FlameParticleEffect(
        position: position.clone(),
        color: Colors.orange,
        particleCount: 20,
        duration: 0.6,
        spreadRadius: 40.0,
      ),
    );

    // Gold coins effect if there's a reward
    if (goldReward > 0) {
      game.add(
        FlameParticleEffect(
          position: position.clone() + Vector2(0, -10),
          color: Colors.yellow,
          particleCount: 10,
          duration: 0.5,
          spreadRadius: 30.0,
        ),
      );
    }
  }

  /// Show bullet impact effect
  void showBulletImpact(Vector2 position, {bool isSplash = false}) {
    game.add(
      FlameParticleEffect(
        position: position.clone(),
        color: isSplash ? Colors.red : Colors.white,
        particleCount: isSplash ? 15 : 8,
        duration: 0.4,
        spreadRadius: isSplash ? 35.0 : 20.0,
      ),
    );
  }

  /// Show wave complete celebration effect
  void showWaveComplete(Vector2 position) {
    // Multi-colored celebration particles
    game.add(
      FlameParticleEffect(
        position: position.clone(),
        color: Colors.green,
        particleCount: 30,
        duration: 1.0,
        spreadRadius: 60.0,
      ),
    );

    // Add secondary burst
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!game.isMounted) return;
      game.add(
        FlameParticleEffect(
          position: position.clone(),
          color: Colors.yellow,
          particleCount: 25,
          duration: 0.8,
          spreadRadius: 50.0,
        ),
      );
    });
  }

  /// Show boss kill effect with screen shake
  void showBossKill(Vector2 position) {
    // Large explosion
    game.add(
      FlameParticleEffect(
        position: position.clone(),
        color: Colors.purple,
        particleCount: 50,
        duration: 1.2,
        spreadRadius: 80.0,
      ),
    );

    // Screen shake effect
    if (game.camera.viewport is Component) {
      (game.camera.viewport as Component).add(
        FlameScreenShake(
          intensity: 8.0,
          duration: 0.8,
        ),
      );
    }
  }

  /// Show damage number
  void showDamageNumber(Vector2 position, double damage, {Color? color}) {
    game.add(
      FlameDamageNumber(
        position: position.clone(),
        damage: damage.toInt(),
        color: color ?? Colors.white,
      ),
    );
  }

  /// Show tower upgrade effect
  void showTowerUpgrade(Vector2 position) {
    game.add(
      FlameParticleEffect(
        position: position.clone(),
        color: Colors.yellow,
        particleCount: 25,
        duration: 0.8,
        spreadRadius: 45.0,
      ),
    );
  }

  /// Show tower build effect
  void showTowerBuild(Vector2 position) {
    game.add(
      FlameParticleEffect(
        position: position.clone(),
        color: Colors.green,
        particleCount: 15,
        duration: 0.5,
        spreadRadius: 35.0,
      ),
    );
  }

  /// Show slow effect indicator
  void showSlowEffect(Vector2 position) {
    game.add(
      FlameParticleEffect(
        position: position.clone(),
        color: Colors.lightBlue,
        particleCount: 12,
        duration: 0.4,
        spreadRadius: 25.0,
      ),
    );
  }
}
