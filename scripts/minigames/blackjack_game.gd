extends Control

signal minigame_closed

const BET_OPTIONS: Array[int] = [100, 500, 1000, 2500, 5000] # $1, $5, $10, $25, $50 in cents
var current_bet_idx := 0

# Deck and hand state
var deck: Array[Dictionary] = []
var player_hand: Array[Dictionary] = []
var dealer_hand: Array[Dictionary] = []

enum State { BETTING, PLAYING, DEALER_TURN, ROUND_OVER }
var state := State.BETTING

@onready var dealer_cards_container: HBoxContainer = $Panel/VBoxContainer/DealerSection/CardsContainer
@onready var dealer_score_lbl: Label = $Panel/VBoxContainer/DealerSection/ScoreLabel
@onready var player_cards_container: HBoxContainer = $Panel/VBoxContainer/PlayerSection/CardsContainer
@onready var player_score_lbl: Label = $Panel/VBoxContainer/PlayerSection/ScoreLabel
@onready var status_lbl: Label = $Panel/VBoxContainer/StatusLabel
@onready var bet_val_lbl: Label = $Panel/BottomBar/BetBox/BetVal
@onready var deal_btn: Button = $Panel/BottomBar/DealBtn
@onready var hit_btn: Button = $Panel/BottomBar/HitBtn
@onready var stand_btn: Button = $Panel/BottomBar/StandBtn
@onready var double_btn: Button = $Panel/BottomBar/DoubleBtn
@onready var bet_minus_btn: Button = $Panel/BottomBar/BetBox/MinusBtn
@onready var bet_plus_btn: Button = $Panel/BottomBar/BetBox/PlusBtn
@onready var close_btn: TextureButton = $CloseBtn

var card_front_tex = preload("res://assets/sprites/cards/card_front.png")
var card_back_tex = preload("res://assets/sprites/cards/card_back.png")
var silkscreen_font = preload("res://assets/fonts/Silkscreen-Regular.ttf")

func _ready() -> void:
	close_btn.pressed.connect(_on_close_pressed)
	deal_btn.pressed.connect(_on_deal_pressed)
	hit_btn.pressed.connect(_on_hit_pressed)
	stand_btn.pressed.connect(_on_stand_pressed)
	double_btn.pressed.connect(_on_double_pressed)
	bet_minus_btn.pressed.connect(_on_minus_bet)
	bet_plus_btn.pressed.connect(_on_plus_bet)
	
	_update_bet_ui()
	_set_ui_state(State.BETTING)
	status_lbl.text = "Place your bet and press DEAL!"

func _update_bet_ui() -> void:
	bet_val_lbl.text = "$%.2f" % (BET_OPTIONS[current_bet_idx] / 100.0)

func _on_minus_bet() -> void:
	if state != State.BETTING: return
	if current_bet_idx > 0:
		current_bet_idx -= 1
		_update_bet_ui()
		if SoundManager: SoundManager.play_sfx("chip_bet")

func _on_plus_bet() -> void:
	if state != State.BETTING: return
	if current_bet_idx < BET_OPTIONS.size() - 1:
		current_bet_idx += 1
		_update_bet_ui()
		if SoundManager: SoundManager.play_sfx("chip_bet")

func _build_deck() -> void:
	deck.clear()
	var suits = ["♠", "♥", "♦", "♣"]
	var ranks = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"]
	for s in suits:
		for r in ranks:
			var val = 0
			if r in ["J", "Q", "K"]: val = 10
			elif r == "A": val = 11
			else: val = int(r)
			var is_red = (s == "♥" or s == "♦")
			deck.append({"rank": r, "suit": s, "val": val, "is_red": is_red})
	deck.shuffle()

func _draw_card() -> Dictionary:
	if deck.is_empty():
		_build_deck()
	return deck.pop_back()

func _calculate_score(hand: Array[Dictionary]) -> int:
	var total = 0
	var aces = 0
	for c in hand:
		total += c["val"]
		if c["rank"] == "A":
			aces += 1
	while total > 21 and aces > 0:
		total -= 10
		aces -= 1
	return total

func _on_deal_pressed() -> void:
	is_doubled = false
	var bet = BET_OPTIONS[current_bet_idx]
	if GameManager.cash_cents < bet:
		status_lbl.text = "Not enough cash!"
		status_lbl.modulate = Color(1.0, 0.3, 0.3)
		return
		
	GameManager.add_cash(-bet)
	if SoundManager: SoundManager.play_sfx("lever_pull")
	
	_build_deck()
	player_hand.clear()
	dealer_hand.clear()
	
	player_hand.append(_draw_card())
	dealer_hand.append(_draw_card())
	player_hand.append(_draw_card())
	dealer_hand.append(_draw_card())
	
	_set_ui_state(State.PLAYING)
	_render_hands(false)
	
	var p_score = _calculate_score(player_hand)
	var d_score = _calculate_score(dealer_hand)
	
	if p_score == 21:
		if d_score == 21:
			_end_round("PUSH! Both have Blackjack!", 0)
		else:
			var win_amount = int(bet * 2.5) # 3:2 payout (original bet + 1.5x)
			_end_round("BLACKJACK! You win $%.2f!" % (win_amount / 100.0), win_amount)
	else:
		status_lbl.text = "Hit, Stand or Double?"
		status_lbl.modulate = Color(1, 1, 1)

