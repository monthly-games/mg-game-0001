# MG-0001 타워 디펜스 - 에셋 생성 프롬프트

## 📊 필요한 에셋 목록

### 🎨 이미지 에셋 (13개)

#### 타워 스프라이트 (4개)
1. **tower_archer.png** (40x40px)
2. **tower_frost.png** (40x40px)
3. **tower_cannon.png** (40x40px)
4. **tower_sniper.png** (40x40px)

#### 몬스터 스프라이트 (3개)
5. **monster_orc.png** (32x32px)
6. **monster_wolf.png** (32x32px)
7. **monster_ogre.png** (32x32px)

#### 발사체 (1개)
8. **projectile_arrow.png** (32x32px)

#### 배경/UI (5개)
9. **bg_lobby.png** (1920x1080px)
10. **bg_game_map1.png** (맵 배경, 타일 기반)
11. **icon_gold.png** (32x32px)
12. **icon_gem.png** (32x32px)
13. **tile_grass.png** (64x64px - 타일맵용)

---

### 🔊 사운드 에셋 (10개)

#### UI 효과음 (3개)
1. **ui_click.wav** - 버튼 클릭
2. **error.wav** - 오류/불가능 액션
3. **sell.wav** - 타워 판매

#### 게임 액션 (4개)
4. **build.wav** - 타워 건설
5. **shoot.wav** - 타워 공격
6. **upgrade.wav** - 타워 업그레이드
7. **hit.wav** - 적 피격

#### 웨이브/게임 (3개)
8. **wave_start.wav** - 웨이브 시작
9. **victory.wav** - 승리
10. **game_over.wav** - 패배

---

## 🎨 이미지 생성 프롬프트

### 타워 스프라이트

#### 1. tower_archer.png
```
Create a pixel art tower sprite (40x40px) for a tower defense game.
- Style: Top-down view, medieval fantasy
- Subject: Archer tower with wooden platform
- Details: Brown wood base, green archer hat on top, small bow visible
- Color palette: Browns, greens, beige
- Background: Transparent
- Art style: Clean pixel art, simple and readable
```

#### 2. tower_frost.png
```
Create a pixel art tower sprite (40x40px) for a tower defense game.
- Style: Top-down view, ice/frost themed
- Subject: Frost tower with icy crystals
- Details: Light blue ice structure, snowflake patterns, frosty edges
- Color palette: Light blue, white, pale cyan
- Background: Transparent
- Art style: Clean pixel art with sparkle effects
```

#### 3. tower_cannon.png
```
Create a pixel art tower sprite (40x40px) for a tower defense game.
- Style: Top-down view, military/siege weapon
- Subject: Cannon tower with stone base
- Details: Gray stone foundation, black/bronze cannon barrel
- Color palette: Grays, dark browns, metallic
- Background: Transparent
- Art style: Clean pixel art, heavy and solid look
```

#### 4. tower_sniper.png
```
Create a pixel art tower sprite (40x40px) for a tower defense game.
- Style: Top-down view, precision/sniper themed
- Subject: Sniper tower with tall watchtower
- Details: Wooden tall structure, scope glint on top, dark colors
- Color palette: Dark browns, black, silver glint
- Background: Transparent
- Art style: Clean pixel art, tall and slender
```

### 몬스터 스프라이트

#### 5. monster_orc.png
```
Create a pixel art monster sprite (32x32px) for a tower defense game.
- Style: Top-down view, fantasy orc
- Subject: Green orc warrior walking
- Details: Green skin, brown armor, weapon in hand
- Color palette: Green, brown, gray
- Background: Transparent
- Art style: Clean pixel art, enemy unit
```

#### 6. monster_wolf.png
```
Create a pixel art monster sprite (32x32px) for a tower defense game.
- Style: Top-down view, fast wolf creature
- Subject: Gray/white wolf running pose
- Details: Lean body, visible fur texture, dynamic pose
- Color palette: Gray, white, black (eyes)
- Background: Transparent
- Art style: Clean pixel art, emphasize speed
```

#### 7. monster_ogre.png
```
Create a pixel art monster sprite (32x32px) for a tower defense game.
- Style: Top-down view, large tank enemy
- Subject: Big muscular ogre
- Details: Large body, brown/gray skin, heavy appearance
- Color palette: Brown, gray, dark tones
- Background: Transparent
- Art style: Clean pixel art, looks bulky and slow
```

### 발사체

#### 8. projectile_arrow.png
```
Create a pixel art arrow projectile sprite (32x32px) for a tower defense game.
- Style: Top-down view, simple arrow
- Subject: Flying arrow with motion
- Details: Wooden shaft, metal tip, feather fletching
- Color palette: Brown, silver, white/gray
- Background: Transparent
- Art style: Clean pixel art, clear directionality
```

### 배경/UI

#### 9. bg_lobby.png
```
Create a fantasy game lobby background (1920x1080px).
- Style: Medieval fantasy, warm atmosphere
- Subject: Castle courtyard or war room view
- Details: Stone walls, torches, banners, warm lighting
- Color palette: Warm browns, oranges, stone grays
- Art style: Game UI background, not too busy
```

