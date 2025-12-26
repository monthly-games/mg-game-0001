# Visual Effects Guide for MG-0001

## Effect Visualization

### 1. Tower Attack Effects (Muzzle Flash)
```
     Tower
       |
      \|/
    ********  <- Yellow/Orange/Blue particles burst outward
     (  )
      ||
      \/
    Bullet
```
**When**: Tower shoots at a monster
**Color**: Varies by tower type
- Basic: Yellow
- Splash: Orange
- Slow: Light Blue
- Sniper: Red
- Air: Cyan
**Particle Count**: 8
**Duration**: 0.3s
**Spread**: 20 pixels

### 2. Bullet Impact Effects
```
Normal Impact:         Splash Impact:
    Bullet                 Bullet
      |                      |
      V                      V
   Target                 Target
  ********             ***************
   (hit)              (BOOM - larger!)
```
**When**: Bullet hits a monster
**Color**:
- Normal: White particles
- Splash: Red particles
**Particle Count**: 8 (normal), 15 (splash)
**Duration**: 0.4s
**Spread**: 20px (normal), 35px (splash)

### 3. Damage Numbers
```
    -25      <- Floats upward and fades
    -18      <- White text
    -32      <- Appears at hit position
```
**When**: Monster takes damage
**Color**: White
**Size**: Based on damage amount
**Animation**: Floats up and fades out

### 4. Monster Death Effect
```
     Monster
       |
       X  <- Dies
    /  |  \
   *   *   *     <- Orange explosion particles
  *    *    *
   $   $   $     <- Yellow coin particles
    $ $ $
```
**When**: Normal monster dies
**Colors**:
- Explosion: Orange (20 particles, 0.6s, 40px spread)
- Coins: Yellow (10 particles, 0.5s, 30px spread)
**Special**: Coin particles only if goldReward > 0

### 5. Boss Kill Effect
```
       BOSS
         |
         X  <- Dies
    ***********
   *           *
  *   SHAKE!    *  <- Screen shakes
   *   BOOM!   *   <- Purple particles everywhere!
    ***********
      ||||||||      <- 50 particles!
```
**When**: Boss monster dies
**Color**: Purple
**Particle Count**: 50 (massive explosion!)
**Duration**: 1.2s
**Spread**: 80px
**Special**: Triggers screen shake (8.0 intensity, 0.8s)

### 6. Tower Build Effect
```
    New Tower
       |
       V
    *******    <- Green celebration particles
   *   🗼   *     burst around new tower
    *******
```
**When**: Tower successfully built
**Color**: Green
**Particle Count**: 15
**Duration**: 0.5s
**Spread**: 35px

### 7. Tower Upgrade Effect
```
     Tower
       ★  <- Upgraded!
    *******    <- Yellow upgrade particles
   *   🗼   *     burst around tower
    *******
```
**When**: Tower upgraded
**Color**: Yellow
**Particle Count**: 25
**Duration**: 0.8s
**Spread**: 45px

### 8. Slow Effect
```
    Monster
       |
    ❄️❄️❄️  <- Light blue particles
   ❄️ 🐢 ❄️    indicate slowed monster
    ❄️❄️❄️
    "SLOW"  <- Blue floating text
```
**When**: Monster gets slowed
**Color**: Light Blue
**Particle Count**: 12
**Duration**: 0.4s
**Spread**: 25px
**Additional**: "SLOW" floating text

### 9. Wave Complete Effect
```
    Center Screen
         |
         V
    ***********    <- Green particles (30)
   *           *      burst out
  *   VICTORY!  *
   *           *
    ***********
   After 0.2s:
    ***********    <- Yellow particles (25)
   *           *      second burst!
  *             *
   *           *
    ***********
```
**When**: Wave completed successfully
**Colors**:
- First burst: Green (30 particles, 1.0s, 60px)
- Second burst: Yellow (25 particles, 0.8s, 50px)
**Timing**: Yellow burst 200ms after green

## Effect Combinations

### Common Gameplay Scenarios

#### Scenario 1: Tower Shooting Sequence
```
1. Tower ready ──> 2. Attack Effect ──> 3. Bullet Travels ──> 4. Impact ──> 5. Damage Number
      🗼              💥 (yellow)            ━━━>              💥 (white)        -25
```

#### Scenario 2: Monster Death Sequence
```
1. Final Hit ──> 2. Damage Number ──> 3. Death Effect ──> 4. Gold Reward
     ━━━>              -15                💥💥💥              +$$ (coins)
```

#### Scenario 3: Boss Kill Sequence
```
1. Final Hit ──> 2. Damage Number ──> 3. Boss Death ──> 4. Screen Shake ──> 5. Gold
     ━━━>              -50             💥💥💥💥💥           📳 SHAKE!          +$$$
                                      (PURPLE!)
```

#### Scenario 4: Tower Build Sequence
```
1. Tap Confirm ──> 2. Tower Appears ──> 3. Build Effect ──> 4. Ready to Shoot
       👆                 🗼               💚 (green)              🗼
```