func _on_hit_pressed() -> void:
	if state != State.PLAYING: return
	player_hand.append(_draw_card())
	if SoundManager: SoundManager.play_sfx("lever_release")
	_render_hands(false)
	
	var score = _calculate_score(player_hand)
	if score > 21:
		_end_round("BUST! You went over 21!", 0)
	elif score == 21:
		_on_stand_pressed()

var is_doubled: bool = false

func _on_double_pressed() -> void:
	if state != State.PLAYING: return
	var bet = BET_OPTIONS[current_bet_idx]
	if GameManager.cash_cents < bet:
		status_lbl.text = "Not enough cash to double!"
		return
	GameManager.add_cash(-bet)
	is_doubled = true
	
	player_hand.append(_draw_card())
	if SoundManager: SoundManager.play_sfx("lever_release")
	_render_hands(false)
	
	var score = _calculate_score(player_hand)
	if score > 21:
		_end_round("BUST on Double! Over 21!", 0)
	else:
		_on_stand_pressed()

func _on_stand_pressed() -> void:
	if state != State.PLAYING: return
	_set_ui_state(State.DEALER_TURN)
	_render_hands(true) # reveal dealer's second card
	
	# Dealer hits until score >= 17
	while _calculate_score(dealer_hand) < 17:
		await get_tree().create_timer(0.4).timeout
		dealer_hand.append(_draw_card())
		if SoundManager: SoundManager.play_sfx("lever_release")
		_render_hands(true)
		
	var p_score = _calculate_score(player_hand)
	var d_score = _calculate_score(dealer_hand)
	var bet = BET_OPTIONS[current_bet_idx] * (2 if is_doubled else 1)
	
	if d_score > 21:
		_end_round("DEALER BUST! You win $%.2f!" % (bet * 2 / 100.0), bet * 2)
	elif p_score > d_score:
		_end_round("YOU WIN $%.2f!" % (bet * 2 / 100.0), bet * 2)
	elif p_score < d_score:
		_end_round("Dealer wins (%d vs %d)." % [d_score, p_score], 0)
	else:
		_end_round("PUSH (Tie)! Bet returned.", bet)

func _end_round(msg: String, payout: int) -> void:
	_set_ui_state(State.ROUND_OVER)
	_render_hands(true)
	status_lbl.text = msg
	
	if payout > 0:
		GameManager.add_cash(payout)
		status_lbl.modulate = Color(0.2, 1.0, 0.4)
		if payout > BET_OPTIONS[current_bet_idx]:
			if SoundManager: SoundManager.play_sfx("jackpot")
	else:
		status_lbl.modulate = Color(1.0, 0.35, 0.35)

func _render_hands(show_dealer_full: bool) -> void:
	# Clear
	for c in dealer_cards_container.get_children(): c.queue_free()
	for c in player_cards_container.get_children(): c.queue_free()
	
	# Render Dealer cards
	for i in range(dealer_hand.size()):
		var card = dealer_hand[i]
		if i == 1 and not show_dealer_full:
			dealer_cards_container.add_child(_create_card_node(card, true))
		else:
			dealer_cards_container.add_child(_create_card_node(card, false))
			
	if show_dealer_full:
		dealer_score_lbl.text = "Score: %d" % _calculate_score(dealer_hand)
	elif dealer_hand.size() > 0:
		dealer_score_lbl.text = "Score: %d + ?" % dealer_hand[0]["val"]
	else:
		dealer_score_lbl.text = "Score: 0"
		
	# Render Player cards
	for card in player_hand:
		player_cards_container.add_child(_create_card_node(card, false))
	player_score_lbl.text = "Score: %d" % _calculate_score(player_hand)

func _create_card_node(card: Dictionary, is_hidden: bool) -> Control:
	var root = TextureRect.new()
	root.custom_minimum_size = Vector2(54, 75)
	root.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	root.stretch_mode = TextureRect.STRETCH_SCALE
	
	if is_hidden:
		root.texture = card_back_tex
	else:
		root.texture = card_front_tex
		var lbl = Label.new()
		lbl.text = "%s\n%s" % [card["rank"], card["suit"]]
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lbl.add_theme_font_override("font", silkscreen_font)
		lbl.add_theme_font_size_override("font_size", 14)
		if card["is_red"]:
			lbl.add_theme_color_override("font_color", Color(0.85, 0.15, 0.15))
		else:
			lbl.add_theme_color_override("font_color", Color(0.12, 0.12, 0.15))
		lbl.set_anchors_preset(PRESET_FULL_RECT)
		root.add_child(lbl)
		
	return root

func _set_ui_state(s: State) -> void:
	state = s
	deal_btn.visible = (s == State.BETTING or s == State.ROUND_OVER)
	hit_btn.visible = (s == State.PLAYING)
	stand_btn.visible = (s == State.PLAYING)
	double_btn.visible = (s == State.PLAYING and player_hand.size() == 2)
	bet_minus_btn.disabled = (s == State.PLAYING or s == State.DEALER_TURN)
	bet_plus_btn.disabled = (s == State.PLAYING or s == State.DEALER_TURN)

func _on_close_pressed() -> void:
	if SoundManager: SoundManager.play_sfx("lever_release")
	minigame_closed.emit()
