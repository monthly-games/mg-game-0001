import 'dart:async';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/core/audio/audio_manager.dart';
import 'package:mg_common_game/core/ui/theme/game_theme.dart';
import 'package:mg_common_game/core/ui/overlays/game_toast.dart';
import 'package:mg_common_game/core/ui/layouts/game_scaffold.dart';
import 'package:mg_common_game/core/economy/gold_manager.dart';
import 'ui/hud/mg_game_hud.dart';
import 'ui/dialogs/game_over_dialog.dart';
import 'ui/dialogs/tower_select_dialog.dart';
import 'ui/dialogs/tower_manage_dialog.dart';
import 'ui/overlays/tutorial_overlay.dart';
import 'package:mg_common_game/core/ui/overlays/pause_game_overlay.dart';
import 'package:mg_common_game/core/ui/overlays/settings_game_overlay.dart';
import 'package:mg_common_game/core/engine/event_bus.dart';
import 'package:mg_common_game/core/systems/save_system.dart';
import 'package:mg_common_game/core/engine/game_manager.dart';
import 'package:mg_common_game/core/engine/input_manager.dart';
import 'package:mg_common_game/systems/progression/progression_manager.dart';
import 'package:mg_common_game/systems/progression/upgrade_manager.dart';
import 'package:mg_common_game/systems/progression/achievement_manager.dart';
import 'package:mg_common_game/systems/progression/prestige_manager.dart';
import 'package:mg_common_game/systems/quests/daily_quest.dart';
import 'package:mg_common_game/systems/quests/weekly_challenge.dart';
import 'package:mg_common_game/systems/stats/statistics_manager.dart';
import 'package:mg_common_game/systems/settings/settings_manager.dart';
import 'package:mg_common_game/core/systems/save_manager_helper.dart';

import 'game/tower_defense_game.dart';

// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';
import 'package:mg_common_game/core/ui/screens/game_loading_screen.dart';
import 'ui/screens/lobby_screen.dart';
import 'app_logger.dart';

