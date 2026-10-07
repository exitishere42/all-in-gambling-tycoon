extends Control

# Virtual Joystick for mobile & touch controls
# Emulates Input actions: move_left, move_right, move_up, move_down

@export var max_distance: float = 60.0
@export var deadzone: float = 12.0

@onready var tip: TextureRect = $Tip

var touch_index: int = -1
var is_dragging: bool = false
var center_pos: Vector2 = Vector2.ZERO
var current_vector: Vector2 = Vector2.ZERO

func _ready() -> void:
	center_pos = size / 2.0
	_reset_tip()

func _reset_tip() -> void:
	tip.position = center_pos - (tip.size / 2.0)
	current_vector = Vector2.ZERO
	_update_input_actions(Vector2.ZERO)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			if touch_index == -1:
				touch_index = event.index
				is_dragging = true
				_handle_input_pos(event.position)
		elif event.index == touch_index:
			touch_index = -1
			is_dragging = false
			_reset_tip()
	elif event is InputEventScreenDrag and event.index == touch_index:
		_handle_input_pos(event.position)
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = true
				_handle_input_pos(event.position)
			else:
				is_dragging = false
				_reset_tip()
	elif event is InputEventMouseMotion and is_dragging:
		_handle_input_pos(event.position)

func _handle_input_pos(pos: Vector2) -> void:
	var diff := pos - center_pos
	var dist := diff.length()
	
	if dist > max_distance:
		diff = diff.normalized() * max_distance
		
	tip.position = (center_pos + diff) - (tip.size / 2.0)
	
	if dist < deadzone:
		current_vector = Vector2.ZERO
	else:
		current_vector = diff / max_distance
		
	_update_input_actions(current_vector)

func _update_input_actions(vec: Vector2) -> void:
	# Horizontal actions
	if vec.x < -0.3:
		Input.action_press("move_left", abs(vec.x))
		Input.action_release("move_right")
	elif vec.x > 0.3:
		Input.action_press("move_right", abs(vec.x))
		Input.action_release("move_left")
	else:
		Input.action_release("move_left")
		Input.action_release("move_right")
		
	# Vertical actions
	if vec.y < -0.3:
		Input.action_press("move_up", abs(vec.y))
		Input.action_release("move_down")
	elif vec.y > 0.3:
		Input.action_press("move_down", abs(vec.y))
		Input.action_release("move_up")
	else:
		Input.action_release("move_up")
		Input.action_release("move_down")

func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED and not is_visible_in_tree():
		if is_dragging or touch_index != -1:
			touch_index = -1
			is_dragging = false
			_reset_tip()
