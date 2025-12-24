import 'package:mg_common_game/core/audio/audio_manager.dart';
import 'dart:ui' as ui;
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/core/engine/event_bus.dart';
import 'package:mg_common_game/core/engine/game_manager.dart';
import 'package:mg_common_game/core/systems/save_system.dart';
import 'package:mg_common_game/core/ui/overlays/game_toast.dart';
import 'package:mg_common_game/core/economy/gold_manager.dart';
import 'package:mg_common_game/systems/progression/progression_manager.dart';
import 'package:mg_common_game/systems/progression/upgrade_manager.dart';
import 'package:mg_common_game/systems/progression/achievement_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tower_defense/game/tower_defense_game.dart';
import 'package:tower_defense/main.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});

    if (!GetIt.I.isRegistered<EventBus>()) {
      GetIt.I.registerSingleton<EventBus>(EventBus());
    }

    if (!GetIt.I.isRegistered<SaveSystem>()) {
      final saveSystem = LocalSaveSystem();
      await saveSystem.init();
      GetIt.I.registerSingleton<SaveSystem>(saveSystem);
    }

    if (!GetIt.I.isRegistered<GameManager>()) {
      GetIt.I.registerSingleton<GameManager>(
        GameManager(GetIt.I<EventBus>(), GetIt.I<SaveSystem>()),
      );
    }

    if (!GetIt.I.isRegistered<AudioManager>()) {
      GetIt.I.registerSingleton<AudioManager>(AudioManager());
    }

    if (!GetIt.I.isRegistered<ToastManager>()) {
      GetIt.I.registerSingleton<ToastManager>(ToastManager());
    }
    if (!GetIt.I.isRegistered<UpgradeManager>()) {
      GetIt.I.registerSingleton(UpgradeManager());
    }
    if (!GetIt.I.isRegistered<AchievementManager>()) {
      GetIt.I.registerSingleton(AchievementManager());
    }
    if (!GetIt.I.isRegistered<ProgressionManager>()) {
      GetIt.I.registerSingleton(ProgressionManager());
    }

    // Register specific upgrades/achievements if needed for logic,
    // but the managers themselves start empty which is fine for basic smoke tests.
    // However, the game logic might try to access specific upgrades (e.g. 'start_gold').
    // So we should register that one to avoid null crashes if logic assumes it exists.
    final upgradeManager = GetIt.I<UpgradeManager>();
    if (upgradeManager.getUpgrade('start_gold') == null) {
      upgradeManager.registerUpgrade(
        Upgrade(
          id: 'start_gold',
          name: 'Starting Gold',
          description: 'Increase starting gold by 50',
          maxLevel: 5,
          baseCost: 100,
          valuePerLevel: 50.0,
        ),
      );
    }
    if (!GetIt.I.isRegistered<GoldManager>()) {
      GetIt.I.registerSingleton<GoldManager>(GoldManager());
    }
  });

  tearDown(() {
    GetIt.I.reset();
  });

  testWidgets('TowerDefenseGame renders correctly', (
    WidgetTester tester,
  ) async {
    // Determine screen size for test
    tester.view.physicalSize = const ui.Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(const MaterialApp(home: GamePage()));

    // Pump to allow async loads and initial frame
    await tester.pump();

    // Check for GameWidget
    expect(find.byType(GameWidget<TowerDefenseGame>), findsOneWidget);

    // Cleanup
    addTearDown(tester.view.resetPhysicalSize);
  });
}
