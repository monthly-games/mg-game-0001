// ============================================================
// Daily Quest Screen -- MG-0001 Tower Defense
// Simplified standalone version
// ============================================================

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/core/ui/theme/mg_colors.dart';
import 'package:mg_common_game/core/economy/gold_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Daily Quest screen for MG-0001 Tower Defense.
class DailyQuestScreen extends StatefulWidget {
  const DailyQuestScreen({super.key});

  @override
  State<DailyQuestScreen> createState() => _DailyQuestScreenState();
}

class _DailyQuestScreenState extends State<DailyQuestScreen> {
  final List<_SimpleQuest> _quests = [];

  @override
  void initState() {
    super.initState();
    _initializeQuests();
  }

  Future<void> _initializeQuests() async {
    final prefs = await SharedPreferences.getInstance();
    final todayKey = '${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}';

    // Create simple daily quests
    _quests.addAll([
      _SimpleQuest(
        id: 'daily_play_3',
        title: 'Play 3 Games',
        description: 'Complete 3 game sessions',
        targetValue: 3,
        goldReward: 100,
      ),
      _SimpleQuest(
        id: 'daily_kill_100',
        title: 'Defeat 100 Enemies',
        description: 'Eliminate 100 enemies across all games',
        targetValue: 100,
        goldReward: 200,
      ),
      _SimpleQuest(
        id: 'daily_wave_10',
        title: 'Reach Wave 10',
        description: 'Survive until wave 10 in a single game',
        targetValue: 10,
        goldReward: 300,
      ),
    ]);

    // Load progress
    for (final quest in _quests) {
      final progress = prefs.getInt('quest_${quest.id}_$todayKey') ?? 0;
      final claimed = prefs.getBool('quest_${quest.id}_claimed_$todayKey') ?? false;
      quest.setProgress(progress);
      if (claimed) quest.claimReward();
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Quests'),
        backgroundColor: MGColors.cardDark,
      ),
      backgroundColor: const Color(0xFF101827),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _quests.length,
        itemBuilder: (context, index) {
          final quest = _quests[index];
          return _QuestCard(
            quest: quest,
            onClaim: () => _claimReward(quest),
          );
        },
      ),
    );
  }

  void _claimReward(_SimpleQuest quest) {
    if (quest.claimReward()) {
      GetIt.I<GoldManager>().addGold(quest.goldReward);

      // Save claimed state
      final todayKey = '${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}';
      SharedPreferences.getInstance().then((prefs) {
        prefs.setBool('quest_${quest.id}_claimed_$todayKey', true);
      });

      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Claimed ${quest.goldReward}g!'),
            backgroundColor: MGColors.success,
          ),
        );
      });
    }
  }
}

class _QuestCard extends StatelessWidget {
  final _SimpleQuest quest;
  final VoidCallback onClaim;

  const _QuestCard({
    required this.quest,
    required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    final isClaimable = quest.isCompleted && !quest.isClaimed;
    final isClaimed = quest.isClaimed;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: MGColors.cardDark,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isClaimed ? Icons.check_circle : Icons.task_alt,
                  color: isClaimed ? MGColors.success : MGColors.primaryAction,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quest.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        quest.description,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '+${quest.goldReward}g',
                  style: const TextStyle(
                    color: MGColors.gold,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: quest.progressPercentage,
              backgroundColor: MGColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(
                isClaimed ? MGColors.success : MGColors.primaryAction,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${quest.currentProgress} / ${quest.targetValue}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
                if (isClaimable)
                  ElevatedButton(
                    onPressed: onClaim,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MGColors.success,
                    ),
                    child: const Text('Claim Reward'),
                  )
                else if (isClaimed)
                  const Text(
                    'Claimed',
                    style: TextStyle(
                      color: MGColors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple quest data class
class _SimpleQuest {
  final String id;
  final String title;
  final String description;
  final int targetValue;
  final int goldReward;

  int _currentProgress = 0;
  bool _isClaimed = false;

  _SimpleQuest({
    required this.id,
    required this.title,
    required this.description,
    required this.targetValue,
    required this.goldReward,
  });

  int get currentProgress => _currentProgress;
  bool get isCompleted => _currentProgress >= targetValue;
  bool get isClaimed => _isClaimed;
  double get progressPercentage => (_currentProgress / targetValue).clamp(0.0, 1.0);

  void setProgress(int progress) {
    _currentProgress = progress.clamp(0, targetValue);
  }

  void addProgress(int amount) {
    if (_isClaimed) return;
    _currentProgress = (_currentProgress + amount).clamp(0, targetValue);

    // Save progress
    final todayKey = '${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}';
    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt('quest_${id}_$todayKey', _currentProgress);
    });
  }

  bool claimReward() {
    if (!isCompleted || _isClaimed) return false;
    _isClaimed = true;
    return true;
  }
}
