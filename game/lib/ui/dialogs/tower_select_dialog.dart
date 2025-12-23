import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/core/economy/gold_manager.dart';
import 'package:mg_common_game/core/ui/theme/app_colors.dart';
import 'package:mg_common_game/core/ui/theme/app_text_styles.dart';
import '../../game/entities/tower_type.dart';

class TowerSelectDialog extends StatelessWidget {
  final Function(TowerType) onTowerSelected;
  final VoidCallback onCancel;
  final int currentStage;

  const TowerSelectDialog({
    super.key,
    required this.onTowerSelected,
    required this.onCancel,
    required this.currentStage,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 600, // Increased width for lock info
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SELECT TOWER (Stage $currentStage)',
                  style: AppTextStyles.header1.copyWith(
                    color: AppColors.primary,
                    fontSize: 24,
                  ),
                ),
                Text(
                  'Locked items unlock at later stages',
                  style: AppTextStyles.caption.copyWith(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 24),
            StreamBuilder<int>(
              stream: GetIt.I<GoldManager>().onGoldChanged,
              initialData: GetIt.I<GoldManager>().currentGold,
              builder: (context, snapshot) {
                final currentGold = snapshot.data ?? 0;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: TowerType.values.map((type) {
                    final stats = TowerStats.get(type);
                    final isUnlocked = currentStage >= stats.unlockStage;
                    final canAfford = currentGold >= stats.cost;

                    if (!isUnlocked) {
                      return _buildLockedCard(stats);
                    }
                    return _buildTowerCard(stats, type, canAfford);
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onCancel,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surface,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text('CANCEL'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLockedCard(TowerStats stats) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.3), width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          Text(
            stats.name,
            style: AppTextStyles.header2.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            'Unlocks at Stage ${stats.unlockStage}',
            style: AppTextStyles.caption.copyWith(color: Colors.redAccent),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTowerCard(TowerStats stats, TowerType type, bool canAfford) {
    return InkWell(
      onTap: canAfford ? () => onTowerSelected(type) : null,
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: canAfford
              ? AppColors.surface.withOpacity(0.8)
              : Colors.grey.shade800.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: canAfford ? AppColors.primary : Colors.grey,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    stats.name,
                    style: AppTextStyles.header2.copyWith(
                      fontSize: 18,
                      color: canAfford ? Colors.white : Colors.grey,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: canAfford ? AppColors.secondary : Colors.grey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.monetization_on,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${stats.cost}',
                        style: AppTextStyles.body.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              stats.description,
              style: AppTextStyles.caption.copyWith(
                color: canAfford ? Colors.white70 : Colors.grey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            _buildStatRow('DMG', stats.damage.toInt().toString(), canAfford),
            const SizedBox(height: 4),
            _buildStatRow('RNG', stats.range.toInt().toString(), canAfford),
            const SizedBox(height: 4),
            _buildStatRow(
              'SPD',
              '${(1.0 / stats.attackSpeed).toStringAsFixed(1)}/s',
              canAfford,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, bool canAfford) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: canAfford ? Colors.white60 : Colors.grey,
            fontSize: 11,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.body.copyWith(
            color: canAfford ? AppColors.primary : Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
