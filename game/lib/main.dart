import 'package:mg_common_game/systems/progression/achievement_manager.dart';

import 'dart:async';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/core/ui/overlays/game_toast.dart';
import 'package:mg_common_game/core/ui/layouts/game_scaffold.dart';
import 'package:mg_common_game/core/economy/gold_manager.dart';
import 'package:mg_common_game/l10n/extensions.dart';
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
import 'package:mg_common_game/mg_common_game.dart';

import 'package:tower_defense/game/tower_defense_game.dart';

// Battlepass & Gacha Adapters
import 'features/battlepass/battlepass_adapter.dart';
import 'features/gacha/gacha_adapter.dart';
import 'ui/screens/battlepass_screen.dart';
import 'ui/screens/gacha_screen.dart';
import 'ui/screens/daily_quest_screen.dart';
import 'ui/screens/achievement_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'firebase_options.dart';
import 'package:mg_common_game/core/ui/screens/game_loading_screen.dart';
import 'package:mg_common_game/core/ui/accessibility/accessibility_settings.dart';
import 'ui/screens/lobby_screen.dart';
import 'app_logger.dart';
import 'screens/collection_screen.dart';
// import 'game/balancing_config.dart'; // BalancingManager not available
// // import 'game/tutorial_config.dart'; // TutorialManager not available
// import 'package:mg_common_game/systems/tutorial/tutorial_manager.dart';
// 
// void main() async {
//   runZonedGuarded(
//     () async {
//       WidgetsFlutterBinding.ensureInitialized();
// 
//       // Initialize Firebase Remote Config
//             // Initialize Firebase Core
//       try {
//         await Firebase.initializeApp(
//           options: DefaultFirebaseOptions.currentPlatform,
//         );
//         print('Firebase Core initialized successfully');
//       } catch (e) {
//         print('Failed to initialize Firebase Core: $e');
//       }
// 
//       try {
//         final remoteConfig = FirebaseRemoteConfig.instance;
//         await remoteConfig.setDefaults({
//           'feature_iap_enabled': true,
//           'feature_battlepass_enabled': true,
//           'feature_gacha_enabled': true,
//           'feature_daily_quest_v2_enabled': true,
//           'feature_daily_rewards_enabled': true,
//           'feature_tutorial_enabled': true,
//           'feature_new_ui_enabled': false,
//           'min_app_version': '1.0.0',
//         });
//         await remoteConfig.fetchAndActivate();
//         print('Remote Config initialized successfully');
//       } catch (e) {
//         print('Failed to initialize Remote Config: $e');
//       }
//       }
// 
// 
//       FlutterError.onError = (FlutterErrorDetails details) {
//         FlutterError.presentError(details);
//         logger.e(
//           'Flutter Error',
//           error: details.exception,
//           stackTrace: details.stack,
//         );
//       };
// 
//       // Register Audio Manager
//       if (!GetIt.I.isRegistered<AudioManager>()) {
//         GetIt.I.registerSingleton<AudioManager>(AudioManager());
//       }
//       await GetIt.I<AudioManager>().initialize();
// 
//       GetIt.I.registerSingleton(ToastManager());
// 
//       // Register Core Services
//       if (!GetIt.I.isRegistered<EventBus>()) {
//         GetIt.I.registerSingleton(EventBus());
//       }
// 
//       if (!GetIt.I.isRegistered<SaveSystem>()) {
//         final saveSystem = LocalSaveSystem();
//         await saveSystem.init();
//         GetIt.I.registerSingleton<SaveSystem>(saveSystem);
//       }
// 
//       if (!GetIt.I.isRegistered<InputManager>()) {
//         GetIt.I.registerSingleton(InputManager(GetIt.I<EventBus>()));
//       }
// 
//       if (!GetIt.I.isRegistered<GameManager>()) {
//         GetIt.I.registerSingleton(
//           GameManager(GetIt.I<EventBus>(), GetIt.I<SaveSystem>()),
//         );
//       }
//       await GetIt.I<GameManager>().initialize();
// 
//       if (!GetIt.I.isRegistered<GoldManager>()) {
//         GetIt.I.registerSingleton(GoldManager());
//       }
//
//       // --- BattlePass System ---
//       if (!GetIt.I.isRegistered<BattlePassManager>()) {
//         GetIt.I.registerSingleton(BattlePassManager());
//         print('BattlePassManager registered');
//       }
// 
//       // -- Monetization Systems Registration --
//       
//       // Battlepass System
//       if (!GetIt.I.isRegistered<TowerBattlePass>()) {
//         GetIt.I.registerSingleton(TowerBattlePass());
//       }
// 
//       // Gacha System
//       if (!GetIt.I.isRegistered<TowerGachaAdapter>()) {
//         GetIt.I.registerSingleton(TowerGachaAdapter());
//       }
// 
//       // -- Meta Progression Registration --
// 
//       // 1. Progression Manager (Player Level)
//       if (!GetIt.I.isRegistered<ProgressionManager>()) {
//         final progressionManager = ProgressionManager();
// 
//         // Setup level up haptic feedback
//         progressionManager.onLevelUp = (newLevel) {
//           if (GetIt.I.isRegistered<SettingsManager>()) {
//             GetIt.I<SettingsManager>().triggerVibration(
//               intensity: VibrationIntensity.heavy,
//             );
//           }
//         };
// 
//         GetIt.I.registerSingleton(progressionManager);
//       }
// 
//       // 2. Upgrade Manager
//       if (!GetIt.I.isRegistered<UpgradeManager>()) {
//         final upgradeManager = UpgradeManager();
// 
//         // Define Upgrades
//         upgradeManager.registerUpgrade(
//           Upgrade(
//             id: 'start_gold',
//             name: 'Starting Gold',
//             description: 'Increase starting gold by 50',
//             maxLevel: 5,
//             baseCost: 100,
//             valuePerLevel: 50.0,
//           ),
//         );
// 
//         upgradeManager.registerUpgrade(
//           Upgrade(
//             id: 'turret_damage',
//             name: 'Turret Damage',
//             description: 'Increase turret damage by 10%',
//             maxLevel: 10,
//             baseCost: 200,
//             valuePerLevel: 0.1, // +10%
//           ),
//         );
// 
//         GetIt.I.registerSingleton(upgradeManager);
//       }
// 
//       // 3. Achievement Manager
//       if (!GetIt.I.isRegistered<AchievementManager>()) {
//         final achievementManager = AchievementManager();
// 
//         // Setup achievement unlock haptic feedback
//         achievementManager.onAchievementUnlocked = (achievement) {
//           if (GetIt.I.isRegistered<SettingsManager>()) {
//             GetIt.I<SettingsManager>().triggerVibration(
//               intensity: VibrationIntensity.heavy,
//             );
//           }
//         };
// 
//         // Define Achievements
//         achievementManager.registerAchievement(
//           Achievement(
//             id: 'wave_5',
//             title: 'Survivor',
//             description: 'Reach Wave 5',
//             iconAsset: 'assets/images/icon_gem.png', // Placeholder
//           ),
//         );
// 
//         achievementManager.registerAchievement(
//           Achievement(
//             id: 'gold_1000',
//             title: 'Rich',
//             description: 'Earn 1000 Gold total',
//             iconAsset: 'assets/images/icon_gold.png',
//           ),
//         );
// 
//         GetIt.I.registerSingleton(achievementManager);
//       }
// 
//       // 4. Prestige Manager
//       if (!GetIt.I.isRegistered<PrestigeManager>()) {
//         final prestigeManager = PrestigeManager();
// 
//         // Define Prestige Upgrades (more powerful, permanent bonuses)
//         prestigeManager.registerPrestigeUpgrade(
//           PrestigeUpgrade(
//             id: 'prestige_xp_boost',
//             name: 'XP Amplifier',
//             description: '+20% XP gain per level',
//             maxLevel: 10,
//             costPerLevel: 1, // 1 prestige point per level
//             bonusPerLevel: 0.2, // 20% per level
//           ),
//         );
// 
//         prestigeManager.registerPrestigeUpgrade(
//           PrestigeUpgrade(
//             id: 'prestige_gold_boost',
//             name: 'Gold Multiplier',
//             description: '+15% gold income per level',
//             maxLevel: 10,
//             costPerLevel: 1,
//             bonusPerLevel: 0.15, // 15% per level
//           ),
//         );
// 
//         prestigeManager.registerPrestigeUpgrade(
//           PrestigeUpgrade(
//             id: 'prestige_tower_power',
//             name: 'Tower Dominance',
//             description: '+10% tower damage per level',
//             maxLevel: 15,
//             costPerLevel: 2,
//             bonusPerLevel: 0.1, // 10% per level
//           ),
//         );
// 
//         GetIt.I.registerSingleton(prestigeManager);
// 
//         // Load saved prestige data
//         prestigeManager.loadPrestigeData();
// 
//         // Connect prestige manager to progression and gold managers
//         GetIt.I<ProgressionManager>().setPrestigeManager(prestigeManager);
//         GetIt.I<GoldManager>().setPrestigeManager(prestigeManager);
//       }
// 
      // 5. Daily Quest Manager
