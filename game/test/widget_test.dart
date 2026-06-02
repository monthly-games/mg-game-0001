import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tower_defense/main.dart';

void main() {
  testWidgets('app boots to the main menu', (tester) async {
    // Mock SharedPreferences to mark tutorial as completed
    SharedPreferences.setMockInitialValues({'onboarding_tutorial_completed': true});

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.textContaining('MG-'), findsWidgets);
    expect(find.text('Start Game'), findsOneWidget);
  });
}
