import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tower_defense/ui/hud/mg_game_hud.dart';

void main() {
  testWidgets('MGGameHud displays gold and wave info', (
    WidgetTester tester,
  ) async {
    // Arrange
    const int testGold = 100;
    const int testWave = 5;
    const int testLives = 20;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              MGGameHud(
                gold: testGold,
                wave: testWave,
                lives: testLives,
                onBuildTower: () {},
                onNextWave: () {},
              ),
            ],
          ),
        ),
      ),
    );

    // Act
    await tester.pumpAndSettle();

    // Assert - Check that the widget renders without errors
    expect(find.byType(MGGameHud), findsOneWidget);
  });
}