//       if (!GetIt.I.isRegistered<DailyQuestManager>()) {
//         final questManager = DailyQuestManager();

//         // Register Tower Defense themed quests
//         questManager.registerQuest(DailyQuest(
//           id: 'td_waves_10',
//           title: 'Wave Defender',
//           description: 'Survive 10 waves',
//           targetValue: 10,
//           goldReward: 150,
//           xpReward: 50,
//         ));

//         questManager.registerQuest(DailyQuest(
//           id: 'td_enemies_100',
//           title: 'Enemy Slayer',
//           description: 'Defeat 100 enemies',
//           targetValue: 100,
//           goldReward: 200,
//           xpReward: 75,
//         ));

//         questManager.registerQuest(DailyQuest(
//           id: 'td_towers_5',
//           title: 'Tower Builder',
//           description: 'Build 5 towers',
//           targetValue: 5,
//           goldReward: 120,
//           xpReward: 40,
//         ));

//         questManager.registerQuest(DailyQuest(
//           id: 'td_gold_2000',
//           title: 'Defense Wealth',
//           description: 'Earn 2000 gold from battles',
//           targetValue: 2000,
//           goldReward: 250,
//           xpReward: 80,
//         ));

//         GetIt.I.registerSingleton(questManager);
//         // Load saved quest data
//         await questManager.loadQuestData();
//       }
// 
//       // 6. Weekly Challenge Manager
//       if (!GetIt.I.isRegistered<WeeklyChallengeManager>()) {
//         final challengeManager = WeeklyChallengeManager();
// 
//         // Haptic feedback on challenge completion
//         challengeManager.onChallengeCompleted = (challenge) {
//           if (GetIt.I.isRegistered<SettingsManager>()) {
//             GetIt.I<SettingsManager>().triggerVibration(
//               intensity: VibrationIntensity.heavy,
//             );
//           }
//         };
// 
//         // Register weekly challenges for Tower Defense
//         challengeManager.registerChallenge(
//           WeeklyChallenge(
//             id: 'weekly_td_games_10',
//             title: 'Weekly Warrior',
//             description: 'Complete 10 tower defense games',
//             targetValue: 10,
//             goldReward: 500,
//             xpReward: 250,
//             tier: ChallengeTier.bronze,
//           ),
//         );
// 
//         challengeManager.registerChallenge(
//           WeeklyChallenge(
//             id: 'weekly_td_enemies_500',
//             title: 'Monster Hunter',
//             description: 'Defeat 500 enemies',
//             targetValue: 500,
//             goldReward: 750,
//             xpReward: 400,
//             tier: ChallengeTier.silver,
//           ),
//         );
// 
//         challengeManager.registerChallenge(
//           WeeklyChallenge(
//             id: 'weekly_td_gold_5000',
//             title: 'Wealthy Commander',
//             description: 'Earn 5000 gold total',
//             targetValue: 5000,
//             goldReward: 1000,
//             xpReward: 500,
//             tier: ChallengeTier.silver,
//           ),
//         );
// 
//         challengeManager.registerChallenge(
//           WeeklyChallenge(
//             id: 'weekly_td_wave_20',
//             title: 'Endurance Master',
//             description: 'Reach wave 20',
//             targetValue: 1,
//             goldReward: 1500,
//             xpReward: 800,
//             prestigePointReward: 1,
//             tier: ChallengeTier.gold,
//           ),
//         );
// 
//         challengeManager.registerChallenge(
//           WeeklyChallenge(
//             id: 'weekly_td_towers_100',
//             title: 'Master Builder',
//             description: 'Place 100 towers',
//             targetValue: 100,
//             goldReward: 800,
//             xpReward: 400,
//             tier: ChallengeTier.silver,
//           ),
//         );
// 
//         challengeManager.registerChallenge(
//           WeeklyChallenge(
//             id: 'weekly_td_perfect_10',
//             title: 'Perfect Defense',
//             description: 'Complete 10 waves without losing a life',
//             targetValue: 10,
//             goldReward: 2000,
//             xpReward: 1000,
//             prestigePointReward: 2,
//             tier: ChallengeTier.platinum,
//           ),
//         );
// 
//         GetIt.I.registerSingleton(challengeManager);
// 
//         // Load saved challenge data and check for weekly reset
//         await challengeManager.loadChallengeData();
//         await challengeManager.checkAndResetIfNeeded();
//       }
// 
//       // 7. Statistics Manager
//       if (!GetIt.I.isRegistered<StatisticsManager>()) {
//         final statisticsManager = StatisticsManager();
//         GetIt.I.registerSingleton(statisticsManager);
// 
//         // Load saved statistics
//         statisticsManager.loadStats();
// 
//         // Start session tracking
//         statisticsManager.startSession();
//       }
// 
//       // 7. Settings Manager
//       if (!GetIt.I.isRegistered<SettingsManager>()) {
//         final settingsManager = SettingsManager();
//         GetIt.I.registerSingleton(settingsManager);
//   // Gacha 시스템
//   GetIt.I.registerSingleton(GachaManager());
//   // Collection 시스템
//   if (!GetIt.I.isRegistered<CollectionManager>()) {
//     GetIt.I.registerSingleton(CollectionManager());
//     _registerCollections();
//   }
//   _setupGacha();
// 
//         // Connect to AudioManager
//         if (GetIt.I.isRegistered<AudioManager>()) {
//           settingsManager.setAudioManager(GetIt.I<AudioManager>());
//         }
// 
//         // Load saved settings
//         await settingsManager.loadSettings();
//       }
// 
//       // ── Retention Systems for DailyHub ────────────────────────
//       // TODO: LoginRewardsManager, StreakManager, DailyChallengeManager not available
//       // if (!GetIt.I.isRegistered<LoginRewardsManager>()) {
//       //   GetIt.I.registerSingleton(LoginRewardsManager());
//       // }
//       // if (!GetIt.I.isRegistered<StreakManager>()) {
//       //   GetIt.I.registerSingleton(StreakManager());
//       // }
//       // if (!GetIt.I.isRegistered<DailyChallengeManager>()) {
//       //   GetIt.I.registerSingleton(DailyChallengeManager());
//       // }
// 
//       // ── P3 Engine Systems ─────────────────────────────────────
//       // TODO: GuildWarManager, TournamentManager, SeasonalContentManager not available
//       // if (!GetIt.I.isRegistered<GuildWarManager>()) {
//       //   GetIt.I.registerSingleton(GuildWarManager());
//       // }
//       // if (!GetIt.I.isRegistered<TournamentManager>()) {
//       //   GetIt.I.registerSingleton(TournamentManager());
//       // }
//       // if (!GetIt.I.isRegistered<SeasonalContentManager>()) {
//       //   GetIt.I.registerSingleton(SeasonalContentManager());
//       // }
// 
//       // === Q8 DI Fix: Tutorial & Balancing ===
//       if (!GetIt.I.isRegistered<TutorialManager>()) {
//         final tutorialManager = TutorialManager();
//         await tutorialManager.initialize();
//         // Note: TutorialManager doesn't have registerTutorial method
//         // The tutorial sequence (kOnboardingTutorial) can be started manually
//         GetIt.I.registerSingleton<TutorialManager>(tutorialManager);
//       }

      // TODO: BalancingManager not available
