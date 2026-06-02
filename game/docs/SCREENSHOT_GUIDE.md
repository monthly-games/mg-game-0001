# 스크린샷 캡처 가이드

## MG-0001 Tower Defense - 스토어 등록용 스크린샷

### 필요한 스크린샷 (8개)

Google Play Store와 Apple App Store 등록을 위해 다음 8개의 스크린샷이 필요합니다.

#### 1. Main Menu (메인 메뉴)
- **내용**: 깔끔한 메인 화면
- **포함 요소**:
  - 게임 타이틀 "MG-0001"
  - 시작 버튼
  - 메타 메뉴 (일일 퀘스트, 토너먼트 등)
- **팁**: 브라우저 개발자 도구에서 모바일 뷰포트 설정 (iPhone 12 Pro: 390x844)

#### 2. Level Selection (레벨 선택)
- **내용**: 8개 레벨 로드맵
- **포함 요소**:
  - 8개 레벨 표시
  - 난이도 표시
  - 잠금 해제 상태
- **도달 방법**: 메인 메뉴 → "Level Roadmap" 클릭

#### 3. Daily Quests (일일 퀘스트)
- **내용**: 일일 퀘스트 화면
- **포함 요소**:
  - 3개 일일 퀘스트
  - 보상 정보
  - 진행 상태
- **도달 방법**: 메인 메뉴 → "Daily Quests" 클릭

#### 4. Gameplay Level 1 (게임플레이)
- **내용**: 실제 타워 디펜스 게임플레이
- **포함 요소**:
  - 타워 배치된 상태
  - 적들이 웨이브 중인 상태
  - UI 요소 (골드, 라이프, 웨이브 정보)
- **도달 방법**: 메인 메뉴 → "Start Game" 클릭
- **팁**: 튜토리얼을 완료해야 실제 게임플레이 가능

#### 5. Rewards Screen (보상 화면)
- **내용**: 보상 시스템
- **포함 요소**:
  - 보상 항목들
  - 골드/XP 정보
  - 클레임 버튼
- **도달 방법**: 메인 메뉴 → "Rewards" 클릭

#### 6. Tournament (토너먼트)
- **내용**: 토너먼트 모드
- **포함 요소**:
  - 토너먼트 정보
  - 랭킹/리더보드
  - 참여 버튼
- **도달 방법**: 메인 메뉴 → "Tournament" 클릭

#### 7. Guild War (길드전)
- **내용**: 길드 시스템
- **포함 요소**:
  - 길드 정보
  - 길드전 상태
  - 길드 멤버
- **도달 방법**: 메인 메뉴 → "Guild War" 클릭

#### 8. Seasonal Event (시즌 이벤트)
- **내용**: 시즌 이벤트
- **포함 요소**:
  - 시즌 정보
  - 한정 보상
  - 이벤트 진행 상황
- **도달 방법**: 메인 메뉴 → "Seasonal Event" 클릭

---

## 캡처 방법

### 방법 1: 웹 빌드 사용 (권장)

```bash
# 1. 웹 빌드 실행
cd game
flutter build web --release

# 2. 웹 서버 시작
python -m http.server 8080 -d build/web

# 3. 브라우저에서 http://localhost:8080 접속
```

### 브라우저 설정 (Chrome DevTools)

1. **개발자 도구 열기**: F12
2. **모바일 뷰포트 활성화**: Ctrl+Shift+M (Cmd+Shift+M)
3. **기기 설정**:
   - iPhone 12 Pro: 390 x 844 (권장)
   - 또는 직접 설정: 1080 x 1920
4. **캡처**: Ctrl+Shift+P → "Capture screenshot"

### 방법 2: Android 에뮬레이터 사용

```bash
# 에뮬레이터 시작
flutter emulators --launch <emulator_id>

# 앱 실행
flutter run

# 스크린샷 캡처
flutter screenshot --type=png --out=screenshot_01.png
```

### 방법 3: Integration Test 사용

```bash
# 스크린샷 캡처 테스트 실행
flutter test integration_test/screenshot_capture_test.dart --dart-define=MG_STORE_SCREENSHOTS=true
```

---

## 스크린샷 요구사항

### Google Play Store
- **최소 크기**: 320px 너비
- **최대 크기**: 3840px 너비
- **권장**: 1080 x 1920 (세로) 또는 1920 x 1080 (가로)
- **형식**: PNG 또는 JPG
- **파일 크기**: 최대 8MB

### Apple App Store
- **iPhone 6.7"**: 1290 x 2796 픽셀
- **iPhone 6.5"**: 1242 x 2688 픽셀
- **iPad Pro 12.9"**: 2048 x 2732 픽셀

---

## 파일 명명 규칙

```
store_screenshot_01_main_menu.png
store_screenshot_02_level_selection.png
store_screenshot_03_daily_quests.png
store_screenshot_04_gameplay_level_1.png
store_screenshot_05_rewards.png
store_screenshot_06_tournament.png
store_screenshot_07_guild_war.png
store_screenshot_08_seasonal_event.png
```

---

## 저장 위치

```
game/
├── assets/
│   └── store_screenshots/
│       ├── store_screenshot_01_main_menu.png
│       ├── store_screenshot_02_level_selection.png
│       ├── ...
│       └── store_screenshot_08_seasonal_event.png
```

---

## 팁

1. **일관된 UI**: 모든 스크린샷에서 동일한 UI 상태 유지
2. **고품질**: 최소 2x 해상도 (Retina)로 캡처
3. **불필요한 요소 제거**: 디버그 정보, 시스템 UI 등 제거
4. **자연스러운 상태**: 게임이 활성화된 상태로 캡처
5. **테스트**: 여러 기기에서 테스트 후 최종 선택

---

## 현재 상태

기존 스크린샷: `docs/images/gameplay-showcase.png` (614KB)

이 파일을 검토하여 품질과 구성을 확인한 후, 8개의 스토어 스크린샷을 생성하세요.
