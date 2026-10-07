# Project Specification: All In: Gambling Tycoon

> **To the Executing Agent:**
> This document is the authoritative specification for the game.
> Strictly follow the roadmap phase-by-phase. 
> Godot 4.4/4.6 compatibility and clean Web (HTML5/CrazyGames) architecture are mandatory.

---

## 1. Project Overview & Scope
- **Title:** All In: Gambling Tycoon
- **Platform:** Web / HTML5 (CrazyGames) & Desktop (Windows/Linux)
- **Engine:** Godot Engine 4.x (GDScript)
- **Target Directory:** `D:\programming\godot\all-in-gambling-tycoon`
- **Core Concept:** 
  A 2D top-down / ¾-perspective RPG-Tycoon set in a bustling retro casino.
  The player controls a character moving through the casino, collects empty bottles from tables/floor for $0.25 each if broke, plays gambling arcade machines (Slots, Crash/Aviation, Roulette), and uses earned money to unlock higher-tier machines, VIP zones, and prestige upgrades.
- **Game Over & Difficulty Modes:**
  - **Standard Mode:** When money drops to $0.00, player can collect bottles ($0.25 each) or do odd jobs to grind back up.
  - **Hardcore Mode:** If money drops to $0.00 and no active bets are running, instant GAME OVER! Savegame resets/deleted.

### In-Scope (MVP v1.0)
1. **Top-Down ¾ Perspective World:**
   - Smooth WASD / Arrow Keys character movement with collision.
   - Interactive objects: Tables with bottles, Arcade cabinets, VIP doors, Bartender/Exchange desk.
   - On-screen touch D-Pad / action button option for mobile/web browsers.
2. **Economy & Bottle Collection System:**
   - Wallet ($ Cash balance down to cents: e.g. `$12.50`).
   - Bottle spawning on tables/floor with pickup prompt (`E` / Space / Click). Each bottle yields `$0.25`.
   - Dynamic bottle re-spawning after cooldowns.
3. **Machine Progression & Unlocks:**
   - **Machine 1: Classic Retro Slots** (Unlocked by default, low bet $0.50 - $10).
   - **Machine 2: Crash / Aviation Game** (Unlock cost e.g. $100, medium bet $5 - $250, rising multiplier with crash mechanic).
   - **Machine 3: Highroller Roulette** (Unlock cost e.g. $1,000, high bet $25 - $2,500, Red/Black, Dozens, Numbers).
4. **Seamless Machine Minigame UI:**
   - Approaching an unlocked machine and pressing `E` opens the dedicated minigame overlay.
   - Polished sound effects & retro pixel art styling.
   - Exit minigame returns smoothly to walking around the casino.
5. **Game Over & Save System:**
   - LocalStorage / `user://savegame.json` persistence for Web/Desktop.
   - Hardcore mode toggle at new game start.
   - CrazyGames SDK integration hooks (ready for ads/banners/save).

### Out-of-Scope (v1.0)
- Multiplayer / Online PvP.
- Real-money transactions / Microtransactions (Strictly fake currency!).
- Complex 3D models (Pure 2D Pixel-Art).

---

## 2. Tech-Stack & Architecture
- **Engine:** Godot 4.4+ (GDScript 2.0).
- **Renderer:** Compatibility / WebGL 2.0 (Mobile/Compatibility renderer for 100% smooth browser performance on CrazyGames).
- **Resolution:** Base viewport `640x360` or `1280x720` with `canvas_items` stretch mode and `integer` aspect ratio for crisp pixel art.
- **Save System:** JSON-based encrypted or serialized save file stored in `user://all_in_save.json`.
- **Audio:** Retro 8-bit/16-bit synth SFX and ambient casino jazz/lo-fi loop.

### Project Structure
```text
all-in-gambling-tycoon/
├── project.godot
├── icon.svg
├── instruction.md
├── assets/
│   ├── sprites/
│   │   ├── player/
│   │   ├── environment/      # Floors, walls, casino tables, neon signs, bottles
│   │   ├── ui/               # Buttons, frames, dialogs, coin/cash icons
│   │   └── minigames/        # Slots reels, Crash airplane & runway, Roulette wheel
│   ├── audio/
│   │   ├── sfx/              # Coin clink, bottle clink, slot spin, plane crash, win fanfare
│   │   └── music/            # Casino BGM
│   └── fonts/               # Pixel font (e.g. Kenney Pixel or PressStart2P)
├── scenes/
│   ├── main.tscn             # Root scene coordinator
│   ├── casino_world.tscn     # The 2D casino floor, tables, NPCs, bottle spawns
│   ├── player.tscn           # Player character with CharacterBody2D, AnimationPlayer/Sprite2D
│   ├── props/
│   │   ├── bottle.tscn       # Collectible bottle with Area2D
│   │   └── arcade_cabinet.tscn # Interactive cabinet triggering minigames
│   ├── minigames/
│   │   ├── slots_game.tscn   # 3-reel slots overlay
│   │   ├── crash_game.tscn   # Aviation crash game overlay
│   │   └── roulette_game.tscn# Roulette table overlay
│   └── ui/
│       ├── hud.tscn          # Cash display, day/time, unlock progress, touch controls
│       ├── game_over.tscn    # Game Over screen (Hardcore)
│       └── pause_menu.tscn   # Settings & save/quit
└── scripts/
    ├── autoload/
    │   ├── game_manager.gd   # Player cash, stats, game mode, unlocked machines
    │   ├── sound_manager.gd  # Audio playback helper
    │   └── crazy_games_sdk.gd# Web SDK wrapper for CrazyGames
    ├── player/
    │   └── player.gd         # 8-direction top-down movement & interaction
    ├── props/
    │   ├── bottle.gd
    │   └── arcade_cabinet.gd
    └── minigames/
        ├── slots_game.gd
        ├── crash_game.gd
        └── roulette_game.gd
```