//       // if (!GetIt.I.isRegistered<BalancingManager>()) {
//       //   GetIt.I.registerSingleton<BalancingManager>(
//       //     BalancingManager(defaultConfig: kDefaultBalancingConfig),
//       //   );
//       // }
// 
//       // 8. Save Manager - Centralized save/load system
//       await SaveManagerHelper.setupSaveManager(
//         autoSaveEnabled: true,
//         autoSaveIntervalSeconds: 30, // Auto-save every 30 seconds
//       );
// 
//       // Also load legacy save data for backwards compatibility
//       await SaveManagerHelper.legacyLoadAll();
// 
//       // ── Social Systems Initialization ─────────────────────────────
//       // TODO: Social systems disabled - missing dependencies
//       // await SocialInitializer.initialize(
//       //   playerId: 'player_${DateTime.now().millisecondsSinceEpoch}',
//       //   playerName: 'Player',
//       //   leaderboards: SocialInitializer.createStandardLeaderboards(
//       //     gameId: 'mg_tower_defense',
//       //     gameName: 'Tower Defense',
//       //   ),
//       //   enableFirebase: true,
//       // );
//       logger.i('Game making startup sequence complete. Launching app.');
//       runApp(const MyApp());
//     },
//     (Object error, StackTrace stack) {
//       logger.e('Uncaught error in root zone', error: error, stackTrace: stack);
//     },
//   );
// }
// 
// class MyApp extends StatefulWidget {
//   const MyApp({super.key});
// 
//   @override
//   State<MyApp> createState() => _MyAppState();
// }
// 
// class _MyAppState extends State<MyApp> {
//   bool _isLoading = true;
// 
//   @override
//   Widget build(BuildContext context) {
//     return MGAccessibilityProvider(
//       settings: MGAccessibilitySettings.defaults,
//       onSettingsChanged: (settings) {
//         // Settings updated
//       },
//       child: MaterialApp(
//       title: 'Tower Defense',
//       supportedLocales: const [Locale('en', 'US')],
//       localizationsDelegates: const [
//         DefaultMaterialLocalizations.delegate,
//         DefaultWidgetsLocalizations.delegate,
//       ],
//       theme: ThemeData.dark(useMaterial3: true).copyWith(
//         primaryColor: MGColors.primaryAction,
//         colorScheme: const ColorScheme.dark(
//           primary: Color(0xFF6200EE),
//           secondary: Color(0xFF03DAC6),
//         ),
//       ),
//       routes: {
//         '/daily-quest': (_) => const DailyQuestScreen(),
//         '/achievements': (_) => const AchievementScreen(),
//         '/collection': (context) => CollectionScreen(
//           collectionManager: GetIt.I<CollectionManager>(),
//         ),
//       },
//       home: _isLoading
//           ? GameLoadingScreen(
//               images: const ['bg_lobby.png', 'icon_gold.png', 'icon_gem.png'],
//               audio: const [], // Add audio later when files exist
//               backgroundImage: 'assets/images/bg_lobby.png',
//               onFinished: () {
//                 setState(() {
//                   _isLoading = false;
//                 });
//               },
//             )
//           : const LobbyScreen(),
//       ),
//     );
//   }
// }

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
    final hasSeenTutorial = await GameTutorialOverlay.hasSeenTutorial();
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
                  return ListenableBuilder(
                    listenable: GetIt.I<GoldManager>(),
                    builder: (context, _) {
                      return MGGameHud(
                        gold: GetIt.I<GoldManager>().currentGold,
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
                        onBattlepass: () {
                          game.pauseEngine();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const BattlepassScreen(),
                            ),
                          ).then((_) => game.resumeEngine());
                        },
                        onGacha: () {
                          game.pauseEngine();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const GachaScreen(),
                            ),
                          ).then((_) => game.resumeEngine());
                        },
                        onDailyHub: () {
                          game.pauseEngine();
                          Navigator.of(context).pushNamed('/daily-hub')
                              .then((_) => game.resumeEngine());
                        },
                        onGuildWar: () {
                          game.pauseEngine();
                          Navigator.of(context).pushNamed('/guild-war').then((_) => game.resumeEngine());
                        },
                        onTournament: () {
                          game.pauseEngine();
                          Navigator.of(context).pushNamed('/tournament').then((_) => game.resumeEngine());
                        },
                        onSeasonalEvent: () {
                          game.pauseEngine();
                          Navigator.of(context).pushNamed('/seasonal-event').then((_) => game.resumeEngine());
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
                  return ListenableBuilder(
                    listenable: GetIt.I<GoldManager>(),
                    builder: (context, _) {
                      if (game.selectedTower == null) {
                        return const SizedBox.shrink();
                      }
                      return TowerManageDialog(
                        tower: game.selectedTower!,
                        currentGold: GetIt.I<GoldManager>().currentGold,
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
              GameTutorialOverlay(
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


void _setupGacha() {
  final gacha = GetIt.I<GachaManager>();

  gacha.registerPool(GachaPool(
    id: 'standard_pool',
    nameKr: '스탠다드 뽑기',
    items: [
      // N (50%)
      ...List.generate(20, (i) => GachaItem(
        id: 'n_item_$i',
        nameKr: '일반 아이템 $i',
        rarity: GachaRarity.normal,
      )),

      // R (35%)
      ...List.generate(10, (i) => GachaItem(
        id: 'r_item_$i',
        nameKr: '레어 아이템 $i',
        rarity: GachaRarity.rare,
      )),

      // SR (12%)
      ...List.generate(5, (i) => GachaItem(
        id: 'sr_item_$i',
        nameKr: '슈퍼레어 아이템 $i',
        rarity: GachaRarity.superRare,
      )),

      // SSR (2.7%)
      GachaItem(
        id: 'ssr_item_1',
        nameKr: '울트라레어 아이템 1',
        rarity: GachaRarity.ultraRare,
      ),

      // UR (0.3%)
      GachaItem(
        id: 'ur_item_1',
        nameKr: '레전더리 아이템 1',
        rarity: GachaRarity.legendary,
      ),
    ],
  ));
}

void _registerCollections() {
  final collection = GetIt.I<CollectionManager>();

  // Characters 컬렉션
  collection.registerCollection(Collection(
    id: 'characters',
    name: '캐릭터',
    description: '모든 캐릭터를 수집하세요',
    items: [
      CollectionItem(
        id: 'char_warrior',
        name: '전사',
        description: '강인한 근접 전투 캐릭터',
        rarity: CollectionRarity.common,
      ),
      CollectionItem(
        id: 'char_mage',
        name: '마법사',
        description: '강력한 마법 공격 캐릭터',
        rarity: CollectionRarity.rare,
      ),
      CollectionItem(
        id: 'char_archer',
        name: '궁수',
        description: '원거리 정밀 공격 캐릭터',
        rarity: CollectionRarity.rare,
      ),
      CollectionItem(
        id: 'char_assassin',
        name: '암살자',
        description: '치명적인 은신 공격 캐릭터',
        rarity: CollectionRarity.epic,
      ),
      CollectionItem(
        id: 'char_healer',
        name: '힐러',
        description: '팀을 치유하는 지원 캐릭터',
        rarity: CollectionRarity.legendary,
      ),
    ],
    completionReward: CollectionReward(type: RewardType.gold, amount: 10000),
    milestoneRewards: {
      25: CollectionReward(type: RewardType.gold, amount: 1000),
      50: CollectionReward(type: RewardType.gold, amount: 3000),
      75: CollectionReward(type: RewardType.gold, amount: 5000),
    },
  ));

  // 아이템 해제 콜백 (햅틱 피드백)
  collection.onItemUnlocked = (collectionId, itemId) {
    // SettingsManager가 등록되어 있으면 햅틱 피드백
    debugPrint('Collection item unlocked: $collectionId / $itemId');
  };
}

void main() {
  runApp(const TowerDefenseApp());
}

class TowerDefenseApp extends StatelessWidget {
  const TowerDefenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tower Defense',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const LobbyScreen(),
    );
  }
}
