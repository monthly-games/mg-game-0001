import 'package:mg_common_game/core/assets/asset_types.dart';

/// Spine 통합 플래그. `--dart-define=SPINE_ENABLED=true`로 활성화.
const kSpineEnabled = bool.fromEnvironment(
  'SPINE_ENABLED',
  defaultValue: false,
);

// ── Tower Archer ─────────────────────────────────────────────

const kTowerArcherMeta = SpineAssetMeta(
  key: 'tower_archer',
  path: 'spine/characters/tower_archer',
  atlasPath: 'assets/spine/characters/tower_archer/tower_archer.atlas',
  skeletonPath:
      'assets/spine/characters/tower_archer/tower_archer.json',
  animations: ['idle', 'walk', 'attack', 'hit'],
  defaultAnimation: 'idle',
  defaultMix: 0.2,
);

// ── Tower Knight ─────────────────────────────────────────────

const kTowerKnightMeta = SpineAssetMeta(
  key: 'tower_knight',
  path: 'spine/characters/tower_knight',
  atlasPath: 'assets/spine/characters/tower_knight/tower_knight.atlas',
  skeletonPath:
      'assets/spine/characters/tower_knight/tower_knight.json',
  animations: ['idle', 'walk', 'attack', 'hit'],
  defaultAnimation: 'idle',
  defaultMix: 0.2,
);

// ── Tower Mage ───────────────────────────────────────────────

const kTowerMageMeta = SpineAssetMeta(
  key: 'tower_mage',
  path: 'spine/characters/tower_mage',
  atlasPath: 'assets/spine/characters/tower_mage/tower_mage.atlas',
  skeletonPath:
      'assets/spine/characters/tower_mage/tower_mage.json',
  animations: ['idle', 'walk', 'attack', 'hit'],
  defaultAnimation: 'idle',
  defaultMix: 0.2,
);