---

## 3. Core Mechanics & Formulas

### A. Cash & Economy
- Cash is stored as `float` or integer cents to avoid floating point drift (`cents: int`, where `$1.00 = 100`).
- Starting Cash:
  - Standard Mode: `$10.00`
  - Hardcore Mode: `$25.00`
- Bottle recycling: `$0.25` (25 cents) per bottle.
- Tables respawn 1–3 bottles every 30–60 seconds if cleared.

### B. Minigames Math
1. **Slots (3 Reels, 5 Symbols: Cherry, Lemon, Bell, Diamond, 777):**
   - Bets: `$0.50`, `$1.00`, `$2.00`, `$5.00`, `$10.00`.
   - RTP ~ 96%.
   - 3x 777 = 50x Bet.
   - 3x Diamond = 25x Bet.
   - 3x Bell = 10x Bet.
   - 3x Cherry/Lemon = 5x Bet.
   - 2x matching = 1.5x Bet.

2. **Crash / Aviation Game:**
   - Multiplier starts at `1.00x` and rises exponentially: $M(t) = e^{0.06 \cdot t}$.
   - Instant Crash Probability at 1.00x: ~3%.
   - Crash point formula: $C = \frac{0.99}{1 - U}$ where $U \in [0, 1)$, capped at 100x.
   - Player can place 1 or 2 bets (e.g. Bet 1: $10, Bet 2: $50) and cash out anytime before the plane crashes.
   - Visual: Airplane flying diagonally with retro particles and dynamic multiplier display.

3. **Highroller Roulette:**
   - European Roulette (0-36).
   - Red/Black, Even/Odd (1:1 payout).
   - Dozen (1-12, 13-24, 25-36) (2:1 payout).
   - Single Number Straight-up (35:1 payout).

---

## 4. Definition of Done (DoD)
1. **Casino Walking & Interaction:**
   - Player can move in 4/8 directions with clean retro animations.
   - When near a table with bottles, an interaction indicator appears.
   - Pressing `E` collects the bottle, plays a bottle clink sound, and adds `$0.25` to HUD cash.
2. **Machine Unlocking:**
   - Slots cabinet is active immediately.
   - Crash cabinet shows "Locked: Costs $100.00". When player has $100 and interacts, cabinet unlocks with fanfare.
   - Roulette cabinet shows "Locked: Costs $1,000.00".
3. **Minigame Playability:**
   - Slots spins with animated reels, sounds, and pays out correctly.
   - Crash game plane flies up, multiplier increases in real-time, player can cash out, crash resets game.
   - Roulette wheel spins, ball lands on number, winnings are calculated accurately.
4. **Game Over System:**
   - In Hardcore mode: If cash hits $0.00, instant Game Over screen appears with stats and "Start New Run".
   - In Normal mode: If cash hits $0.00, warning popup reminds player to collect bottles to bounce back.
5. **CrazyGames / Web Compatibility:**
   - Exports seamlessly to HTML5 without errors.
   - Fullscreen button and responsive canvas scaling.

---

## 5. Implementation Roadmap
- **Phase 1: Godot Project Setup & Core Singletons** (`project.godot`, `GameManager`, `SoundManager`, Theme/Fonts).
- **Phase 2: Casino World & Player Movement** (CharacterBody2D, TileMap/Casino Floor, Collision, Camera2D).
- **Phase 3: Bottle Collection & Economy** (Bottle spawning, collection mechanics, HUD Cash counter).
- **Phase 4: Slots Minigame & Cabinet** (Slots overlay UI, spinning reels logic, payouts).
- **Phase 5: Crash/Aviation Minigame & Cabinet** (Plane curve, multiplier math, dual bet buttons, cashout).
- **Phase 6: Roulette Minigame & Cabinet** (Roulette wheel, betting board, payouts).
- **Phase 7: Hardcore Mode & Savegame** (Save/Load system, Game Over state, CrazyGames hooks).
- **Phase 8: Polish, SFX & Web Export Verification**.
