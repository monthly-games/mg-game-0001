# MG-0001 개발 진척도

**게임명**: Simple Tower Defense
**장르**: 타워 디펜스 + 전략
**시작일**: 2025-07-01
**최근 업데이트**: 2025-12-17
**현재 진척도**: 70% (핵심 기능 완성, 콘텐츠 확장 필요)

---

## ✅ 구현 완료 시스템

### 1. 프로젝트 기본 구조 (100%) ✅
Flame 엔진 기반 타워 디펜스 아키텍처.

**구현 항목**:
- ✅ main.dart (GetIt DI, 에러 핸들링)
- ✅ CoreGame 상속 구조
- ✅ 서비스 등록 (AudioManager, EventBus, SaveSystem, GameManager, GoldManager)
- ✅ 로딩 화면 (GameLoadingScreen)
- ✅ Toast 시스템

### 2. 맵 시스템 (100%) ✅
타일 기반 그리드 맵.

**구현 항목**:
- ✅ MapSystem (9x16 타일 그리드)
- ✅ 타일 타입 (Empty, Path, Start, End)
- ✅ 경로 시각화 (노란색 라인)
- ✅ 그리드 렌더링
- ✅ 위치 계산 헬퍼 함수

### 3. 타워 시스템 (90%) ✅
타워 건설, 타겟팅, 공격.

**구현 항목**:
- ✅ Tower 엔티티 (사거리, 데미지, 쿨다운)
- ✅ GhostTower (건설 프리뷰)
- ✅ 타겟 감지 (사거리 내 몬스터)
- ✅ 발사체 생성 (Bullet)
- ✅ 건설 모드 토글
- ✅ 건설 가능 여부 검증
- ⬜ 타워 업그레이드 시스템 (미구현)
- ⬜ 다양한 타워 타입 (현재 1종)

### 4. 몬스터 시스템 (100%) ✅
경로 따라 이동, HP 관리.

**구현 항목**:
- ✅ Monster 엔티티 (HP, 속도)
- ✅ 경로 추적 (Path following)
- ✅ HP 바 렌더링
- ✅ 사망 처리
- ✅ 골드 드롭

### 5. 웨이브 시스템 (100%) ✅
순차적 웨이브, 난이도 증가.

**구현 항목**:
- ✅ WaveManager
- ✅ 웨이브 구성 (몬스터 수, 간격)
- ✅ 자동 웨이브 진행
- ✅ 웨이브 클리어 보상
- ✅ 난이도 스케일링

### 6. 전투 시스템 (100%) ✅
타워 공격, 발사체, 데미지.

**구현 항목**:
- ✅ Bullet 엔티티
- ✅ 충돌 감지 (HasCollisionDetection)
- ✅ 데미지 적용
- ✅ 발사체 회전 (방향)
- ✅ 폭발 효과 (FloatingText)

### 7. 경제 시스템 (100%) ✅
골드 관리.

**구현 항목**:
- ✅ GoldManager (mg_common_game)
- ✅ 골드 획득 (몬스터 킬)
- ✅ 골드 소비 (타워 건설)
- ✅ 스트림 기반 UI 업데이트
- ✅ 초기 골드 (100)

### 8. UI/HUD (80%) 🚧
게임 HUD, 로비 화면.

**구현 항목**:
- ✅ GameHud (골드, 웨이브 표시)
- ✅ 타워 건설 버튼
- ✅ Next Wave 버튼
- ✅ LobbyScreen
- ⬜ 게임 오버 화면
- ⬜ 승리 화면
- ⬜ 일시정지 메뉴
- ⬜ 설정 화면

### 9. 오디오 시스템 (50%) 🚧
AudioManager 통합.

**구현 항목**:
- ✅ AudioManager 등록
- ✅ 초기화
- ⬜ 배경 음악
- ⬜ 효과음 (타워 발사, 몬스터 사망)

---

## ⬜ 미구현 기능 (GDD 기준)

### 1. 타워 다양화 (0%)
현재 1종류만 구현.

**필요 항목**:
- ⬜ 다양한 타워 타입 (예: Archer, Cannon, Laser, Slow)
- ⬜ 타워별 특수 능력
- ⬜ 타워 업그레이드 (레벨, 스탯)
- ⬜ 타워 판매 기능

### 2. 몬스터 다양화 (0%)
현재 1종류만 구현.

**필요 항목**:
- ⬜ 다양한 몬스터 타입 (예: Fast, Tank, Flying)
- ⬜ 보스 몬스터
- ⬜ 몬스터별 특수 능력
- ⬜ 몬스터 스프라이트

### 3. 맵 다양화 (0%)
현재 1개 맵만 구현.

