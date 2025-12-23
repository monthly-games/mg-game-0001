enum TowerType {
  basic,
  slow,
  splash,
  sniper,
  air, // Anti-Air
}

class TowerStats {
  final String name;
  final int cost;
  final double range;
  final double damage;
  final double attackSpeed;
  final String spriteName;
  final String description;
  final int unlockStage;

  const TowerStats({
    required this.name,
    required this.cost,
    required this.range,
    required this.damage,
    required this.attackSpeed,
    required this.spriteName,
    required this.description,
    this.unlockStage = 1,
  });

  static const Map<TowerType, TowerStats> stats = {
    TowerType.basic: TowerStats(
      name: 'Basic Tower',
      cost: 50,
      range: 150.0,
      damage: 25.0,
      attackSpeed: 1.0,
      spriteName: 'tower_archer.png',
      description: 'Balanced tower with good damage and range',
      unlockStage: 1,
    ),
    TowerType.slow: TowerStats(
      name: 'Frost Tower',
      cost: 75,
      range: 130.0,
      damage: 15.0,
      attackSpeed: 1.2,
      spriteName: 'tower_frost.png',
      description: 'Slows enemies by 50% for 2 seconds',
      unlockStage: 10, // Stage 11-15 -> unlock condition Clear Stage 10
    ),
    TowerType.splash: TowerStats(
      name: 'Cannon Tower',
      cost: 100,
      range: 120.0,
      damage: 40.0,
      attackSpeed: 2.0,
      spriteName: 'tower_cannon.png',
      description: 'Deals area damage to nearby enemies',
      unlockStage: 5, // Stage 6-10 -> Clear Stage 5
    ),
    TowerType.sniper: TowerStats(
      name: 'Sniper Tower',
      cost: 120,
      range: 250.0,
      damage: 60.0,
      attackSpeed: 2.5,
      spriteName: 'tower_sniper.png',
      description: 'Long range with high damage but slow attack',
      unlockStage:
          1, // Default? Design doc didn't specify Sniper explicitly, assumed basic set
    ),
    TowerType.air: TowerStats(
      name: 'Sky Watcher',
      cost: 90,
      range: 180.0,
      damage: 35.0,
      attackSpeed: 0.8,
      spriteName: 'tower_air.png',
      description: 'High damage against flying enemies',
      unlockStage: 15, // Stage 16-20 -> Clear Stage 15
    ),
  };

  static TowerStats get(TowerType type) => stats[type]!;
}
