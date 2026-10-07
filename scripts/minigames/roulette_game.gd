extends Control

signal minigame_closed

const BET_OPTIONS: Array[int] = [1000, 2500, 5000, 10000, 25000, 50000] # $10 to $500
var current_bet_idx := 1 # Default $25.00
var is_spinning := false

# European Roulette sequence in clockwise order starting at index 0 (top = 0):
const WHEEL_NUMBERS: Array[int] = [
	0, 32, 15, 19, 4, 21, 2, 25, 17, 34, 6, 27, 13, 36, 11, 30, 8, 23, 10,
	5, 24, 16, 33, 1, 20, 14, 31, 9, 22, 18, 29, 7, 28, 12, 35, 3, 26
]

const RED_NUMS: Array[int] = [1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36]

# Selected bet: "RED", "BLACK", "GREEN", "EVEN", "ODD", "1-12", "13-24", "25-36"
var selected_bet_type := "RED"

@onready var wheel_sprite: Sprite2D = $Panel/RouletteArea/WheelRotor
@onready var ball_sprite: Sprite2D = $Panel/RouletteArea/Ball
@onready var result_number_lbl: Label = $Panel/ResultBanner/ResultNumberLabel
@onready var result_color_rect: ColorRect = $Panel/ResultBanner/ColorIndicator
@onready var bet_amount_lbl: Label = $Panel/Controls/BetContainer/BetVal
@onready var spin_btn: Button = $Panel/Controls/SpinBtn
@onready var close_btn: Button = $Panel/CloseButton
@onready var status_lbl: Label = $Panel/StatusLabel

# Animation variables
var spin_duration := 3.2
var spin_elapsed := 0.0
var ball_radius := 90.0
var target_number := 0
var target_pocket_index := 0
var final_ball_angle := 0.0

func _ready() -> void:
	update_bet_display()
	close_btn.pressed.connect(func(): minigame_closed.emit())
	spin_btn.pressed.connect(_on_spin_pressed)
	$Panel/Controls/BetContainer/MinusBtn.pressed.connect(func(): _adjust_bet(-1))
	$Panel/Controls/BetContainer/PlusBtn.pressed.connect(func(): _adjust_bet(1))
	
	# Connect all bet selection buttons
	$Panel/TableGrid/GreenBtn.pressed.connect(func(): _set_bet_type("GREEN"))
	$Panel/TableGrid/RedBtn.pressed.connect(func(): _set_bet_type("RED"))
	$Panel/TableGrid/BlackBtn.pressed.connect(func(): _set_bet_type("BLACK"))
	$Panel/TableGrid/EvenBtn.pressed.connect(func(): _set_bet_type("EVEN"))
	$Panel/TableGrid/OddBtn.pressed.connect(func(): _set_bet_type("ODD"))
	$Panel/TableGrid/Doz1Btn.pressed.connect(func(): _set_bet_type("1-12"))
	$Panel/TableGrid/Doz2Btn.pressed.connect(func(): _set_bet_type("13-24"))
	$Panel/TableGrid/Doz3Btn.pressed.connect(func(): _set_bet_type("25-36"))
	
	_update_selected_bet_ui()
	_update_result_ui(0)
	
	# Place ball initially at 0 (top)
	ball_sprite.position = wheel_sprite.position + Vector2(0, -68)

func _adjust_bet(delta: int) -> void:
	if is_spinning: return
	current_bet_idx = clampi(current_bet_idx + delta, 0, BET_OPTIONS.size() - 1)
	SoundManager.play_sfx("button_click")
	update_bet_display()
	_update_selected_bet_ui()

func update_bet_display() -> void:
	bet_amount_lbl.text = GameManager.format_cash(BET_OPTIONS[current_bet_idx])

func _set_bet_type(b_type: String) -> void:
	if is_spinning: return
	SoundManager.play_sfx("button_click")
	selected_bet_type = b_type
	_update_selected_bet_ui()

func _update_selected_bet_ui() -> void:
	var mult_str := ""
	match selected_bet_type:
		"GREEN": mult_str = "36x"
		"RED", "BLACK", "EVEN", "ODD": mult_str = "2x"
		"1-12", "13-24", "25-36": mult_str = "3x"
	status_lbl.text = "Wette: [%s] (%s) - Einsatz: %s" % [selected_bet_type, mult_str, GameManager.format_cash(BET_OPTIONS[current_bet_idx])]

func _update_result_ui(num: int) -> void:
	result_number_lbl.text = str(num)
	if num == 0:
		result_color_rect.color = Color(0.1, 0.75, 0.25) # Green
	elif num in RED_NUMS:
		result_color_rect.color = Color(0.85, 0.15, 0.15) # Red
	else:
		result_color_rect.color = Color(0.15, 0.15, 0.2) # Black

