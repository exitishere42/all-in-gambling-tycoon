import os
import base64
import subprocess

def encode_img_b64(path):
    if not os.path.exists(path):
        print(f"WARN: Image not found: {path}")
        return ""
    with open(path, "rb") as f:
        data = base64.b64encode(f.read()).decode("utf-8")
        ext = os.path.splitext(path)[1].lower().replace(".", "")
        if ext == "jpg": ext = "jpeg"
        return f"data:image/{ext};base64,{data}"

base_brain = r"C:\Users\timo\.gemini\antigravity\brain\03c1e787-33c2-4cdb-a31a-0819e5fe6dd4"
project_dir = r"D:\programming\godot\all-in-gambling-tycoon"

img_cover = encode_img_b64(os.path.join(project_dir, "export", "media", "cover_landscape_1920x1080.png"))
img_letter = encode_img_b64(os.path.join(base_brain, ".user_uploaded", "media_1791308997397.png"))
img_casino_overview = encode_img_b64(os.path.join(base_brain, ".user_uploaded", "media_1791315522336.png"))
img_vinnie_shop = encode_img_b64(os.path.join(base_brain, ".user_uploaded", "media_1791315472645.png"))
img_bob_expansion = encode_img_b64(os.path.join(base_brain, ".user_uploaded", "media_1791315489162.png"))
img_slot_minigame = encode_img_b64(os.path.join(base_brain, ".user_uploaded", "media_1791315457762.png"))
img_main_menu = encode_img_b64(os.path.join(base_brain, ".user_uploaded", "media_1791315406798.png"))
img_icon = encode_img_b64(os.path.join(project_dir, "export", "crazygames_icon_512.png"))

