extends Control

signal next_day_pressed

@onready var day_lbl: Label = $Panel/VBoxContainer/DayLabel
@onready var guests_lbl: Label = $Panel/VBoxContainer/GuestsRow/Val
@onready var slots_lbl: Label = $Panel/VBoxContainer/SlotsRow/Val
@onready var bar_lbl: Label = $Panel/VBoxContainer/BarRow/Val
@onready var upkeep_lbl: Label = $Panel/VBoxContainer/UpkeepRow/Val
@onready var net_lbl: Label = $Panel/VBoxContainer/NetRow/Val
@onready var rating_lbl: Label = $Panel/VBoxContainer/RatingRow/Val
@onready var continue_btn: Button = $Panel/ContinueBtn

func setup(day_num: int, guests: int, games_income: int, bar_income: int, upkeep: int) -> void:
	var net = games_income + bar_income - upkeep
	var is_de = (GameManager.current_lang == "de")
	
	day_lbl.text = ("ABRECHNUNG: TAG %d" if is_de else "SUMMARY: DAY %d") % day_num
	guests_lbl.text = ("%d Besucher" if is_de else "%d Guests") % guests
	slots_lbl.text = "+$%.2f" % (games_income / 100.0)
	bar_lbl.text = "+$%.2f" % (bar_income / 100.0)
	upkeep_lbl.text = "-$%.2f" % (upkeep / 100.0)
	net_lbl.text = "%s$%.2f" % ["+" if net >= 0 else "", net / 100.0]
	
	# Localize row header labels
	$Panel/VBoxContainer/GuestsRow/Label.text = "Gäste im Casino:" if is_de else "Casino Guests:"
	$Panel/VBoxContainer/SlotsRow/Label.text = "Spiele-Hausgewinn:" if is_de else "Gaming Profit:"
	$Panel/VBoxContainer/BarRow/Label.text = "Bar-Getränkeumsatz:" if is_de else "Bar Revenue:"
	$Panel/VBoxContainer/UpkeepRow/Label.text = "Strom & Betriebskosten:" if is_de else "Power & Upkeep:"
	$Panel/VBoxContainer/NetRow/Label.text = "Tages-Reingewinn:" if is_de else "Daily Net Profit:"
	$Panel/VBoxContainer/RatingRow/Label.text = "Casino-Bewertung:" if is_de else "Casino Rating:"
	continue_btn.text = "NÄCHSTER TAG" if is_de else "NEXT DAY"
	if net >= 0:
		net_lbl.modulate = Color(0.3, 1.0, 0.5)
	else:
		net_lbl.modulate = Color(1.0, 0.3, 0.3)
		
	# Star Rating based on furniture count and net profit
	var stars = "★☆☆☆☆"
	if net > 50000: stars = "★★★★★"
	elif net > 25000: stars = "★★★★☆"
	elif net > 10000: stars = "★★★☆☆"
	elif net > 2000: stars = "★★☆☆☆"
	rating_lbl.text = stars
	
	GameManager.add_cash(net)
	GameManager.casino_day += 1
	GameManager.casino_open = false
	GameManager.night_closed = false
	GameManager.night_elapsed = 0.0
	GameManager.save_game()
	
	if SoundManager:
		if net >= 0: SoundManager.play_sfx("jackpot")
		else: SoundManager.play_sfx("lever_release")

func _ready() -> void:
	continue_btn.pressed.connect(_on_continue)

func _on_continue() -> void:
	if SoundManager: SoundManager.play_sfx("lever_release")
	next_day_pressed.emit()
	var coord = get_tree().get_first_node_in_group("main_coordinator")
	if coord and coord.hud:
		coord.hud._update_hud()
	queue_free()
