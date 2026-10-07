# All In: Gambling Tycoon – Story- & Aufbau-Roadmap („The Father's Legacy“)

## 1. Die Story & Prämisse

> *„Mein Sohn... wenn du das liest, habe ich mein letztes Blatt ausgespielt. Das 'Lucky Diamond' gehört jetzt dir. Es hat seine besten Tage hinter sich – voller Staub, Müll und Schulden. Aber tief im Inneren schlägt hier noch das Herz eines echten Casinos. Bring die Lichter wieder zum Leuchten... geh All-In!“*

* **Der Einstieg:** Der Spieler betritt das alte, dunkle Casino seines Vaters.
* **Phase 1: Das große Aufräumen:** Der Boden ist voll mit Müllsäcken, zerbrochenen Flaschen und Spinnweben. Der Spieler muss diese anklicken / aufräumen, um sauberen Bauplatz freizuschalten (und findet dabei etwas Startgeld!).
* **Phase 2: Die erste ranzige Slot-Maschine:** Im Lager steht nur ein einziger verbeulter, alter Einarmiger Bandit. Der wird aufgestellt, die ersten Stadtbewohner kommen herein.
* **Phase 3: Stadtgang & Möbel-Shop:** Außerhalb des Casinos liegt eine kleine, atmosphärische Straße (Neonlichter, Straßensperren, Gehweg). Dort betritt man den Ausstatter-Laden, um neue Möbel und Tische zu kaufen.
* **Phase 4: Der Aufstieg zum Luxus-Casino:** Von der ranzigen Slot-Maschine bis zum High-Roller-Blackjack!

---

## 2. Die Spiel-Welt & Zonen

```
┌────────────────────────────────────────────────────────┐
│  KLEINE AUSSENSTADT (Gehweg, Laternen, Straßensperren) │
│                                                        │
│  [Möbel- & Casino-Store] ◄────► [Casino-Eingangstür]   │
│  (Kaufe Tische, Stühle, Deko)                          │
└───────────────────────────────────┬────────────────────┘
                                    │
                                    ▼
┌────────────────────────────────────────────────────────┐
│  DEIN CASINO (Rasterbasiertes Bausystem)               │
│                                                        │
│  • Zunächst verstaubt, Müll & Flaschen am Boden        │
│  • Nach dem Aufräumen: Freies Platzieren               │
│  • Bar-Theke, Stühle, Automaten & Tische               │
│  • Kasse / Büro des Vaters                             │
└────────────────────────────────────────────────────────┘
```

---

## 3. Die Ausrüstungs- & Spiele-Progression

| Stufe | Spiel / Objekt | Kosten | Besonderheit |
| :--- | :--- | :--- | :--- |
| **Tier 0** | **Alte ranzige Slot-Maschine** | *Im Keller gefunden* | Wirft wenig ab, kann klemmen, lockt einfache Gäste an |
| **Tier 1** | **Moderne LED-Slot-Maschine** | $500 | Höhere Einsätze, blinkende Lichter, mehr Gäste |
| **Tier 2** | **Aviation / Crash-Terminal** | $1.500 | Junge, risikofreudige Zocker, schnelle Spielrunden |
| **Tier 3** | **Klassischer Roulette-Tisch** | $3.500 | Benötigt 2x1 Felder & Croupier, zieht wohlhabende Gäste an |
| **Tier 4** | **VIP Blackjack-Tisch** | $7.500 | Das Kronjuwel: Höchster Profit, eleganter Samt, High-Roller |
| **Gastro** | **Bar-Theke & Hocker** | $300 – $1.200 | Gäste kaufen Drinks ($15–$35 Reingewinn) |
| **Deko**| **Pflanzen, Teppiche, Lichter** | $50 – $400 | Steigert Casino-Atmosphäre & Gästezufriedenheit |

---

## 4. Detaillierte Meilenstein-Roadmap

### Meilenstein 1: Story-Auftakt & Das große Aufräumen
* **Intro-Sequenz / Brief des Vaters:** Einblendung des Abschiedsbriefs mit Casino-Schlüssel.
* **Müll- & Schmutz-System:**
  * Casino startet dunkel und voller Gerümpel (Müllsäcke, Staubflecken, leere Flaschen).
  * Interaktion: Spieler klickt Schmutz an &rarr; Aufräum-Animation/Sound &rarr; Müll verschwindet, Feld wird baubar.
  * Belohnung: Man findet beim Aufräumen etwas vergessenes Startkapital.

### Meilenstein 2: Die Außenstadt & Der Casino-Ausstatter-Shop
* **Stadt-Map (Außenbereich):**
  * Gehweg vor dem Casino mit Neon-Schriftzug *„Lucky Diamond“*.
  * Begrenzung durch Baustellen-Barrieren, Zäune und Häuserfronten (klar definierter Laufweg).
  * Nahtloser Zonenwechsel durch die Eingangstür (Innen &harr; Außen).
* **Möbel- & Geräte-Laden („Vinnie's Casino Supplies“):**
  * Begehbarer Laden mit Shop-Keeper am Tresen.
  * Katalog / Shop-UI: Kauf von Möbeln, Teppichen, Dekorationen und neuen Glücksspielgeräten.
  * Gekaufte Gegenstände landen im Inventar / Baumodus.

### Meilenstein 3: Grid-Bausystem & Automaten-Stufen
* **Raster-Platzierung im Casino:**
  * Kachel-Raster auf dem sauberen Casino-Boden.
  * Visuelle Platzierungsvorschau (Grün = frei, Rot = blockiert).
  * Drehen (R), Verschieben und Verkaufen.
* **Die Glücksspiel-Stufen:**
  * *Ranzige Slot-Maschine:* Rostige Pixel-Textur, knackende Sounds.
  * *Moderne LED-Slots:* Schicke Leuchteffekte.
  * *Aviation-Terminal & Roulette-Tisch:* Passende Möbel-Sprites.

### Meilenstein 4: Tageszyklus & Gäste-Simulation
* **Der Tagesablauf:**
  * **Tag (Vorbereitung):** Türen geschlossen, freies Umbauen, Einkaufen in der Stadt.
  * **Abend/Nacht (Betrieb):** Türen öffnen, Straßenbewohner und Zocker betreten das Casino.
  * **Gäste-Verhalten:** Laufen zu freien Maschinen, trinken an der Bar, setzen Geld.
  * **Tagesabrechnung (Feierabend):** Besucheranzahl, Spiele-Gewinn, Bar-Einnahmen, Strom/Kosten, Sterne-Rating.

### Meilenstein 5: Blackjack-Minispiel & Doppelmodus
* **Neues Minispiel: Blackjack:**
  * Vollwertiges 2D-Pixel-Art Blackjack (Hit, Stand, Double, Dealer zieht bis 17).
  * Sowohl für Gäste (automatische Runden) als auch für den Spieler spielbar.
* **Zwei Modi im Hauptmenü:**
  1. *Story / Tycoon-Modus:* Vom ranzigen Erbe zum Imperium.
  2. *High-Roller Modus:* Das bestehende Luxus-Casino als freier Spieler besuchen.

### Meilenstein 6: Sound-Atmosphäre, Polish & CrazyGames-Submission
* **Atmosphäre:**
  * Außen: Gedämpfter Stadt-Sound, ferne Sirenen, Neon-Brummen.
  * Innen: Entspannter Retro-Casino-Jazz, klirrende Gläser, Münz-Klingeln.
* **CrazyGames Re-Submission:**
  * Erfüllt zu 100 % alle Qualitäts- und Content-Erwartungen von CrazyGames für ein Featured-Spiel.