html_content = f"""<!DOCTYPE html>
<html lang="de">
<head>
<meta charset="UTF-8">
<title>All In: Gambling Tycoon - Spielpräsentation & Gameplay Guide</title>
<style>
  @import url('https://fonts.googleapis.com/css2?family=Press+Start+2P&family=Inter:wght@300;400;600;700;800&display=swap');

  @page {{
    size: A4 landscape;
    margin: 0;
  }}

  * {{
    box-sizing: border-box;
    margin: 0;
    padding: 0;
  }}

  body {{
    font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
    background-color: #0b0c10;
    color: #e2e8f0;
    -webkit-print-color-adjust: exact;
    print-color-adjust: exact;
  }}

  .page {{
    width: 297mm;
    height: 210mm;
    page-break-after: always;
    position: relative;
    padding: 16mm 20mm;
    background-color: #0b0f19;
    overflow: hidden;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
  }}

  @media screen {{
    body {{
      padding: 30px 0;
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 30px;
    }}
    .page {{
      border: 1px solid #374151;
      border-radius: 8px;
    }}
  }}

  /* Page Footer */
  .page-footer {{
    display: flex;
    justify-content: space-between;
    align-items: center;
    border-top: 1px solid #2d3748;
    padding-top: 8px;
    font-size: 11px;
    color: #94a3b8;
  }}
  .page-footer .game-title {{
    color: #facc15;
    font-weight: 700;
    letter-spacing: 1px;
  }}

  /* Header styles */
  .slide-header {{
    margin-bottom: 12px;
  }}
  .slide-tag {{
    display: inline-block;
    background-color: #eab308;
    color: #000;
    font-size: 10px;
    font-weight: 800;
    text-transform: uppercase;
    padding: 4px 10px;
    border-radius: 4px;
    letter-spacing: 1.5px;
    margin-bottom: 6px;
  }}
  .slide-title {{
    font-size: 26px;
    font-weight: 800;
    color: #ffffff;
    display: flex;
    align-items: center;
    gap: 12px;
  }}
  .slide-title span.gold {{
    color: #facc15;
  }}
  .slide-subtitle {{
    font-size: 13px;
    color: #94a3b8;
    margin-top: 2px;
  }}

  /* Grid Layouts */
  .content-grid-2 {{
    display: grid;
    grid-template-columns: 1.15fr 0.85fr;
    gap: 18px;
    align-items: center;
    flex: 1;
    margin: 8px 0;
  }}

  .content-grid-equal {{
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 18px;
    align-items: center;
    flex: 1;
    margin: 8px 0;
  }}

  .content-grid-3 {{
    display: grid;
    grid-template-columns: 1fr 1fr 1fr;
    gap: 14px;
    flex: 1;
    margin: 8px 0;
  }}

  /* Cards */
  .card {{
    background-color: #111827;
    border: 2px solid #374151;
    border-radius: 8px;
    padding: 16px;
    box-shadow: none;
  }}

  .card-header {{
    font-size: 15px;
    font-weight: 700;
    color: #facc15;
    margin-bottom: 8px;
    display: flex;
    align-items: center;
    gap: 8px;
  }}

  .card p {{
    font-size: 12px;
    line-height: 1.55;
    color: #cbd5e1;
    margin-bottom: 8px;
  }}

  .feature-list {{
    list-style: none;
    margin-top: 6px;
  }}
  .feature-list li {{
    font-size: 11.5px;
    line-height: 1.5;
    color: #e2e8f0;
    margin-bottom: 5px;
    display: flex;
    align-items: flex-start;
    gap: 8px;
  }}
  .feature-list li::before {{
    content: "✦";
    color: #facc15;
    font-size: 11px;
    line-height: 1.4;
  }}

  /* Image wrappers */
  .img-frame {{
    background: #000;
    border: 2px solid #374151;
    border-radius: 6px;
    overflow: hidden;
    box-shadow: none;
    position: relative;
  }}
  .img-frame img {{
    width: 100%;
    height: 100%;
    object-fit: cover;
    display: block;
    image-rendering: pixelated;
  }}
  .img-caption {{
    background-color: #111827;
    color: #94a3b8;
    font-size: 10.5px;
    padding: 6px 10px;
    border-top: 1px solid #374151;
    text-align: center;
  }}

  /* Badge pill */
  .pill {{
    display: inline-block;
    padding: 3px 8px;
    border-radius: 4px;
    font-size: 10px;
    font-weight: 700;
    margin-right: 4px;
    margin-bottom: 4px;
  }}
  .pill-gold {{ background-color: #372f0b; color: #facc15; border: 1px solid #eab308; }}
  .pill-green {{ background-color: #0b371b; color: #4ade80; border: 1px solid #22c55e; }}
  .pill-blue {{ background-color: #0b1f37; color: #60a5fa; border: 1px solid #3b82f6; }}
  .pill-purple {{ background-color: #270b37; color: #c084fc; border: 1px solid #a855f7; }}

  /* Cover Page Specific */
  .cover-container {{
    display: flex;
    flex-direction: column;
    height: 100%;
    justify-content: space-between;
    text-align: center;
  }}
  .cover-top {{
    margin-top: 10px;
  }}
  .cover-badge {{
    display: inline-block;
    background-color: #1e293b;
    border: 2px solid #facc15;
    color: #facc15;
    padding: 6px 18px;
    border-radius: 6px;
    font-size: 12px;
    font-weight: 700;
    letter-spacing: 2px;
    text-transform: uppercase;
  }}
  .cover-title {{
    font-size: 44px;
    font-weight: 900;
    color: #ffffff;
    letter-spacing: -0.5px;
    margin-top: 12px;
    text-shadow: none;
  }}
  .cover-title span {{
    color: #facc15;
  }}
  .cover-sub {{
    font-size: 16px;
    color: #cbd5e1;
    margin-top: 6px;
    max-width: 750px;
    margin-left: auto;
    margin-right: auto;
  }}
  .cover-media {{
    margin: 14px auto;
    max-width: 820px;
    border-radius: 6px;
    overflow: hidden;
    border: 2px solid #eab308;
    box-shadow: none;
  }}
  .cover-media img {{
    width: 100%;
    max-height: 110mm;
    object-fit: cover;
    display: block;
  }}
  .cover-meta {{
    display: flex;
    justify-content: center;
    gap: 30px;
    font-size: 12px;
    color: #94a3b8;
    margin-bottom: 6px;
  }}
  .cover-meta strong {{
    color: #facc15;
  }}

  /* Step box */
  .step-num {{
    width: 24px;
    height: 24px;
    border-radius: 50%;
    background: #facc15;
    color: #000;
    font-weight: 800;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    font-size: 12px;
    margin-right: 6px;
  }}
</style>
</head>
<body>

  <!-- ==================== SLIDE 1: COVER ==================== -->
  <div class="page">
    <div class="cover-container">
      <div class="cover-top">
        <div class="cover-badge">Game Pitch & Gameplay Walkthrough</div>
        <h1 class="cover-title">ALL IN: <span>GAMBLING TYCOON</span></h1>
        <p class="cover-sub">Vom heruntergekommenen Familienerbe zum glamourösen High-Roller Casino-Imperium</p>
      </div>

      <div class="cover-media">
        <img src="{img_cover}" alt="All In Cover">
      </div>

      <div class="cover-meta">
        <div><strong>Genre:</strong> 2D Pixel-Art Tycoon & Casino Management</div>
        <div><strong>Plattformen:</strong> Web (CrazyGames HTML5), PC (Windows & Linux)</div>
        <div><strong>Engine:</strong> Godot Engine 4.7 & Custom CrazyGames SDK</div>
      </div>

      <div class="page-footer">
        <span class="game-title">ALL IN: GAMBLING TYCOON</span>
        <span>Präsentation & Gameplay-Konzept 2026</span>
        <span>Seite 1 / 7</span>
      </div>
    </div>
  </div>

  <!-- ==================== SLIDE 2: DER EINSTIEG & CASINO AUFRÄUMEN ==================== -->
  <div class="page">
    <div>
      <div class="slide-header">
        <div class="slide-tag">Kapitel 1: Der Start</div>
        <h2 class="slide-title">Das Vermächtnis des Vaters & <span class="gold">Die Aufräumaktion</span></h2>
        <div class="slide-subtitle">Der Spieler übernimmt das marode "Lucky Diamond" und startet seine Tycoon-Karriere.</div>
      </div>

      <div class="content-grid-2">
        <div>
          <div class="card" style="margin-bottom: 12px;">
            <div class="card-header"><span class="step-num">1</span> Ein letzter Brief vom Dad</div>
            <p>Das Casino hat seine besten Tage hinter sich. Staub, Müllbeutel, Scherben und Spinnweben bedecken den Boden. Als einziges Inventar steht noch ein <strong>rostiger Spielautomat</strong> in der Ecke.</p>
            <div style="margin-top: 6px;">
              <span class="pill pill-gold">Startkapital: $20.00</span>
              <span class="pill pill-blue">1x Rostiger Slot (betriebsbereit)</span>
            </div>
          </div>

          <div class="card">
            <div class="card-header"><span class="step-num">2</span> Casino putzen & Sauberkeits-Bonus</div>
            <p>Vor der großen Neueröffnung muss der Schandfleck glänzen:</p>
            <ul class="feature-list">
              <li><strong>10 Müllstellen aufsammeln:</strong> Jedes beseitigte Müllteil bringt $2.00 vergessenes Kleingeld (+$20.00).</li>
              <li><strong>CASINO BLITZSAUBER BONUS:</strong> Ist der letzte Dreck weg, belohnt das Spiel mit satten <strong>+$200.00 Sauberkeitsbonus</strong>!</li>
              <li><strong>Gesamtkapital für Vinnie:</strong> Exakt <strong>$240.00</strong> stehen für den ersten großen Einkauf bereit.</li>
            </ul>
          </div>
        </div>

        <div style="display: flex; flex-direction: column; gap: 12px;">
          <div class="img-frame" style="height: 175px;">
            <img src="{img_letter}" alt="Dads Brief">
            <div class="img-caption">Dads Abschiedsbrief: Die Schlüssel zum "Lucky Diamond"</div>
          </div>
          <div class="img-frame" style="height: 185px;">
            <img src="{img_casino_overview}" alt="Casino Übersicht">
            <div class="img-caption">Tag 1: Die Casino-Halle mit Zugang zur City Street</div>
          </div>
        </div>
      </div>
    </div>

    <div class="page-footer">
      <span class="game-title">ALL IN: GAMBLING TYCOON</span>
      <span>Kapitel 1: Story-Einstieg & Saubermachen</span>
      <span>Seite 2 / 7</span>
    </div>
  </div>

  <!-- ==================== SLIDE 3: SHOPPING BEI VINNIE & BOB ==================== -->
  <div class="page">
    <div>
      <div class="slide-header">
        <div class="slide-tag">Kapitel 2: Die Außenwelt</div>
        <h2 class="slide-title">Shopping auf der City Street: <span class="gold">Vinnie & Bob</span></h2>
        <div class="slide-subtitle">Draußen vor der Tür schlägt das Herz der Stadt: Händler, Handwerker und der eigene Wagen.</div>
      </div>

      <div class="content-grid-2">
        <div style="display: flex; flex-direction: column; gap: 12px;">
          <div class="img-frame" style="height: 185px;">
            <img src="{img_vinnie_shop}" alt="Vinnies Laden Katalog">
            <div class="img-caption">Vinnie's Casino Supplies: Getränkeautomat, Tische, Stühle & Deko</div>
          </div>
          <div class="img-frame" style="height: 185px;">
            <img src="{img_bob_expansion}" alt="Bobs Bauamt">
            <div class="img-caption">Bob's Bauamt: Raum-Erweiterungen (Ost-Flügel, VIP-Lounge)</div>
          </div>
        </div>

        <div>
          <div class="card" style="margin-bottom: 12px;">
            <div class="card-header">🏪 Vinnie's Gebrauchtwarenladen</div>
            <p>Hier deckt sich der Casino-Besitzer mit allem Nötigen ein. Das Starter-Budget von $240.00 ist <strong>perfekt abgestimmt</strong>:</p>
            <ul class="feature-list">
              <li><strong>Getränkeautomat ($105.00):</strong> Kühle Dosen & Drinks (bringt $3–$9 pro Gast).</li>
              <li><strong>Casino-Tisch ($45.00):</strong> Platz für Drink-Dosen und Entspannung.</li>
              <li><strong>3x Stühle / Barhocker ($75.00):</strong> 1x für den Automaten + 2x für den Tisch.</li>
              <li><strong>Mülleimer ($15.00):</strong> Hält den Raum sauber & liefert tägliches Trinkgeld.</li>
              <li><em>Summe: Exakt $240.00 – genau passend aufgebraucht!</em></li>
            </ul>
          </div>

          <div class="card">
            <div class="card-header">🏗️ Bob's Bauamt (Raum-Expansionen)</div>
            <p>Später im Spiel schaltet Bob neue Flügel und Upgrades frei:</p>
            <div style="margin-top: 4px;">
              <span class="pill pill-gold">Ost-Flügel (+Fläche für High-Tier Games)</span>
              <span class="pill pill-purple">VIP-Lounge (+Millionär-Gäste)</span>
              <span class="pill pill-green">Leuchtreklame & Security (+Gäste & -30% Kosten)</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div class="page-footer">
      <span class="game-title">ALL IN: GAMBLING TYCOON</span>
      <span>Kapitel 2: City Street & Ausstatter</span>
      <span>Seite 3 / 7</span>
    </div>
  </div>

  <!-- ==================== SLIDE 4: DER BAUMODUS ==================== -->
  <div class="page">
    <div>
      <div class="slide-header">
        <div class="slide-tag">Kapitel 3: Einrichtung</div>
        <h2 class="slide-title">Präziser Baumodus & <span class="gold">32x32 Raster-Snapping</span></h2>
        <div class="slide-subtitle">Vollständige Gestaltungsfreiheit: Platziere, verschiebe und organisiere deine Casino-Halle.</div>
      </div>

      <div class="content-grid-2">
        <div>
          <div class="card" style="margin-bottom: 12px;">
            <div class="card-header">📐 Intuitives Bau-System</div>
            <p>Über den Button <strong>[BAUMODUS]</strong> schaltet das Spiel in den architektonischen Editiermodus um:</p>
            <ul class="feature-list">
              <li><strong>Aktives Kachel-Overlay:</strong> Grün markiert gültige Freiflächen, Rot warnt vor Wänden oder besetzten Feldern.</li>
              <li><strong>32x32 Pixel Snapping:</strong> Alle Spielautomaten, Theken, Tische und Stühle rasten pixelgenau ein.</li>
              <li><strong>Möbel verschieben:</strong> Bereits platzierte Gegenstände können jederzeit angeklickt und umgestellt werden.</li>
              <li><strong>Einpacken ins Inventar:</strong> Mit Rechtsklick wandern Möbel zurück ins Inventar für spätere Umbauten.</li>
            </ul>
          </div>

          <div class="card">
            <div class="card-header">💡 Strategische Raumaufteilung</div>
            <p>Gute Planung zahlt sich aus: Stelle Spielautomaten in den Eingangsbereich, den neuen Getränkeautomaten ins Zentrum und Tische mit Stühlen in gemütliche Ecken, um den Gäste-Fluss optimal zu leiten.</p>
          </div>
        </div>

        <div>
          <div class="img-frame" style="height: 380px;">
            <img src="{img_casino_overview}" alt="Casino Layout">
            <div class="img-caption">Eingerichtetes Casino: Spieltisch, Stühle, Mülleimer & Getränkeautomat</div>
          </div>
        </div>
      </div>
    </div>

    <div class="page-footer">
      <span class="game-title">ALL IN: GAMBLING TYCOON</span>
      <span>Kapitel 3: Baumodus & Rasterplatzierung</span>
      <span>Seite 4 / 7</span>
    </div>
  </div>

  <!-- ==================== SLIDE 5: DIE CASINO-NACHT & GETRÄNKEAUTOMAT-QUEUE ==================== -->
  <div class="page">
    <div>
      <div class="slide-header">
        <div class="slide-tag">Kapitel 4: Simulation & Gameplay</div>
        <h2 class="slide-title">Die Casino-Nacht & <span class="gold">Lebendige NPC-Gäste</span></h2>
        <div class="slide-subtitle">Türen öffnen! 5–10 Minuten Echtzeit voller Action, Zockerlaune und Getränkeverkauf.</div>
      </div>

      <div class="content-grid-2">
        <div>
          <div class="img-frame" style="height: 380px;">
            <img src="{img_casino_overview}" alt="Nacht Casino Betrieb">
            <div class="img-caption">Lebendige Spielhalle: Gäste zocken, stehen an Automaten an & sitzen an Tischen</div>
          </div>
        </div>

        <div>
          <div class="card" style="margin-bottom: 12px;">
            <div class="card-header">🥤 Getränkeautomat mit echter Warteschlange</div>
            <p>Die NPCs verhalten sich natürlich und dynamisch nach klaren Regeln:</p>
            <ul class="feature-list">
              <li><strong>Einlass & Anstehen:</strong> Gäste reihen sich draußen vor der Tür auf und treten nacheinander ein.</li>
              <li><strong>Getränkeautomat-Queue:</strong> Steht bereits ein Gast vorne am Automaten, <em>stellen sich nachfolgende Gäste ordentlich in einer Schlange an</em> (5–10 Sek. Kaufzeit, <em>"Klick... Dose fällt! 🥤"</em>).</li>
              <li><strong>Nachrücken:</strong> Sobald der vordere Gast fertig ist, rückt der nächste Wartende automatisch vor!</li>
              <li><strong>Hinsetzen oder Stehend trinken:</strong> Gäste setzen sich mit Drinks an Tische/Stühle oder genießen ihre Dose gemütlich im Stehen.</li>
              <li><strong>Sperrstunde:</strong> Um Mitternacht verlassen alle Gäste geordnet die Halle über die Straße.</li>
            </ul>
          </div>

          <div class="card">
            <div class="card-header">🚶‍♂️ Barrierefreier Spieler</div>
            <p>Der Spieler hat <strong>keine blockierende Hitbox</strong> gegen NPCs – du kannst dich flüssig durch die Menge bewegen, ohne an Gästen hängenzubleiben.</p>
          </div>
        </div>
      </div>
    </div>

    <div class="page-footer">
      <span class="game-title">ALL IN: GAMBLING TYCOON</span>
      <span>Kapitel 4: Nachtzyklus & NPC-Verhalten</span>
      <span>Seite 5 / 7</span>
    </div>
  </div>

  <!-- ==================== SLIDE 6: DIE MINISPIELE ==================== -->
  <div class="page">
    <div>
      <div class="slide-header">
        <div class="slide-tag">Kapitel 5: Minispiele</div>
        <h2 class="slide-title">4 Vollwertige Minispiele: <span class="gold">Selbst Zocken & Gewinnen</span></h2>
        <div class="slide-subtitle">Jedes aufgestellte Spielgerät kann vom Spieler selbst interaktiv mit echtem Hebel gespielt werden!</div>
      </div>

      <div class="content-grid-2">
        <div>
          <div class="card" style="margin-bottom: 10px;">
            <div class="card-header">🎰 1. Slots (Rostig & Modern)</div>
            <p>3 rotierende Walzen mit Retro-Symbolen (Kirschen, Glocken, Diamanten, 7er). Authentischer interaktiver Hebel, Soundeffekte und Gewinnlinien. Rostige Slots haben charmante Gebrauchsspuren, moderne Varianten glänzen mit LEDs!</p>
          </div>

          <div class="card" style="margin-bottom: 10px;">
            <div class="card-header">🚀 2. Crash-Terminal (Aviation Multiplier)</div>
            <p>Die Rakete steigt mit rasant wachsendem Multiplikator (1.0x bis 50x+). Steige rechtzeitig vor dem Absturz aus, um den Jackpot einzustreichen!</p>
          </div>

          <div class="card">
            <div class="card-header">🎡 3. Roulette & ♠️ 4. Blackjack</div>
            <p><strong>Roulette:</strong> Setze auf Rot, Schwarz oder Zahlen mit physikalisch animierter Kugel.<br>
            <strong>Blackjack:</strong> Das klassische 21 gegen den Dealer mit Hit, Stand und Double-Down.</p>
          </div>
        </div>

        <div>
          <div class="img-frame" style="height: 380px;">
            <img src="{img_slot_minigame}" alt="Slot Minigame">
            <div class="img-caption">Interaktives Minispiel: Detailreiches Kabinett mit animiertem Hebel & Walzen</div>
          </div>
        </div>
      </div>
    </div>

    <div class="page-footer">
      <span class="game-title">ALL IN: GAMBLING TYCOON</span>
      <span>Kapitel 5: Minispiele & Interaktive Geräte</span>
      <span>Seite 6 / 7</span>
    </div>
  </div>

  <!-- ==================== SLIDE 7: FEIERABEND, WIRTSCHAFT & AUSBLICK ==================== -->
  <div class="page">
    <div>
      <div class="slide-header">
        <div class="slide-tag">Kapitel 6: Spielmodi & Langzeit-Motivation</div>
        <h2 class="slide-title">Zwei Spielmodi, Tagesbilanz & <span class="gold">Expansion</span></h2>
        <div class="slide-subtitle">Vom knappen Starttag zum profitablen Wirtschaftsimperium mit Raum-Upgrades.</div>
      </div>

      <div class="content-grid-2">
        <div>
          <div class="card" style="margin-bottom: 12px;">
            <div class="card-header">🚗 Heimfahrt & 📊 Transparente Bilanz</div>
            <p>Wenn die Sperrstunde schlägt, begibt sich der Spieler zu seinem Auto links auf der Straße:</p>
            <ul class="feature-list">
              <li><strong>Tagesabschluss:</strong> Interaktion mit dem Auto beendet den Tag und ruft den Bilanz-Report auf.</li>
              <li><strong>Einnahmen vs. Kosten:</strong> Übersicht über Slot-Gewinne, Drink-Umsatz und sparsame Fixkosten ($22.50 Upkeep in Nacht 1).</li>
              <li><strong>Reingewinn:</strong> Verbleibender Gewinn steht direkt am Folgetag für Expansionen zur Verfügung.</li>
            </ul>
          </div>

          <div class="card">
            <div class="card-header">🎮 Spielmodi für jeden Spielertyp</div>
            <p>Bereits im Hauptmenü wählt der Spieler seinen bevorzugten Spielstil:</p>
            <ul class="feature-list">
              <li><strong>Casino Tycoon:</strong> Die authentische Story-Kampagne mit schrittweisem Aufbau, Müll-Aufräumen, Vinnie-Einkauf und dynamischer Wirtschaft.</li>
              <li><strong>High Roller:</strong> Sofortige Zocker-Freiheit mit hohem Startkapital, allen Geräten und purem Casino-Nervenkitzel ohne Restriktionen!</li>
            </ul>
          </div>
        </div>

        <div>
          <div class="img-frame" style="height: 380px;">
            <img src="{img_main_menu}" alt="Hauptmenü Spielmodi">
            <div class="img-caption">Hauptmenü: Auswahl zwischen Casino Tycoon & High Roller Modus</div>
          </div>
        </div>
      </div>

      <!-- Summary banner -->
      <div class="card" style="background-color: #1a2234; border: 2px solid #facc15; margin-top: 10px;">
        <div style="display: flex; justify-content: space-between; align-items: center;">
          <div>
            <div style="font-size: 15px; font-weight: 800; color: #facc15;">Bereit zum Spielen & Präsentieren!</div>
            <div style="font-size: 12px; color: #cbd5e1; margin-top: 2px;">Vollständig automatisiert getestet (167/167 Unit-Tests bestanden), CrazyGames Web-Ready.</div>
          </div>
          <div>
            <span class="pill pill-green" style="font-size: 11px; padding: 6px 12px;">STATUS: PRODUCTION READY</span>
          </div>
        </div>
      </div>
    </div>

    <div class="page-footer">
      <span class="game-title">ALL IN: GAMBLING TYCOON</span>
      <span>Kapitel 6: Bilanz & Expansion</span>
      <span>Seite 7 / 7</span>
    </div>
  </div>

</body>
</html>
"""

html_path = os.path.join(project_dir, "export", "game_presentation.html")
pdf_path = os.path.join(project_dir, "export", "All_In_Gambling_Tycoon_Presentation.pdf")

with open(html_path, "w", encoding="utf-8") as f:
    f.write(html_content)

print(f"HTML presentation written: {html_path} ({len(html_content)} bytes)")

edge_exe = r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
cmd = [
    edge_exe,
    "--headless",
    "--disable-gpu",
    "--no-pdf-header-footer",
    f"--print-to-pdf={pdf_path}",
    html_path
]

print("Executing Edge Headless to generate PDF...")
res = subprocess.run(cmd, capture_output=True, text=True)
if os.path.exists(pdf_path):
    size_kb = os.path.getsize(pdf_path) / 1024.0
    print(f"SUCCESS: PDF created at {pdf_path} ({size_kb:.1f} KB)")
else:
    print(f"ERROR: PDF was not created. Output: {res.stdout} / {res.stderr}")