#### 10. icon_gold.png
```
Create a pixel art gold coin icon (32x32px) for game UI.
- Style: Top-down view, shiny gold coin
- Subject: Single gold coin with shine
- Details: Gold metallic surface, highlight glint
- Color palette: Gold yellow, orange highlights
- Background: Transparent
- Art style: Clean pixel art, UI icon quality
```

#### 11. icon_gem.png
```
Create a pixel art gem icon (32x32px) for game UI.
- Style: Top-down view, precious gem
- Subject: Blue/purple gem crystal
- Details: Faceted surface, magical glow
- Color palette: Blue, purple, white highlights
- Background: Transparent
- Art style: Clean pixel art, UI icon quality
```

---

## 🔊 사운드 생성 프롬프트

### ElevenLabs / Sound Effect Generator 프롬프트

#### UI 효과음

**1. ui_click.wav**
```
Generate a short UI click sound effect.
- Duration: 0.1-0.2 seconds
- Type: Clean button click
- Tone: Light, satisfying "click"
- Style: Modern game UI, not too harsh
```

**2. error.wav**
```
Generate a negative feedback sound effect.
- Duration: 0.3-0.5 seconds
- Type: Error/buzzer sound
- Tone: Low "bzzzt" or descending tone
- Style: Game UI, indicates invalid action
```

**3. sell.wav**
```
Generate a selling/transaction sound effect.
- Duration: 0.4-0.6 seconds
- Type: Cash register or coin chime
- Tone: Medium, positive "cha-ching"
- Style: Game economy, selling items
```

#### 게임 액션

**4. build.wav**
```
Generate a construction/building sound effect.
- Duration: 0.5-0.8 seconds
- Type: Hammer hitting wood or stone placing
- Tone: Solid "thunk" or "clank"
- Style: Medieval construction
```

**5. shoot.wav**
```
Generate an arrow shooting sound effect.
- Duration: 0.2-0.4 seconds
- Type: Bow release and arrow whoosh
- Tone: Sharp "twang" + "whoosh"
- Style: Fantasy archery
```

**6. upgrade.wav**
```
Generate an upgrade/power-up sound effect.
- Duration: 0.6-1.0 seconds
- Type: Magical power-up with sparkle
- Tone: Ascending chimes, bright
- Style: Fantasy RPG, positive enhancement
```

**7. hit.wav**
```
Generate an impact/hit sound effect.
- Duration: 0.2-0.3 seconds
- Type: Weapon hitting flesh/armor
- Tone: Dull "thud" or "clang"
- Style: Combat hit, enemy taking damage
```

#### 웨이브/게임

**8. wave_start.wav**
```
Generate a battle horn or alert sound effect.
- Duration: 1.0-1.5 seconds
- Type: Horn blast or war drum
- Tone: Deep, commanding "BRAAAA"
- Style: Medieval battle start
```

**9. victory.wav**
```
Generate a victory fanfare sound effect.
- Duration: 2.0-3.0 seconds
- Type: Triumphant horn melody
- Tone: Ascending, heroic, major key
- Style: Fantasy game victory theme
```

**10. game_over.wav**
```
Generate a defeat/failure sound effect.
- Duration: 1.5-2.0 seconds
- Type: Sad descending tones or mournful horn
- Tone: Low, descending, minor key
- Style: Game over, losing theme
```

---

## 📝 대체 생성 방법

### 무료 리소스 사이트
- **Images**: OpenGameArt.org, itch.io (free assets)
- **Sounds**: Freesound.org, Zapsplat.com, OpenGameArt.org

### AI 생성 도구
- **Images**:
  - DALL-E 3 (위 프롬프트 사용)
  - Midjourney (픽셀 아트 모드)
  - Stable Diffusion (pixel art 모델)

- **Sounds**:
  - ElevenLabs Sound Effects
  - Soundraw.io
  - Jsfxr.com (8-bit style)

### 임시 플레이스홀더
이미 구현된 코드는 에셋이 없어도 fallback으로 작동합니다:
- 타워: tower_archer.png로 fallback
- 몬스터: monster_orc.png로 fallback
- 사운드: try-catch로 무시

---

## ✅ 구현 완료 상태 (95%)

### 완료된 기능
- ✅ Lives UI (하트 아이콘)
- ✅ 승리/패배 화면
- ✅ 게임 오버 재시작
- ✅ 타워 4종 (Basic, Slow, Splash, Sniper)
- ✅ 몬스터 3종 (Basic, Fast, Tank)
- ✅ 웨이브 10개 밸런싱
- ✅ 타워 업그레이드 (2단계, ★ 표시)
- ✅ 타워 판매 (70% 환불)

### 남은 작업 (5%)
- ⏳ 에셋 생성 (위 프롬프트 사용)
- ⏳ 스테이지 시스템 (선택사항)

게임 코어 로직은 100% 완성되었으며, 에셋만 교체하면 바로 플레이 가능합니다!
