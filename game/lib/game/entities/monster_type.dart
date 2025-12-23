enum MonsterType { basic, fast, tank, air, boss }

class MonsterStats {
  final String name;
  final double speed;
  final double maxHp;
  final int goldReward;
  final String spriteName;

  const MonsterStats({
    required this.name,
    required this.speed,
    required this.maxHp,
    required this.goldReward,
    required this.spriteName,
  });

  static const Map<MonsterType, MonsterStats> stats = {
    MonsterType.basic: MonsterStats(
      name: 'Orc',
      speed: 100.0,
      maxHp: 100.0,
      goldReward: 10,
      spriteName: 'monster_orc.png',
    ),
    MonsterType.fast: MonsterStats(
      name: 'Wolf',
      speed: 180.0,
      maxHp: 60.0,
      goldReward: 15,
      spriteName: 'monster_wolf.png',
    ),
    MonsterType.tank: MonsterStats(
      name: 'Ogre',
      speed: 60.0,
      maxHp: 250.0,
      goldReward: 25,
      spriteName: 'monster_ogre.png',
    ),
    MonsterType.air: MonsterStats(
      name: 'Bat',
      speed: 120.0,
      maxHp: 80.0,
      goldReward: 20,
      spriteName: 'monster_bat.png', // Placeholder
    ),
    MonsterType.boss: MonsterStats(
      name: 'Boss',
      speed: 50.0,
      maxHp: 1000.0,
      goldReward: 100,
      spriteName: 'monster_boss.png', // Placeholder
    ),
  };

  static MonsterStats get(MonsterType type) => stats[type]!;
}
