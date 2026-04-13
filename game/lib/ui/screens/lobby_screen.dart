import 'package:mg_common_game/core/ui/layout/mg_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'stage_select_screen.dart';
import 'battlepass_screen.dart';
import 'gacha_screen.dart';
import 'package:mg_common_game/core/ui/theme/mg_colors.dart';


class LobbyScreen extends StatelessWidget {
  const LobbyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      backgroundImage: 'assets/images/bg_lobby.png',
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Image.asset('assets/images/logo.png', width: 300),
                  const SizedBox(height: 20),

                  // Interactive Spine Character Placeholder
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tower Guardian greets you!'),
                          duration: Duration(seconds: 1),
                          backgroundColor: Colors.amber,
                        ),
                      );
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber.shade700, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withValues(alpha: 0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person, size: 40, color: Colors.white),
                          SizedBox(height: 4),
                          Text(
                            'Guardian',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Quick Start Button
                  _buildMenuButton(
              context,
              label: 'Quick Start',
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const GamePage()),
                );
              },
            ),
            const SizedBox(height: MGSpacing.sm),
                  // Stage Select Button
            _buildMenuButton(
              context,
              label: 'Select Stage',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const StageSelectScreen()),
                );
              },
            ),
            const SizedBox(height: MGSpacing.sm),
                  _buildMenuButton(
              context,
              label: 'Prestige',
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
            const SizedBox(height: MGSpacing.sm),
            _buildMenuButton(
              context,
              label: 'Daily Quests',
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
            const SizedBox(height: MGSpacing.sm),
            _buildMenuButton(
              context,
              label: 'Weekly Challenges',
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
            const SizedBox(height: MGSpacing.sm),
            _buildMenuButton(
              context,
              label: 'Battle Pass',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const BattlepassScreen(),
                  ),
                );
              },
              isSecondary: true,
            ),
            const SizedBox(height: MGSpacing.sm),
            _buildMenuButton(
              context,
              label: 'Gacha',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const GachaScreen(),
                  ),
                );
              },
              isSecondary: true,
            ),
            const SizedBox(height: MGSpacing.sm),
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
            const SizedBox(height: MGSpacing.sm),
            _buildMenuButton(
              context,
              label: 'FRIENDS',
              onTap: () {
                Navigator.of(context).pushNamed('/friends');
              },
              isSecondary: true,
            ),
            const SizedBox(height: MGSpacing.sm),
            _buildMenuButton(
              context,
              label: 'LEADERBOARD',
              onTap: () {
                Navigator.of(context).pushNamed('/leaderboard');
              },
              isSecondary: true,
            ),
            const SizedBox(height: MGSpacing.sm),
            _buildMenuButton(
              context,
              label: 'Settings',
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
            const SizedBox(height: 40),
          ],
        ),
            ),
          ),
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
          width: 260,
          height: 60,
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
                  color: isSecondary ? Colors.white70 : MGColors.textHighEmphasis,
                  fontSize: 18,
                  shadows: [
                    Shadow(
                      color: isSecondary
                          ? Colors.black45
                          : AppColors.primary.withValues(alpha: 0.8),
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