void main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        logger.e(
          'Flutter Error',
          error: details.exception,
          stackTrace: details.stack,
        );
      };

      // Register Audio Manager
      if (!GetIt.I.isRegistered<AudioManager>()) {
        GetIt.I.registerSingleton<AudioManager>(AudioManager());
      }
      await GetIt.I<AudioManager>().initialize();

      GetIt.I.registerSingleton(ToastManager());

      // Register Core Services
      if (!GetIt.I.isRegistered<EventBus>()) {
        GetIt.I.registerSingleton(EventBus());
      }

      if (!GetIt.I.isRegistered<SaveSystem>()) {
        final saveSystem = LocalSaveSystem();
        await saveSystem.init();
        GetIt.I.registerSingleton<SaveSystem>(saveSystem);
      }

      if (!GetIt.I.isRegistered<InputManager>()) {
        GetIt.I.registerSingleton(InputManager(GetIt.I<EventBus>()));
      }

      if (!GetIt.I.isRegistered<GameManager>()) {
        GetIt.I.registerSingleton(
          GameManager(GetIt.I<EventBus>(), GetIt.I<SaveSystem>()),
        );
      }
      await GetIt.I<GameManager>().initialize();

      if (!GetIt.I.isRegistered<GoldManager>()) {
        GetIt.I.registerSingleton(GoldManager());
      }

      // -- Meta Progression Registration --

      // 1. Progression Manager (Player Level)
      if (!GetIt.I.isRegistered<ProgressionManager>()) {
        final progressionManager = ProgressionManager();

        // Setup level up haptic feedback
        progressionManager.onLevelUp = (newLevel) {
          if (GetIt.I.isRegistered<SettingsManager>()) {
            GetIt.I<SettingsManager>().triggerVibration(
              intensity: VibrationIntensity.heavy,
            );
          }
        };

        GetIt.I.registerSingleton(progressionManager);
      }

      // 2. Upgrade Manager
      if (!GetIt.I.isRegistered<UpgradeManager>()) {
        final upgradeManager = UpgradeManager();

        // Define Upgrades
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

        upgradeManager.registerUpgrade(
          Upgrade(
            id: 'turret_damage',
            name: 'Turret Damage',
            description: 'Increase turret damage by 10%',
            maxLevel: 10,
            baseCost: 200,
            valuePerLevel: 0.1, // +10%
          ),
        );

        GetIt.I.registerSingleton(upgradeManager);
      }

      // 3. Achievement Manager
      if (!GetIt.I.isRegistered<AchievementManager>()) {
        final achievementManager = AchievementManager();

        // Setup achievement unlock haptic feedback
        achievementManager.onAchievementUnlocked = (achievement) {
          if (GetIt.I.isRegistered<SettingsManager>()) {
            GetIt.I<SettingsManager>().triggerVibration(
              intensity: VibrationIntensity.heavy,
            );
          }
        };

        // Define Achievements
        achievementManager.registerAchievement(
          Achievement(
            id: 'wave_5',
            title: 'Survivor',
            description: 'Reach Wave 5',
            iconAsset: 'assets/images/icon_gem.png', // Placeholder
          ),
        );

        achievementManager.registerAchievement(
          Achievement(
            id: 'gold_1000',
            title: 'Rich',
            description: 'Earn 1000 Gold total',
            iconAsset: 'assets/images/icon_gold.png',
          ),
        );

        GetIt.I.registerSingleton(achievementManager);
      }

      // 4. Prestige Manager
      if (!GetIt.I.isRegistered<PrestigeManager>()) {
        final prestigeManager = PrestigeManager();

        // Define Prestige Upgrades (more powerful, permanent bonuses)
        prestigeManager.registerPrestigeUpgrade(
          PrestigeUpgrade(
            id: 'prestige_xp_boost',
            name: 'XP Amplifier',
            description: '+20% XP gain per level',
            maxLevel: 10,
            costPerLevel: 1, // 1 prestige point per level
            bonusPerLevel: 0.2, // 20% per level
          ),
        );

        prestigeManager.registerPrestigeUpgrade(
          PrestigeUpgrade(
            id: 'prestige_gold_boost',
            name: 'Gold Multiplier',
            description: '+15% gold income per level',
            maxLevel: 10,
            costPerLevel: 1,
            bonusPerLevel: 0.15, // 15% per level
          ),
        );

        prestigeManager.registerPrestigeUpgrade(
          PrestigeUpgrade(
            id: 'prestige_tower_power',
            name: 'Tower Dominance',
            description: '+10% tower damage per level',
            maxLevel: 15,
            costPerLevel: 2,
            bonusPerLevel: 0.1, // 10% per level
          ),
        );

        GetIt.I.registerSingleton(prestigeManager);

        // Load saved prestige data
        prestigeManager.loadPrestigeData();

        // Connect prestige manager to progression and gold managers
        GetIt.I<ProgressionManager>().setPrestigeManager(prestigeManager);
        GetIt.I<GoldManager>().setPrestigeManager(prestigeManager);
      }

      // 5. Daily Quest Manager
      if (!GetIt.I.isRegistered<DailyQuestManager>()) {
        final questManager = DailyQuestManager();

        // Register daily quests for Tower Defense
        questManager.registerQuest(
          DailyQuest(
            id: 'td_play_3_games',
            title: 'Tower Master',
            description: 'Complete 3 tower defense games',
            targetValue: 3,
            goldReward: 100,
            xpReward: 50,
          ),
        );

        questManager.registerQuest(
          DailyQuest(
            id: 'td_defeat_50_enemies',
            title: 'Monster Slayer',
            description: 'Defeat 50 enemies',
            targetValue: 50,
            goldReward: 150,
            xpReward: 75,
          ),
        );

        questManager.registerQuest(
          DailyQuest(
            id: 'td_place_20_towers',
            title: 'Tower Engineer',
            description: 'Place 20 towers',
            targetValue: 20,
            goldReward: 80,
            xpReward: 40,
          ),
        );

        questManager.registerQuest(
          DailyQuest(
            id: 'td_earn_500_gold',
            title: 'Gold Collector',
            description: 'Earn 500 gold total',
            targetValue: 500,
            goldReward: 200,
            xpReward: 100,
          ),
        );

        questManager.registerQuest(
          DailyQuest(
            id: 'td_survive_wave_10',
            title: 'Survivor',
            description: 'Reach wave 10',
            targetValue: 1,
            goldReward: 250,
            xpReward: 150,
          ),
        );

        GetIt.I.registerSingleton(questManager);

        // Load saved quest data and check for daily reset
        questManager.loadQuestData();
        questManager.checkAndResetIfNeeded();
      }

      // 6. Weekly Challenge Manager
      if (!GetIt.I.isRegistered<WeeklyChallengeManager>()) {
        final challengeManager = WeeklyChallengeManager();

        // Haptic feedback on challenge completion
        challengeManager.onChallengeCompleted = (challenge) {
          if (GetIt.I.isRegistered<SettingsManager>()) {
            GetIt.I<SettingsManager>().triggerVibration(
              intensity: VibrationIntensity.heavy,
            );
          }
        };

        // Register weekly challenges for Tower Defense
        challengeManager.registerChallenge(
          WeeklyChallenge(
            id: 'weekly_td_games_10',
            title: 'Weekly Warrior',
            description: 'Complete 10 tower defense games',
            targetValue: 10,
            goldReward: 500,
            xpReward: 250,
            tier: ChallengeTier.bronze,
          ),
        );

        challengeManager.registerChallenge(
          WeeklyChallenge(
            id: 'weekly_td_enemies_500',
            title: 'Monster Hunter',
            description: 'Defeat 500 enemies',
            targetValue: 500,
            goldReward: 750,
            xpReward: 400,
            tier: ChallengeTier.silver,
          ),
        );

        challengeManager.registerChallenge(
          WeeklyChallenge(
            id: 'weekly_td_gold_5000',
            title: 'Wealthy Commander',
            description: 'Earn 5000 gold total',
            targetValue: 5000,
            goldReward: 1000,
            xpReward: 500,
            tier: ChallengeTier.silver,
          ),
        );

        challengeManager.registerChallenge(
          WeeklyChallenge(
            id: 'weekly_td_wave_20',
            title: 'Endurance Master',
            description: 'Reach wave 20',
            targetValue: 1,
            goldReward: 1500,
            xpReward: 800,
            prestigePointReward: 1,
            tier: ChallengeTier.gold,
          ),
        );

        challengeManager.registerChallenge(
          WeeklyChallenge(
            id: 'weekly_td_towers_100',
            title: 'Master Builder',
            description: 'Place 100 towers',
            targetValue: 100,
            goldReward: 800,
            xpReward: 400,
            tier: ChallengeTier.silver,
          ),
        );

        challengeManager.registerChallenge(
          WeeklyChallenge(
            id: 'weekly_td_perfect_10',
            title: 'Perfect Defense',
            description: 'Complete 10 waves without losing a life',
            targetValue: 10,
            goldReward: 2000,
            xpReward: 1000,
            prestigePointReward: 2,
            tier: ChallengeTier.platinum,
          ),
        );

        GetIt.I.registerSingleton(challengeManager);

        // Load saved challenge data and check for weekly reset
        await challengeManager.loadChallengeData();
        await challengeManager.checkAndResetIfNeeded();
      }

      // 7. Statistics Manager
      if (!GetIt.I.isRegistered<StatisticsManager>()) {
        final statisticsManager = StatisticsManager();
        GetIt.I.registerSingleton(statisticsManager);

        // Load saved statistics
        statisticsManager.loadStats();

        // Start session tracking
        statisticsManager.startSession();
      }

      // 7. Settings Manager
      if (!GetIt.I.isRegistered<SettingsManager>()) {
        final settingsManager = SettingsManager();
        GetIt.I.registerSingleton(settingsManager);

        // Connect to AudioManager
        if (GetIt.I.isRegistered<AudioManager>()) {
          settingsManager.setAudioManager(GetIt.I<AudioManager>());
        }

        // Load saved settings
        await settingsManager.loadSettings();
      }

      // 8. Save Manager - Centralized save/load system
      await SaveManagerHelper.setupSaveManager(
        autoSaveEnabled: true,
        autoSaveIntervalSeconds: 30, // Auto-save every 30 seconds
      );

      // Also load legacy save data for backwards compatibility
      await SaveManagerHelper.legacyLoadAll();

      logger.i('Game making startup sequence complete. Launching app.');
      runApp(const MyApp());
    },
    (Object error, StackTrace stack) {
      logger.e('Uncaught error in root zone', error: error, stackTrace: stack);
    },
  );
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
          : const LobbyScreen(),
    );
  }
}

