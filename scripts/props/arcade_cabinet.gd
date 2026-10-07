extends StaticBody2D

@export var machine_id: String = "slots" # slots, crash, roulette
@export var machine_name: String = "Slots"
@export var cabinet_texture: Texture2D

@onready var interact_area: Area2D = $InteractArea
@onready var prompt_label: Label = $PromptLabel
@onready var sprite_2d: Sprite2D = $Sprite2D

const PIXEL_FONT = preload("res://assets/fonts/Silkscreen-Regular.ttf")

func _ready() -> void:
	if machine_id == "slot_rusty":
		machine_id = "slots"
	if cabinet_texture:
		sprite_2d.texture = cabinet_texture
	interact_area.add_to_group("interactable")
	# Store reference to parent on the area for interaction forwarding
	interact_area.set_meta("owner_cabinet", self)
	prompt_label.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	prompt_label.add_theme_font_override("font", PIXEL_FONT)
	prompt_label.add_theme_font_size_override("font_size", 11)
	prompt_label.visible = false
	interact_area.body_entered.connect(_on_body_entered)
	interact_area.body_exited.connect(_on_body_exited)
	interact_area.area_entered.connect(_on_area_entered)
	interact_area.area_exited.connect(_on_area_exited)

func update_status() -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" or body.is_in_group("player"):
		update_prompt_text()
		prompt_label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player" or body.is_in_group("player"):
		prompt_label.visible = false

func _on_area_entered(area: Area2D) -> void:
	if area.name == "InteractDetector" or area.get_parent().name == "Player":
		update_prompt_text()
		prompt_label.visible = true

func _on_area_exited(area: Area2D) -> void:
	if area.name == "InteractDetector" or area.get_parent().name == "Player":
		prompt_label.visible = false

func update_prompt_text() -> void:
	if GameManager.is_unlocked(machine_id):
		prompt_label.text = GameManager.tr_text("interact_play")
		prompt_label.modulate = Color(0.2, 1.0, 0.4)
	else:
		var cost := GameManager.get_unlock_cost(machine_id)
		prompt_label.text = GameManager.tr_text("interact_unlock") % GameManager.format_cash(cost)
		prompt_label.modulate = Color(1.0, 0.8, 0.2)

func on_interact() -> void:
	if GameManager.is_unlocked(machine_id):
		# Open minigame UI
		var main_node = get_tree().get_first_node_in_group("main_coordinator")
		if not main_node:
			main_node = get_tree().root.get_node_or_null("Main")
		if not main_node:
			main_node = get_tree().current_scene
		if main_node and main_node.has_method("open_minigame"):
			main_node.open_minigame(machine_id)
	else:
		# Attempt unlock
		if GameManager.unlock_machine(machine_id):
			update_prompt_text()
		else:
			prompt_label.text = GameManager.tr_text("not_enough_cash")
			prompt_label.modulate = Color(1.0, 0.2, 0.2)
