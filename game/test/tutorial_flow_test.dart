import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tower_defense/game/tutorial_config.dart';
import 'package:tower_defense/main.dart';

void main() {
  testWidgets(
    'tutorial route advances through every onboarding step and opens the main menu',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'onboarding_tutorial_completed': false,
      });

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Tutorial is displayed as home screen
      expect(find.byKey(const ValueKey('tutorial-screen')), findsOneWidget);
      expect(find.text(kOnboardingTutorial.steps.first.title), findsOneWidget);

      for (
        var index = 1;
        index < kOnboardingTutorial.steps.length;
        index += 1
      ) {
        await tester.tap(find.byKey(const ValueKey('tutorial-next')));
        await tester.pumpAndSettle();
        expect(
          find.text(kOnboardingTutorial.steps[index].title),
          findsOneWidget,
        );
      }

      await tester.tap(find.byKey(const ValueKey('tutorial-next')));
      await tester.pumpAndSettle();

      final prefs = await SharedPreferences.getInstance();
      final completed = prefs.getBool('onboarding_tutorial_completed') ?? false;
      expect(completed, isTrue);
      expect(find.byKey(const ValueKey('game-id')), findsOneWidget);
      expect(find.byKey(const ValueKey('start-game')), findsOneWidget);
    },
  );
}
