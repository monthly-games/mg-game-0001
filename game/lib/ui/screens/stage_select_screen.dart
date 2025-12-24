import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/core/ui/layouts/game_scaffold.dart';
import 'package:mg_common_game/core/ui/theme/app_colors.dart';
import 'package:mg_common_game/core/ui/theme/app_text_styles.dart';
import 'package:mg_common_game/systems/progression/progression_manager.dart';
import '../../game/core/stage_data.dart';
import '../../main.dart';

class StageSelectScreen extends StatefulWidget {
  const StageSelectScreen({super.key});

  @override
  State<StageSelectScreen> createState() => _StageSelectScreenState();
}

class _StageSelectScreenState extends State<StageSelectScreen> {
  int _selectedChapter = 0;

  @override
  Widget build(BuildContext context) {
    final progressionManager = GetIt.I<ProgressionManager>();
    final clearedStages = progressionManager.currentLevel; // Use level as cleared stages

    return GameScaffold(
      backgroundImage: 'assets/images/bg_lobby.png',
      body: Column(
        children: [
          // Header
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'SELECT STAGE',
                    style: AppTextStyles.header1.copyWith(
                      color: Colors.white,
                      fontSize: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Chapter Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: List.generate(StageData.chapters.length, (index) {
                final chapter = StageData.chapters[index];
                final isSelected = _selectedChapter == index;
                final isUnlocked = clearedStages >= chapter.unlockStage;

                return Expanded(
                  child: GestureDetector(
                    onTap: isUnlocked ? () => setState(() => _selectedChapter = index) : null,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : isUnlocked
                                ? Colors.black54
                                : Colors.black26,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : Colors.white24,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          if (!isUnlocked)
                            const Icon(Icons.lock, color: Colors.white38, size: 20)
                          else
                            Text(
                              chapter.name,
                              style: TextStyle(
                                color: isUnlocked ? Colors.white : Colors.white38,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),

          // Stage Grid
          Expanded(
            child: _buildStageGrid(clearedStages),
          ),
        ],
      ),
    );
  }

  Widget _buildStageGrid(int clearedStages) {
    final chapter = StageData.chapters[_selectedChapter];
    final stages = chapter.stages;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: stages.length,
      itemBuilder: (context, index) {
        final stage = stages[index];
        final isUnlocked = clearedStages >= stage.stageNumber - 1;
        final isCleared = clearedStages >= stage.stageNumber;
        final stars = isCleared ? _getStars(stage.stageNumber) : 0;

        return _buildStageButton(
          stage: stage,
          isUnlocked: isUnlocked,
          isCleared: isCleared,
          stars: stars,
        );
      },
    );
  }

  int _getStars(int stageNumber) {
    // TODO: Load from save data
    return 3; // Placeholder: all 3 stars
  }

  Widget _buildStageButton({
    required StageInfo stage,
    required bool isUnlocked,
    required bool isCleared,
    required int stars,
  }) {
    return GestureDetector(
      onTap: isUnlocked
          ? () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => GamePage(stageNumber: stage.stageNumber),
                ),
              );
            }
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: isUnlocked
              ? (isCleared ? Colors.green.withOpacity(0.3) : Colors.black54)
              : Colors.black26,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUnlocked
                ? (isCleared ? Colors.green : AppColors.primary)
                : Colors.white24,
            width: 2,
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: (isCleared ? Colors.green : AppColors.primary)
                        .withOpacity(0.3),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isUnlocked)
              const Icon(Icons.lock, color: Colors.white38, size: 28)
            else ...[
              Text(
                '${stage.stageNumber}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: isCleared ? Colors.green : AppColors.primary,
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
              if (isCleared) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) {
                    return Icon(
                      Icons.star,
                      size: 14,
                      color: i < stars ? Colors.yellow : Colors.white24,
                    );
                  }),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
