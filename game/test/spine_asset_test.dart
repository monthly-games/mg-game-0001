import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Verifies deployed Spine assets for tower_archer exist at
/// the paths referenced by spine_config.dart.
///
/// This is a plain Dart test (no widget pump needed) — it checks
/// the file system directly to confirm assets are in place.
void main() {
  const basePath = 'assets/spine/characters/tower_archer';

  group('Spine Assets — tower_archer', () {
    test(
      'Given deployed assets, '
      'When checking skeleton JSON, '
      'Then tower_archer.json exists',
      () {
        final file = File('$basePath/tower_archer.json');
        expect(
          file.existsSync(),
          isTrue,
          reason: 'tower_archer.json must exist at $basePath/',
        );
      },
    );

    test(
      'Given deployed assets, '
      'When checking atlas file, '
      'Then tower_archer.atlas exists',
      () {
        final file = File('$basePath/tower_archer.atlas');
        expect(
          file.existsSync(),
          isTrue,
          reason: 'tower_archer.atlas must exist at $basePath/',
        );
      },
    );

    test(
      'Given deployed assets, '
      'When listing PNG body parts, '
      'Then at least 3 PNGs exist',
      () {
        final dir = Directory(basePath);
        expect(dir.existsSync(), isTrue, reason: '$basePath/ must exist');

        final pngs = dir
            .listSync()
            .whereType<File>()
            .where((f) => f.path.endsWith('.png'))
            .toList();
        expect(
          pngs.length,
          greaterThanOrEqualTo(3),
          reason: 'Expected >=3 PNGs, found ${pngs.length}',
        );
      },
    );

    test(
      'Given deployed assets, '
      'When checking specific body-part PNGs, '
      'Then core PNGs exist by name',
      () {
        const requiredPngs = [
          'body.png',
          'arm_L.png',
          'arm_R.png',
          'hips.png',
          'weapon.png',
        ];

        for (final png in requiredPngs) {
          expect(
            File('$basePath/$png').existsSync(),
            isTrue,
            reason: '$png must exist at $basePath/',
          );
        }
      },
    );
  });
}
