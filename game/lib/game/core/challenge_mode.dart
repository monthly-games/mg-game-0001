/// Challenge Mode System for MG-0001 Tower Defense X
/// Provides alternative game modes for replay motivation

enum ChallengeMode {
  /// Standard gameplay mode
  normal,

  /// Hardcore: 1 life, limited starting gold (50% of normal)
  hardcore,

  /// Speed: Track fastest clear time, 2x game speed locked
  speed,

  /// Endless: Infinite waves with scaling difficulty
  endless,
}

class ChallengeModeConfig {
  final ChallengeMode mode;
  final String displayName;
  final String description;
  final int startingLives;
  final double startingGoldMultiplier;
  final bool lockGameSpeed;
  final double lockedGameSpeed;
  final bool infiniteWaves;
  final double waveDifficultyScaling;

  const ChallengeModeConfig({
    required this.mode,
    required this.displayName,
    required this.description,
    required this.startingLives,
    required this.startingGoldMultiplier,
    this.lockGameSpeed = false,
    this.lockedGameSpeed = 1.0,
    this.infiniteWaves = false,
    this.waveDifficultyScaling = 0.1,
  });

  static const Map<ChallengeMode, ChallengeModeConfig> configs = {
    ChallengeMode.normal: ChallengeModeConfig(
      mode: ChallengeMode.normal,
      displayName: 'Normal Mode',
      description: 'Standard tower defense experience',
      startingLives: 20,
      startingGoldMultiplier: 1.0,
    ),
    ChallengeMode.hardcore: ChallengeModeConfig(
      mode: ChallengeMode.hardcore,
      displayName: 'Hardcore Mode',
      description: 'Only 1 life! Limited gold. Perfection required.',
      startingLives: 1,
      startingGoldMultiplier: 0.5,
    ),
    ChallengeMode.speed: ChallengeModeConfig(
      mode: ChallengeMode.speed,
      displayName: 'Speed Run',
      description: 'Fastest clear time wins! 2x speed locked.',
      startingLives: 20,
      startingGoldMultiplier: 1.0,
      lockGameSpeed: true,
      lockedGameSpeed: 2.0,
    ),
    ChallengeMode.endless: ChallengeModeConfig(
      mode: ChallengeMode.endless,
      displayName: 'Endless Mode',
      description: 'How long can you survive? Infinite waves!',
      startingLives: 20,
      startingGoldMultiplier: 1.0,
      infiniteWaves: true,
      waveDifficultyScaling: 0.15,
    ),
  };

  static ChallengeModeConfig get(ChallengeMode mode) => configs[mode]!;

  /// Calculate starting gold based on base gold and challenge mode
  int calculateStartingGold(int baseGold) {
    return (baseGold * startingGoldMultiplier).round();
  }

  /// Check if game speed can be changed in this mode
  bool canChangeSpeed() => !lockGameSpeed;

  /// Get the difficulty multiplier for a specific wave in endless mode
  double getWaveDifficultyMultiplier(int wave) {
    if (!infiniteWaves) return 1.0;
    return 1.0 + (wave * waveDifficultyScaling);
  }
}

/// Speed run tracking data
class SpeedRunData {
  final int stageNumber;
  final ChallengeMode mode;
  final Duration clearTime;
  final DateTime timestamp;

  SpeedRunData({
    required this.stageNumber,
    required this.mode,
    required this.clearTime,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'stageNumber': stageNumber,
    'mode': mode.name,
    'clearTimeMs': clearTime.inMilliseconds,
    'timestamp': timestamp.toIso8601String(),
  };

  factory SpeedRunData.fromJson(Map<String, dynamic> json) => SpeedRunData(
    stageNumber: json['stageNumber'] as int,
    mode: ChallengeMode.values.firstWhere((m) => m.name == json['mode']),
    clearTime: Duration(milliseconds: json['clearTimeMs'] as int),
    timestamp: DateTime.parse(json['timestamp'] as String),
  );
}

/// Endless mode wave data
class EndlessWaveData {
  final int waveNumber;
  final int monstersKilled;
  final int goldEarned;
  final bool survived;

  EndlessWaveData({
    required this.waveNumber,
    required this.monstersKilled,
    required this.goldEarned,
    required this.survived,
  });
}
