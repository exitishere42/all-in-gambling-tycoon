extends Control

signal letter_closed

@onready var enter_btn: Button = $Panel/EnterBtn
@onready var title_lbl: Label = $Panel.get_node_or_null("Title")
@onready var text_lbl: Label = $Panel/LetterText

func _ready() -> void:
	if GameManager.current_lang != "de":
		if title_lbl:
			title_lbl.text = "YOUR FATHER'S LEGACY"
		text_lbl.text = "My son...\n\nIf you're reading this, I've played my final hand.\nThe 'Lucky Diamond' is yours now. It has seen better days — covered in dust and trash.\n\n1. Clean up the mess: Clear the trash to find some spare cash!\n2. Head outside to the street to visit Vinnie & Bob for machines, furniture & upgrades.\n3. Open doors each night, entertain guests and bring this casino back to glory!\n\nGo All-In!\n— Dad"
		enter_btn.text = "TAKE KEYS & START"
	else:
		if title_lbl:
			title_lbl.text = "DAS VERMÄCHTNIS DEINES VATERS"
		text_lbl.text = "Mein Sohn...\n\nwenn du das hier liest, habe ich mein letztes Blatt gespielt.\nDas 'Lucky Diamond' gehört jetzt dir. Es hat seine besten Tage hinter sich – voller Staub, Müll und Schulden.\n\n1. Schnapp dir den Besen: Räum den Dreck weg (du findest sicher etwas vergessenes Kleingeld!).\n2. Geh nach draußen in die Stadt zu Vinnie & Bob für Automaten, Möbel & Ausbauten.\n3. Öffne abends die Türen, bediene Gäste und führe das Casino wieder an die Spitze!\n\nGeh All-In!\n— Dein Dad"
		enter_btn.text = "SCHLÜSSEL NEHMEN & STARTEN"
		
	enter_btn.pressed.connect(_on_enter_pressed)
	if SoundManager:
		SoundManager.play_sfx("lever_pull")

func _on_enter_pressed() -> void:
	GameManager.has_seen_dad_letter = true
	GameManager.save_game()
	if SoundManager:
		SoundManager.play_sfx("lever_release")
	letter_closed.emit()
	queue_free()
