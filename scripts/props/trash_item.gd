extends Area2D

signal trash_cleaned(item_type: String, cash_found_cents: int)

@export var trash_type: String = "trash_bag"

@onready var sprite: Sprite2D = $Sprite2D
@onready var prompt_label: Label = $PromptLabel

var is_player_nearby: bool = false
var is_cleaned: bool = false

var textures = {
	"trash_bag": preload("res://assets/sprites/cleanup/trash_bag.png"),
	"trash_pile": preload("res://assets/sprites/cleanup/trash_pile.png"),
	"dirt_stain": preload("res://assets/sprites/cleanup/dirt_stain.png"),
	"cobweb": preload("res://assets/sprites/cleanup/cobweb.png"),
	"spilled_chips": preload("res://assets/sprites/cleanup/spilled_chips.png")
}

func _ready() -> void:
	add_to_group("interactable")
	if textures.has(trash_type):
		sprite.texture = textures[trash_type]
		
	prompt_label.visible = false
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" or body.is_in_group("player"):
		is_player_nearby = true
		prompt_label.visible = true
		prompt_label.text = "[E] Aufräumen"

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player" or body.is_in_group("player"):
		is_player_nearby = false
		prompt_label.visible = false

func _on_area_entered(area: Area2D) -> void:
	if area.name == "InteractDetector" or area.get_parent().name == "Player":
		is_player_nearby = true
		prompt_label.visible = true
		prompt_label.text = "[E] Aufräumen"

func _on_area_exited(area: Area2D) -> void:
	if area.name == "InteractDetector" or area.get_parent().name == "Player":
		is_player_nearby = false
		prompt_label.visible = false

func on_interact() -> void:
	if not is_cleaned:
		clean_up()

func _unhandled_input(event: InputEvent) -> void:
	if is_player_nearby and not is_cleaned and event.is_action_pressed("interact"):
		clean_up()

func clean_up() -> void:
	if is_cleaned: return
	is_cleaned = true
	is_player_nearby = false
	prompt_label.visible = false
	
	# Cash found under trash: $2.00 per item ($20.00 total for 10 items)
	var cash_found = 200
	GameManager.add_cash(cash_found)
	GameManager.cleaned_trash_count += 1
	
	if SoundManager:
		SoundManager.play_sfx("coin_win")
		
	var main_coord = get_tree().get_first_node_in_group("main_coordinator")
	if main_coord and main_coord.hud:
		main_coord.hud.show_floating_banner("Müll aufgeräumt: %d/%d (+$%.2f)" % [
			GameManager.cleaned_trash_count,
			GameManager.total_trash_count,
			cash_found / 100.0
		])
		
	# Floating text effect
	var float_lbl = Label.new()
	float_lbl.text = "+$%.2f!" % (cash_found / 100.0)
	float_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	float_lbl.add_theme_font_override("font", preload("res://assets/fonts/Silkscreen-Regular.ttf"))
	float_lbl.add_theme_font_size_override("font_size", 13)
	float_lbl.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5))
	float_lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	float_lbl.add_theme_constant_override("outline_size", 2)
	float_lbl.position = Vector2(-30, -35)
	add_child(float_lbl)
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(float_lbl, "position:y", float_lbl.position.y - 25.0, 0.6)
	tween.tween_property(float_lbl, "modulate:a", 0.0, 0.6)
	tween.tween_property(sprite, "modulate:a", 0.0, 0.3)
	tween.tween_property(sprite, "scale", Vector2(0.2, 0.2), 0.3)
	
	await get_tree().create_timer(0.65).timeout
	trash_cleaned.emit(trash_type, cash_found)
	queue_free()