**필요 항목**:
- ⬜ 다양한 맵 레이아웃
- ⬜ 분기 경로
- ⬜ 멀티 스타트/엔드
- ⬜ 장애물 타일

### 4. 진행 시스템 (0%)
레벨, 스테이지 진행.

**필요 항목**:
- ⬜ 스테이지 선택 화면
- ⬜ 난이도 선택
- ⬜ 별 점수 시스템
- ⬜ 진행도 저장

### 5. 업적/보상 (0%)
플레이어 동기부여.

**필요 항목**:
- ⬜ 업적 시스템
- ⬜ 일일 퀘스트
- ⬜ 보상 시스템
- ⬜ 언락 요소

---

## 📊 진척도 요약

| 시스템 | 진척도 | 상태 |
|--------|--------|------|
| 프로젝트 구조 | 100% | ✅ Flame + GetIt DI 완성 |
| 맵 시스템 | 100% | ✅ 타일 그리드 완성 |
| 타워 시스템 | 90% | 🚧 기본 완성, 다양화 필요 |
| 몬스터 시스템 | 100% | ✅ 경로 추적 완성 |
| 웨이브 시스템 | 100% | ✅ 순차 진행 완성 |
| 전투 시스템 | 100% | ✅ 공격/데미지 완성 |
| 경제 시스템 | 100% | ✅ 골드 관리 완성 |
| UI/HUD | 80% | 🚧 HUD 완성, 메뉴 필요 |
| 오디오 | 50% | 🚧 구조만, 에셋 필요 |
| 콘텐츠 다양화 | 0% | ⬜ 타워/몬스터/맵 1종씩 |

**전체 진척도**: 70% (핵심 기능 완성, 콘텐츠 확장 필요)

---

## 🐛 알려진 이슈

1. **Firebase 에러** (Low Priority)
   - firebase_core 미설치로 인한 컴파일 에러
   - main.dart에서 Firebase 초기화 코드는 주석 처리됨
   - 현재 게임 플레이에 영향 없음

2. **Deprecated API 사용** (Low Priority)
   - `withOpacity()` → `withValues()` 전환 필요
   - `printTime` → `dateTimeFormat` 전환 필요

3. **미사용 import** (Low Priority)
   - bullet.dart: `dart:ui`
   - monster.dart: `package:flame/effects.dart`

4. **미사용 필드** (Low Priority)
   - tower.dart: `_rotation` 필드

---

## 🎯 다음 작업 우선순위

### 우선순위 1: 콘텐츠 확장 (30% → 50%)
1. ⬜ **다양한 타워 추가**
   - 3-5종 타워 타입 (Archer, Cannon, Laser, Slow, Splash)
   - 타워별 고유 능력
2. ⬜ **다양한 몬스터 추가**
   - 3-5종 몬스터 (Fast, Tank, Flying, Boss)
   - 몬스터별 특성

### 우선순위 2: UI 완성 (50% → 60%)
1. ⬜ **게임 결과 화면**
   - 승리 화면 (별 점수, 보상)
   - 패배 화면 (재시도, 메인)
2. ⬜ **게임 메뉴**
   - 일시정지
   - 설정 (사운드, 난이도)

### 우선순위 3: 진행 시스템 (60% → 70%)
1. ⬜ **스테이지 시스템**
   - 다양한 맵
   - 스테이지 선택 화면
   - 별 점수 시스템

### 우선순위 4: 폴리시 (70% → 90%)
1. ⬜ **오디오 에셋**
   - 배경 음악
   - 효과음 (발사, 폭발, 승리)
2. ⬜ **비주얼 폴리시**
   - 타워 스프라이트
   - 몬스터 스프라이트
   - 이펙트 (발사, 폭발)

---

## 📁 파일 구조

```
game/lib/
├── main.dart (앱 진입점, DI 설정)
├── app_logger.dart
├── firebase_options.dart (미사용)
├── game/
│   ├── tower_defense_game.dart (메인 게임 로직)
│   ├── core/
│   │   ├── map_system.dart (그리드 맵)
│   │   └── wave_manager.dart (웨이브 관리)
│   └── entities/
│       ├── tower.dart
│       ├── ghost_tower.dart
│       ├── monster.dart
│       └── bullet.dart
└── ui/
    ├── screens/
    │   └── lobby_screen.dart
    └── hud/
        └── game_hud.dart
```

---

## 📝 참고 문서

- [GDD](design/gdd_game_0001.json) - 게임 설계 문서
- [Fun Design](fun_design.md) - 재미 요소 설계
- [BM Design](bm_design.md) - 비즈니스 모델
- [Monetization Design](monetization_design.md) - 수익화 전략
- [Ops Design](ops_design.md) - 운영 설계

---

**작성일**: 2025-12-17
**버전**: 1.0
**작성자**: Claude Code (MG Development Assistant)
