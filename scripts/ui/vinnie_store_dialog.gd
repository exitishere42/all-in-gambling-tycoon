extends Control

signal store_closed

@onready var close_btn: TextureButton = $CloseBtn
@onready var items_container: VBoxContainer = $Panel/ScrollContainer/ItemsContainer
@onready var cash_label: Label = $Panel/TopBar/CashLabel
@onready var notice_label: Label = $Panel/NoticeLabel

const CATALOG = [
	{
		"id": "trash_bin",
		"name_de": "Mülleimer",
		"name_en": "Trash Bin",
		"desc_de": "Hält sauber. Täglich +$0.50 Trinkgeld.",
		"desc_en": "Keeps tidy. Daily +$0.50 tips.",
		"price_cents": 1500, # $15.00
		"icon": "res://assets/sprites/furniture/trash_bin.png"
	},
	{
		"id": "bar_stool",
		"name_de": "Barhocker",
		"name_en": "Bar Stool",
		"desc_de": "Sitzplatz für durstige Casino-Gäste.",
		"desc_en": "Seating for thirsty casino guests.",
		"price_cents": 2500, # $25.00
		"icon": "res://assets/sprites/furniture/bar_stool.png"
	},
	{
		"id": "table",
		"name_de": "Casino-Tisch",
		"name_en": "Casino Table",
		"desc_de": "Gäste stellen Bar-Drinks ab (Müll zum Aufräumen).",
		"desc_en": "Guests place bar drinks here (trash to clean).",
		"price_cents": 4500, # $45.00
		"icon": "res://assets/sprites/environment/table.png"
	},
	{
		"id": "plant",
		"name_de": "Casino-Palme",
		"name_en": "Palm Plant",
		"desc_de": "Steigert Ambiente und Gäste-Laune.",
		"desc_en": "Boosts atmosphere & mood.",
		"price_cents": 4000, # $40.00
		"icon": "res://assets/sprites/furniture/potted_plant.png"
	},
	{
		"id": "bar_counter",
		"name_de": "Getränkeautomat",
		"name_en": "Drink Vending Machine",
		"desc_de": "Kühle Dosen & Drinks. Bringt $3 bis $9 pro Gast.",
		"desc_en": "Chilled cans & sodas. Earns $3 to $9 per guest.",
		"price_cents": 10500, # $105.00
		"icon": "res://assets/sprites/furniture/bar_counter.png"
	},
	{
		"id": "slot_modern",
		"name_de": "Moderne Slots",
		"name_en": "Modern Slots",
		"desc_de": "LED-Automat. Beliebt bei Zockern.",
		"desc_en": "LED machine. Attracts gamblers.",
		"price_cents": 35000, # $350.00
		"icon": "res://assets/sprites/raw_slots/Slot Machine/slot-machine1.png"
	},
	{
		"id": "atm",
		"name_de": "Geldautomat",
		"name_en": "ATM Machine",
		"desc_de": "Gäste heben neues Spielgeld ab.",
		"desc_en": "Guests withdraw fresh cash.",
		"price_cents": 50000, # $500.00
		"icon": "res://assets/sprites/furniture/atm_machine.png"
	},
	{
		"id": "crash",
		"name_de": "Crash-Terminal",
		"name_en": "Crash Terminal",
		"desc_de": "Schnelle Runden, hohes Risiko.",
		"desc_en": "Fast rounds, high multiplier.",
		"price_cents": 100000, # $1,000.00
		"icon": "res://assets/sprites/environment/crash_cabinet.png"
	},
	{
		"id": "roulette",
		"name_de": "Roulette-Tisch",
		"name_en": "Roulette Table",
		"desc_de": "Klassiker für wohlhabende Gäste.",
		"desc_en": "Classic wheel for wealthy guests.",
		"price_cents": 250000, # $2,500.00
		"icon": "res://assets/sprites/props/roulette_table.png"
	},
	{
		"id": "blackjack",
		"name_de": "Blackjack-Tisch",
		"name_en": "Blackjack Table",
		"desc_de": "Top-Tisch für echte High-Roller.",
		"desc_en": "Elite table for high-rollers.",
		"price_cents": 500000, # $5,000.00
		"icon": "res://assets/sprites/props/blackjack_table.png"
	}
]

var store_font = preload("res://assets/fonts/Silkscreen-Regular.ttf")

func _ready() -> void:
	close_btn.pressed.connect(_on_close_pressed)
	GameManager.cash_changed.connect(_on_cash_changed)
	_update_cash_display()
	_populate_store()
	var is_de = (GameManager.current_lang == "de")
	notice_label.text = "Vinnie's Laden: Kaufe Ausstattung für dein Casino." if is_de else "Vinnie's Shop: Buy games and furniture."

func _update_cash_display() -> void:
	var is_de = (GameManager.current_lang == "de")
	cash_label.text = ("Geld: $%.2f" if is_de else "Cash: $%.2f") % (GameManager.cash_cents / 100.0)

func _on_cash_changed(_new_val: int, _delta: int) -> void:
	_update_cash_display()
	_populate_store()

