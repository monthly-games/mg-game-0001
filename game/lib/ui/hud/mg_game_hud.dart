import 'package:flutter/material.dart';
import 'package:mg_common_game/core/ui/mg_ui.dart';

/// MG UI 기반 타워 디펜스 HUD
/// mg_common_game의 공통 UI 컴포넌트 활용
class MGGameHud extends StatelessWidget {
  final int gold;
  final int wave;
  final int maxWave;
  final int lives;
  final int maxLives;
  final bool isWaveActive;
  final double gameSpeed;
  final VoidCallback? onBuildTower;
  final VoidCallback? onNextWave;
  final VoidCallback? onPause;
  final VoidCallback? onSpeedChange;

  const MGGameHud({
    super.key,
    required this.gold,
    required this.wave,
    this.maxWave = 10,
    required this.lives,
    this.maxLives = 20,
    this.isWaveActive = false,
    this.gameSpeed = 1.0,
    this.onBuildTower,
    this.onNextWave,
    this.onPause,
    this.onSpeedChange,
  });

  @override
  Widget build(BuildContext context) {
    final safeArea = MediaQuery.of(context).padding;

    return Positioned.fill(
      child: Column(
        children: [
          // 상단 HUD: 웨이브 + 자원
          Container(
            padding: EdgeInsets.only(
              top: safeArea.top + MGSpacing.hudMargin,
              left: safeArea.left + MGSpacing.hudMargin,
              right: safeArea.right + MGSpacing.hudMargin,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildWaveInfo(),
                _buildResourceBar(),
              ],
            ),
          ),

          // 중앙 영역 확장
          const Expanded(child: SizedBox()),

          // 하단 HUD: 타워 빌드 + 다음 웨이브
          Container(
            padding: EdgeInsets.only(
              bottom: safeArea.bottom + MGSpacing.hudMargin,
              left: safeArea.left + MGSpacing.hudMargin,
              right: safeArea.right + MGSpacing.hudMargin,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTowerSelection(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildSpeedControl(),
                    MGSpacing.hSm,
                    _buildPauseButton(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isWaveActive ? MGColors.warning : Colors.white24,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.waves,
            color: isWaveActive ? MGColors.warning : Colors.white,
            size: 20,
          ),
          MGSpacing.hXs,
          Text(
            'Wave $wave/$maxWave',
            style: MGTextStyles.hud.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (isWaveActive) ...[
            MGSpacing.hSm,
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResourceBar() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 골드
        MGResourceBar(
          icon: Icons.monetization_on,
          value: _formatNumber(gold),
          iconColor: MGColors.gold,
          onTap: null,
        ),
        MGSpacing.hSm,
        // 생명력
        _buildLivesIndicator(),
      ],
    );
  }

  Widget _buildLivesIndicator() {
    final isLow = lives <= 5;
    final percentage = lives / maxLives;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
        border: isLow
            ? Border.all(color: MGColors.error, width: 2)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.favorite,
            color: isLow ? MGColors.error : Colors.red,
            size: 20,
          ),
          MGSpacing.hXs,
          SizedBox(
            width: 60,
            child: MGLinearProgress(
              value: percentage,
              height: 8,
              valueColor: isLow ? MGColors.error : Colors.red,
              backgroundColor: Colors.red.withValues(alpha: 0.3),
              borderRadius: 4,
            ),
          ),
          MGSpacing.hXs,
          Text(
            '$lives',
            style: MGTextStyles.hudSmall.copyWith(
              color: isLow ? MGColors.error : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTowerSelection() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 타워 건설 버튼
        MGButton.primary(
          label: 'BUILD',
          icon: Icons.add_circle,
          size: MGButtonSize.small,
          onPressed: onBuildTower,
        ),
        MGSpacing.hMd,
        // 다음 웨이브 버튼
        MGButton(
          label: 'NEXT WAVE',
          icon: Icons.fast_forward,
          style: MGButtonStyle.filled,
          size: MGButtonSize.small,
          backgroundColor: isWaveActive ? Colors.grey : MGColors.warning,
          onPressed: isWaveActive ? null : onNextWave,
        ),
      ],
    );
  }

  Widget _buildSpeedControl() {
    return GestureDetector(
      onTap: onSpeedChange,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              gameSpeed == 1.0 ? Icons.play_arrow : Icons.fast_forward,
              color: Colors.white,
              size: 20,
            ),
            MGSpacing.vXs,
            Text(
              '${gameSpeed.toStringAsFixed(0)}x',
              style: MGTextStyles.caption.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPauseButton() {
    return MGIconButton(
      icon: Icons.pause,
      onPressed: onPause,
      size: 44,
      backgroundColor: Colors.black54,
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
