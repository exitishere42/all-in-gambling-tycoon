extends Control

signal minigame_closed

const PIXEL_FONT = preload("res://assets/fonts/Silkscreen-Regular.ttf")

# State
enum State { WAITING, FLYING, CRASHED }
var current_state := State.WAITING

var current_multiplier := 1.00
var crash_multiplier := 1.00
var state_time := 0.0

const COUNTDOWN_DURATION := 10.0
var countdown_remaining := 10.0

# Current active bets for the current flying round
var bet1_cents := 1000 # $10.00
var bet2_cents := 10000 # $100.00
var bet1_placed := false
var bet2_placed := false
var bet1_cashed_out := false
var bet2_cashed_out := false

# Queued bets placed while round is in progress
var bet1_next_cents := 1000
var bet2_next_cents := 10000
var bet1_queued_for_next := false
var bet2_queued_for_next := false

# History of previous rounds
var history: Array[float] = [1.60, 0.98, 0.93, 1.16, 91.38, 1.15]

# Node references
@onready var game_area: Control = $Panel/GameAreaFrame/GameArea
@onready var multiplier_label: Label = $Panel/GameAreaFrame/GameArea/MultiplierLabel
@onready var plane_sprite: Sprite2D = $Panel/GameAreaFrame/GameArea/PlaneSprite
@onready var status_label: Label = $Panel/StatusLabel
@onready var history_container: HBoxContainer = $Panel/HistoryBar/Scroll/HistoryContainer
@onready var close_button: Button = $Panel/CloseButton

# Bet 1 controls
@onready var bet1_btn: Button = $Panel/BetBar/Bet1Section/HBox/Bet1ActionBtn
@onready var bet1_val_lbl: Label = $Panel/BetBar/Bet1Section/HBox/VBox/Steppers/Bet1Val
@onready var bet1_minus: Button = $Panel/BetBar/Bet1Section/HBox/VBox/Steppers/MinusBtn
@onready var bet1_plus: Button = $Panel/BetBar/Bet1Section/HBox/VBox/Steppers/PlusBtn

# Bet 2 controls
@onready var bet2_btn: Button = $Panel/BetBar/Bet2Section/HBox/Bet2ActionBtn
@onready var bet2_val_lbl: Label = $Panel/BetBar/Bet2Section/HBox/VBox/Steppers/Bet2Val
@onready var bet2_minus: Button = $Panel/BetBar/Bet2Section/HBox/VBox/Steppers/MinusBtn
@onready var bet2_plus: Button = $Panel/BetBar/Bet2Section/HBox/VBox/Steppers/PlusBtn

# Visual flight path bounds
var start_pos := Vector2(65, 235)
var target_pos := Vector2(480, 55)

# Visual trail line & particles
var trail_line: Line2D
var trail_timer := 0.0

func _ready() -> void:
	# Create trail Line2D behind plane
	trail_line = Line2D.new()
	trail_line.width = 4.0
	var grad := Gradient.new()
	grad.set_color(0, Color(1.0, 0.9, 0.3, 0.0)) # tail fade
	grad.set_color(1, Color(1.0, 0.3, 0.2, 0.9)) # fiery head near plane
	trail_line.gradient = grad
	trail_line.joint_mode = Line2D.LINE_JOINT_ROUND
	trail_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	trail_line.end_cap_mode = Line2D.LINE_CAP_ROUND
	trail_line.z_index = 0
	game_area.add_child(trail_line)
	game_area.move_child(trail_line, 0) # Behind plane
	
	close_button.pressed.connect(_on_close_pressed)
	bet1_btn.pressed.connect(_on_bet1_action)
	bet2_btn.pressed.connect(_on_bet2_action)
	bet1_minus.pressed.connect(func(): _adjust_bet(1, -500))
	bet1_plus.pressed.connect(func(): _adjust_bet(1, 500))
	bet2_minus.pressed.connect(func(): _adjust_bet(2, -2500))
	bet2_plus.pressed.connect(func(): _adjust_bet(2, 2500))
	
	update_history_ui()
	start_countdown()

