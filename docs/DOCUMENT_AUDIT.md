# MG-0001 문서 감사 보고서

**작성일**: 2025-12-17 (초안)
**업데이트**: 2025-12-17 (CRITICAL 이슈 해결 완료)
**감사자**: Claude Code (MG Development Assistant)

---

## ✅ 최종 결과 요약 (2025-12-17 업데이트)

### 🎉 CRITICAL 이슈 해결 완료

**문제**: BM Design과 Monetization Design 문서가 완전히 다른 게임("던전 타이쿤 퍼즐RPG")에 대한 내용이었음

**해결**:
- ✅ `bm_design.md` 전면 재작성 (322줄)
  - 타워 디펜스 게임에 맞는 수익 구조 설계
  - 광고 중심 (50%) + 스킨 (20%) + 편의 (15%) + 광고 제거 (10%) + 스페셜 타워 (5%)
  - P2W 방지 가드레일 (±20% 밸런스)
  - 타워 스킨, 발사체 이펙트, 맵 테마 등 비주얼 커스터마이징 중심
- ✅ `monetization_design.md` 전면 재작성 (416줄)
  - 7개 광고 Placement 정의 (Rewarded only, 강제 광고 없음)
  - 상세 IAP 상품 라인업
  - 재화 밸런스 설계 (골드, 젬 only)
  - KPI 목표, LiveOps 전략, A/B 테스트 계획, 경쟁사 벤치마크

**현재 상태**: **MG-0001 문서 일치성 확보 ✅**
- GDD ✅ (Simple Tower Defense)
- Fun Design ✅ (Simple Tower Defense)
- BM Design ✅ (Simple Tower Defense) - **재작성 완료**
- Monetization Design ✅ (Simple Tower Defense) - **재작성 완료**
- Ops Design 🔍 (확인 필요)

---

## ⚠️ 발견된 문제

### 🚨 CRITICAL: 문서 불일치

**문제**: BM Design과 Monetization Design 문서가 **완전히 다른 게임**에 대한 내용입니다.

| 문서 | 게임 타이틀 | 장르 | 상태 |
|------|------------|------|------|
| `gdd_game_0001.json` | Simple Tower Defense | 타워 디펜스 | ✅ 정확 |
| `fun_design.md` | Simple Tower Defense | 타워 디펜스 | ✅ 정확 |
| `bm_design.md` | **던전 타이쿤 퍼즐RPG** | **퍼즐 + 방치형 RPG** | ❌ **잘못됨** |
| `monetization_design.md` | **던전 타이쿤 퍼즐RPG** | **퍼즐 + 방치형 RPG** | ❌ **잘못됨** |
| `ops_design.md` | (미확인) | - | 🔍 검토 필요 |
| **실제 구현 코드** | Tower Defense Game | 타워 디펜스 | ✅ GDD와 일치 |

---

## 📋 세부 분석

### 1. GDD (gdd_game_0001.json) ✅
- **타이틀**: Simple Tower Defense
- **장르**: tower-defense, strategy
- **핵심 루프**: Build Towers → Defend Waves → Earn Gold
- **주요 엔티티**:
  - Towers: Basic tower (cost 50, range 150, damage 25)
  - Monsters: Basic monster (speed 100, hp 100)
- **엔진**: Flame
- **상태**: **코드 구현과 정확히 일치** ✅

### 2. Fun Design (fun_design.md) ✅
- **타이틀**: Simple Tower Defense (Prototype)
- **장르**: tower-defense, strategy, arcade
- **핵심 루프**:
  1. Build Phase (Preparation)
  2. Defend Wave (Action)
  3. Earn Gold (Reward)
  4. Upgrade/Build More (Growth)
- **Fun Pillars**:
  - Strategic Placement
  - Economic Efficiency
  - Crisis Management
- **상태**: **GDD 및 코드와 일치** ✅

### 3. BM Design (bm_design.md) ❌
- **타이틀**: **던전 타이쿤 퍼즐RPG** (잘못됨!)
- **장르**: 퍼즐 + 방치형 + 라이트 JRPG (잘못됨!)
- **수익 구조**:
  - 캐릭터/영웅 수집 (가챠) 35%
  - 성장/강화 패키지 25%
  - 시즌 패스 20%
  - 스태미너 10%
  - 광고 10%
- **문제점**:
  - ❌ 타워 디펜스가 아닌 퍼즐 RPG 수익화 설계
  - ❌ 가챠, 영웅 수집 등 게임에 없는 시스템
  - ❌ 스태미나 시스템 없음 (타워 디펜스에 부적합)
  - ❌ 완전히 다른 게임의 BM 문서

### 4. Monetization Design (monetization_design.md) ❌
- **타이틀**: **던전 타이쿤 퍼즐RPG** (잘못됨!)
- **장르**: 퍼즐 + 방치형 + 라이트 JRPG (잘못됨!)
- **광고 배치**:
  - puzzle_hint, puzzle_double (퍼즐 게임 전용)
  - battle_revive, dungeon_skip (RPG 전용)
  - gacha_extra (가챠 게임 전용)
- **IAP 상품**:
  - 던전 탐험가 팩, 퍼즐 마스터 팩
  - 젬, 스태미나, 가챠 티켓
- **문제점**:
  - ❌ 타워 디펜스에 맞지 않는 수익화 전략
  - ❌ 퍼즐, 가챠, RPG 요소 중심 (게임에 없음)
  - ❌ 완전히 다른 게임의 수익화 문서

---

## 🔍 원인 분석

