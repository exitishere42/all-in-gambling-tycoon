extends Control

@onready var player_art: TextureRect = $PlayerArt
@onready var play_button: Button = $LeftPanel/MenuContainer/PlayButton
@onready var high_roller_button: Button = $LeftPanel/MenuContainer/HighRollerButton
@onready var new_game_button: Button = $LeftPanel/MenuContainer/NewGameButton
@onready var hardcore_check: CheckBox = $LeftPanel/MenuContainer/ModeContainer/HardcoreCheck
@onready var cheat_check: CheckBox = $LeftPanel/MenuContainer/CheatCheck
@onready var stats_label: Label = $LeftPanel/MenuContainer/StatsLabel
@onready var exit_button: Button = $LeftPanel/MenuContainer/ExitButton
@onready var lang_button: Button = $LeftPanel/BottomRow/LangButton
@onready var disclaimer_label: Label = $LeftPanel/BottomRow/DisclaimerLabel

var anim_time: float = 0.0
var base_player_y: float = 0.0

func _ready() -> void:
	if player_art:
		base_player_y = player_art.position.y
		
	if CrazyGamesSDK:
		CrazyGamesSDK.gameplay_stop()
		
	# Try loading saved state to display existing progress
	GameManager.load_game()
	
	hardcore_check.button_pressed = GameManager.is_hardcore
	cheat_check.button_pressed = GameManager.cheat_mode_enabled
	
	hardcore_check.toggled.connect(_on_hardcore_toggled)
	cheat_check.toggled.connect(_on_cheat_toggled)
	play_button.pressed.connect(_on_play_pressed)
	high_roller_button.pressed.connect(_on_high_roller_pressed)
	new_game_button.pressed.connect(_on_new_game_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	lang_button.pressed.connect(_on_lang_pressed)
	
	_update_ui_texts()

func _update_ui_texts() -> void:
	hardcore_check.text = GameManager.tr_text("hardcore")
	cheat_check.text = GameManager.tr_text("cheat")
	new_game_button.text = GameManager.tr_text("new_game")
	exit_button.text = GameManager.tr_text("exit")
	disclaimer_label.text = GameManager.tr_text("disclaimer")
	lang_button.text = "DE" if GameManager.current_lang == "de" else "EN"
	
	play_button.text = "CASINO TYCOON"
	high_roller_button.text = "HIGH ROLLER"
	
	var save_exists := FileAccess.file_exists(GameManager.SAVE_PATH)
	if save_exists and GameManager.cash_cents > 0 and not GameManager.is_game_over:
		new_game_button.visible = true
		stats_label.text = "%s • Tag %d" % [
			GameManager.format_cash(GameManager.cash_cents),
			GameManager.casino_day
		]
	else:
		new_game_button.visible = false
		stats_label.text = "Starte dein Casino-Imperium!"

func _process(delta: float) -> void:
	anim_time += delta
	if player_art:
		player_art.position.y = base_player_y + sin(anim_time * 2.2) * 5.0

func _on_lang_pressed() -> void:
	GameManager.current_lang = "de" if GameManager.current_lang == "en" else "en"
	if SoundManager:
		SoundManager.play_sfx("button_click")
	_update_ui_texts()

func _on_play_pressed() -> void:
	GameManager.game_mode = "tycoon"
	if SoundManager:
		SoundManager.play_sfx("coin_win")
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_high_roller_pressed() -> void:
	GameManager.game_mode = "high_roller"
	if SoundManager:
		SoundManager.play_sfx("coin_win")
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_new_game_pressed() -> void:
	if SoundManager:
		SoundManager.play_sfx("lever_pull")
	GameManager.reset_game(hardcore_check.button_pressed)
	GameManager.game_mode = "tycoon"
	GameManager.has_seen_dad_letter = false
	GameManager.casino_cleaned = false
	GameManager.placed_furniture.clear()
	GameManager.inventory = {
		"slot_rusty": 1, "slot_modern": 0, "crash": 0, "roulette": 0,
		"blackjack": 0, "bar_counter": 0, "bar_stool": 0, "atm": 0, "plant": 0, "trash_bin": 0
	}
	GameManager.save_game()
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_hardcore_toggled(toggled_on: bool) -> void:
	GameManager.is_hardcore = toggled_on
	if SoundManager:
		SoundManager.play_sfx("reel_tick")
	if not FileAccess.file_exists(GameManager.SAVE_PATH) or play_button.text in [GameManager.tr_text("play"), "PLAY", "SPIELEN"]:
		stats_label.text = GameManager.format_cash(
			2500 if toggled_on else 1000
		)

func _on_cheat_toggled(toggled_on: bool) -> void:
	GameManager.cheat_mode_enabled = toggled_on
	if SoundManager:
		SoundManager.play_sfx("reel_tick")

func _on_exit_pressed() -> void:
	if SoundManager:
		SoundManager.play_sfx("button_click")
	GameManager.save_game()
	if OS.has_feature("web"):
		# In Web / browser environment, window closing is blocked by browsers
		JavaScriptBridge.eval("window.close();")
	else:
		get_tree().quit()
