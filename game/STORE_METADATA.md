# MG-0001 Store Metadata

## Google Play Store

### App Information
- **Title**: MG-0001: Tower Defense
- **Short Description** (80 chars): Strategic tower defense with 8 levels & tournaments!
- **Full Description**: See `android/app/src/main/play/store/listings/en-US/description.txt`

### Screenshots
8 screenshots required for Google Play Store:

1. `store_screenshot_01_main_menu.png` - Main menu screen
2. `store_screenshot_02_level_selection.png` - Level selection/roadmap
3. `store_screenshot_03_daily_quests.png` - Daily quests screen
4. `store_screenshot_04_gameplay_level_1.png` - Active gameplay
5. `store_screenshot_05_rewards.png` - Rewards screen
6. `store_screenshot_06_tournament.png` - Tournament mode
7. `store_screenshot_07_guild_war.png` - Guild war screen
8. `store_screenshot_08_seasonal_event.png` - Seasonal event

### Screenshot Specifications
- **Minimum Size**: 320px width
- **Maximum Size**: 3840px width
- **Recommended**: 1080x1920 (portrait) or 1920x1080 (landscape)
- **Format**: PNG or JPG
- **File Size**: Max 8MB each

### Capture Screenshots
To capture screenshots, run:

```bash
# Android
flutter test integration_test/screenshot_capture_test.dart --dart-define=MG_STORE_SCREENSHOTS=true

# Screenshots will be saved to:
# build/app/outputs/flutter_apk/screenshot-store_screenshot_XX_*.png
```

## Apple App Store

### App Information
- **Name**: MG-0001: Tower Defense
- **Subtitle** (30 chars): Strategic Tower Defense Game
- **Description**: See README.md for full description

### Screenshots
For iOS, you need screenshots for:
- iPhone 6.7" Display (1290x2796 pixels)
- iPhone 6.5" Display (1242x2688 pixels)
- iPad Pro 12.9" Display (2048x2732 pixels)

### Keywords
tower, defense, strategy, action, td, game, casual, challenging, waves, enemies

## Privacy Policy URL
[To be added before submission]

## Support Email
support@monthlygames.com

## Content Rating
- **Violence**: Mild (cartoon/fantasy violence)
- **Language**: None
- **Sexual Content**: None
- **Gambling**: None

## Categories
- **Primary**: Game
- **Secondary**: Strategy
