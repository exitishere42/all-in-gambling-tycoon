extends Node

# Signal definitions
signal cash_changed(new_cents: int, delta_cents: int)
signal machine_unlocked(machine_id: String)
signal game_over_triggered(reason: String)
signal game_mode_changed(is_hardcore: bool)
signal bottles_collected_changed(count: int)
signal area_unlocked(area_id: String)
signal upgrade_purchased(upgrade_id: String)

# Machine definitions and unlock costs in cents
const MACHINE_SLOTS := "slots"
const MACHINE_CRASH := "crash"
const MACHINE_ROULETTE := "roulette"
const MACHINE_BLACKJACK := "blackjack"

const UNLOCK_COSTS := {
	MACHINE_SLOTS: 0,
	MACHINE_CRASH: 10000,     # $100.00
	MACHINE_ROULETTE: 100000, # $1,000.00
	MACHINE_BLACKJACK: 250000 # $2,500.00
}

# Tycoon State
var game_mode: String = "tycoon" # "tycoon" or "high_roller"
var has_seen_dad_letter: bool = false
var casino_cleaned: bool = false
var cleaned_trash_count: int = 0
var total_trash_count: int = 8
var casino_open: bool = false
var casino_day: int = 1
var day_timer: float = 0.0
const NIGHT_DURATION: float = 360.0 # 6 minutes (5-10 min real time) per business night
var night_elapsed: float = 0.0
var night_closed: bool = false

signal night_closed_signal()
signal night_time_updated(elapsed: float, total: float)

# Player inventory of placeable objects (bought at Vinnie's store)
var inventory: Dictionary = {
	"slot_rusty": 1, # Start with 1 rusty slot machine in inventory or placed
	"slot_modern": 0,
	"crash": 0,
	"roulette": 0,
	"blackjack": 0,
	"bar_counter": 0,
	"bar_stool": 0,
	"table": 0,
	"atm": 0,
	"plant": 0,
	"trash_bin": 0
}

# Placed objects in the casino floor: Array of { "type": String, "grid_x": int, "grid_y": int }
var placed_furniture: Array = []

# Casino Expansion & Area Unlocks ("starter", "east_wing", "vip_lounge")
var unlocked_areas: Array = ["starter"]
var upgrades: Dictionary = {
	"neon_sign": false,
	"security": false
}

func is_area_unlocked(area_id: String) -> bool:
	if game_mode == "high_roller":
		return true # Everything unlocked in high roller mode
	return unlocked_areas.has(area_id)

func unlock_area(area_id: String) -> void:
	if not unlocked_areas.has(area_id):
		unlocked_areas.append(area_id)
		area_unlocked.emit(area_id)
		save_game()

func has_upgrade(upg_id: String) -> bool:
	return upgrades.get(upg_id, false)

func purchase_upgrade(upg_id: String) -> void:
	upgrades[upg_id] = true
	upgrade_purchased.emit(upg_id)
	save_game()

# Cheat toggle: set to true to enable the cheat button in HUD
var cheat_mode_enabled: bool = true

# State
var cash_cents: int = 2000 # Default $20.00 starter cash in tycoon mode
var is_hardcore: bool = false
var total_bottles_collected: int = 0
var total_winnings_cents: int = 0
var unlocked_machines: Dictionary = {
	MACHINE_SLOTS: true,
	MACHINE_CRASH: false,
	MACHINE_ROULETTE: false
}

var active_minigame: String = ""
var is_game_over: bool = false
var current_lang: String = "en"

