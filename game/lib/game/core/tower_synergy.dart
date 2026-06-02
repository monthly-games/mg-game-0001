import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:tower_defense/game/entities/tower.dart';
import 'package:tower_defense/game/entities/tower_type.dart';
import 'package:tower_defense/game/tower_defense_game.dart';

/// Tower Synergy System for MG-0001 Tower Defense X
/// Provides bonus effects when towers of the same type are placed adjacently

class TowerSynergyManager extends Component
    with HasGameReference<TowerDefenseGame> {
  /// Map to track tower positions by grid coordinates
  final Map<String, List<Tower>> _towersByPosition = {};

  /// Get grid position key for a tower
  String _getGridKey(Tower tower) {
    final x = (tower.position.x - 20) ~/ 40; // Assuming 40 tile size
    final y = (tower.position.y - 20) ~/ 40;
    return '$x,$y';
  }

  /// Register a tower when it's placed
  void registerTower(Tower tower) {
    final key = _getGridKey(tower);
    _towersByPosition.putIfAbsent(key, () => []);
    _towersByPosition[key]!.add(tower);

    // Check for synergies with this new tower
    _checkAndApplySynergies(tower);
  }

  /// Unregister a tower when it's removed
  void unregisterTower(Tower tower) {
    final key = _getGridKey(tower);
    if (_towersByPosition.containsKey(key)) {
      _towersByPosition[key]!.remove(tower);
      if (_towersByPosition[key]!.isEmpty) {
        _towersByPosition.remove(key);
      }
    }

    // Re-evaluate synergies for nearby towers
    _reevaluateNearbySynergies(tower);
  }

  /// Check and apply synergies for a newly placed tower
  void _checkAndApplySynergies(Tower newTower) {
    final nearbyTowers = _getNearbyTowers(newTower);

    // Group by tower type
    final Map<TowerType, List<Tower>> towersByType = {};
    for (final tower in nearbyTowers) {
      towersByType.putIfAbsent(tower.towerType, () => []);
      towersByType[tower.towerType]!.add(tower);
    }

    // Apply synergies based on tower type clusters
    for (final entry in towersByType.entries) {
      final type = entry.key;
      final towers = entry.value;

      // Same type synergy: 3+ adjacent towers of same type = +20% damage
      if (towers.length >= 2) {
        // Including the new tower
        final bonus = _calculateSynergyBonus(type, towers.length);
        _applySynergyBonus(towers, bonus);
      }
    }
  }

  /// Get towers in adjacent positions (including diagonals)
  List<Tower> _getNearbyTowers(Tower tower) {
    final x = (tower.position.x - 20) ~/ 40;
    final y = (tower.position.y - 20) ~/ 40;

    final nearbyTowers = <Tower>[];

    // Check all 8 adjacent positions
    for (int dx = -1; dx <= 1; dx++) {
      for (int dy = -1; dy <= 1; dy++) {
        if (dx == 0 && dy == 0) continue; // Skip current position

        final key = '${x + dx},${y + dy}';
        if (_towersByPosition.containsKey(key)) {
          nearbyTowers.addAll(_towersByPosition[key]!);
        }
      }
    }

    return nearbyTowers;
  }

  /// Calculate synergy bonus based on tower type and count
  SynergyBonus _calculateSynergyBonus(TowerType type, int count) {
    double damageMultiplier = 1.0;
    double rangeMultiplier = 1.0;
    double attackSpeedMultiplier = 1.0;
    List<String> specialEffects = [];

    // Base synergy: 3+ same type = +20% damage
    if (count >= 3) {
      damageMultiplier += 0.2;

      // Additional bonuses for larger clusters
      if (count >= 5) {
        damageMultiplier += 0.1; // +30% total
        rangeMultiplier += 0.1; // +10% range
      }
      if (count >= 7) {
        attackSpeedMultiplier += 0.15; // +15% attack speed
        specialEffects.add('Master Synergy');
      }
    }

    // Type-specific synergies
    switch (type) {
      case TowerType.basic:
        // Basic towers: +5% damage per adjacent tower (max +25%)
        if (count > 0) {
          damageMultiplier += (count * 0.05).clamp(0.0, 0.25);
        }
        break;
      case TowerType.splash:
        // Splash towers: +10% splash radius per tower (max +50%)
        if (count >= 2) {
          specialEffects.add('Expanding Blast');
        }
        break;
      case TowerType.slow:
        // Slow towers: stacking slow effect
        if (count >= 2) {
          specialEffects.add('Deep Freeze');
        }
        if (count >= 4) {
          specialEffects.add('Permafrost');
        }
        break;
      case TowerType.sniper:
        // Sniper towers: +10% range per tower (max +30%)
        if (count > 0) {
          rangeMultiplier += (count * 0.1).clamp(0.0, 0.3);
        }
        if (count >= 3) {
          specialEffects.add('Death Zone');
        }
        break;
      case TowerType.air:
        // Air towers: chain lightning effect at 3+ towers
        if (count >= 3) {
          specialEffects.add('Chain Lightning');
        }
        break;
    }

    return SynergyBonus(
      damageMultiplier: damageMultiplier,
      rangeMultiplier: rangeMultiplier,
      attackSpeedMultiplier: attackSpeedMultiplier,
      specialEffects: specialEffects,
      towerCount: count,
    );
  }

  /// Apply synergy bonus to a group of towers
  void _applySynergyBonus(List<Tower> towers, SynergyBonus bonus) {
    for (final tower in towers) {
      tower.applySynergyBonus(bonus);
    }

    // Show visual feedback
    if (towers.isNotEmpty) {
      final centerTower = towers.first;
      game.vfxManager.showSynergyActivated(centerTower.position, bonus);
    }
  }

  /// Re-evaluate synergies for towers near a removed tower
  void _reevaluateNearbySynergies(Tower removedTower) {
    final nearbyTowers = _getNearbyTowers(removedTower);

    // Clear all synergy bonuses from nearby towers
    for (final tower in nearbyTowers) {
      tower.clearSynergyBonus();
    }

    // Re-apply synergies without the removed tower
    for (final tower in nearbyTowers) {
      _checkAndApplySynergies(tower);
    }
  }

  /// Get synergy info for a tower at a position
  SynergyInfo? getSynergyInfo(Tower tower) {
    final nearbyTowers = _getNearbyTowers(tower);
    final Map<TowerType, int> typeCount = {};

    for (final nearby in nearbyTowers) {
      typeCount[nearby.towerType] = (typeCount[nearby.towerType] ?? 0) + 1;
    }

    if (typeCount.isEmpty) return null;

    return SynergyInfo(
      nearbyTowers: nearbyTowers.length,
      typeBreakdown: typeCount,
      potentialBonus: _calculateSynergyBonus(
        tower.towerType,
        (typeCount[tower.towerType] ?? 0),
      ),
    );
  }
}

