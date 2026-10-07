extends Area2D

@onready var prompt: Label = $PromptLabel
var is_collected: bool = false

func _ready() -> void:
	add_to_group("interactable")
	prompt.text = GameManager.tr_text("collect_bottle")
	prompt.visible = false
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		prompt.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		prompt.visible = false

func _on_area_entered(area: Area2D) -> void:
	if area.name == "InteractDetector" or area.get_parent().name == "Player":
		prompt.visible = true

func _on_area_exited(area: Area2D) -> void:
	if area.name == "InteractDetector" or area.get_parent().name == "Player":
		prompt.visible = false

func on_interact() -> void:
	if is_collected:
		return
	is_collected = true
	
	GameManager.collect_bottle()
	if SoundManager:
		SoundManager.play_sfx("coin_win")
		
	# Spawn floating pickup text "+$0.25" in world
	_spawn_pickup_text()
	queue_free()

const PIXEL_FONT = preload("res://assets/fonts/Silkscreen-Regular.ttf")

func _spawn_pickup_text() -> void:
	var parent_node = get_parent()
	if not parent_node:
		return
		
	var float_label := Label.new()
	float_label.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	float_label.text = "+$0.25"
	float_label.z_index = 35
	float_label.add_theme_font_override("font", PIXEL_FONT)
	float_label.add_theme_font_size_override("font_size", 12)
	float_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5))
	float_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	float_label.add_theme_constant_override("outline_size", 6)
	float_label.global_position = global_position + Vector2(-28, -26)
	parent_node.add_child(float_label)
	
	var tween = float_label.create_tween()
	tween.set_parallel(true)
	tween.tween_property(float_label, "position:y", float_label.position.y - 28.0, 0.7).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(float_label, "modulate:a", 0.0, 0.7).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(float_label.queue_free)
