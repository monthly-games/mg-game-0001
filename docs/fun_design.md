# Tower Defense (Project 0001) - Fun Design Document

> game_id: game_0001
> repo: mg-game-0001

---

## 1. Game Overview
| Item | Content |
|------|---------|
| Title | Simple Tower Defense (Prototype) |
| Genre | `tower-defense`, `strategy`, `arcade` |
| Goal | Defend the base from infinite waves of monsters by building and upgrading towers. |

---

## 2. Core Loop

```
┌─────────────────────────────────────────────────────────┐
│  1. Build Phase (Preparation)                            │
│         ↓                                               │
│  2. Defend Wave (Action)                                 │
│         ↓                                               │
│  3. Earn Gold (Reward)                                   │
│         ↓                                               │
│  4. Upgrade/Build More (Growth) ───────→ (Repeat)        │
└─────────────────────────────────────────────────────────┘
```

### Loop Details
1.  **Build Phase**: Player spends Gold to place towers on the grid.
2.  **Defend Wave**: Monsters spawn and travel along a fixed path. Towers auto-attack.
3.  **Earn Gold**: Killing monsters rewards Gold.
4.  **Growth**: Use Gold to build more towers or upgrade existing ones to handle stronger waves.

---

## 3. Fun Pillars

### 3.1 Strategic Placement (Strategy)
- **Goal**: Player feels smart by finding optimal tower positions.
- **Key Experience**: "My tower placement decimated that wave!"

### 3.2 Economic Efficiency (Management)
- **Goal**: Balancing spending vs. saving.
- **Key Experience**: maximizing damage per gold spent.

### 3.3 Crisis Management (Action)
- **Goal**: Handling leaks (monsters getting through).
- **Key Experience**: Using emergency skills (future feature) or quick-building to stop a leak.

---

## 4. Key Mechanics
- **Path System**: Monsters follow a pre-determined path (Grid based).
- **Tower Types**: 
    - *Basic Tower*: Moderate range/damage.
    - *(Planned)* *Sniper Tower*: Long range, slow fire.
    - *(Planned)* *Rapid Tower*: Short range, fast fire.
- **Wave System**: 
    - Structured waves with increasing difficulty (count, speed, HP).
- **Life System**: 
    - Player has 20 Lives. 
    - 1 Leak = -1 Life. 
    - 0 Lives = Game Over.

---

## 5. Visual & Audio
- **Visual**: Dark theme, Neon towers, Clear visibility of projectiles.
- **Audio**: Arcade-style SFX (Shoot, Hit).
