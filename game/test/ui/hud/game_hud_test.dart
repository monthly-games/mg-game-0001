import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mg_common_game/core/ui/widgets/hud/resource_bar.dart';
import 'package:tower_defense/ui/hud/game_hud.dart';
// Note: tower_defense is the package name defined in pubspec.yaml of mg-game-0001

void main() {
  testWidgets('GameHud displays gold and wave info', (
    WidgetTester tester,
  ) async {
    // Arrange
    const int testGold = 100;
    const int testWave = 5;
    bool buildPressed = false;
    bool nextWavePressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GameHud(
            gold: testGold,
            wave: testWave,
            onBuildTower: () => buildPressed = true,
            onNextWave: () => nextWavePressed = true,
          ),
        ),
      ),
    );

    // Act
    await tester.pumpAndSettle();

    // Assert
    // Check Gold Display (ResourceBar)
    expect(find.byType(ResourceBar), findsOneWidget);
    expect(find.text('100'), findsOneWidget);

    // Check Wave Display
    expect(find.text('WAVE 5'), findsOneWidget);

    // Check Buttons
    expect(find.text('BUILD TOWER'), findsOneWidget);
    expect(find.text('NEXT WAVE'), findsOneWidget);

    // Interaction
    await tester.tap(find.text('BUILD TOWER'));
    expect(buildPressed, isTrue);

    await tester.tap(find.text('NEXT WAVE'));
    expect(nextWavePressed, isTrue);
  });
}
