# All In: Gambling Tycoon 🎰

[![Godot Engine](https://img.shields.io/badge/Godot-4.7.2-478cbf?logo=godotengine&logoColor=white)](https://godotengine.org/)
[![Tests](https://img.shields.io/badge/Unit%20Tests-167%2F167%20PASS-22c55e)](#automated-testing)
[![Platform](https://img.shields.io/badge/Platform-Web%20%7C%20Windows%20%7C%20Linux-eab308)](#platforms)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](#license)

> **From a rundown family inheritance to a thriving high-roller casino empire.**

**All In: Gambling Tycoon** is a retro 2D pixel-art casino management and simulation game developed in Godot Engine 4.7. Build, furnish, and manage your own gambling hall, satisfy thirsty guests, expand room wings, and personally play interactive casino minigames.

---

## 📸 Presentation & Pitch Deck

The repository includes a standalone presentation and pitch deck ready for browsers and PDF export:
- 🌐 **Interactive Standalone HTML Presentation:** [`export/game_presentation.html`](export/game_presentation.html)
- 📄 **Print-Ready Pitch Deck PDF:** [`export/All_In_Gambling_Tycoon_Presentation.pdf`](export/All_In_Gambling_Tycoon_Presentation.pdf)

---

## 🌟 Core Gameplay Features

### 1. Story & Starting Day Cleanup
- Inherit the rundown *"Lucky Diamond"* casino from your dad with only $20.00 cash and one rusty slot machine.
- Clean up 10 trash piles around the dusty casino floor for pocket change and earn a **+$200.00 Sparkling Clean Bonus** ($240.00 starter capital).

### 2. City Street & Shopkeepers
- Walk out onto the lively city street to trade with local merchants:
  - **Vinnie's Casino Supplies:** Purchase starter equipment (Drink Vending Machine, Tables, Stools, Trash Bins). Starter budget matches inventory perfectly!
  - **Bob's Expansion Office:** Unlock major casino expansions including the **East Wing** (space for high-tier machines) and the **VIP Lounge** (attracts millionaire high-rollers).
  - **Player Car:** Parked on the street curb to close the night, drive home, and review the daily financial balance.

### 3. Precision Building & Grid Snapping
- **32×32 Pixel Grid Overlay:** Green tiles indicate valid free floor space; red highlights walls or occupied spots.
- **Relocate & Pack Up:** Click placed furniture to move it around or right-click to return items to your inventory.
- **Collision Boundary Safety:** Robust physics barriers keep NPCs from wandering through store booths or out of bounds.

### 4. Night Cycle & Realistic NPC Behaviors
- **Door Queue & Entry:** Guests line up outside the front door and enter sequentially when doors open.
- **Drink Vending Machine & Queue System:** Guests crave cold refreshments. When one guest interacts with the vending machine (5–10 second dispense time), subsequent guests form an orderly waiting line and advance automatically.
- **Table & Chair Seating:** Guests take drinks to tables and sit on chairs with proper sprite sorting, or enjoy their beverage standing up.
- **Non-Blocking Player Movement:** The player moves freely through crowds without getting trapped by NPC hitboxes.

### 5. Four Interactive Minigames
Players can personally step up and play any installed machine:
- **🎰 Slot Machines (Rusty & Modern):** 3 spinning reels with classic retro symbols (Cherries, Bells, Diamonds, 7s) and animated mechanical lever.
- **🚀 Crash Terminal:** Watch the multiplier climb from 1.0x to 50x+ and cash out before the rocket crashes!
- **🎡 Roulette:** Bet on red, black, or specific numbers with a simulated spinning wheel and ball physics.
- **♠️ Blackjack:** Classic 21 against the virtual dealer featuring Hit, Stand, and Double Down.

### 6. Economy & Daily Balances
- Detailed daily accounting breaks down:
  - Machine turnover & guest losses
  - Beverage & vending sales revenue
  - Daily room & power upkeep costs
  - Net operating profit for next-day investments

---

## 🕹️ Controls

| Action | Key / Input |
|---|---|
| **Move Player** | `W`, `A`, `S`, `D` or Arrow Keys |
| **Interact / Open Menu / Play** | `E` or `Space` / Click |
| **Toggle Build Mode** | `B` or On-Screen Button |
| **Move / Place Furniture** | Left Click on Grid |
| **Pack Furniture to Inventory** | Right Click in Build Mode |
| **Close Menus / Pause** | `Escape` |

---

## 🧪 Automated Testing

The game includes a headless regression test suite verifying scene instantiation, economy balancing, grid snapping, NPC queuing, and player collision masks.

To run the test suite via Godot Console:
```bash
Godot_v4.7.2-stable_win64_console.exe --headless --path . tests/test_scene.tscn
```

**Test Status:** `167 PASSED, 0 FAILED (100% Success Rate)`

---

## 🛠️ Project Structure

```text
├── assets/
│   ├── audio/            # Retro sound effects, lever pulls, chimes & background music
│   ├── fonts/            # Clean pixel typography (Silkscreen, Press Start 2P)
│   └── sprites/          # Character sprites, furniture, vending machines, facades
├── export/
│   ├── game_presentation.html               # Standalone self-contained HTML presentation
│   ├── All_In_Gambling_Tycoon_Presentation.pdf # Pitch deck PDF export
│   └── generate_presentation_pdf.py        # Edge headless generator script
├── scenes/
│   ├── casino_world.tscn # Main game world with street and casino interior
│   ├── minigames/        # Slots, Crash, Roulette, and Blackjack scenes
│   ├── props/            # Vending machines, arcade cabinets, tables, chairs
│   └── ui/               # HUD, shops, renovation overlays, daily summary
├── scripts/
│   ├── autoload/         # GameManager, SoundManager, TycoonEconomy
│   └── props/            # NPC state machine, build grid overlay, vending logic
└── tests/
    └── test_scene.tscn   # Comprehensive 167-assertion automated test suite
```

---

## 🚀 Running the Project

1. Install [Godot Engine 4.7+ (Standard)](https://godotengine.org/download).
2. Clone this repository:
   ```bash
   git clone https://github.com/exitishere42/all-in-gambling-tycoon.git
   ```
3. Open Godot, click **Import**, select `project.godot`, and launch with **Run (F5)**.

---

## 📄 License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