class GamePage extends StatefulWidget {
  final int stageNumber;

  const GamePage({super.key, this.stageNumber = 1});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  bool _showTutorial = false;
  late TowerDefenseGame _game;

  @override
  void initState() {
    super.initState();
    _game = TowerDefenseGame(stageNumber: widget.stageNumber);
    _checkTutorial();
  }

  Future<void> _checkTutorial() async {
    final hasSeenTutorial = await TutorialOverlay.hasSeenTutorial();
    if (!hasSeenTutorial && mounted) {
      setState(() {
        _showTutorial = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GameToastOverlay(
      manager: GetIt.I<ToastManager>(),
      child: GameScaffold(
        backgroundImage: 'assets/images/bg_lobby.png',
        body: Stack(
          children: [
            GameWidget<TowerDefenseGame>(
              game: _game,
              initialActiveOverlays: const ['HUD'],
              overlayBuilderMap: {
                'HUD': (BuildContext context, TowerDefenseGame game) {
                  return StreamBuilder<int>(
                    stream: GetIt.I<GoldManager>().onGoldChanged,
                    initialData: GetIt.I<GoldManager>().currentGold,
                    builder: (context, snapshot) {
                      return MGGameHud(
                        gold: snapshot.data ?? 0,
                        wave: game.currentWave,
                        maxWave: game.stageInfo?.waves ?? 10,
                        lives: game.lives,
                        maxLives: game.stageInfo?.startingLives ?? 20,
                        isWaveActive: game.isWaveInProgress,
                        gameSpeed: game.gameSpeed,
                        onBuildTower: game.buildTower,
                        onNextWave: game.startNextWave,
                        onSpeedChange: game.toggleSpeed,
                        onPause: () {
                          game.pauseEngine();
                          game.overlays.add('PauseGame');
                        },
                      );
                    },
                  );
                },
                'GameOver': (BuildContext context, TowerDefenseGame game) {
                  return GameOverDialog(
                    isVictory:
                        game.currentWave >= TowerDefenseGame.victoryWaveCount,
                    wave: game.currentWave,
                    goldEarned: game.totalGoldEarned,
                    onRestart: () {
                      game.restart();
                    },
                    onMainMenu: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const LobbyScreen(),
                        ),
                      );
                    },
                  );
                },
                'TowerSelect': (BuildContext context, TowerDefenseGame game) {
                  return TowerSelectDialog(
                    currentStage: game.waveManager.currentStage,
                    onTowerSelected: (type) {
                      game.startBuildMode(type);
                    },
                    onCancel: () {
                      game.cancelBuildMode();
                    },
                  );
                },
                'TowerManage': (BuildContext context, TowerDefenseGame game) {
                  return StreamBuilder<int>(
                    stream: GetIt.I<GoldManager>().onGoldChanged,
                    initialData: GetIt.I<GoldManager>().currentGold,
                    builder: (context, snapshot) {
                      if (game.selectedTower == null) {
                        return const SizedBox.shrink();
                      }
                      return TowerManageDialog(
                        tower: game.selectedTower!,
                        currentGold: snapshot.data ?? 0,
                        onUpgrade: () => game.upgradeTower(),
                        onSell: () => game.sellTower(),
                        onCancel: () => game.closeTowerManage(),
                      );
                    },
                  );
                },
                'PauseGame': (BuildContext context, TowerDefenseGame game) {
                  return PauseGameOverlay(
                    game: game,
                    onResume: () {
                      game.resumeEngine();
                      game.overlays.remove('PauseGame');
                    },
                    onSettings: () {
                      game.overlays.add('SettingsGame');
                    },
                    onQuit: () {
                      game.resumeEngine();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const LobbyScreen(),
                        ),
                      );
                    },
                  );
                },
                'SettingsGame': (BuildContext context, TowerDefenseGame game) {
                  return SettingsGameOverlay(
                    game: game,
                    onBack: () {
                      game.overlays.remove('SettingsGame');
                    },
                  );
                },
              },
            ),

            // Tutorial overlay
            if (_showTutorial)
              TutorialOverlay(
                onComplete: () {
                  setState(() {
                    _showTutorial = false;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }
}
