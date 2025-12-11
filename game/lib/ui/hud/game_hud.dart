import 'package:flutter/material.dart';
import 'package:mg_common_game/core/ui/theme/app_colors.dart';
import 'package:mg_common_game/core/ui/theme/app_text_styles.dart';
import 'package:mg_common_game/core/ui/widgets/hud/resource_bar.dart';
import 'package:mg_common_game/core/ui/widgets/containers/game_panel.dart';
import 'package:mg_common_game/core/ui/widgets/buttons/game_button.dart';

class GameHud extends StatelessWidget {
  final int gold;
  final int wave;
  final VoidCallback? onBuildTower;
  final VoidCallback? onNextWave;

  const GameHud({
    super.key,
    required this.gold,
    required this.wave,
    this.onBuildTower,
    this.onNextWave,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top Left: Gold
        Positioned(
          top: 16,
          left: 16,
          child: ResourceBar(
            icon: Icons.monetization_on,
            value: '$gold',
            label: 'GOLD',
            color: AppColors.secondary,
          ),
        ),

        // Top Right: Wave Info
        Positioned(
          top: 16,
          right: 16,
          child: GamePanel(
            isGlass: true,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              'WAVE $wave',
              style: AppTextStyles.header2.copyWith(fontSize: 20),
            ),
          ),
        ),

        // Bottom Center: Build Controls
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: Center(
            child: GamePanel(
              isGlass: true,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildActionButton(
                    icon: Icons.security,
                    label: 'BUILD TOWER',
                    onTap: onBuildTower,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 16),
                  _buildActionButton(
                    icon: Icons.fast_forward,
                    label: 'NEXT WAVE',
                    onTap: onNextWave,
                    color: AppColors.error,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(8),
            color: color.withOpacity(0.2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
