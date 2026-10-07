extends Control

signal store_closed

@onready var close_btn: TextureButton = $CloseBtn
@onready var items_container: VBoxContainer = $Panel/ScrollContainer/ItemsContainer
@onready var cash_label: Label = $Panel/TopBar/CashLabel
@onready var notice_label: Label = $Panel/NoticeLabel

const CATALOG = [
	{
		"id": "east_wing",
		"type": "area",
		"name_de": "Ost-Flügel Anbau",
		"name_en": "East Wing Expansion",
		"desc_de": "Verdoppelt Spielfläche. Höhere Strom- & Gebäudekosten!",
		"desc_en": "Doubles casino floor space. Higher building & power upkeep!",
		"price_cents": 25000, # $250.00
		"icon": "res://assets/sprites/environment/modular_wall_h.png"
	},
	{
		"id": "vip_lounge",
		"type": "area",
		"name_de": "VIP-Lounge Ausbau",
		"name_en": "VIP Lounge Expansion",
		"desc_de": "Oberer VIP-Saal. Deutlich höhere Luxus-Betriebskosten!",
		"desc_en": "Upper VIP floor. Substantially higher luxury upkeep!",
		"price_cents": 80000, # $800.00
		"icon": "res://assets/sprites/props/blackjack_table.png"
	},
	{
		"id": "neon_sign",
		"type": "upgrade",
		"name_de": "Leuchtreklame",
		"name_en": "Neon Sign",
		"desc_de": "Lockt jede Nacht +5 extra Gäste an.",
		"desc_en": "Attracts +5 extra guests each night.",
		"price_cents": 15000, # $150.00
		"icon": "res://assets/sprites/props/flickering_sign.png"
	},
	{
		"id": "security",
		"type": "upgrade",
		"name_de": "Sicherheits-Wache",
		"name_en": "Security Guard",
		"desc_de": "Senkt die nächtlichen Betriebskosten um 30%.",
		"desc_en": "Reduces nightly upkeep costs by 30%.",
		"price_cents": 20000, # $200.00
		"icon": "res://assets/sprites/furniture/atm_machine.png"
	}
]

var store_font = preload("res://assets/fonts/Silkscreen-Regular.ttf")

func _ready() -> void:
	close_btn.pressed.connect(_on_close_pressed)
	GameManager.cash_changed.connect(_on_cash_changed)
	_update_cash_display()
	_populate_store()
	var is_de = (GameManager.current_lang == "de")
	notice_label.text = "Bob's Bauamt: Schalte neue Bereiche & Upgrades frei." if is_de else "Bob's Construction: Unlock new wings & upgrades."

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
		
		var is_purchased = false
		if item["type"] == "area":
			is_purchased = GameManager.is_area_unlocked(item["id"])
		else:
			is_purchased = GameManager.has_upgrade(item["id"])
			
		var status_lbl = Label.new()
		status_lbl.add_theme_font_override("font", store_font)
		status_lbl.add_theme_font_size_override("font_size", 10)
		if is_purchased:
			status_lbl.text = "STATUS: FREIGESCHALTET" if is_de else "STATUS: UNLOCKED"
			status_lbl.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5))
		else:
			status_lbl.text = "STATUS: NICHT ERWORBEN" if is_de else "STATUS: NOT PURCHASED"
			status_lbl.add_theme_color_override("font_color", Color(0.9, 0.7, 0.3))
		vbox.add_child(status_lbl)
		h.add_child(vbox)
		
		# Buy Button
		var buy_btn = Button.new()
		buy_btn.custom_minimum_size = Vector2(140, 36)
		buy_btn.add_theme_font_override("font", store_font)
		buy_btn.add_theme_font_size_override("font_size", 11)
		
		if is_purchased:
			buy_btn.text = "BEREITS GEKAUFT" if is_de else "PURCHASED"
			buy_btn.disabled = true
			buy_btn.modulate = Color(0.6, 0.6, 0.6)
		else:
			var has_enough = (GameManager.cash_cents >= item["price_cents"])
			if has_enough:
				buy_btn.text = ("KAUFEN ($%.2f)" if is_de else "BUY ($%.2f)") % (item["price_cents"] / 100.0)
				buy_btn.modulate = Color(1.0, 1.0, 1.0)
			else:
				buy_btn.text = "$%.2f (%s)" % [(item["price_cents"] / 100.0), "FEHLT" if is_de else "LOCKED"]
				buy_btn.modulate = Color(1.0, 0.65, 0.65)
				
			var item_id = item["id"]
			var item_type = item["type"]
			var item_price = item["price_cents"]
			var item_name = item["name_de"] if is_de else item["name_en"]
			buy_btn.pressed.connect(func(): _buy_upgrade(item_id, item_type, item_price, item_name))
			
		h.add_child(buy_btn)
		items_container.add_child(row)

func _buy_upgrade(item_id: String, item_type: String, price_cents: int, item_name: String) -> void:
	var is_de = (GameManager.current_lang == "de")
	if GameManager.cash_cents >= price_cents:
		GameManager.add_cash(-price_cents)
		if item_type == "area":
			# Spawn Renovation Screen
			var renov_scene = preload("res://scenes/ui/renovation_screen.tscn")
			var renov = renov_scene.instantiate()
			var coord = get_tree().get_first_node_in_group("main_coordinator")
			if coord and coord.has_node("UILayer"):
				coord.get_node("UILayer").add_child(renov)
			else:
				get_parent().add_child(renov)
			
			renov.start_renovation(item_id)
			renov.renovation_completed.connect(func():
				GameManager.unlock_area(item_id)
				GameManager.save_game()
			)
			_on_close_pressed()
			return
		else:
			GameManager.purchase_upgrade(item_id)
			GameManager.save_game()
			
			if SoundManager:
				SoundManager.play_sfx("coin_win")
				
			notice_label.text = ("Erfolgreich gebaut: %s ist jetzt freigeschaltet!" if is_de else "Successfully built: %s is now unlocked!") % item_name
			notice_label.modulate = Color(0.3, 1.0, 0.5)
			_populate_store()
	else:
		var missing_cents = price_cents - GameManager.cash_cents
		if is_de:
			notice_label.text = "Zu wenig Geld! Du hast $%.2f, benötigst aber $%.2f (fehlen: $%.2f)!" % [
				GameManager.cash_cents / 100.0,
				price_cents / 100.0,
				missing_cents / 100.0
			]
		else:
			notice_label.text = "Not enough cash! You have $%.2f, need $%.2f (missing: $%.2f)!" % [
				GameManager.cash_cents / 100.0,
				price_cents / 100.0,
				missing_cents / 100.0
			]
		notice_label.modulate = Color(1.0, 0.35, 0.35)
		if SoundManager:
			SoundManager.play_sfx("lever_pull")
			
		var tw = create_tween()
		var orig_x = notice_label.position.x
		tw.tween_property(notice_label, "position:x", orig_x + 6, 0.04)
		tw.tween_property(notice_label, "position:x", orig_x - 6, 0.04)
		tw.tween_property(notice_label, "position:x", orig_x, 0.04)

func _on_close_pressed() -> void:
	if SoundManager:
		SoundManager.play_sfx("lever_release")
	store_closed.emit()
	queue_free()