const LOCALIZATION: Dictionary = {
	"play": {"en": "PLAY", "de": "SPIELEN"},
	"continue": {"en": "CONTINUE", "de": "FORTSETZEN"},
	"new_game": {"en": "NEW GAME", "de": "NEUES SPIEL"},
	"hardcore": {"en": "Hardcore Mode", "de": "Hardcore-Modus"},
	"cheat": {"en": "Developer Cheat", "de": "Entwickler-Cheat"},
	"menu": {"en": "Menu", "de": "Menü"},
	"interact_play": {"en": "[E] Play", "de": "[E] Spielen"},
	"interact_unlock": {"en": "[E] Unlock (%s)", "de": "[E] Freischalten (%s)"},
	"collect_bottle": {"en": "[E] Collect (+$0.25)", "de": "[E] Pfand (+$0.25)"},
	"not_enough_cash": {"en": "Not enough cash!", "de": "Zu wenig Geld!"},
	"bet": {"en": "BET:", "de": "EINSATZ:"},
	"exit": {"en": "EXIT", "de": "BEENDEN"},
	"disclaimer": {
		"en": "Virtual play money only. No real money gambling.",
		"de": "Reine virtuelle Spielwährung. Kein echtes Glücksspiel."
	}
}

func tr_text(key: String) -> String:
	if LOCALIZATION.has(key):
		var entry = LOCALIZATION[key]
		if entry.has(current_lang):
			return entry[current_lang]
		return entry["en"]
	return key

const SAVE_PATH := "user://savegame.json"

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var loc := OS.get_locale_language().to_lower()
	if loc == "de":
		current_lang = "de"
	else:
		current_lang = "en"

func reset_game(hardcore: bool = false) -> void:
	is_hardcore = hardcore
	is_game_over = false
	active_minigame = ""
	total_bottles_collected = 0
	total_winnings_cents = 0
	
	if is_hardcore:
		cash_cents = 1500 # $15.00
	else:
		cash_cents = 2000 # $20.00
		
	unlocked_machines = {
		MACHINE_SLOTS: true,
		MACHINE_CRASH: false,
		MACHINE_ROULETTE: false
	}
	
	unlocked_areas = ["starter"]
	upgrades = {
		"neon_sign": false,
		"security": false
	}
	
	night_elapsed = 0.0
	night_closed = false
	casino_open = false
	casino_day = 1
	inventory = {
		"slot_rusty": 1,
		"slot_modern": 0,
		"crash": 0,
		"roulette": 0,
		"blackjack": 0,
		"bar_counter": 0,
		"bar_stool": 0,
		"table": 0,
		"atm": 0,
		"plant": 0,
		"trash_bin": 0
	}
	
	cash_changed.emit(cash_cents, 0)
	game_mode_changed.emit(is_hardcore)

func format_cash(cents: int = -1) -> String:
	var c := cents if cents >= 0 else cash_cents
	@warning_ignore("integer_division")
	var dollars: int = c / 100
	var remainder: int = abs(c % 100)
	return "$%d.%02d" % [dollars, remainder]

func add_cash(cents_delta: int) -> void:
	if is_game_over:
		return
	cash_cents += cents_delta
	if cents_delta > 0:
		total_winnings_cents += cents_delta
	cash_changed.emit(cash_cents, cents_delta)
	check_game_over_condition()

func spend_cash(cents_delta: int) -> bool:
	if is_game_over or cash_cents < cents_delta:
		return false
	cash_cents -= cents_delta
	cash_changed.emit(cash_cents, -cents_delta)
	check_game_over_condition()
	return true

func collect_bottle() -> void:
	total_bottles_collected += 1
	bottles_collected_changed.emit(total_bottles_collected)
	add_cash(25) # 25 Cents ($0.25)
	if SoundManager:
		SoundManager.play_sfx("bottle_pickup")

func is_unlocked(machine_id: String) -> bool:
	return unlocked_machines.get(machine_id, false)

func get_unlock_cost(machine_id: String) -> int:
	return UNLOCK_COSTS.get(machine_id, 0)

func unlock_machine(machine_id: String) -> bool:
	if is_unlocked(machine_id):
		return true
	var cost: int = get_unlock_cost(machine_id)
	if spend_cash(cost):
		unlocked_machines[machine_id] = true
		machine_unlocked.emit(machine_id)
		if SoundManager:
			SoundManager.play_sfx("machine_unlock")
		save_game()
		return true
	return false

func check_game_over_condition() -> void:
	if is_game_over:
		return
	if is_hardcore and cash_cents <= 0 and active_minigame == "":
		is_game_over = true
		game_over_triggered.emit("Pleite im Hardcore-Modus!")
		if SoundManager:
			SoundManager.play_sfx("game_over")