func _populate_store() -> void:
	for c in items_container.get_children():
		c.queue_free()
		
	var is_de = (GameManager.current_lang == "de")
	for item in CATALOG:
		var row = PanelContainer.new()
		var h = HBoxContainer.new()
		h.set("theme_override_constants/separation", 12)
		row.add_child(h)
		
		# Icon
		var icon_rect = TextureRect.new()
		icon_rect.custom_minimum_size = Vector2(40, 40)
		icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		if ResourceLoader.exists(item["icon"]):
			icon_rect.texture = load(item["icon"])
		h.add_child(icon_rect)
		
		# Text box
		var vbox = VBoxContainer.new()
		vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var title = Label.new()
		title.text = item["name_de"] if is_de else item["name_en"]
		title.add_theme_font_override("font", store_font)
		title.add_theme_font_size_override("font_size", 12)
		title.add_theme_color_override("font_color", Color(1, 0.88, 0.35))
		vbox.add_child(title)
		
		var desc = Label.new()
		desc.text = item["desc_de"] if is_de else item["desc_en"]
		desc.add_theme_font_override("font", store_font)
		desc.add_theme_font_size_override("font_size", 10)
		desc.add_theme_color_override("font_color", Color(0.82, 0.86, 0.94))
		vbox.add_child(desc)
		
		var owned_count = GameManager.inventory.get(item["id"], 0)
		var owned_lbl = Label.new()
		owned_lbl.text = ("Besitz: %d" if is_de else "Owned: %d") % owned_count
		owned_lbl.add_theme_font_override("font", store_font)
		owned_lbl.add_theme_font_size_override("font_size", 10)
		owned_lbl.add_theme_color_override("font_color", Color(0.4, 0.95, 0.6))
		vbox.add_child(owned_lbl)
		h.add_child(vbox)
		
		# Buy Button (ALWAYS CLICKABLE with immediate interactive feedback)
		var buy_btn = Button.new()
		buy_btn.custom_minimum_size = Vector2(130, 36)
		buy_btn.add_theme_font_override("font", store_font)
		buy_btn.add_theme_font_size_override("font_size", 11)
		
		var has_enough = (GameManager.cash_cents >= item["price_cents"])
		if has_enough:
			buy_btn.text = ("KAUFEN ($%.2f)" if is_de else "BUY ($%.2f)") % (item["price_cents"] / 100.0)
			buy_btn.modulate = Color(1.0, 1.0, 1.0)
		else:
			buy_btn.text = "$%.2f (%s)" % [(item["price_cents"] / 100.0), "FEHLT" if is_de else "LOCKED"]
			buy_btn.modulate = Color(1.0, 0.65, 0.65)
			
		var item_id = item["id"]
		var item_price = item["price_cents"]
		var item_name = item["name_de"] if is_de else item["name_en"]
		buy_btn.pressed.connect(func(): _buy_item(item_id, item_price, item_name))
		h.add_child(buy_btn)
		
		items_container.add_child(row)

func _buy_item(item_id: String, price_cents: int, item_name: String) -> void:
	var is_de = (GameManager.current_lang == "de")
	if GameManager.cash_cents >= price_cents:
		GameManager.add_cash(-price_cents)
		GameManager.inventory[item_id] = GameManager.inventory.get(item_id, 0) + 1
		GameManager.save_game()
		
		if SoundManager:
			SoundManager.play_sfx("coin_win")
			
		notice_label.text = ("Gekauft! 1x %s im Inventar. Drücke [B] zum Platzieren!" if is_de else "Purchased! 1x %s added. Press [B] to place!") % item_name
		notice_label.modulate = Color(0.3, 1.0, 0.5)
		_populate_store()
	else:
		var missing_cents = price_cents - GameManager.cash_cents
		if is_de:
			notice_label.text = "Zu wenig Geld! Du hast $%.2f, benötigst $%.2f (es fehlen $%.2f)!" % [
				GameManager.cash_cents / 100.0,
				price_cents / 100.0,
				missing_cents / 100.0
			]
		else:
			notice_label.text = "Not enough cash! You have $%.2f, need $%.2f (missing $%.2f)!" % [
				GameManager.cash_cents / 100.0,
				price_cents / 100.0,
				missing_cents / 100.0
			]
		notice_label.modulate = Color(1.0, 0.35, 0.35)
		if SoundManager:
			SoundManager.play_sfx("lever_pull")
			
		# Gentle shake animation on notice label
		var tw = create_tween()
		var orig_x = notice_label.position.x
		tw.tween_property(notice_label, "position:x", orig_x + 6, 0.04)
		tw.tween_property(notice_label, "position:x", orig_x - 6, 0.04)
		tw.tween_property(notice_label, "position:x", orig_x + 3, 0.04)
		tw.tween_property(notice_label, "position:x", orig_x, 0.04)

func _on_close_pressed() -> void:
	if SoundManager:
		SoundManager.play_sfx("lever_release")
	store_closed.emit()
	queue_free()