#### Scenario 5: Splash Attack Sequence
```
1. Cannon Shoots ──> 2. Orange Flash ──> 3. Bullet ──> 4. RED BOOM! ──> 5. Multiple Hits
      🗼                 💥 (orange)         ━━━>         💥💥💥           -20 -15 -10
                                                       (splash!)
```

## Color Palette Reference

```
Effect Colors:
┌─────────────────┬──────────────┬────────────────────┐
│ Effect Type     │ Color        │ Hex Code (approx) │
├─────────────────┼──────────────┼────────────────────┤
│ Basic Attack    │ Yellow       │ #FFEB3B           │
│ Splash Attack   │ Orange       │ #FF9800           │
│ Slow Attack     │ Light Blue   │ #03A9F4           │
│ Sniper Attack   │ Red          │ #F44336           │
│ Air Attack      │ Cyan         │ #00BCD4           │
│ Monster Death   │ Orange       │ #FF9800           │
│ Gold Coins      │ Yellow       │ #FFC107           │
│ Boss Death      │ Purple       │ #9C27B0           │
│ Tower Build     │ Green        │ #4CAF50           │
│ Tower Upgrade   │ Yellow       │ #FFEB3B           │
│ Slow Effect     │ Light Blue   │ #03A9F4           │
│ Wave Complete 1 │ Green        │ #4CAF50           │
│ Wave Complete 2 │ Yellow       │ #FFEB3B           │
│ Normal Impact   │ White        │ #FFFFFF           │
│ Splash Impact   │ Red          │ #F44336           │
│ Damage Numbers  │ White        │ #FFFFFF           │
└─────────────────┴──────────────┴────────────────────┘
```

## Particle Properties

```
Particle Behavior:
┌──────────────────┬───────┬──────────┬────────┬─────────────┐
│ Effect           │ Count │ Duration │ Spread │ Special     │
├──────────────────┼───────┼──────────┼────────┼─────────────┤
│ Tower Attack     │   8   │  0.3s    │  20px  │ -           │
│ Normal Impact    │   8   │  0.4s    │  20px  │ -           │
│ Splash Impact    │  15   │  0.4s    │  35px  │ -           │
│ Monster Death    │  20   │  0.6s    │  40px  │ + 10 coins  │
│ Boss Death       │  50   │  1.2s    │  80px  │ Screen shake│
│ Tower Build      │  15   │  0.5s    │  35px  │ -           │
│ Tower Upgrade    │  25   │  0.8s    │  45px  │ -           │
│ Slow Effect      │  12   │  0.4s    │  25px  │ + text      │
│ Wave Complete 1  │  30   │  1.0s    │  60px  │ -           │
│ Wave Complete 2  │  25   │  0.8s    │  50px  │ +200ms delay│
└──────────────────┴───────┴──────────┴────────┴─────────────┘
```

## Animation Timing

```
Timeline Examples:

Tower Attack Cycle (Total: ~1.5s for attack speed 1.5):
0.0s: Cooldown complete
0.0s: Target acquired
0.0s: Muzzle flash effect starts
0.0s: Bullet spawns
0.0s: Bounce animation starts
0.1s: Bounce reaches peak
0.2s: Bounce returns to normal
0.3s: Muzzle flash fades out
0.5s: Bullet reaches target
0.5s: Impact effect starts
0.5s: Damage number appears
0.9s: Impact effect fades
1.5s: Cooldown reset, ready to shoot again

Monster Death (Total: ~0.6s):
0.0s: HP reaches 0
0.0s: Explosion particles start (orange)
0.0s: Coin particles start (yellow, offset +10px up)
0.0s: Monster removed from game
0.5s: Coin particles fade
0.6s: Explosion particles fade

Boss Death (Total: ~1.2s):
0.0s: HP reaches 0
0.0s: Massive explosion starts (purple, 50 particles)
0.0s: Screen shake starts (intensity 8.0)
0.8s: Screen shake ends
1.2s: Explosion fades out

Wave Complete (Total: ~1.2s):
0.0s: Last monster dies
0.0s: Green burst starts (30 particles)
0.2s: Yellow burst starts (25 particles)
1.0s: Green burst fades
1.2s: Yellow burst fades
```

## Implementation Notes

### Particle System
- Uses Flame's built-in particle system
- Particles spread radially from spawn point
- Each particle has random velocity
- Fade out animation applied
- Auto-cleanup when finished

### Performance
- Lightweight: Each particle is just a colored rectangle/circle
- Short-lived: Max duration 1.2s
- No physics simulation: Simple linear movement
- Batched rendering: Flame handles efficiently
- No impact on game logic or collision detection

### Customization
All effects can be customized by modifying VfxManager:
- Particle counts (more/fewer particles)
- Colors (change to match your theme)
- Durations (faster/slower effects)
- Spread radius (larger/smaller explosions)
- Add new effect types as needed

---
Use this guide to understand what each effect will look like in-game!
