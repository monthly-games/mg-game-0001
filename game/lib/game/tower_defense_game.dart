import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/core/engine/core_game.dart';
import 'package:mg_common_game/core/ui/overlays/game_toast.dart';
import 'core/map_system.dart';
import 'core/wave_manager.dart';
import 'entities/tower.dart';

class TowerDefenseGame extends CoreGame with HasCollisionDetection {
  late final MapSystem mapSystem;
  late final WaveManager waveManager;
  int lives = 20;

  @override
  Color backgroundColor() => const Color(0xFF222222); // Dark Grey

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    print('TowerDefenseGame Loaded!');

    // Show Welcome Toast
    GetIt.I<ToastManager>().show(
      'Welcome to Tower Defense!',
      backgroundColor: Colors.blueAccent,
    );

    mapSystem = MapSystem();
    add(mapSystem);

    camera.viewfinder.anchor = Anchor.topLeft;

    // Test Tower
    add(Tower(position: mapSystem.getPosition(2, 2)));
    add(Tower(position: mapSystem.getPosition(4, 3))); // Second tower

    // Wave Manager
    waveManager = WaveManager(mapSystem: mapSystem);
    add(waveManager);
  }

  int get currentWave => waveManager.currentWave;

  void decreaseLives(int amount) {
    lives -= amount;
    if (lives <= 0) {
      lives = 0;
      pauseEngine();
      GetIt.I<ToastManager>().show('GAME OVER', backgroundColor: Colors.red);
      print('GAME OVER');
    } else {
      GetIt.I<ToastManager>().show(
        'Lives: $lives',
        backgroundColor: Colors.orange,
      );
    }
  }

  void buildTower() {
    print('Build Tower Pressed');
    GetIt.I<ToastManager>().show('Build Mode Active (Click Map to Build)');
  }

  void startNextWave() {
    print('Next Wave Pressed');
    waveManager.startNextWave();
    GetIt.I<ToastManager>().show('Wave ${waveManager.currentWave} Started!');
  }
}