func _adjust_bet(slot: int, delta_cents: int) -> void:
	var is_de: bool = (GameManager.current_lang == "de")
	if slot == 1:
		if current_state == State.WAITING and not bet1_placed:
			bet1_cents = clampi(bet1_cents + delta_cents, 100, 25000)
			bet1_val_lbl.text = GameManager.format_cash(bet1_cents)
		elif current_state != State.WAITING and not bet1_queued_for_next:
			bet1_next_cents = clampi(bet1_next_cents + delta_cents, 100, 25000)
			bet1_val_lbl.text = GameManager.format_cash(bet1_next_cents)
	else:
		if current_state == State.WAITING and not bet2_placed:
			bet2_cents = clampi(bet2_cents + delta_cents, 500, 100000)
			bet2_val_lbl.text = GameManager.format_cash(bet2_cents)
		elif current_state != State.WAITING and not bet2_queued_for_next:
			bet2_next_cents = clampi(bet2_next_cents + delta_cents, 500, 100000)
			bet2_val_lbl.text = GameManager.format_cash(bet2_next_cents)

func update_history_ui() -> void:
	for child in history_container.get_children():
		child.queue_free()
	for val in history:
		var lbl := Label.new()
		lbl.text = " %.2fX " % val
		lbl.add_theme_font_override("font", PIXEL_FONT)
		lbl.add_theme_font_size_override("font_size", 9)
		if val >= 10.0:
			lbl.modulate = Color(1.0, 0.35, 0.35)
		elif val >= 2.0:
			lbl.modulate = Color(0.2, 1.0, 0.4)
		else:
			lbl.modulate = Color(0.7, 0.75, 0.85)
		history_container.add_child(lbl)

func start_countdown() -> void:
	current_state = State.WAITING
	current_multiplier = 1.00
	state_time = 0.0
	countdown_remaining = COUNTDOWN_DURATION
	
	# Apply any queued bets from previous flight
	if bet1_queued_for_next:
		bet1_placed = true
		bet1_queued_for_next = false
		bet1_cents = bet1_next_cents
	else:
		bet1_placed = false
		
	if bet2_queued_for_next:
		bet2_placed = true
		bet2_queued_for_next = false
		bet2_cents = bet2_next_cents
	else:
		bet2_placed = false
		
	bet1_cashed_out = false
	bet2_cashed_out = false
	
	# Reset plane visual
	plane_sprite.position = start_pos
	plane_sprite.rotation_degrees = -20
	plane_sprite.visible = true
	plane_sprite.modulate = Color(1, 1, 1, 1)
	
	if trail_line:
		trail_line.clear_points()
		
	multiplier_label.modulate = Color(1, 1, 1)
	_update_bet_buttons_ui()

