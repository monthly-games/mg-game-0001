import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/core/ui/layouts/game_scaffold.dart';
import 'package:mg_common_game/core/ui/theme/app_text_styles.dart';
import 'package:mg_common_game/core/ui/theme/app_colors.dart';
import 'package:mg_common_game/systems/progression/prestige_manager.dart';
import 'package:mg_common_game/systems/progression/progression_manager.dart';
import 'package:mg_common_game/core/ui/screens/prestige_screen.dart';
import 'package:mg_common_game/systems/quests/daily_quest.dart';
import 'package:mg_common_game/core/ui/screens/daily_quest_screen.dart';
import 'package:mg_common_game/systems/quests/weekly_challenge.dart';
import 'package:mg_common_game/core/ui/screens/weekly_challenge_screen.dart';
import 'package:mg_common_game/core/economy/gold_manager.dart';
import 'package:mg_common_game/systems/stats/statistics_manager.dart';
import 'package:mg_common_game/core/ui/screens/statistics_screen.dart';
import 'package:mg_common_game/systems/progression/achievement_manager.dart';
import 'package:mg_common_game/systems/settings/settings_manager.dart';
import 'package:mg_common_game/core/ui/screens/settings_screen.dart';
import '../../main.dart'; // To access GamePage

class LobbyScreen extends StatelessWidget {
  const LobbyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      backgroundImage: 'assets/images/bg_lobby.png',
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            const Spacer(flex: 2),
            Image.asset('assets/images/logo.png', width: 400),
            const Spacer(flex: 1),

            // Start Button
            _buildMenuButton(
              context,
              label: 'START DEFENSE',
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const GamePage()),
                );
              },
            ),
            const SizedBox(height: 20),
            _buildMenuButton(
              context,
              label: 'PRESTIGE',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PrestigeScreen(
                      prestigeManager: GetIt.I<PrestigeManager>(),
                      progressionManager: GetIt.I<ProgressionManager>(),
                      title: 'Tower Defense Prestige',
                      accentColor: AppColors.primary,
                      onClose: () => Navigator.of(context).pop(),
                      onPrestige: () {
                        // Perform prestige: gain points and reset
                        final prestigeManager = GetIt.I<PrestigeManager>();
                        final progressionManager = GetIt.I<ProgressionManager>();

                        final pointsGained = prestigeManager.performPrestige(
                          progressionManager.currentLevel,
                        );

                        // Reset progression
                        progressionManager.reset();

                        // TODO: Reset game-specific progress (gold, upgrades, etc.)

                        Navigator.of(context).pop();

                        // Show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Prestige successful! Gained $pointsGained points!',
                            ),
                            backgroundColor: Colors.amber,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
              isSecondary: true,
            ),
            const SizedBox(height: 20),
            _buildMenuButton(
              context,
              label: 'DAILY QUESTS',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => DailyQuestScreen(
                      questManager: GetIt.I<DailyQuestManager>(),
                      title: 'Daily Quests',
                      accentColor: AppColors.primary,
                      onClaimReward: (questId, goldReward, xpReward) {
                        // Give rewards
                        final goldManager = GetIt.I<GoldManager>();
                        final progressionManager = GetIt.I<ProgressionManager>();

                        goldManager.addGold(goldReward);
                        progressionManager.addXp(xpReward);
                      },
                      onClose: () => Navigator.of(context).pop(),
                    ),
                  ),
                );
              },
              isSecondary: true,
            ),
            const SizedBox(height: 20),
            _buildMenuButton(
              context,
              label: 'WEEKLY CHALLENGES',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => WeeklyChallengeScreen(
                      challengeManager: GetIt.I<WeeklyChallengeManager>(),
                      title: 'Weekly Challenges',
                      accentColor: Colors.amber,
                      onClaimReward: (challengeId, goldReward, xpReward, prestigeReward) {
                        // Give rewards
                        final goldManager = GetIt.I<GoldManager>();
                        final progressionManager = GetIt.I<ProgressionManager>();
                        final prestigeManager = GetIt.I<PrestigeManager>();

                        goldManager.addGold(goldReward);
                        progressionManager.addXp(xpReward);
                        if (prestigeReward > 0) {
                          prestigeManager.addPrestigePoints(prestigeReward);
                        }
                      },
                      onClose: () => Navigator.of(context).pop(),
                    ),
                  ),
                );
              },
              isSecondary: true,
            ),
            const SizedBox(height: 20),
            _buildMenuButton(
              context,
              label: 'STATISTICS',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => StatisticsScreen(
                      statisticsManager: GetIt.I<StatisticsManager>(),
                      progressionManager: GetIt.I<ProgressionManager>(),
                      prestigeManager: GetIt.I<PrestigeManager>(),
                      questManager: GetIt.I<DailyQuestManager>(),
                      achievementManager: GetIt.I<AchievementManager>(),
                      title: 'Game Statistics',
                      accentColor: AppColors.primary,
                      onClose: () => Navigator.of(context).pop(),
                    ),
                  ),
                );
              },
              isSecondary: true,
            ),
            const SizedBox(height: 20),
            _buildMenuButton(
              context,
              label: 'SETTINGS',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SettingsScreen(
                      settingsManager: GetIt.I<SettingsManager>(),
                      title: 'Settings',
                      accentColor: AppColors.primary,
                      onClose: () => Navigator.of(context).pop(),
                      version: '1.0.0',
                    ),
                  ),
                );
              },
              isSecondary: true,
            ),
            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
    bool isSecondary = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 280,
          height: 80,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Button Background using Luma Key Matrix
              // Button Background
              Image.asset(
                'assets/images/ui_button_wide.png',
                fit: BoxFit.contain,
              ),

              Text(
                label,
                style: AppTextStyles.header2.copyWith(
                  color: isSecondary ? Colors.white70 : Colors.white,
                  fontSize: 22,
                  shadows: [
                    Shadow(
                      color: isSecondary
                          ? Colors.black45
                          : AppColors.primary.withOpacity(0.8),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
