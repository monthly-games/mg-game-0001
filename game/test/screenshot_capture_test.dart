import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tower_defense/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Screenshot Capture Test for Game Store Assets
/// Captures key screens for Google Play Store and Apple App Store
/// Required sizes:
/// - Phone: 320px (min width) to 3840px (max width)
/// - Recommended: 1080x1920 (portrait), 1920x1080 (landscape)
void main() {
  const enableStoreScreenshots = bool.fromEnvironment('MG_STORE_SCREENSHOTS');
  if (!enableStoreScreenshots) {
    group('Store Screenshots', () {
      test(
        'skipped in normal unit test runs',
        () {},
        skip:
            'Run screenshot capture separately with integration_test support.',
      );
    });
    return;
  }

  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Store Screenshots', () {
    testWidgets('Screenshot 1: Main Menu', (tester) async {
      SharedPreferences.setMockInitialValues({
        'onboarding_tutorial_completed': true,
      });

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Take screenshot of main menu
      await binding.takeScreenshot('store_screenshot_01_main_menu');

      print('✅ Screenshot 1 captured: Main Menu');
    });

    testWidgets('Screenshot 2: Level Selection', (tester) async {
      SharedPreferences.setMockInitialValues({
        'onboarding_tutorial_completed': true,
      });

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('level-roadmap')));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      await binding.takeScreenshot('store_screenshot_02_level_selection');

      print('✅ Screenshot 2 captured: Level Selection');
    });

    testWidgets('Screenshot 3: Daily Quests', (tester) async {
      SharedPreferences.setMockInitialValues({
        'onboarding_tutorial_completed': true,
      });

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('daily-quests')));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      await binding.takeScreenshot('store_screenshot_03_daily_quests');

      print('✅ Screenshot 3 captured: Daily Quests');
    });

    testWidgets('Screenshot 4: Game Screen - Level Start', (tester) async {
      SharedPreferences.setMockInitialValues({
        'onboarding_tutorial_completed': true,
      });

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('start-game')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await binding.takeScreenshot('store_screenshot_04_gameplay_level_1');

      print('✅ Screenshot 4 captured: Gameplay Level 1');
    });

    testWidgets('Screenshot 5: Rewards Screen', (tester) async {
      SharedPreferences.setMockInitialValues({
        'onboarding_tutorial_completed': true,
      });

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('rewards')));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      await binding.takeScreenshot('store_screenshot_05_rewards');

      print('✅ Screenshot 5 captured: Rewards Screen');
    });

    testWidgets('Screenshot 6: Tournament Screen', (tester) async {
      SharedPreferences.setMockInitialValues({
        'onboarding_tutorial_completed': true,
      });

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('tournament')));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      await binding.takeScreenshot('store_screenshot_06_tournament');

      print('✅ Screenshot 6 captured: Tournament');
    });

    testWidgets('Screenshot 7: Guild War Screen', (tester) async {
      SharedPreferences.setMockInitialValues({
        'onboarding_tutorial_completed': true,
      });

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('guild-war')));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      await binding.takeScreenshot('store_screenshot_07_guild_war');

      print('✅ Screenshot 7 captured: Guild War');
    });

    testWidgets('Screenshot 8: Seasonal Event', (tester) async {
      SharedPreferences.setMockInitialValues({
        'onboarding_tutorial_completed': true,
      });

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('seasonal-event')));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      await binding.takeScreenshot('store_screenshot_08_seasonal_event');

      print('✅ Screenshot 8 captured: Seasonal Event');
    });
  });
}