**추정 원인**:
- 문서 작성 시 템플릿 또는 다른 프로젝트 문서를 복사했으나, 내용을 수정하지 않음
- 또는 MG-0001이 원래 "던전 타이쿤 퍼즐RPG"였으나 중간에 타워 디펜스로 변경되었고, BM/Monetization 문서만 업데이트되지 않음

---

## ✅ 필요한 조치

### 우선순위 1: BM Design 재작성 ✅ **완료 (2025-12-17)**
타워 디펜스 게임에 맞는 BM 설계:
- ✅ 수익 구조 재정의
  - 리워드 광고 중심 (50%)
  - 타워 스킨/장식 IAP (20%)
  - 편의 기능 (15%)
  - 광고 제거 패스 (10%)
  - 스페셜 타워 (5%)
- ✅ IAP 상품 재설계
  - 타워 스킨 ($1.99~3.99)
  - 발사체 이펙트 ($0.99~1.99)
  - 맵 테마 ($2.99~4.99)
  - 골드 패키지 ($0.99~9.99)
  - 편의 기능 (타워 슬롯, 오토 플레이 등)
  - 스페셜 타워 ($1.99~2.99, P2W 방지 ±20% 밸런스)
- ✅ 광고 배치 재정의
  - 웨이브 클리어 보상 2배 (일일 10회)
  - 골드 부스트 30분 (일일 3회)
  - 타워 업그레이드 즉시 완료 (일일 3회)
  - 부활 Life +5 회복 (일일 5회)
  - 웨이브 스킵 (일일 3회)
  - 일일 보너스 골드 (일일 1회)
  - 총 일일 캡: 25회

**재작성된 파일**: `bm_design.md` (전면 재작성, 322줄)

### 우선순위 2: Monetization Design 재작성 ✅ **완료 (2025-12-17)**
타워 디펜스에 맞는 수익화 전략:
- ✅ 광고 전략 재설계
  - 7개 Placement 정의 (Rewarded only, 강제 광고 없음)
  - 광고 설계 원칙 (첫 3분 차단, 쿨다운 30초, 일일 캡 25회)
  - 광고 KPI 목표 (시청률 50~60%, ARPDAU $0.05~0.08)
  - A/B 테스트 계획 (광고 캡, 쿨다운, 보상 배율, 가격)
- ✅ IAP 상품 구성 재정의
  - 타워 스킨/장식 (20% 수익 기여)
  - 편의 기능 (15% 수익 기여)
  - 광고 제거 및 프리미엄 패스 (10% 수익 기여)
  - 스페셜 타워 (5% 수익 기여, 밸런스 가드레일)
- ✅ 재화 밸런스 조정 (골드, 젬 only)
  - 진행도별 골드 획득량 설계
  - 무료 vs 광고 유저 획득량 비교
  - 골드 Sink 설계 (타워 구매/업그레이드)
- ✅ KPI 목표 재설정
  - 수익 KPI (ARPU, ARPPU, 결제 전환율, 광고 시청률)
  - 참여 KPI (D1/D7/D30 Retention)
  - 밸런스 KPI (골드 인플레이션율, 진행 막힘 비율)
- ✅ LiveOps 수익화 전략
  - 일일/주간/시즌 이벤트
  - 수익화 타임라인 (D0~D30)
- ✅ 경쟁사 벤치마크 및 리스크 대응

**재작성된 파일**: `monetization_design.md` (전면 재작성, 416줄)

### 우선순위 3: Ops Design 검토 ⚠️ **파일 없음**
- ⚠️ `ops_design.md` 파일이 `docs/` 폴더에 존재하지만, `docs/design/` 폴더에는 없음
- 🔍 파일 내용 확인 필요 (다음 단계에서 검토)

---

## 📊 권장 BM 방향 (타워 디펜스용)

### 수익 구조 제안
```
┌─────────────────────────────────────────────┐
│         타워 디펜스 수익 구조 (제안)          │
├─────────────────────────────────────────────┤
│  리워드 광고                    50%          │
│  타워 스킨/장식 IAP             20%          │
│  편의 기능 (골드 부스트 등)     15%          │
│  광고 제거 패스                 10%          │
│  스페셜 타워 IAP                 5%          │
└─────────────────────────────────────────────┘
```

### 주요 수익화 포인트
1. **리워드 광고**:
   - 웨이브 클리어 보상 2배
   - 골드 획득 부스트 (30분)
   - 부활 (Life +5)
   - 무료 타워 업그레이드

2. **IAP - 스킨/장식**:
   - 타워 스킨 (성능 동일, 비주얼만)
   - 발사체 이펙트
   - 승리 이펙트
   - 맵 테마

3. **IAP - 편의**:
   - 골드 패키지
   - 타워 슬롯 확장
   - 오토 플레이
   - 스킵 티켓

4. **IAP - 스페셜 타워**:
   - 한정 타워 (성능 밸런스 유지)
   - 시즌 타워
   - 이벤트 타워

---

## 📝 권장 사항

1. **즉시 조치**:
   - `bm_design.md` → `bm_design_OLD.md` 백업
   - `monetization_design.md` → `monetization_design_OLD.md` 백업
   - 타워 디펜스용 새 BM/Monetization 문서 작성

2. **검증**:
   - 모든 설계 문서가 "Simple Tower Defense"를 대상으로 하는지 확인
   - 코드 구현과 문서의 일치성 재검증

3. **문서 관리**:
   - 각 문서 헤더에 game_id 명시
   - 문서 작성 시 GDD 기준 검증 프로세스 추가

---

**결론**: BM Design과 Monetization Design 문서는 **완전히 잘못된 게임**에 대한 내용이므로, 타워 디펜스 게임에 맞게 **전면 재작성 필요**.
