extends Control

signal minigame_closed

const BET_OPTIONS: Array[int] = [50, 100, 200, 500, 1000] # In cents ($0.50 to $10.00)
var current_bet_idx := 0
var is_spinning := false

# Slot symbol textures from Pixel Fantasy Slot Machine pack
var symbol_textures := {
	"cherry": preload("res://assets/sprites/minigames/sym_cherry.png"),
	"lemon": preload("res://assets/sprites/minigames/sym_lemon.png"),
	"bar": preload("res://assets/sprites/minigames/sym_bar.png"),
	"seven": preload("res://assets/sprites/minigames/sym_seven.png")
}

# Full-resolution lever layers (816x624)
var lever_up_tex := preload("res://assets/sprites/minigames/slot_lever_up.png")
var lever_down_tex := preload("res://assets/sprites/minigames/slot_lever_down.png")
var frame_overlay_tex := preload("res://assets/sprites/minigames/slot_frame_overlay.png")
var reel_bg_tex := preload("res://assets/sprites/minigames/slot_reel_bg.png")

# Rusty slot machine textures
var lever_up_rusty := preload("res://assets/sprites/minigames/slot_lever_up_rusty.png")
var lever_down_rusty := preload("res://assets/sprites/minigames/slot_lever_down_rusty.png")
var frame_overlay_rusty := preload("res://assets/sprites/minigames/slot_frame_overlay_rusty.png")
var reel_bg_rusty := preload("res://assets/sprites/minigames/slot_reel_bg_rusty.png")

const SYMBOL_KEYS := ["cherry", "lemon", "bar", "seven"]
const WEIGHTS := [40, 30, 20, 10] # Weighted probabilities

@onready var reel1_rect: TextureRect = $SlotRoot/ReelWindow/Reel1/SymbolRect
@onready var reel2_rect: TextureRect = $SlotRoot/ReelWindow/Reel2/SymbolRect
@onready var reel3_rect: TextureRect = $SlotRoot/ReelWindow/Reel3/SymbolRect
@onready var reel_window_bg: TextureRect = $SlotRoot/ReelWindowBg
@onready var frame_overlay: TextureRect = $SlotRoot/MachineFrameOverlay
@onready var lever_rect: TextureRect = $SlotRoot/LeverLayer
@onready var lever_click_area: TextureButton = $SlotRoot/LeverClickArea
@onready var bet_label: Label = $ControlsBar/HBoxContainer/BetContainer/BetValueLabel
@onready var close_button: Button = $CloseButton
@onready var win_loss_label: Label = $ControlsBar/HBoxContainer/WinLossLabel

var spin_timer := 0.0
var spin_duration := 1.4
var spin_step := 0.06
var elapsed_step := 0.0
var is_rusty: bool = false

func _ready() -> void:
	is_rusty = (GameManager.active_minigame == "slot_rusty" or (GameManager.active_minigame == GameManager.MACHINE_SLOTS and GameManager.game_mode == "tycoon" and not GameManager.has_upgrade("modern_slots")))
	
	if is_rusty:
		frame_overlay.texture = frame_overlay_rusty
		reel_window_bg.texture = reel_bg_rusty
		lever_up_tex = lever_up_rusty
		lever_down_tex = lever_down_rusty
	else:
		frame_overlay.texture = frame_overlay_tex
		reel_window_bg.texture = reel_bg_tex
		
	update_bet_display()
	win_loss_label.text = "$0.00"
	win_loss_label.modulate = Color(0.85, 0.88, 0.95)
	
	lever_click_area.pressed.connect(_on_lever_pulled)
	$ControlsBar/HBoxContainer/SpinButton.pressed.connect(_on_lever_pulled)
	close_button.pressed.connect(_on_close_pressed)
	$ControlsBar/HBoxContainer/BetContainer/BetMinusBtn.pressed.connect(_on_bet_minus)
	$ControlsBar/HBoxContainer/BetContainer/BetPlusBtn.pressed.connect(_on_bet_plus)
	
	# Initial states
	reel1_rect.texture = symbol_textures["seven"]
	reel2_rect.texture = symbol_textures["seven"]
	reel3_rect.texture = symbol_textures["seven"]
	lever_rect.texture = lever_up_tex