func _process(delta: float) -> void:
	if is_spinning:
		spin_elapsed += delta
		var progress: float = clampf(spin_elapsed / spin_duration, 0.0, 1.0)
		
		# Smooth deceleration
		var ease_out: float = 1.0 - (progress * progress)
		wheel_sprite.rotation += 3.5 * ease_out * delta
		
		# Compute exact pocket angle for target number based on current wheel rotation:
		# Angle of pocket i relative to wheel is: i * (TAU / 37) - PI/2
		# In world coordinates: pocket_world_angle = wheel_sprite.rotation + (target_pocket_index * (TAU / 37) - PI/2)
		var pocket_world_angle = wheel_sprite.rotation + (float(target_pocket_index) * (TAU / 37.0) - (PI / 2.0))
		
		# In flight: ball spins fast in reverse; in last 30% of time: ball synchronizes exactly into target pocket!
		var current_ball_angle: float
		if progress < 0.7:
			# Fast ball spinning counter-clockwise
			current_ball_angle = - (1.0 - progress) * 24.0
			ball_radius = lerp(92.0, 75.0, progress / 0.7)
		else:
			# Smoothly snap into target pocket angle
			var snap_t := (progress - 0.7) / 0.3
			var start_interp_angle = pocket_world_angle - (1.0 - snap_t) * 2.0
			current_ball_angle = lerp_angle(start_interp_angle, pocket_world_angle, snap_t)
			ball_radius = lerp(75.0, 68.0, snap_t)
			
		var center := wheel_sprite.position
		ball_sprite.position = center + Vector2(cos(current_ball_angle), sin(current_ball_angle)) * ball_radius
		
		if spin_elapsed >= spin_duration:
			# Final exact lock to pocket
			ball_sprite.position = center + Vector2(cos(pocket_world_angle), sin(pocket_world_angle)) * 68.0
			_finish_spin()

func _on_spin_pressed() -> void:
	if is_spinning: return
	var bet: int = BET_OPTIONS[current_bet_idx]
	if not GameManager.spend_cash(bet):
		status_lbl.text = "Nicht genug Geld für diesen Einsatz!"
		status_lbl.modulate = Color(1.0, 0.3, 0.3)
		return
		
	# Determine target number and pocket index BEFORE spinning
	target_pocket_index = randi() % 37 # 0 to 36
	target_number = WHEEL_NUMBERS[target_pocket_index]
	
	is_spinning = true
	spin_elapsed = 0.0
	spin_btn.disabled = true
	SoundManager.play_sfx("spin")
	status_lbl.text = "Die weiße Kugel rollt im Roulette-Kessel..."
	status_lbl.modulate = Color(1, 1, 1)

func _finish_spin() -> void:
	is_spinning = false
	spin_btn.disabled = false
	
	_update_result_ui(target_number)
	
	var is_red: bool = target_number in RED_NUMS
	var is_black: bool = (target_number != 0) and not is_red
	var is_even: bool = (target_number != 0) and (target_number % 2 == 0)
	var is_odd: bool = (target_number != 0) and (target_number % 2 != 0)
	var bet: int = BET_OPTIONS[current_bet_idx]
	var won := false
	var multiplier := 0.0
	
	match selected_bet_type:
		"GREEN":
			if target_number == 0: won = true; multiplier = 36.0
		"RED":
			if is_red: won = true; multiplier = 2.0
		"BLACK":
			if is_black: won = true; multiplier = 2.0
		"EVEN":
			if is_even: won = true; multiplier = 2.0
		"ODD":
			if is_odd: won = true; multiplier = 2.0
		"1-12":
			if target_number >= 1 and target_number <= 12: won = true; multiplier = 3.0
		"13-24":
			if target_number >= 13 and target_number <= 24: won = true; multiplier = 3.0
		"25-36":
			if target_number >= 25 and target_number <= 36: won = true; multiplier = 3.0
			
	var is_de: bool = (GameManager.current_lang == "de")
	var color_name := ("GREEN" if not is_de else "GRUEN") if target_number == 0 else (("RED" if not is_de else "ROT") if is_red else ("BLACK" if not is_de else "SCHWARZ"))
	
	if won:
		var payout := int(bet * multiplier)
		GameManager.add_cash(payout)
		status_lbl.text = ("WIN! Ball on %d (%s)! (+%s)" if not is_de else "GEWINN! Kugel auf %d (%s)! (+%s)") % [target_number, color_name, GameManager.format_cash(payout)]
		status_lbl.modulate = Color(0.2, 1.0, 0.3)
		if multiplier >= 30.0:
			SoundManager.play_sfx("jackpot")
		else:
			SoundManager.play_sfx("coin_win")
	else:
		status_lbl.text = ("Lost! Ball landed on %d (%s)." if not is_de else "Verloren! Kugel fiel auf %d (%s).") % [target_number, color_name]
		status_lbl.modulate = Color(0.9, 0.5, 0.5)
