import '../entities/monster_type.dart';
import '../entities/tower_type.dart';

/// Stage information
class StageInfo {
  final int stageNumber;
  final String name;
  final int waves;
  final List<TowerType> availableTowers;
  final List<MonsterType> monsterTypes;
  final int startingGold;
  final int startingLives;
  final double difficultyMultiplier;
  final bool hasBoss;

  const StageInfo({
    required this.stageNumber,
    required this.name,
    this.waves = 10,
    required this.availableTowers,
    required this.monsterTypes,
    this.startingGold = 200,
    this.startingLives = 20,
    this.difficultyMultiplier = 1.0,
    this.hasBoss = false,
  });
}

/// Chapter information
class ChapterInfo {
  final String name;
  final String description;
  final int unlockStage;
  final List<StageInfo> stages;

  const ChapterInfo({
    required this.name,
    required this.description,
    required this.unlockStage,
    required this.stages,
  });
}

/// All stage data
class StageData {
  static const List<ChapterInfo> chapters = [
    // Chapter 1: Forest (Stages 1-5)
    ChapterInfo(
      name: 'Forest',
      description: 'The orcs emerge from the dark forest.',
      unlockStage: 0,
      stages: [
        StageInfo(
          stageNumber: 1,
          name: 'First Wave',
          waves: 5,
          availableTowers: [TowerType.basic],
          monsterTypes: [MonsterType.basic],
          startingGold: 150,
          startingLives: 20,
          difficultyMultiplier: 0.5,
        ),
        StageInfo(
          stageNumber: 2,
          name: 'Growing Threat',
          waves: 6,
          availableTowers: [TowerType.basic],
          monsterTypes: [MonsterType.basic],
          startingGold: 175,
          difficultyMultiplier: 0.6,
        ),
        StageInfo(
          stageNumber: 3,
          name: 'Wolf Pack',
          waves: 7,
          availableTowers: [TowerType.basic, TowerType.sniper],
          monsterTypes: [MonsterType.basic, MonsterType.fast],
          startingGold: 200,
          difficultyMultiplier: 0.7,
        ),
        StageInfo(
          stageNumber: 4,
          name: 'Strategic Point',
          waves: 8,
          availableTowers: [TowerType.basic, TowerType.sniper],
          monsterTypes: [MonsterType.basic, MonsterType.fast],
          startingGold: 225,
          difficultyMultiplier: 0.8,
        ),
        StageInfo(
          stageNumber: 5,
          name: 'Forest Guardian',
          waves: 10,
          availableTowers: [TowerType.basic, TowerType.sniper],
          monsterTypes: [MonsterType.basic, MonsterType.fast],
          startingGold: 250,
          difficultyMultiplier: 0.9,
          hasBoss: true,
        ),
      ],
    ),

    // Chapter 2: Canyon (Stages 6-10)
    ChapterInfo(
      name: 'Canyon',
      description: 'Cannons roar through the rocky canyons.',
      unlockStage: 5,
      stages: [
        StageInfo(
          stageNumber: 6,
          name: 'Canyon Entry',
          waves: 8,
          availableTowers: [TowerType.basic, TowerType.sniper, TowerType.splash],
          monsterTypes: [MonsterType.basic, MonsterType.fast],
          startingGold: 250,
          difficultyMultiplier: 1.0,
        ),
        StageInfo(
          stageNumber: 7,
          name: 'Narrow Path',
          waves: 9,
          availableTowers: [TowerType.basic, TowerType.sniper, TowerType.splash],
          monsterTypes: [MonsterType.basic, MonsterType.fast, MonsterType.tank],
          startingGold: 275,
          difficultyMultiplier: 1.1,
        ),
        StageInfo(
          stageNumber: 8,
          name: 'Tank Rush',
          waves: 9,
          availableTowers: [TowerType.basic, TowerType.sniper, TowerType.splash],
          monsterTypes: [MonsterType.basic, MonsterType.tank],
          startingGold: 300,
          difficultyMultiplier: 1.2,
        ),
        StageInfo(
          stageNumber: 9,
          name: 'Mixed Forces',
          waves: 10,
          availableTowers: [TowerType.basic, TowerType.sniper, TowerType.splash],
          monsterTypes: [MonsterType.basic, MonsterType.fast, MonsterType.tank],
          startingGold: 300,
          difficultyMultiplier: 1.3,
        ),
        StageInfo(
          stageNumber: 10,
          name: 'Canyon Boss',
          waves: 10,
          availableTowers: [TowerType.basic, TowerType.sniper, TowerType.splash],
          monsterTypes: [MonsterType.basic, MonsterType.fast, MonsterType.tank],
          startingGold: 350,
          difficultyMultiplier: 1.4,
          hasBoss: true,
        ),
      ],
    ),

    // Chapter 3: Frozen Peaks (Stages 11-15)
    ChapterInfo(
      name: 'Frozen',
      description: 'Frost towers freeze the advancing horde.',
      unlockStage: 10,
      stages: [
        StageInfo(
          stageNumber: 11,
          name: 'Frozen Gate',
          waves: 10,
          availableTowers: [TowerType.basic, TowerType.sniper, TowerType.splash, TowerType.slow],
          monsterTypes: [MonsterType.basic, MonsterType.fast, MonsterType.tank],
          startingGold: 350,
          difficultyMultiplier: 1.5,
        ),
        StageInfo(
          stageNumber: 12,
          name: 'Ice Bridge',
          waves: 10,
          availableTowers: [TowerType.basic, TowerType.sniper, TowerType.splash, TowerType.slow],
          monsterTypes: [MonsterType.basic, MonsterType.fast, MonsterType.tank],
          startingGold: 375,
          difficultyMultiplier: 1.6,
        ),
        StageInfo(
          stageNumber: 13,
          name: 'Blizzard',
          waves: 10,
          availableTowers: [TowerType.basic, TowerType.sniper, TowerType.splash, TowerType.slow],
          monsterTypes: [MonsterType.basic, MonsterType.fast, MonsterType.tank],
          startingGold: 400,
          difficultyMultiplier: 1.7,
        ),
        StageInfo(
          stageNumber: 14,
          name: 'Avalanche',
          waves: 10,
          availableTowers: [TowerType.basic, TowerType.sniper, TowerType.splash, TowerType.slow],
          monsterTypes: [MonsterType.basic, MonsterType.fast, MonsterType.tank],
          startingGold: 400,
          difficultyMultiplier: 1.8,
        ),
        StageInfo(
          stageNumber: 15,
          name: 'Frost Giant',
          waves: 12,
          availableTowers: [TowerType.basic, TowerType.sniper, TowerType.splash, TowerType.slow],
          monsterTypes: [MonsterType.basic, MonsterType.fast, MonsterType.tank],
          startingGold: 450,
          difficultyMultiplier: 1.9,
          hasBoss: true,
        ),
      ],
    ),

    // Chapter 4: Sky Fortress (Stages 16-20)
    ChapterInfo(
      name: 'Sky',
      description: 'Flying enemies fill the skies.',
      unlockStage: 15,
      stages: [
        StageInfo(
          stageNumber: 16,
          name: 'Sky Patrol',
          waves: 10,
          availableTowers: TowerType.values,
          monsterTypes: [MonsterType.basic, MonsterType.fast, MonsterType.air],
          startingGold: 450,
          difficultyMultiplier: 2.0,
        ),
        StageInfo(
          stageNumber: 17,
          name: 'Air Assault',
          waves: 10,
          availableTowers: TowerType.values,
          monsterTypes: [MonsterType.basic, MonsterType.air],
          startingGold: 475,
          difficultyMultiplier: 2.1,
        ),
        StageInfo(
          stageNumber: 18,
          name: 'Sky Swarm',
          waves: 10,
          availableTowers: TowerType.values,
          monsterTypes: [MonsterType.fast, MonsterType.air],
          startingGold: 500,
          difficultyMultiplier: 2.2,
        ),
        StageInfo(
          stageNumber: 19,
          name: 'Combined Arms',
          waves: 12,
          availableTowers: TowerType.values,
          monsterTypes: MonsterType.values.where((t) => t != MonsterType.boss).toList(),
          startingGold: 500,
          difficultyMultiplier: 2.3,
        ),
        StageInfo(
          stageNumber: 20,
          name: 'Sky Dragon',
          waves: 12,
          availableTowers: TowerType.values,
          monsterTypes: MonsterType.values.where((t) => t != MonsterType.boss).toList(),
          startingGold: 550,
          difficultyMultiplier: 2.4,
          hasBoss: true,
        ),
      ],
    ),

    // Chapter 5: Dark Castle (Stages 21-25)
    ChapterInfo(
      name: 'Castle',
      description: 'The dark lord awaits in his fortress.',
      unlockStage: 20,
      stages: [
        StageInfo(
          stageNumber: 21,
          name: 'Castle Gate',
          waves: 12,
          availableTowers: TowerType.values,
          monsterTypes: MonsterType.values.where((t) => t != MonsterType.boss).toList(),
          startingGold: 550,
          difficultyMultiplier: 2.5,
        ),
        StageInfo(
          stageNumber: 22,
          name: 'Courtyard',
          waves: 12,
          availableTowers: TowerType.values,
          monsterTypes: MonsterType.values.where((t) => t != MonsterType.boss).toList(),
          startingGold: 575,
          difficultyMultiplier: 2.6,
        ),
        StageInfo(
          stageNumber: 23,
          name: 'Inner Keep',
          waves: 12,
          availableTowers: TowerType.values,
          monsterTypes: MonsterType.values.where((t) => t != MonsterType.boss).toList(),
          startingGold: 600,
          difficultyMultiplier: 2.7,
        ),
        StageInfo(
          stageNumber: 24,
          name: 'Throne Room',
          waves: 12,
          availableTowers: TowerType.values,
          monsterTypes: MonsterType.values.where((t) => t != MonsterType.boss).toList(),
          startingGold: 600,
          difficultyMultiplier: 2.8,
        ),
        StageInfo(
          stageNumber: 25,
          name: 'Dark Lord',
          waves: 15,
          availableTowers: TowerType.values,
          monsterTypes: MonsterType.values.where((t) => t != MonsterType.boss).toList(),
          startingGold: 650,
          difficultyMultiplier: 3.0,
          hasBoss: true,
        ),
      ],
    ),

    // Chapter 6: Endless (Stages 26-30)
    ChapterInfo(
      name: 'Endless',
      description: 'Ultimate challenge awaits the brave.',
      unlockStage: 25,
      stages: [
        StageInfo(
          stageNumber: 26,
          name: 'Nightmare I',
          waves: 15,
          availableTowers: TowerType.values,
          monsterTypes: MonsterType.values.where((t) => t != MonsterType.boss).toList(),
          startingGold: 650,
          startingLives: 15,
          difficultyMultiplier: 3.2,
        ),
        StageInfo(
          stageNumber: 27,
          name: 'Nightmare II',
          waves: 15,
          availableTowers: TowerType.values,
          monsterTypes: MonsterType.values.where((t) => t != MonsterType.boss).toList(),
          startingGold: 700,
          startingLives: 15,
          difficultyMultiplier: 3.5,
        ),
        StageInfo(
          stageNumber: 28,
          name: 'Nightmare III',
          waves: 15,
          availableTowers: TowerType.values,
          monsterTypes: MonsterType.values.where((t) => t != MonsterType.boss).toList(),
          startingGold: 750,
          startingLives: 10,
          difficultyMultiplier: 4.0,
        ),
        StageInfo(
          stageNumber: 29,
          name: 'Hell Gate',
          waves: 20,
          availableTowers: TowerType.values,
          monsterTypes: MonsterType.values.where((t) => t != MonsterType.boss).toList(),
          startingGold: 800,
          startingLives: 10,
          difficultyMultiplier: 4.5,
          hasBoss: true,
        ),
        StageInfo(
          stageNumber: 30,
          name: 'Final Stand',
          waves: 25,
          availableTowers: TowerType.values,
          monsterTypes: MonsterType.values.where((t) => t != MonsterType.boss).toList(),
          startingGold: 1000,
          startingLives: 5,
          difficultyMultiplier: 5.0,
          hasBoss: true,
        ),
      ],
    ),
  ];

  /// Get stage info by stage number
  static StageInfo? getStage(int stageNumber) {
    for (final chapter in chapters) {
      for (final stage in chapter.stages) {
        if (stage.stageNumber == stageNumber) {
          return stage;
        }
      }
    }
    return null;
  }

  /// Get total stage count
  static int get totalStages => chapters.fold(0, (sum, c) => sum + c.stages.length);
}