func _update_bet_buttons_ui() -> void:
	var is_de: bool = (GameManager.current_lang == "de")
	
	if current_state == State.WAITING:
		# Bet 1
		if bet1_placed:
			bet1_btn.text = "PLATZIERT" if is_de else "PLACED"
			bet1_btn.disabled = true
		else:
			bet1_btn.text = "BET"
			bet1_btn.disabled = false
		bet1_val_lbl.text = GameManager.format_cash(bet1_cents)
		
		# Bet 2
		if bet2_placed:
			bet2_btn.text = "PLATZIERT" if is_de else "PLACED"
			bet2_btn.disabled = true
		else:
			bet2_btn.text = "BET"
			bet2_btn.disabled = false
		bet2_val_lbl.text = GameManager.format_cash(bet2_cents)
		
	elif current_state == State.FLYING:
		# Bet 1
		if bet1_placed and not bet1_cashed_out:
			bet1_btn.text = "CASHOUT (%s)" % GameManager.format_cash(int(bet1_cents * current_multiplier))
			bet1_btn.disabled = false
			bet1_val_lbl.text = GameManager.format_cash(bet1_cents)
		elif bet1_queued_for_next:
			bet1_btn.text = "NAECHSTE RUNDE" if is_de else "NEXT ROUND"
			bet1_btn.disabled = true
			bet1_val_lbl.text = GameManager.format_cash(bet1_next_cents)
		else:
			bet1_btn.text = "FUER NAECHSTE" if is_de else "BET NEXT"
			bet1_btn.disabled = false
			bet1_val_lbl.text = GameManager.format_cash(bet1_next_cents)
			
		# Bet 2
		if bet2_placed and not bet2_cashed_out:
			bet2_btn.text = "CASHOUT (%s)" % GameManager.format_cash(int(bet2_cents * current_multiplier))
			bet2_btn.disabled = false
			bet2_val_lbl.text = GameManager.format_cash(bet2_cents)
		elif bet2_queued_for_next:
			bet2_btn.text = "NAECHSTE RUNDE" if is_de else "NEXT ROUND"
			bet2_btn.disabled = true
			bet2_val_lbl.text = GameManager.format_cash(bet2_next_cents)
		else:
			bet2_btn.text = "FUER NAECHSTE" if is_de else "BET NEXT"
			bet2_btn.disabled = false
			bet2_val_lbl.text = GameManager.format_cash(bet2_next_cents)

func start_flight() -> void:
	current_state = State.FLYING
	state_time = 0.0
	
	# Generate crash multiplier: C = 0.99 / (1 - U)
	var u := randf()
	if u < 0.04: # 4% instant crash
		crash_multiplier = 1.00
	else:
		crash_multiplier = clampf(0.99 / (1.0 - u), 1.01, 100.0)
	
	var is_de: bool = (GameManager.current_lang == "de")
	status_label.text = "Flugzeug gestartet! Steige rechtzeitig aus!" if is_de else "Plane airborne! Cash out before crash!"
	status_label.modulate = Color(0.3, 0.9, 1.0)
	
	if trail_line:
		trail_line.clear_points()
		trail_line.add_point(plane_sprite.position + Vector2(-14, 0))
		
	_update_bet_buttons_ui()

func _process(delta: float) -> void:
	var is_de: bool = (GameManager.current_lang == "de")
	
	if current_state == State.WAITING:
		countdown_remaining -= delta
		if countdown_remaining > 0.0:
			multiplier_label.text = "%.1fs" % countdown_remaining
			status_label.text = ("Naechste Runde startet in %.1f Sekunden..." if is_de else "Next round starts in %.1f seconds...") % countdown_remaining
			status_label.modulate = Color(1.0, 0.85, 0.25)
		else:
			start_flight()
			
	elif current_state == State.FLYING:
		state_time += delta
		# Exponential rise
		current_multiplier = exp(0.08 * state_time)
		multiplier_label.text = "%.2fX" % current_multiplier
		
		# Move plane smoothly up and right
		var t := clampf(state_time / 14.0, 0.0, 1.0)
		var current_pos: Vector2 = start_pos.lerp(target_pos, t) + Vector2(0, sin(state_time * 6.0) * 3.5)
		plane_sprite.position = current_pos
		
		# Add points to line trail
		trail_timer += delta
		if trail_timer >= 0.04:
			trail_timer = 0.0
			var tail_pos := current_pos + Vector2(-16, 2).rotated(plane_sprite.rotation)
			trail_line.add_point(tail_pos)
			if trail_line.get_point_count() > 40:
				trail_line.remove_point(0)
				
		_update_bet_buttons_ui()
		
		if current_multiplier >= crash_multiplier:
			_crash()
			
	elif current_state == State.CRASHED:
		state_time += delta
		if state_time >= 2.0:
			start_countdown()

