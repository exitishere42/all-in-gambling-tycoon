extends StaticBody2D

@export var item_type: String = "bar_counter"

@onready var sprite: Sprite2D = $Sprite2D
@onready var prompt_lbl: Label = $PromptLabel
@onready var interact_area: Area2D = $InteractArea

var is_player_nearby: bool = false

const TEXTURES = {
	"slot_rusty": "res://assets/sprites/props/slot_machine_rusty.png",
	"slot_modern": "res://assets/sprites/raw_slots/Slot Machine/slot-machine1.png",
	"crash": "res://assets/sprites/environment/crash_cabinet.png",
	"roulette": "res://assets/sprites/props/roulette_table.png",
	"blackjack": "res://assets/sprites/props/blackjack_table.png",
	"bar_counter": "res://assets/sprites/furniture/bar_counter.png",
	"bar_stool": "res://assets/sprites/furniture/bar_stool.png",
	"table": "res://assets/sprites/environment/table.png",
	"atm": "res://assets/sprites/furniture/atm_machine.png",
	"plant": "res://assets/sprites/furniture/potted_plant.png",
	"trash_bin": "res://assets/sprites/furniture/trash_bin.png"
}

func _ready() -> void:
	if TEXTURES.has(item_type) and ResourceLoader.exists(TEXTURES[item_type]):
		sprite.texture = load(TEXTURES[item_type])
		
	# Stools/chairs are walkable seating furniture, disable wall collision so guests can sit cleanly!
	if item_type == "bar_stool":
		var col = get_node_or_null("CollisionShape2D")
		if col:
			col.set_deferred("disabled", true)
		collision_layer = 0
	elif item_type == "table":
		var col = get_node_or_null("CollisionShape2D")
		if col:
			var new_shape = RectangleShape2D.new()
			new_shape.size = Vector2(76, 36)
			col.shape = new_shape
			col.position = Vector2(0, -6)
	elif item_type == "bar_counter":
		# Vending machine: 32x48 upright cabinet
		sprite.offset = Vector2(0, -20)
		var col = get_node_or_null("CollisionShape2D")
		if col:
			var new_shape = RectangleShape2D.new()
			new_shape.size = Vector2(26, 20)
			col.shape = new_shape
			col.position = Vector2(0, -2)
		
	prompt_lbl.visible = false
	interact_area.add_to_group("interactable")
	interact_area.set_meta("owner_cabinet", self)
	
	interact_area.body_entered.connect(_on_body_entered)
	interact_area.body_exited.connect(_on_body_exited)
	interact_area.area_entered.connect(_on_area_entered)
	interact_area.area_exited.connect(_on_area_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" or body.is_in_group("player"):
		_show_prompt()

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player" or body.is_in_group("player"):
		_hide_prompt()

func _on_area_entered(area: Area2D) -> void:
	if area.name == "InteractDetector" or area.get_parent().name == "Player":
		_show_prompt()

func _on_area_exited(area: Area2D) -> void:
	if area.name == "InteractDetector" or area.get_parent().name == "Player":
		_hide_prompt()

func _show_prompt() -> void:
	is_player_nearby = true
	prompt_lbl.visible = true
	match item_type:
		"slot_rusty", "slot_modern": prompt_lbl.text = "[E] Slots spielen"
		"crash": prompt_lbl.text = "[E] Crash spielen"
		"roulette": prompt_lbl.text = "[E] Roulette spielen"
		"blackjack": prompt_lbl.text = "[E] Blackjack spielen"
		"bar_counter": prompt_lbl.text = "[E] Getränk kaufen ($10)"
		"table": prompt_lbl.text = "Casino-Tisch"
		"atm": prompt_lbl.text = "Casino Geldautomat"
		"plant": prompt_lbl.text = "Casino-Palme"
		"trash_bin": prompt_lbl.text = "Casino-Mülleimer"
		_: prompt_lbl.text = "[E] Interagieren"

func _hide_prompt() -> void:
	is_player_nearby = false
	prompt_lbl.visible = false

func on_interact() -> void:
	trigger_action()

func _unhandled_input(event: InputEvent) -> void:
	if is_player_nearby and event.is_action_pressed("interact"):
		trigger_action()

func trigger_action() -> void:
	var coord = get_tree().get_first_node_in_group("main_coordinator")
	match item_type:
		"slot_rusty", "slot_modern":
			if coord: coord.open_minigame(item_type)
		"crash":
			if coord: coord.open_minigame(GameManager.MACHINE_CRASH)
		"roulette":
			if coord: coord.open_minigame(GameManager.MACHINE_ROULETTE)
		"blackjack":
			if coord: coord.open_minigame(GameManager.MACHINE_BLACKJACK)
		"bar_counter":
			if GameManager.cash_cents >= 1000:
				GameManager.add_cash(-1000)
				if SoundManager: SoundManager.play_sfx("lever_release")
				prompt_lbl.text = "Dose entnommen! (-$10)"
			else:
				prompt_lbl.text = "Zu wenig Geld!"
