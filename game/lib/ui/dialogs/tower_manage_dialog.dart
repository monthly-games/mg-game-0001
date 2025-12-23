import 'package:flutter/material.dart';
import 'package:mg_common_game/core/ui/theme/app_colors.dart';
import 'package:mg_common_game/core/ui/theme/app_text_styles.dart';
import '../../game/entities/tower.dart';
import '../../game/entities/tower_type.dart';

class TowerManageDialog extends StatelessWidget {
  final Tower tower;
  final int currentGold;
  final VoidCallback onUpgrade;
  final VoidCallback onSell;
  final VoidCallback onCancel;

  const TowerManageDialog({
    super.key,
    required this.tower,
    required this.currentGold,
    required this.onUpgrade,
    required this.onSell,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final stats = TowerStats.get(tower.towerType);
    final upgradeCost = tower.getUpgradeCost();
    final sellValue = tower.getSellValue();
    final canAffordUpgrade = currentGold >= upgradeCost && tower.canUpgrade();

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 350,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tower Name
            Text(
              stats.name,
              style: AppTextStyles.header1.copyWith(
                color: AppColors.primary,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 8),

            // Upgrade Level
            if (tower.upgradeLevel > 0)
              Text(
                '★' * tower.upgradeLevel,
                style: const TextStyle(
                  color: Colors.yellow,
                  fontSize: 20,
                ),
              ),
            const SizedBox(height: 16),

            // Stats
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildStatRow('Damage', tower.damage.toInt().toString()),
                  const SizedBox(height: 8),
                  _buildStatRow('Range', tower.range.toInt().toString()),
                  const SizedBox(height: 8),
                  _buildStatRow('Speed', '${(1.0 / tower.attackSpeed).toStringAsFixed(1)}/s'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Upgrade Button
            if (tower.canUpgrade())
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: canAffordUpgrade ? onUpgrade : null,
                  icon: const Icon(Icons.upgrade, size: 24),
                  label: Text(
                    'UPGRADE (${upgradeCost}g)',
                    style: AppTextStyles.button,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canAffordUpgrade ? Colors.green : Colors.grey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    disabledBackgroundColor: Colors.grey.shade800,
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: const Text(
                  'MAX LEVEL',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 12),

            // Sell Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onSell,
                icon: const Icon(Icons.sell, size: 24),
                label: Text(
                  'SELL (+${sellValue}g)',
                  style: AppTextStyles.button,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Cancel Button
            TextButton(
              onPressed: onCancel,
              child: Text(
                'CANCEL',
                style: AppTextStyles.button.copyWith(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.header2.copyWith(
            color: AppColors.primary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