func _crash() -> void:
	current_state = State.CRASHED
	state_time = 0.0
	multiplier_label.text = "%.2fX CRASHED!" % crash_multiplier
	multiplier_label.modulate = Color(1.0, 0.25, 0.25)
	
	var is_de: bool = (GameManager.current_lang == "de")
	status_label.text = "Flugzeug abgestuerzt! Neuer Countdown in Kuerze..." if is_de else "Plane crashed! New countdown starting soon..."
	status_label.modulate = Color(1.0, 0.3, 0.3)
	SoundManager.play_sfx("crash")
	
	# Fade plane slightly on crash
	plane_sprite.modulate = Color(1.0, 0.3, 0.3, 0.7)
	
	# Add to history
	history.push_front(crash_multiplier)
	if history.size() > 10:
		history.pop_back()
	update_history_ui()
	
	# Disable cashouts
	if bet1_placed and not bet1_cashed_out:
		bet1_btn.disabled = true
	if bet2_placed and not bet2_cashed_out:
		bet2_btn.disabled = true

func _on_bet1_action() -> void:
	var is_de: bool = (GameManager.current_lang == "de")
	if current_state == State.WAITING:
		if not bet1_placed:
			if GameManager.spend_cash(bet1_cents):
				bet1_placed = true
				SoundManager.play_sfx("button_click")
				_update_bet_buttons_ui()
			else:
				status_label.text = "Nicht genug Geld fuer Wette 1!" if is_de else "Not enough cash for Bet 1!"
				status_label.modulate = Color(1.0, 0.3, 0.3)
	elif current_state == State.FLYING:
		if bet1_placed and not bet1_cashed_out:
			# Cashout current active bet
			bet1_cashed_out = true
			var win_cents := int(bet1_cents * current_multiplier)
			GameManager.add_cash(win_cents)
			bet1_btn.text = "GEWONNEN!" if is_de else "WON!"
			bet1_btn.disabled = true
			SoundManager.play_sfx("coin_win")
		elif not bet1_placed and not bet1_queued_for_next:
			# Place bet for NEXT round while flight is active
			if GameManager.spend_cash(bet1_next_cents):
				bet1_queued_for_next = true
				SoundManager.play_sfx("button_click")
				_update_bet_buttons_ui()
			else:
				status_label.text = "Nicht genug Geld fuer naechste Runde!" if is_de else "Not enough cash for next round!"
				status_label.modulate = Color(1.0, 0.3, 0.3)

func _on_bet2_action() -> void:
	var is_de: bool = (GameManager.current_lang == "de")
	if current_state == State.WAITING:
		if not bet2_placed:
			if GameManager.spend_cash(bet2_cents):
				bet2_placed = true
				SoundManager.play_sfx("button_click")
				_update_bet_buttons_ui()
			else:
				status_label.text = "Nicht genug Geld fuer Wette 2!" if is_de else "Not enough cash for Bet 2!"
				status_label.modulate = Color(1.0, 0.3, 0.3)
	elif current_state == State.FLYING:
		if bet2_placed and not bet2_cashed_out:
			# Cashout current active bet
			bet2_cashed_out = true
			var win_cents := int(bet2_cents * current_multiplier)
			GameManager.add_cash(win_cents)
			bet2_btn.text = "GEWONNEN!" if is_de else "WON!"
			bet2_btn.disabled = true
			SoundManager.play_sfx("coin_win")
		elif not bet2_placed and not bet2_queued_for_next:
			# Place bet for NEXT round while flight is active
			if GameManager.spend_cash(bet2_next_cents):
				bet2_queued_for_next = true
				SoundManager.play_sfx("button_click")
				_update_bet_buttons_ui()
			else:
				status_label.text = "Nicht genug Geld fuer naechste Runde!" if is_de else "Not enough cash for next round!"
				status_label.modulate = Color(1.0, 0.3, 0.3)

func _on_close_pressed() -> void:
	minigame_closed.emit()
