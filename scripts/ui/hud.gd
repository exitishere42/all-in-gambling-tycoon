extends Control

@onready var cash_label: Label = $TopRightPill/HBoxContainer/CashBox/CashLabel
@onready var mode_label: Label = $TopRightPill/HBoxContainer/ModeLabel
@onready var bottles_label: Label = $TopRightPill/HBoxContainer/BottleBox/BottlesLabel
@onready var cheat_button: Button = $TopRightPill/HBoxContainer/CheatButton
@onready var menu_button: Button = $TopLeftContainer/MenuButton
@onready var build_button: Button = $TopLeftContainer/BuildButton
@onready var open_casino_btn: Button = $TopLeftContainer/OpenCasinoButton
@onready var bankrupt_hint: Label = $BankruptHint
@onready var touch_controls: Control = $TouchControls
@onready var build_system_ui: Control = $BuildSystemUI
@onready var floating_banner: Label = $FloatingBanner
@onready var objective_label: Label = $BottomInfoBar/ObjectiveLabel
@onready var controls_label: Label = $BottomInfoBar/ControlsLabel

func _ready() -> void:
	GameManager.cash_changed.connect(_on_cash_changed)
	GameManager.game_mode_changed.connect(_on_mode_changed)
	GameManager.bottles_collected_changed.connect(_on_bottles_changed)
	
	# Show touch controls on mobile or touch-enabled devices
	touch_controls.visible = _is_touch_screen() and (GameManager.active_minigame == "")
	
	cheat_button.visible = GameManager.cheat_mode_enabled
	cheat_button.pressed.connect(_on_cheat_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	
	# Tycoon mode specific buttons
	var is_tycoon = (GameManager.game_mode == "tycoon")
	build_button.visible = is_tycoon
	open_casino_btn.visible = is_tycoon
	build_button.pressed.connect(_on_build_pressed)
	open_casino_btn.pressed.connect(_on_open_casino_pressed)
	
	build_system_ui.build_mode_toggled.connect(_on_build_mode_toggled)
	build_system_ui.item_selected.connect(_on_build_item_selected)
	
	GameManager.night_time_updated.connect(_on_night_time_updated)
	GameManager.night_closed_signal.connect(_on_night_closed)
	
	_update_hud()

func _on_build_mode_toggled(is_active: bool) -> void:
	var world = get_tree().current_scene.get_node_or_null("CasinoWorld")
	if not world: world = get_tree().get_first_node_in_group("casino_world")
	if world and world.has_method("set_build_mode"):
		world.set_build_mode(is_active, build_system_ui.selected_item_type)

func _on_build_item_selected(item_id: String) -> void:
	var world = get_tree().current_scene.get_node_or_null("CasinoWorld")
	if not world: world = get_tree().get_first_node_in_group("casino_world")
	if world and world.has_method("set_build_item"):
		world.set_build_item(item_id)

func _is_touch_screen() -> bool:
	if OS.has_feature("mobile") or OS.has_feature("android") or OS.has_feature("ios"):
		return true
	if OS.has_feature("web"):
		var is_mobile = JavaScriptBridge.eval("Boolean(/Android|iPhone|iPad|iPod|webOS|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent))")
		if is_mobile:
			return true
	return false

func _process(_delta: float) -> void:
	# Hide joystick and interact button while playing a minigame so they don't overlap
	touch_controls.visible = _is_touch_screen() and (GameManager.active_minigame == "")
	_update_objective_label()

func _on_build_pressed() -> void:
	build_system_ui.toggle_build_mode()

func _on_open_casino_pressed() -> void:
	var world = get_tree().current_scene.get_node_or_null("CasinoWorld")
	if not world:
		world = get_tree().get_first_node_in_group("casino_world")
	if world and not GameManager.casino_open and not GameManager.night_closed:
		world.start_business_night()
		open_casino_btn.disabled = true
		var is_de = (GameManager.current_lang == "de")
		open_casino_btn.text = "22:00 UHR" if is_de else "10:00 PM"
		show_floating_banner("CASINO GEÖFFNET! GÄSTE STRÖMEN HEREIN!" if is_de else "CASINO OPENED! GUESTS ARE FLOCKING IN!")

var moving_item_orig_pos: Vector2 = Vector2.ZERO
var moving_item_type: String = ""

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_B and GameManager.game_mode == "tycoon":
			_on_build_pressed()
			
	if not build_system_ui.is_building:
		return
		
	var world = get_tree().current_scene.get_node_or_null("CasinoWorld")
	if not world:
		world = get_tree().get_first_node_in_group("casino_world")
	var cam = get_viewport().get_camera_2d()
	var m_pos = cam.get_global_mouse_position() if cam else Vector2.ZERO
	var is_de = (GameManager.current_lang == "de")

	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			# 1. If currently moving an item, place it at the new target position
			if moving_item_type != "" and moving_item_orig_pos != Vector2.ZERO:
				if world and world.move_furniture(moving_item_orig_pos, m_pos):
					show_floating_banner("Möbelstück verschoben!" if is_de else "Furniture moved!")
					moving_item_type = ""
					moving_item_orig_pos = Vector2.ZERO
					if world.build_grid_overlay:
						world.build_grid_overlay.clear_moving_item()
				else:
					if SoundManager: SoundManager.play_sfx("lever_pull")
				get_viewport().set_input_as_handled()
				return
				
			# 2. If an inventory item is selected from the toolbar, place a new one
			if build_system_ui.selected_item_type != "":
				if GameManager.inventory.get(build_system_ui.selected_item_type, 0) <= 0:
					build_system_ui.selected_item_type = ""
					if world and world.has_method("set_build_item"): world.set_build_item("")
					build_system_ui._refresh_toolbar()
					return
					
				if world and world.place_new_furniture(build_system_ui.selected_item_type, m_pos):
					if GameManager.inventory.get(build_system_ui.selected_item_type, 0) <= 0:
						build_system_ui.selected_item_type = ""
						if world.has_method("set_build_item"):
							world.set_build_item("")
					build_system_ui._refresh_toolbar()
				get_viewport().set_input_as_handled()
				return

			# 3. Otherwise (no item selected, not moving yet): click an existing item to start moving it
			if world and world.has_method("get_furniture_at"):
				var target_item = world.get_furniture_at(m_pos)
				if not target_item.is_empty():
					moving_item_type = target_item.get("type", "")
					var p = target_item.get("pos", Vector2.ZERO)
					if p is Vector2:
						moving_item_orig_pos = p
					elif p is String:
						var s: String = p.strip_edges().trim_prefix("(").trim_suffix(")")
						var parts := s.split(",")
						if parts.size() >= 2:
							moving_item_orig_pos = Vector2(parts[0].to_float(), parts[1].to_float())
					if world.build_grid_overlay:
						world.build_grid_overlay.set_moving_item(moving_item_type, moving_item_orig_pos)
					if SoundManager: SoundManager.play_sfx("chip_bet")
					get_viewport().set_input_as_handled()
					return

		elif event.button_index == MOUSE_BUTTON_RIGHT:
			# 1. Cancel moving mode if currently moving
			if moving_item_type != "":
				moving_item_type = ""
				moving_item_orig_pos = Vector2.ZERO
				if world and world.build_grid_overlay:
					world.build_grid_overlay.clear_moving_item()
				if SoundManager: SoundManager.play_sfx("lever_pull")
				get_viewport().set_input_as_handled()
				return
				
			# 2. Deselect toolbar item if one is selected
			if build_system_ui.selected_item_type != "":
				build_system_ui.selected_item_type = ""
				if world and world.has_method("set_build_item"):
					world.set_build_item("")
				build_system_ui.mode_label.text = "BAUMODUS: Wähle ein Möbelstück oder klicke auf ein platziertes Objekt zum Verschieben." if is_de else "BUILD MODE: Select furniture or click placed item to move."
				get_viewport().set_input_as_handled()
				return

			# 3. Right-click on existing placed item: pack it back into inventory
			if world and world.has_method("get_furniture_at"):
				var target_item = world.get_furniture_at(m_pos)
				if not target_item.is_empty():
					var p = target_item.get("pos", Vector2.ZERO)
					var p_vec: Vector2 = Vector2.ZERO
					if p is Vector2:
						p_vec = p
					elif p is String:
						var s: String = p.strip_edges().trim_prefix("(").trim_suffix(")")
						var parts := s.split(",")
						if parts.size() >= 2:
							p_vec = Vector2(parts[0].to_float(), parts[1].to_float())
					var removed_type = world.remove_furniture_to_inventory(p_vec)
					if removed_type != "":
						show_floating_banner("Möbelstück ins Inventar gepackt!" if is_de else "Furniture packed into inventory!")
						build_system_ui._refresh_toolbar()
					get_viewport().set_input_as_handled()
					return

func show_floating_banner(msg: String) -> void:
	floating_banner.text = msg
	floating_banner.visible = true
	floating_banner.modulate.a = 1.0
	var tween = create_tween()
	tween.tween_interval(2.5)
	tween.tween_property(floating_banner, "modulate:a", 0.0, 0.5)
	await tween.finished
	floating_banner.visible = false

func _on_menu_pressed() -> void:
	GameManager.save_game()
	if SoundManager:
		SoundManager.play_sfx("lever_release")
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

func _on_cheat_pressed() -> void:
	GameManager.add_cash(10000000) # +$100,000.00 (in cents)
	if SoundManager:
		SoundManager.play_sfx("jackpot")

func _update_hud() -> void:
	var is_de = (GameManager.current_lang == "de")
	menu_button.text = GameManager.tr_text("menu")
	cash_label.text = GameManager.format_cash()
	mode_label.visible = GameManager.is_hardcore
	bottles_label.text = str(GameManager.total_bottles_collected)
	build_button.text = "BAUEN [B]" if is_de else "BUILD [B]"
	if not GameManager.casino_open and not GameManager.night_closed:
		open_casino_btn.disabled = false
		open_casino_btn.text = "CASINO ÖFFNEN" if is_de else "OPEN CASINO"
	elif GameManager.night_closed:
		open_casino_btn.disabled = true
		open_casino_btn.text = "NACHT BEENDET" if is_de else "NIGHT ENDED"
	controls_label.text = "[WASD / ZQSD] Bewegen | [E] Interaktion | [B] Bauen" if is_de else "[WASD / ZQSD] Move | [E] Interact | [B] Build"
	_check_bankrupt_hint()
	_update_objective_label()

func _on_night_closed() -> void:
	var is_de = (GameManager.current_lang == "de")
	open_casino_btn.disabled = true
	open_casino_btn.text = "NACHT BEENDET" if is_de else "NIGHT ENDED"
	_update_objective_label()

func _on_night_time_updated(elapsed: float, total: float) -> void:
	if GameManager.casino_open and not GameManager.night_closed:
		var is_de = (GameManager.current_lang == "de")
		var r = clamp(elapsed / total, 0.0, 1.0)
		var total_mins = int(r * 360)
		var hour = (22 + (total_mins / 60)) % 24
		var minute = total_mins % 60
		open_casino_btn.text = ("%02d:%02d UHR" if is_de else "%02d:%02d") % [hour, minute]

func _update_objective_label() -> void:
	if not objective_label: return
	var is_de = (GameManager.current_lang == "de")
	if GameManager.game_mode == "tycoon":
		if not GameManager.casino_cleaned:
			objective_label.text = "Ziel: Räume das Casino sauber" if is_de else "Goal: Clean up casino trash"
		elif GameManager.placed_furniture.size() <= 1:
			objective_label.text = "Ziel: Besuche Vinnie & Bob draußen" if is_de else "Goal: Visit Vinnie & Bob outside"
		elif not GameManager.casino_open and not GameManager.night_closed:
			objective_label.text = "Ziel: Öffne das Casino & mache Gewinn!" if is_de else "Goal: Open casino & earn profit!"
		elif GameManager.casino_open:
			var r = clamp(GameManager.night_elapsed / GameManager.NIGHT_DURATION, 0.0, 1.0)
			var total_mins = int(r * 360)
			var hour = (22 + (total_mins / 60)) % 24
			var minute = total_mins % 60
			objective_label.text = ("Nacht %d (%02d:%02d Uhr) - Gäste spielen & trinken" if is_de else "Night %d (%02d:%02d) - Guests playing & drinking") % [GameManager.casino_day, hour, minute]
		elif GameManager.night_closed:
			objective_label.text = "Feierabend! Gehe zum Auto links zum Tag beenden" if is_de else "Closing time! Go to your car on the left to end day"
	else:
		objective_label.text = "Ziel: Gewinne den Jackpot!" if is_de else "Goal: Hit the jackpot at tables!"

func _on_cash_changed(_new_cents: int, _delta: int) -> void:
	cash_label.text = GameManager.format_cash()
	_check_bankrupt_hint()

func _on_mode_changed(is_hardcore: bool) -> void:
	mode_label.visible = is_hardcore

func _on_bottles_changed(count: int) -> void:
	bottles_label.text = str(count)

func _check_bankrupt_hint() -> void:
	var is_de = (GameManager.current_lang == "de")
	bankrupt_hint.text = "Du bist pleite! Sammle leere Flaschen von den Tischen ($0.25 Pfand)!" if is_de else "Out of cash! Collect empty bottles from tables ($0.25 each)!"
	if not GameManager.is_hardcore and GameManager.cash_cents <= 0:
		bankrupt_hint.visible = true
	else:
		bankrupt_hint.visible = false
