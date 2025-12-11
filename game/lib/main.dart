import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/core/ui/theme/game_theme.dart';
import 'package:mg_common_game/core/ui/overlays/game_toast.dart';
import 'package:mg_common_game/core/ui/layouts/game_scaffold.dart';
import 'package:mg_common_game/core/economy/gold_manager.dart';
import 'ui/hud/game_hud.dart';
import 'game/tower_defense_game.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:mg_common_game/core/ui/screens/game_loading_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Try to initialize Firebase.
  // Note: This will fail at runtime if firebase_options.dart is still the placeholder.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Firebase init failed: $e');
    // We don't crash the app, just log it, so development can continue without valid config
  }

  GetIt.I.registerSingleton(ToastManager());
  // Ensure GoldManager is registered if not already (it might be by shared init, but let's be safe for this app)
  if (!GetIt.I.isRegistered<GoldManager>()) {
    GetIt.I.registerSingleton(GoldManager());
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tower Defense',
      theme: GameTheme.darkTheme,
      home: _isLoading
          ? GameLoadingScreen(
              images: const ['bg_lobby.png', 'icon_gold.png', 'icon_gem.png'],
              audio: const [], // Add audio later when files exist
              backgroundImage: 'assets/images/bg_lobby.png',
              onFinished: () {
                setState(() {
                  _isLoading = false;
                });
              },
            )
          : const GamePage(),
    );
  }
}

class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GameToastOverlay(
      manager: GetIt.I<ToastManager>(),
      child: GameScaffold(
        backgroundImage: 'assets/images/bg_lobby.png',
        body: GameWidget<TowerDefenseGame>(
          game: TowerDefenseGame(),
          initialActiveOverlays: const ['HUD'],
          overlayBuilderMap: {
            'HUD': (BuildContext context, TowerDefenseGame game) {
              return StreamBuilder<int>(
                stream: GetIt.I<GoldManager>().onGoldChanged,
                initialData: GetIt.I<GoldManager>().currentGold,
                builder: (context, snapshot) {
                  return GameHud(
                    gold: snapshot.data ?? 0,
                    wave: game.currentWave,
                    onBuildTower: game.buildTower,
                    onNextWave: game.startNextWave,
                  );
                },
              );
            },
          },
        ),
      ),
    );
  }
}
