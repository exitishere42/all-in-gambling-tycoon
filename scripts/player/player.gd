extends CharacterBody2D

@export var move_speed: float = 140.0
@onready var sprite: Sprite2D = $Sprite2D
@onready var interact_detector: Area2D = $InteractDetector
@onready var camera: Camera2D = $Camera2D

var can_move: bool = true

# Zoom state (defaults to close-up 1.75x)
var target_zoom: float = 1.75
const MIN_ZOOM: float = 1.25
const MAX_ZOOM: float = 2.25

# Animation state
var anim_time: float = 0.0
const BASE_SPRITE_Y: float = -12.0

func _ready() -> void:
	update_camera_bounds()
	GameManager.area_unlocked.connect(func(_area): update_camera_bounds())

func update_camera_bounds() -> void:
	if not camera: return
	camera.limit_left = 35
	camera.limit_right = 1245
	camera.limit_bottom = 980
	if GameManager.game_mode == "tycoon":
		camera.limit_top = 35 if GameManager.is_area_unlocked("vip_lounge") else 240
	else:
		camera.limit_top = 35

func _physics_process(delta: float) -> void:
	if not can_move or GameManager.is_game_over or GameManager.active_minigame != "":
		velocity = Vector2.ZERO
		_update_animations(delta, false)
		return
		
	var input_vector := Vector2.ZERO
	input_vector.x = Input.get_axis("move_left", "move_right")
	input_vector.y = Input.get_axis("move_up", "move_down")
	
	var is_moving := false
	if input_vector != Vector2.ZERO:
		is_moving = true
		input_vector = input_vector.normalized()
		velocity = input_vector * move_speed
		
		# Facing direction flip
		if input_vector.x < 0:
			sprite.flip_h = true
		elif input_vector.x > 0:
			sprite.flip_h = false
	else:
		velocity = Vector2.ZERO
		
	move_and_slide()
	_update_animations(delta, is_moving)

func _update_animations(delta: float, is_moving: bool) -> void:
	anim_time += delta
	if is_moving:
		# Walk cycle: energetic step bobbing (up/down) + slight foot roll tilt
		var step_bob = abs(sin(anim_time * 14.0)) * 3.5
		sprite.position.y = -step_bob
		sprite.rotation = sin(anim_time * 14.0) * 0.12 # slight walk tilt
		# Squash and stretch
		sprite.scale = Vector2(1.0 + sin(anim_time * 14.0) * 0.05, 1.0 - sin(anim_time * 14.0) * 0.05)
	else:
		# Idle: clean, stable natural breathing (no unnatural bouncing)
		sprite.position.y = 0.0
		sprite.rotation = 0.0
		sprite.scale = Vector2(1.0, 1.0 + sin(anim_time * 2.5) * 0.02)

func _process(delta: float) -> void:
	if camera:
		camera.zoom = camera.zoom.lerp(Vector2(target_zoom, target_zoom), delta * 8.0)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			target_zoom = clamp(target_zoom + 0.1, MIN_ZOOM, MAX_ZOOM)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			target_zoom = clamp(target_zoom - 0.1, MIN_ZOOM, MAX_ZOOM)
			
	if event.is_action_pressed("interact"):
		trigger_nearby_interaction()

func trigger_nearby_interaction() -> void:
	if not interact_detector:
		return
	var areas = interact_detector.get_overlapping_areas()
	for area in areas:
		if area.is_in_group("interactable"):
			if area.has_method("on_interact"):
				area.on_interact()
				return
			var parent = area.get_parent()
			if parent and parent.has_method("on_interact"):
				parent.on_interact()
				return
			if area.has_meta("owner_cabinet"):
				var cab = area.get_meta("owner_cabinet")
				if cab and cab.has_method("on_interact"):
					cab.on_interact()
					return
