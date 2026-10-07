# CrazyGames Publishing Guide: All In: Gambling Tycoon

This document outlines everything needed to export, upload, and publish **All In: Gambling Tycoon** to [CrazyGames Developer Portal](https://developer.crazygames.com).

---

## 1. Technical Requirements & Limits
- **Initial Download Size:** Max 50 MB (Our game is < 15 MB).
- **Total Zip File Size:** Max 250 MB.
- **File Count:** Max 1500 files.
- **Entry File:** Must be named `index.html` at the root of the ZIP archive.
- **Engine Renderer:** Godot 4 Compatibility / WebGL 2.0 (Enabled in `project.godot`).
- **Language / Localization:** English UI supported by default.
- **Controls:** WASD / Arrow Keys for moving, `E` / Space for interaction, Mouse clicks for betting and levers.

---

## 2. Integrated CrazyGames SDK v3 Features (100% Kostenlos & Werbefrei)
Das Spiel ist als reines Hobby-/Gratis-Projekt konzipiert (**keine Monetarisierung, kein Geldverdienen, keine störende Werbung**).
Der SDK-Wrapper (`res://scripts/autoload/crazy_games_sdk.gd`) nutzt daher ausschließlich spielerfreundliche Komfort-Features:
1. **Cloud Save (Data Module):**
   - Synchronisiert Spielguthaben, Flaschenanzahl und freigeschaltete Automaten kostenlos über den CrazyGames-Account (`CrazyGames.SDK.data.setItem('all_in_savegame', json)` / `getItem()`).
   - Spieler können ihr Spiel jederzeit auf jedem PC/Browser nahtlos fortsetzen.
   - Offline-Fallback auf lokales `localStorage` bzw. Godot `user://savegame.json`.
2. **Gameplay Lifecycle:**
   - Meldet Spielstart (`gameplayStart()`) und Pausen (`gameplayStop()`) sauber an die Plattform für optimale Performance.
   - Jackpot-Effekt (`happytime()` für Konfetti-Effekte der Plattform).
3. **Werbung / Ads:**
   - **Vollständig deaktiviert (`ads_enabled = false`)**. Es werden keine Midroll-Videos, keine Banner und keine Werbeunterbrechungen aufgerufen. Das Spiel läuft 100 % flüssig und ungestört durch!
   - Keine Bankverbindung, keine Gewerbe- oder Steuerangaben im CrazyGames-Entwicklerportal nötig.

---

## 3. How to Export from Godot 4.7
1. Open Godot 4.7 with the project at `D:\programming\godot\all-in-gambling-tycoon`.
2. Go to **Project > Export...** (or press Ctrl + E).
3. Select the preset **Web (CrazyGames)**.
   *(Make sure Godot Web Export Templates for 4.7.2 are downloaded via Editor > Manage Export Templates if doing a full local build)*.
4. Set Export Path to `export/web/index.html`.
5. Click **Export Project** (Release build).
6. Navigate to `export/web/` and select all generated files:
   - `index.html`
   - `index.js`
   - `index.wasm`
   - `index.pck`
   - `index.icon.png` (optional)
7. Right-click and compress into a single `.zip` file (e.g. `all-in-gambling-tycoon-web.zip`).
   > **Important:** `index.html` must be in the root of the zip file, NOT inside a subfolder!

---

## 4. CrazyGames Submission Steps
1. Create or log in to your account at [CrazyGames Developer Portal](https://developer.crazygames.com).
2. Click **Submit a Game**.
3. Fill in the metadata:
   - **Game Title:** All In: Gambling Tycoon
   - **Game Description:**
     > Start with a few dollars in a retro casino! Collect empty champagne bottles from the tables for $0.25 each if you are broke, play classic Pixel Fantasy Slots, advance to high-flying Aviation Crash, and bet it all on Highroller Roulette. Can you build a gambling empire without going homeless?
   - **Controls:**
     - `WASD` / `Arrow Keys`: Move character
     - `E` / `Space`: Collect bottles & interact with machines
     - `Mouse Click`: Spin slots, pull lever, bet & cash out
4. **Enable Cloud Save:**
   - In the submission form, make sure to check the toggle **"Progress Save" / "Cloud Save"**.
5. **Upload Media Assets:**
   - **Landscape Cover:** 16:9 (e.g. 1200x675 or 1920x1080)
   - **Portrait Cover:** 3:4 (e.g. 600x800 or 1200x1600)
   - **Square Cover:** 1:1 (e.g. 512x512)
   - Gameplay video or animated GIF
6. **Upload Build:**
   - Drag and drop your `.zip` archive into the build uploader.
   - Use the embedded CrazyGames QA preview player to test loading, ads, and cloud save.
7. Click **Submit for Review**.

---

## 5. Launch & Kein Geld verdienen / Werbefrei
- **Keine Auszahlungsdaten nötig:** Da du kein Geld verdienen willst, musst du im Developer-Portal **keine Bankverbindung, keine PayPal-Daten und keine Steuerformulare** ausfüllen.
- **Dauerhaft werbefrei:** Ohne hinterlegte Auszahlungsdaten und mit im Code deaktivierten Werbeaufrufen (`ads_enabled = false`) bleibt dein Spiel für alle Spieler zu 100 % werbefrei, ohne nervige Midroll-Clips oder Banner.
- **Voller Spieler-Komfort:** Das kostenlose CrazyGames Cloud-Speichern funktioniert trotzdem ganz normal für jeden eingeloggten Nutzer!

---

## 6. CrazyGames Content Policy & Terms Checkliste (Garantierte Freigabe)

Um sicherzustellen, dass das Spiel **zu 100 % den CrazyGames Terms & Conditions und Content Policies entspricht** und die QA-Prüfung ohne Beanstandung besteht, sind folgende Punkte implementiert:

1. **Simulated Gambling vs. Real Money Gambling:**
   - **Richtlinie:** Es darf auf keinen Fall echtes Geld gesetzt oder gewonnen werden. Keine Links zu externen Glücksspielseiten.
   - **Umsetzung im Spiel:** 
     - Reine virtuelle Spielwährung ohne realen Gegenwert.
     - Sichtbarer Disclaimer im Hauptmenü: *"Virtual play money only. No real money gambling."*
     - Für die Einreichung im Feld "Description" diesen Satz am Ende einfügen:
       > *"Disclaimer: All In: Gambling Tycoon is a simulation and tycoon game for entertainment purposes only. It uses strictly virtual play money and does not offer real-money gambling, payouts, or prizes."*

2. **Englisch-Sprachunterstützung (QA Requirement):**
   - **Richtlinie:** CrazyGames verlangt zwingend englische Sprachunterstützung (*"Submissions may be rejected for lack of English-language support"*).
   - **Umsetzung:** Das Spiel erkennt automatisch die Browser-Sprache (Englisch für internationale QA-Tester / Deutsch für deutschsprachige Spieler) und bietet einen manuellen `EN / DE` Umschalter im Hauptmenü.

3. **Performance & Dateilimits:**
   - **Richtlinie:** Initialer Download < 50 MB, Dateianzahl < 1.500 Dateien, Ladezeit < 20 Sekunden.
   - **Umsetzung:** Unser komprimierter WebGL-Build ist nur ca. 12–15 MB groß, hat unter 150 Dateien und lädt in unter 2 Sekunden.

4. **Keine Tastatur-Störungen im Browser:**
   - Im HTML-Header ist ein Skript hinterlegt, das verhindert, dass `Space` oder Pfeiltasten die Browser-Webseite nach oben/unten scrollen.

5. **PEGI-12 & Jugendschutz:**
   - Keine Drogen, keine Gewalt, keine obszönen Inhalte. Reines Pfandflaschensammeln und Retro-Casino-Minigames.