/// Data class for synergy bonuses
class SynergyBonus {
  final double damageMultiplier;
  final double rangeMultiplier;
  final double attackSpeedMultiplier;
  final List<String> specialEffects;
  final int towerCount;

  SynergyBonus({
    required this.damageMultiplier,
    required this.rangeMultiplier,
    required this.attackSpeedMultiplier,
    required this.specialEffects,
    required this.towerCount,
  });

  /// Get display text for the bonus
  String getDisplayText() {
    final parts = <String>[];

    if (damageMultiplier > 1.0) {
      parts.add('+${((damageMultiplier - 1.0) * 100).toInt()}% DMG');
    }
    if (rangeMultiplier > 1.0) {
      parts.add('+${((rangeMultiplier - 1.0) * 100).toInt()}% RNG');
    }
    if (attackSpeedMultiplier > 1.0) {
      parts.add('+${((attackSpeedMultiplier - 1.0) * 100).toInt()}% SPD');
    }
    if (specialEffects.isNotEmpty) {
      parts.add(specialEffects.join(', '));
    }

    return parts.isEmpty ? 'No Synergy' : parts.join(' | ');
  }

  /// Get color based on bonus strength
  Color getBonusColor() {
    if (specialEffects.isNotEmpty) return Colors.purple;
    if (damageMultiplier >= 1.3) return Colors.orange;
    if (damageMultiplier >= 1.2) return Colors.yellow;
    return Colors.green;
  }
}

/// Data class for synergy information display
class SynergyInfo {
  final int nearbyTowers;
  final Map<TowerType, int> typeBreakdown;
  final SynergyBonus potentialBonus;

  SynergyInfo({
    required this.nearbyTowers,
    required this.typeBreakdown,
    required this.potentialBonus,
  });

  String getDescription() {
    if (nearbyTowers == 0) return 'No adjacent towers';

    final typeStrings = typeBreakdown.entries
        .map((e) {
          final typeName = _getTowerTypeName(e.key);
          return '$typeName: ${e.value}';
        })
        .join(', ');

    return 'Nearby: $nearbyTowers ($typeStrings)';
  }

  static String _getTowerTypeName(TowerType type) {
    switch (type) {
      case TowerType.basic:
        return 'Basic';
      case TowerType.slow:
        return 'Frost';
      case TowerType.splash:
        return 'Cannon';
      case TowerType.sniper:
        return 'Sniper';
      case TowerType.air:
        return 'Sky';
    }
  }
}