func save_game() -> void:
	var serializable_furniture := []
	for f in placed_furniture:
		var p = f.get("pos", Vector2.ZERO)
		var px := 0.0
		var py := 0.0
		if p is Vector2:
			px = p.x
			py = p.y
		elif p is String:
			var s: String = p.strip_edges().trim_prefix("(").trim_suffix(")")
			var parts := s.split(",")
			if parts.size() >= 2:
				px = parts[0].to_float()
				py = parts[1].to_float()
		serializable_furniture.append({
			"type": f.get("type", "slot_rusty"),
			"pos": "(%.1f, %.1f)" % [px, py]
		})

	var data := {
		"cash_cents": cash_cents,
		"is_hardcore": is_hardcore,
		"total_bottles_collected": total_bottles_collected,
		"total_winnings_cents": total_winnings_cents,
		"unlocked_machines": unlocked_machines,
		"game_mode": game_mode,
		"has_seen_dad_letter": has_seen_dad_letter,
		"casino_cleaned": casino_cleaned,
		"cleaned_trash_count": cleaned_trash_count,
		"casino_day": casino_day,
		"inventory": inventory,
		"placed_furniture": serializable_furniture,
		"unlocked_areas": unlocked_areas,
		"upgrades": upgrades,
		"timestamp": Time.get_unix_time_from_system()
	}
	var json_str := JSON.stringify(data)
	
	# Local file storage
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(json_str)
		file.close()
		
	# CrazyGames Cloud Save (Data Module)
	if CrazyGamesSDK:
		CrazyGamesSDK.save_data("all_in_savegame", json_str)

func load_game() -> bool:
	var content := ""
	
	# Check CrazyGames Cloud Save first
	if CrazyGamesSDK and CrazyGamesSDK.is_web:
		var cloud_data = CrazyGamesSDK.load_data("all_in_savegame")
		if cloud_data != "":
			content = cloud_data
			
	# Fallback to local user file
	if content == "":
		if not FileAccess.file_exists(SAVE_PATH):
			return false
		var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
		if not file:
			return false
		content = file.get_as_text()
		file.close()
		
	var json := JSON.new()
	if json.parse(content) != OK:
		return false
	var data: Dictionary = json.data
	cash_cents = int(data.get("cash_cents", 1000))
	is_hardcore = bool(data.get("is_hardcore", false))
	total_bottles_collected = int(data.get("total_bottles_collected", 0))
	total_winnings_cents = int(data.get("total_winnings_cents", 0))
	if data.has("unlocked_machines"):
		unlocked_machines = data.get("unlocked_machines")
	game_mode = data.get("game_mode", "tycoon")
	has_seen_dad_letter = bool(data.get("has_seen_dad_letter", false))
	casino_cleaned = bool(data.get("casino_cleaned", false))
	cleaned_trash_count = int(data.get("cleaned_trash_count", 0))
	casino_day = int(data.get("casino_day", 1))
	if data.has("inventory"):
		inventory = data.get("inventory")
	if data.has("placed_furniture"):
		var raw_list = data.get("placed_furniture", [])
		placed_furniture = []
		for f in raw_list:
			if f is Dictionary:
				var pos_val = f.get("pos")
				var parsed_pos := Vector2.ZERO
				if pos_val is Vector2:
					parsed_pos = pos_val
				elif pos_val is String:
					var s: String = pos_val.strip_edges().trim_prefix("(").trim_suffix(")")
					var parts := s.split(",")
					if parts.size() >= 2:
						parsed_pos = Vector2(parts[0].to_float(), parts[1].to_float())
				elif pos_val is Dictionary:
					parsed_pos = Vector2(float(pos_val.get("x", 0.0)), float(pos_val.get("y", 0.0)))
				placed_furniture.append({
					"type": f.get("type", "slot_rusty"),
					"pos": parsed_pos
				})
	if data.has("unlocked_areas"):
		unlocked_areas = data.get("unlocked_areas")
	if data.has("upgrades"):
		upgrades = data.get("upgrades")
	cash_changed.emit(cash_cents, 0)
	return true