func _process(delta: float) -> void:
	if is_spinning:
		spin_timer += delta
		elapsed_step += delta
		if elapsed_step >= spin_step:
			elapsed_step = 0.0
			SoundManager.play_sfx("spin")
			if spin_timer < spin_duration * 0.4:
				reel1_rect.texture = symbol_textures[get_random_symbol_key()]
			if spin_timer < spin_duration * 0.7:
				reel2_rect.texture = symbol_textures[get_random_symbol_key()]
			reel3_rect.texture = symbol_textures[get_random_symbol_key()]
			
		# Return lever up after initial pull
		if spin_timer >= 0.4 and lever_rect.texture != lever_up_tex:
			lever_rect.texture = lever_up_tex
			SoundManager.play_sfx("lever_release")
			
		if spin_timer >= spin_duration:
			_finish_spin()

func get_bet_cents() -> int:
	return BET_OPTIONS[current_bet_idx]

func update_bet_display() -> void:
	bet_label.text = GameManager.format_cash(get_bet_cents())

func _on_bet_minus() -> void:
	if is_spinning: return
	if current_bet_idx > 0:
		current_bet_idx -= 1
		SoundManager.play_sfx("button_click")
		update_bet_display()

func _on_bet_plus() -> void:
	if is_spinning: return
	if current_bet_idx < BET_OPTIONS.size() - 1:
		current_bet_idx += 1
		SoundManager.play_sfx("button_click")
		update_bet_display()

func get_random_symbol_key() -> String:
	var total_weight: int = 0
	for w in WEIGHTS:
		total_weight += w
	var roll: int = randi() % total_weight
	var accum: int = 0
	for i in range(SYMBOL_KEYS.size()):
		accum += WEIGHTS[i]
		if roll < accum:
			return SYMBOL_KEYS[i]
	return SYMBOL_KEYS[0]

func _on_lever_pulled() -> void:
	if is_spinning: return
	SoundManager.play_sfx("lever_pull")
	lever_rect.texture = lever_down_tex
	_start_spin_logic()

func _start_spin_logic() -> void:
	var bet := get_bet_cents()
	if not GameManager.spend_cash(bet):
		lever_rect.texture = lever_up_tex
		win_loss_label.text = "-%s" % GameManager.format_cash(bet)
		win_loss_label.modulate = Color(1.0, 0.25, 0.25)
		return
		
	is_spinning = true
	spin_timer = 0.0
	elapsed_step = 0.0
	lever_click_area.disabled = true
	win_loss_label.text = "..."
	win_loss_label.modulate = Color(0.7, 0.75, 0.85)

func _finish_spin() -> void:
	is_spinning = false
	lever_click_area.disabled = false
	lever_rect.texture = lever_up_tex
	
	var s1 := get_random_symbol_key()
	var s2 := get_random_symbol_key()
	var s3 := get_random_symbol_key()
	
	reel1_rect.texture = symbol_textures[s1]
	reel2_rect.texture = symbol_textures[s2]
	reel3_rect.texture = symbol_textures[s3]
	
	var bet := get_bet_cents()
	var win_multiplier := 0.0
	
	if s1 == s2 and s2 == s3:
		match s1:
			"seven": win_multiplier = 50.0
			"bar": win_multiplier = 20.0
			"lemon": win_multiplier = 8.0
			"cherry": win_multiplier = 5.0
	elif s1 == s2 or s2 == s3 or s1 == s3:
		win_multiplier = 1.5
		
	if win_multiplier > 0.0:
		var payout := int(bet * win_multiplier)
		GameManager.add_cash(payout)
		win_loss_label.text = "+%s" % GameManager.format_cash(payout)
		win_loss_label.modulate = Color(0.25, 1.0, 0.45)
		if win_multiplier >= 20.0:
			SoundManager.play_sfx("jackpot")
		else:
			SoundManager.play_sfx("coin_win")
	else:
		win_loss_label.text = "-%s" % GameManager.format_cash(bet)
		win_loss_label.modulate = Color(1.0, 0.35, 0.35)

func _on_close_pressed() -> void:
	if is_spinning: return
	SoundManager.play_sfx("button_click")
	minigame_closed.emit()
