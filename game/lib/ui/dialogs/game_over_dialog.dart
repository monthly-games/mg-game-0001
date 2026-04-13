import 'package:mg_common_game/core/ui/layout/mg_spacing.dart';
import 'package:flutter/material.dart';
import 'package:mg_common_game/core/ui/theme/app_colors.dart';
import 'package:mg_common_game/core/ui/theme/app_text_styles.dart';
import 'package:mg_common_game/core/ui/theme/mg_colors.dart';

class GameOverDialog extends StatelessWidget {
  final bool isVictory;
  final int wave;
  final int goldEarned;
  final VoidCallback onRestart;
  final VoidCallback onMainMenu;

  const GameOverDialog({
    super.key,
    required this.isVictory,
    required this.wave,
    required this.goldEarned,
    required this.onRestart,
    required this.onMainMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(MGSpacing.xl),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isVictory ? MGColors.success : MGColors.error,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: (isVictory ? MGColors.success : MGColors.error).withValues(alpha: 0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              isVictory ? '🎉 VICTORY! 🎉' : '💀 GAME OVER 💀',
              style: AppTextStyles.header1.copyWith(
                color: isVictory ? MGColors.success : MGColors.error,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: MGSpacing.lg),

            // Stats
            _buildStatRow(
              'Waves Survived:',
              '$wave',
              isVictory ? MGColors.success : MGColors.warning,
            ),
            const SizedBox(height: MGSpacing.sm),
            _buildStatRow(
              'Gold Earned:',
              '$goldEarned',
              AppColors.secondary,
            ),
            const SizedBox(height: MGSpacing.xl),

            // Buttons
            Column(
              children: [
                _buildButton(
                  label: 'PLAY AGAIN',
                  icon: Icons.replay,
                  color: AppColors.primary,
                  onPressed: onRestart,
                ),
                const SizedBox(height: MGSpacing.sm),
                _buildButton(
                  label: 'MAIN MENU',
                  icon: Icons.home,
                  color: AppColors.surface,
                  onPressed: onMainMenu,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: Colors.white70,
            fontSize: 18,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.header2.copyWith(
            color: valueColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 24),
        label: Text(
          label,
          style: AppTextStyles.button.copyWith(fontSize: 18),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: MGColors.textHighEmphasis,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 8,
        ),
      ),
    );
  }
}
