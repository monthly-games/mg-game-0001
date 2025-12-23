# MG-0001: 심플 타워 디펜스

**장르**: 타워 디펜스 + 전략
**핵심 메커니즘**: 타워 배치, 웨이브 방어
**카테고리**: Year 1 Core
**Phase**: Production Ready

---

## 1. 개요

이 프로젝트는 **심플 타워 디펜스**의 Flutter 구현체입니다.

> **주의**: 이 문서는 `GAME_MASTER_LIST.md`를 기반으로 자동 생성되었습니다.

---

## 2. 문서 구조

### 기획 문서
| 문서 | 설명 |
|------|------|
| [docs/design/gdd_game_0001.json](docs/design/gdd_game_0001.json) | 게임 디자인 문서 |
| [docs/design/ui_ux_spec.md](docs/design/ui_ux_spec.md) | UI/UX 스펙 |
| [docs/fun_design.md](docs/fun_design.md) | 재미 설계 |
| [docs/bm_design.md](docs/bm_design.md) | 수익 모델 |
| [docs/production_design.md](docs/production_design.md) | 프로덕션 설계 |

### 소스 코드
| 폴더 | 설명 |
|------|------|
| [game/](game/) | Flutter 게임 코드 |
| [backend/](backend/) | Firebase Functions |
| [analytics/](analytics/) | BigQuery 스키마 |
| [config/](config/) | Remote Config |

---

## 3. UI/UX 가이드라인

### 게임별 스펙
| 항목 | 값 |
|------|-----|
| **화면 방향** | Portrait |
| **기준 해상도** | 1080 x 1920 |
| **UI 복잡도** | Tier 1 (Simple) |
| **타겟 FPS** | 60fps |

### 공통 UI/UX 가이드라인

> 아래 문서들은 모든 MG Games 프로젝트에서 공통으로 적용되는 UI/UX 표준입니다.

| 가이드 | 설명 | 경로 |
|--------|------|------|
| **마스터 가이드** | 디자인 원칙, 컬러 시스템, 타이포그래피, 컴포넌트 | [UI_UX_MASTER_GUIDE.md](../mg-meta/docs/design/UI_UX_MASTER_GUIDE.md) |
| **화면 방향** | Portrait/Landscape 설정, Flutter 구현 코드 | [SCREEN_ORIENTATION_GUIDE.md](../mg-meta/docs/design/SCREEN_ORIENTATION_GUIDE.md) |
| **Safe Area** | iOS/Android 디바이스별 Safe Area 스펙 | [SAFE_AREA_GUIDE.md](../mg-meta/docs/design/SAFE_AREA_GUIDE.md) |
| **접근성** | 색맹 모드, 텍스트 스케일링, 스크린 리더 | [ACCESSIBILITY_GUIDE.md](../mg-meta/docs/design/ACCESSIBILITY_GUIDE.md) |
| **디바이스 최적화** | APK 크기, 메모리, 배터리, 네트워크 최적화 | [DEVICE_OPTIMIZATION_GUIDE.md](../mg-meta/docs/design/DEVICE_OPTIMIZATION_GUIDE.md) |

### 가이드라인 적용 체크리스트

- [ ] 화면 방향 설정 완료 (`AndroidManifest.xml`, `Info.plist`)
- [ ] Safe Area 적용 완료 (Flutter `SafeArea` 위젯)
- [ ] 색맹 모드 지원
- [ ] 최소 터치 영역 44x44dp 준수
- [ ] APK 크기 최적화 (< 100MB)

---

## 4. 기술 스택

| 항목 | 기술 |
|------|------|
| **엔진** | Flutter + Flame |
| **UI 컴포넌트** | mg_common_game (공통 디자인 시스템) |
| **백엔드** | Firebase (Analytics, Remote Config, Crashlytics) |
| **분석** | BigQuery Export |
| **구조** | Melos Monorepo |

---

## 5. HUD (Heads-Up Display)

### HUD 구조

이 게임은 **mg_common_game** 디자인 시스템을 기반으로 한 표준화된 HUD를 사용합니다.

**HUD 파일**: [game/lib/ui/hud/mg_game_hud.dart](game/lib/ui/hud/mg_game_hud.dart)

### 주요 HUD 요소

| 요소 | 설명 | 컴포넌트 |
|------|------|----------|
| **웨이브 정보** | 현재 웨이브 및 진행 상태 | Custom Container |
| **골드** | 타워 건설용 골드 표시 | MGResourceBar |
| **생명력 (Lives)** | 남은 생명 HP 바 | MGLinearProgress |
| **빌드 버튼** | 타워 건설 버튼 | MGButton.primary |
| **다음 웨이브** | 다음 웨이브 시작 버튼 | MGButton |
| **게임 속도** | 1x/2x 속도 조절 | Custom Button |
| **일시정지** | 게임 일시정지 버튼 | MGIconButton |

### UI 레이아웃

타워 디펜스 게임은 **Positioned.fill** 기반 전체 화면 레이아웃을 사용합니다:

```dart
Positioned.fill(
  child: Column(
    children: [
      // 상단: 웨이브 + 자원
      Container(
        padding: EdgeInsets.only(
          top: safeArea.top + MGSpacing.hudMargin,
          left: MGSpacing.hudMargin,
          right: MGSpacing.hudMargin,
        ),
        child: Row(/* Wave info + Resources */),
      ),

      // 중앙: 게임 화면 영역
      const Expanded(child: SizedBox()),

      // 하단: 빌드 버튼 + 컨트롤
      Container(
        padding: EdgeInsets.only(
          bottom: safeArea.bottom + MGSpacing.hudMargin,
        ),
        child: Row(/* Build + Controls */),
      ),
    ],
  ),
)
```

### 사용된 mg_common_game 컴포넌트

```dart
import 'package:mg_common_game/core/ui/mg_ui.dart';
```

All-in-one import로 모든 MG UI 컴포넌트를 사용합니다:
- `MGColors` - 색상 시스템
- `MGSpacing` - 간격 시스템
- `MGTextStyles` - 타이포그래피
- `MGButton` - 액션 버튼
- `MGIconButton` - 아이콘 버튼
- `MGResourceBar` - 리소스 표시
- `MGLinearProgress` - 프로그레스 바

### HUD 사용 가이드

전체 HUD 컴포넌트 사용법은 [MG_HUD_COMPONENT_GUIDE.md](../../MG_HUD_COMPONENT_GUIDE.md)를 참고하세요.

타워 디펜스 HUD 예제는 가이드 문서의 "Tower Defense" 섹션을 참고하세요.

---

## 6. 상태

- 문서화 표준 준수
- 인코딩: UTF-8
- Phase: Production Ready
- ✅ HUD 표준화 완료 (mg_common_game)
- ✅ Positioned.fill 레이아웃 적용
