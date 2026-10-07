extends CharacterBody2D

@export var texture_path: String = "res://assets/sprites/npcs/npc_gambler1.png"
@export var is_wandering: bool = true
@export var wander_speed: float = 35.0

@onready var sprite: Sprite2D = $Sprite2D

var move_timer := 0.0
var move_direction := Vector2.ZERO
var pause_timer := 0.0

# Animation variables
var anim_time: float = 0.0
var anim_offset: float = 0.0

enum State {
	QUEUING,
	ENTERING,
	ROAMING,
	PLAYING_GAME,
	ORDERING_BAR,
	QUEUING_VENDING,
	DRINKING_STANDING,
	SEATED_STOOL,
	SEATED_TABLE,
	LEAVING
}

var current_state: State = State.ROAMING
var target_destination: Vector2 = Vector2.ZERO
var path_points: Array[Vector2] = []
var current_path_idx: int = 0

# Activity details
var current_activity_pos: Vector2 = Vector2.ZERO
var current_activity_type: String = ""
var activity_timer: float = 0.0
var action_tick_timer: float = 0.0
var target_table_pos: Vector2 = Vector2.ZERO
var has_drink: bool = false
var has_bar_claim: bool = false
var stuck_nav_timer: float = 0.0

func _exit_tree() -> void:
	_free_current_activity()

# Visual action bubble
var bubble_label: Label = null

func _ready() -> void:
	if ResourceLoader.exists(texture_path):
		sprite.texture = load(texture_path)
	anim_offset = randf() * 10.0
	anim_time = anim_offset
	
	_setup_bubble_label()
	
	if is_wandering and current_state == State.ROAMING:
		_pick_new_state()

func _setup_bubble_label() -> void:
	bubble_label = Label.new()
	bubble_label.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	bubble_label.z_index = 25
	bubble_label.visible = false
	bubble_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bubble_label.position = Vector2(-40, -32)
	bubble_label.size = Vector2(80, 16)
	
	var font = load("res://assets/fonts/Silkscreen-Regular.ttf")
	if font:
		bubble_label.add_theme_font_override("font", font)
		bubble_label.add_theme_font_size_override("font_size", 9)
	bubble_label.add_theme_color_override("font_color", Color(1, 0.9, 0.4))
	bubble_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	bubble_label.add_theme_constant_override("outline_size", 4)
	add_child(bubble_label)

func show_bubble(text: String, duration: float = 2.0, color: Color = Color(1, 0.9, 0.4)) -> void:
	if not bubble_label: return
	bubble_label.text = text
	bubble_label.add_theme_color_override("font_color", color)
	bubble_label.visible = true
	bubble_label.modulate.a = 1.0
	
	var tw = create_tween()
	tw.tween_interval(duration * 0.75)
	tw.tween_property(bubble_label, "modulate:a", 0.0, duration * 0.25)
	tw.tween_callback(func():
		if is_instance_valid(bubble_label):
			bubble_label.visible = false
	)

func set_queue_position(target_pos: Vector2) -> void:
	current_state = State.QUEUING
	target_destination = target_pos
	is_wandering = false

func start_entering(waypoints: Array[Vector2]) -> void:
	current_state = State.ENTERING
	path_points = waypoints
	current_path_idx = 0
	is_wandering = false

func assign_bar_seat(seat_pos: Vector2) -> void:
	_free_current_activity()
	current_state = State.SEATED_STOOL
	target_destination = seat_pos
	current_activity_pos = seat_pos
	current_activity_type = "bar_stool"
	activity_timer = randf_range(20.0, 45.0)
	action_tick_timer = randf_range(4.0, 7.0)
	stuck_nav_timer = 0.0
	is_wandering = false

func assign_game(game_type: String, spot_pos: Vector2) -> void:
	_free_current_activity()
	current_state = State.PLAYING_GAME
	target_destination = spot_pos
	current_activity_pos = spot_pos
	current_activity_type = game_type
	activity_timer = randf_range(20.0, 40.0)
	action_tick_timer = randf_range(2.5, 4.5)
	stuck_nav_timer = 0.0
	is_wandering = false

func assign_bar_order(bar_pos: Vector2, next_table_pos: Vector2 = Vector2.ZERO) -> void:
	_free_current_activity()
	current_state = State.ORDERING_BAR
	target_destination = bar_pos
	current_activity_pos = bar_pos
	current_activity_type = "bar_counter"
	target_table_pos = next_table_pos
	activity_timer = randf_range(5.0, 10.0) # Takes 5-10 seconds to purchase beverage!
	action_tick_timer = 2.0
	stuck_nav_timer = 0.0
	is_wandering = false

func assign_vending_queue(queue_pos: Vector2) -> void:
	_free_current_activity()
	current_state = State.QUEUING_VENDING
	target_destination = queue_pos
	current_activity_pos = queue_pos
	current_activity_type = "vending_queue"
	action_tick_timer = randf_range(3.0, 6.0)
	stuck_nav_timer = 0.0
	is_wandering = false
	show_bubble("In der Schlange... ⏳", 2.0, Color(1.0, 0.9, 0.5))

func update_queue_destination(new_pos: Vector2) -> void:
	target_destination = new_pos
	current_activity_pos = new_pos

func advance_to_vending_machine(front_pos: Vector2) -> void:
	current_state = State.ORDERING_BAR
	target_destination = front_pos
	current_activity_pos = front_pos
	current_activity_type = "bar_counter"
	activity_timer = randf_range(5.0, 10.0)
	action_tick_timer = 2.0
	stuck_nav_timer = 0.0
	is_wandering = false
	show_bubble("Jetzt bin ich dran! 🪙", 2.0, Color(1.0, 0.95, 0.4))

func start_drinking_standing() -> void:
	_free_current_activity()
	current_state = State.DRINKING_STANDING
	# Move a few paces aside away from vending machine
	var angle = randf() * TAU
	var offset = Vector2(cos(angle), abs(sin(angle))).normalized() * randf_range(35.0, 65.0)
	target_destination = position + offset
	target_destination.x = clampf(target_destination.x, 150.0, 1150.0)
	target_destination.y = clampf(target_destination.y, 120.0, 600.0)
	activity_timer = randf_range(8.0, 16.0) # Savor drink for 8-16 seconds
	action_tick_timer = randf_range(2.5, 4.0)
	stuck_nav_timer = 0.0
	is_wandering = false
	show_bubble("Erstmal trinken... 🥤", 2.0, Color(0.8, 0.95, 1.0))

func assign_table(table_pos: Vector2) -> void:
	_free_current_activity()
	current_state = State.SEATED_TABLE
	target_destination = table_pos
	current_activity_pos = table_pos
	current_activity_type = "table"
	activity_timer = randf_range(20.0, 40.0)
	action_tick_timer = randf_range(5.0, 8.0)
	stuck_nav_timer = 0.0
	is_wandering = false

func start_leaving(exit_waypoints: Array[Vector2]) -> void:
	_free_current_activity()
	current_state = State.LEAVING
	path_points = exit_waypoints
	current_path_idx = 0
	is_wandering = false
	show_bubble("Bis morgen!", 1.5, Color(0.8, 0.9, 1.0))

func _physics_process(delta: float) -> void:
	anim_time += delta
	var is_moving := false
	
	match current_state:
		State.QUEUING:
			var dist = position.distance_to(target_destination)
			if dist > 4.0:
				var dir = (target_destination - position).normalized()
				velocity = dir * (wander_speed * 0.9)
				is_moving = true
				sprite.flip_h = (dir.x < 0)
				move_and_slide()
			else:
				velocity = Vector2.ZERO
				sprite.flip_h = false
				
		State.ENTERING:
			if current_path_idx < path_points.size():
				var target_pt = path_points[current_path_idx]
				var dist = position.distance_to(target_pt)
				if dist > 6.0:
					var dir = (target_pt - position).normalized()
					velocity = dir * (wander_speed * 1.25)
					is_moving = true
					sprite.flip_h = (dir.x < 0)
					move_and_slide()
				else:
					current_path_idx += 1
			else:
				# Reached inside the casino!
				_decide_next_activity()
				
		State.PLAYING_GAME:
			var dist = position.distance_to(target_destination)
			var arrived = dist <= 6.0 or (dist <= 26.0 and get_real_velocity().length() < 3.0 and is_moving)
			if not arrived:
				stuck_nav_timer += delta
				if stuck_nav_timer > 2.5 and dist <= 36.0:
					arrived = true
				elif stuck_nav_timer > 4.5:
					stuck_nav_timer = 0.0
					_free_current_activity()
					_decide_next_activity()
					return
					
			if not arrived:
				var dir = (target_destination - position).normalized()
				velocity = dir * wander_speed
				is_moving = true
				sprite.flip_h = (dir.x < 0)
				move_and_slide()
			else:
				stuck_nav_timer = 0.0
				position = target_destination
				velocity = Vector2.ZERO
				is_moving = false
				sprite.flip_h = false # Face cabinet
				
				# Play loop
				action_tick_timer -= delta
				if action_tick_timer <= 0.0:
					action_tick_timer = randf_range(3.0, 5.5)
					_do_game_play_tick()
					
				activity_timer -= delta
				if activity_timer <= 0.0:
					_free_current_activity()
					_decide_next_activity()
					
		State.ORDERING_BAR:
			var dist = position.distance_to(target_destination)
			var arrived = dist <= 6.0 or (dist <= 26.0 and get_real_velocity().length() < 3.0 and is_moving)
			if not arrived:
				stuck_nav_timer += delta
				if stuck_nav_timer > 2.5 and dist <= 36.0:
					arrived = true
				elif stuck_nav_timer > 4.5:
					stuck_nav_timer = 0.0
					_free_current_activity()
					_decide_next_activity()
					return
					
			if not arrived:
				var dir = (target_destination - position).normalized()
				velocity = dir * wander_speed
				is_moving = true
				sprite.flip_h = (dir.x < 0)
				move_and_slide()
			else:
				stuck_nav_timer = 0.0
				position = target_destination
				velocity = Vector2.ZERO
				is_moving = false
				sprite.flip_h = false
				
				# Vending interaction ticks during 5-10 seconds
				action_tick_timer -= delta
				if action_tick_timer <= 0.0:
					action_tick_timer = randf_range(3.0, 5.0)
					if activity_timer > 2.5:
						show_bubble("Klick... Dose fällt! 🥤", 2.0, Color(1, 0.9, 0.4))
						_add_bar_revenue(randi_range(300, 700))
					
				activity_timer -= delta
				if activity_timer <= 0.0:
					# Purchased drink!
					has_drink = true
					_on_drink_ordered()
					_free_current_activity() # Frees front spot so queue advances!
					
					# Decide: Sit down (table or stool) or stand around and drink!
					var casino_world = _get_casino_world()
					var sat_down := false
					if randf() < 0.60 and casino_world:
						if target_table_pos != Vector2.ZERO:
							assign_table(target_table_pos)
							sat_down = true
						elif casino_world.has_method("get_available_table"):
							var t_pos = casino_world.get_available_table()
							if t_pos != Vector2.ZERO:
								assign_table(t_pos)
								sat_down = true
						if not sat_down and casino_world.has_method("get_available_bar_seat"):
							var s_pos = casino_world.get_available_bar_seat()
							if s_pos != Vector2.ZERO:
								assign_bar_seat(s_pos)
								sat_down = true
					if not sat_down:
						start_drinking_standing()

		State.QUEUING_VENDING:
			var dist = position.distance_to(target_destination)
			var arrived = dist <= 6.0 or (dist <= 26.0 and get_real_velocity().length() < 3.0 and is_moving)
			if not arrived:
				stuck_nav_timer += delta
				if stuck_nav_timer > 2.5 and dist <= 36.0:
					arrived = true
				elif stuck_nav_timer > 5.0:
					stuck_nav_timer = 0.0
					_free_current_activity()
					_decide_next_activity()
					return
					
			if not arrived:
				var dir = (target_destination - position).normalized()
				velocity = dir * wander_speed
				is_moving = true
				sprite.flip_h = (dir.x < 0)
				move_and_slide()
			else:
				stuck_nav_timer = 0.0
				position = target_destination
				velocity = Vector2.ZERO
				is_moving = false
				sprite.flip_h = false # Face front of line
				
				action_tick_timer -= delta
				if action_tick_timer <= 0.0:
					action_tick_timer = randf_range(4.0, 7.0)
					var line_quotes = ["Gleich bin ich dran... ⏳", "Durst auf Cola! 🥤", "Warte kurz... 🕒"]
					show_bubble(line_quotes[randi() % line_quotes.size()], 2.0, Color(0.9, 0.9, 0.5))

		State.DRINKING_STANDING:
			var dist = position.distance_to(target_destination)
			var arrived = dist <= 6.0 or (dist <= 26.0 and get_real_velocity().length() < 3.0 and is_moving)
			if not arrived:
				stuck_nav_timer += delta
				if stuck_nav_timer > 2.0:
					arrived = true
			if not arrived:
				var dir = (target_destination - position).normalized()
				velocity = dir * (wander_speed * 0.8)
				is_moving = true
				sprite.flip_h = (dir.x < 0)
				move_and_slide()
			else:
				velocity = Vector2.ZERO
				is_moving = false
				
				action_tick_timer -= delta
				if action_tick_timer <= 0.0:
					action_tick_timer = randf_range(3.5, 6.0)
					var drink_quotes = ["Schluck... 🥤", "Erfrischend! 🍹", "Kühle Dose! ✨"]
					show_bubble(drink_quotes[randi() % drink_quotes.size()], 2.0, Color(0.8, 0.95, 1.0))
					
				activity_timer -= delta
				if activity_timer <= 0.0:
					# Finished drink -> drop empty can/trash and pick next activity
					var casino_world = _get_casino_world()
					if casino_world and casino_world.has_method("spawn_table_trash"):
						casino_world.spawn_table_trash(position)
					has_drink = false
					show_bubble("Ah, das tat gut!", 1.8, Color(0.9, 0.9, 1.0))
					_free_current_activity()
					_decide_next_activity()
						
		State.SEATED_STOOL:
			var dist = position.distance_to(target_destination)
			var arrived = dist <= 6.0 or (dist <= 26.0 and get_real_velocity().length() < 3.0 and is_moving)
			if not arrived:
				stuck_nav_timer += delta
				if stuck_nav_timer > 2.5 and dist <= 36.0:
					arrived = true
				elif stuck_nav_timer > 4.5:
					stuck_nav_timer = 0.0
					_free_current_activity()
					_decide_next_activity()
					return
					
			if not arrived:
				var dir = (target_destination - position).normalized()
				velocity = dir * wander_speed
				is_moving = true
				sprite.flip_h = (dir.x < 0)
				move_and_slide()
			else:
				stuck_nav_timer = 0.0
				position = target_destination
				velocity = Vector2.ZERO
				is_moving = false
				z_index = 2 # Always render cleanly ON TOP of the stool cushion!
				sprite.flip_h = false
				
				action_tick_timer -= delta
				if action_tick_timer <= 0.0:
					action_tick_timer = randf_range(5.0, 9.0)
					if has_drink or has_bar_claim:
						show_bubble("Prost! 🍺", 2.0, Color(1, 0.85, 0.4))
						_add_bar_revenue(randi_range(50, 150))
					else:
						show_bubble("Herrlich bequem! 🪑", 2.0, Color(0.8, 0.9, 1.0))
					
				activity_timer -= delta
				if activity_timer <= 0.0:
					_free_current_activity()
					_decide_next_activity()
					
		State.SEATED_TABLE:
			var dist = position.distance_to(target_destination)
			var arrived = dist <= 6.0 or (dist <= 26.0 and get_real_velocity().length() < 3.0 and is_moving)
			if not arrived:
				stuck_nav_timer += delta
				if stuck_nav_timer > 2.5 and dist <= 36.0:
					arrived = true
				elif stuck_nav_timer > 4.5:
					stuck_nav_timer = 0.0
					_free_current_activity()
					_decide_next_activity()
					return
					
			if not arrived:
				var dir = (target_destination - position).normalized()
				velocity = dir * wander_speed
				is_moving = true
				sprite.flip_h = (dir.x < 0)
				move_and_slide()
			else:
				stuck_nav_timer = 0.0
				position = target_destination
				velocity = Vector2.ZERO
				is_moving = false
				z_index = 1
				_face_towards_nearest_table()
				
				action_tick_timer -= delta
				if action_tick_timer <= 0.0:
					action_tick_timer = randf_range(6.0, 10.0)
					show_bubble("Guter Drink! 🍹", 2.0, Color(0.9, 0.7, 1.0))
					
				activity_timer -= delta
				if activity_timer <= 0.0:
					# Finished drink at table -> LEAVE DIRTY BOTTLE / TRASH!
					_leave_table_trash()
					has_drink = false
					_free_current_activity()
					_decide_next_activity()

		State.ROAMING:
			if is_wandering:
				if pause_timer > 0.0:
					pause_timer -= delta
					velocity = Vector2.ZERO
					move_and_slide()
					if pause_timer <= 0.0:
						_pick_new_state()
				else:
					move_timer -= delta
					if move_timer <= 0.0:
						_pick_new_state()
					else:
						# If approaching the bar counter itself and NOT having the bar claim, steer away!
						var casino_world = _get_casino_world()
						if casino_world and not has_bar_claim and casino_world.has_method("get_bar_location"):
							var bar_loc = casino_world.get_bar_location()
							if bar_loc != Vector2.ZERO and position.distance_to(bar_loc) < 32.0:
								move_direction = (position - bar_loc).normalized()

						var next_pos = position + move_direction * wander_speed * delta
						if next_pos.y > 640.0: # Keep inside casino bounds
							move_direction.y = -abs(move_direction.y)
						if next_pos.x < 110.0 or next_pos.x > 1200.0 or next_pos.y < 90.0:
							_pick_new_state()
						else:
							is_moving = true
							velocity = move_direction * (wander_speed * 0.75)
							if move_direction.x < 0:
								sprite.flip_h = true
							elif move_direction.x > 0:
								sprite.flip_h = false
							move_and_slide()
							
		State.LEAVING:
			if current_path_idx < path_points.size():
				var target_pt = path_points[current_path_idx]
				var dist = position.distance_to(target_pt)
				if dist > 6.0:
					var dir = (target_pt - position).normalized()
					velocity = dir * (wander_speed * 1.3)
					is_moving = true
					sprite.flip_h = (dir.x < 0)
					move_and_slide()
				else:
					current_path_idx += 1
			else:
				# Reached end of street -> disappear!
				queue_free()
				return
				
	_update_animations(is_moving)

func _do_game_play_tick() -> void:
	# Visual spin bounce
	var tw = create_tween()
	tw.tween_property(sprite, "position:y", -4.0, 0.12)
	tw.tween_property(sprite, "position:y", 0.0, 0.12)
	
	var is_win = randf() < 0.40
	if is_win:
		show_bubble("Gewinn! +$$", 1.5, Color(0.3, 1.0, 0.4))
	else:
		show_bubble("Spin! 🎰", 1.2, Color(1.0, 0.8, 0.3))
		
	var casino_world = _get_casino_world()
	if casino_world:
		var earn = randi_range(30, 90)
		if current_activity_type == "slot_modern": earn = randi_range(60, 200)
		elif current_activity_type == "crash": earn = randi_range(100, 300)
		elif current_activity_type == "roulette": earn = randi_range(150, 450)
		elif current_activity_type == "blackjack": earn = randi_range(250, 750)
		casino_world.tonight_game_revenue_cents += earn

func _on_drink_ordered() -> void:
	show_bubble("1 Drink bitte! 🍹", 1.8, Color(1, 0.85, 0.3))
	_add_bar_revenue(randi_range(400, 900))

func _add_bar_revenue(cents: int) -> void:
	var casino_world = _get_casino_world()
	if casino_world:
		casino_world.tonight_bar_revenue_cents += cents

func _leave_table_trash() -> void:
	var casino_world = _get_casino_world()
	if casino_world and casino_world.has_method("spawn_table_trash"):
		var trash_pos = current_activity_pos
		for item in GameManager.placed_furniture:
			if item.get("type") == "table":
				var p_vec = _parse_pos_to_vec2(item.get("pos"))
				if p_vec != Vector2.ZERO and current_activity_pos.distance_to(p_vec) < 80.0:
					# Place directly onto the table surface near the guest
					var dir = (current_activity_pos - p_vec).normalized()
					trash_pos = p_vec + dir * 24.0 + Vector2(0, -6)
					break
		casino_world.spawn_table_trash(trash_pos)
	show_bubble("Sehr lecker!", 1.5, Color(0.7, 0.9, 1.0))

func _free_current_activity() -> void:
	z_index = 0
	stuck_nav_timer = 0.0
	var casino_world = _get_casino_world()
	if has_bar_claim or current_state == State.QUEUING_VENDING or current_state == State.ORDERING_BAR:
		has_bar_claim = false
		if casino_world and casino_world.has_method("release_bar_idea"):
			casino_world.release_bar_idea(self)
	if current_activity_pos != Vector2.ZERO:
		if casino_world and casino_world.has_method("release_activity_spot"):
			casino_world.release_activity_spot(current_activity_pos)
		current_activity_pos = Vector2.ZERO
		current_activity_type = ""

func _decide_next_activity() -> void:
	# If casino night has closed, immediately leave
	if GameManager.night_closed or not GameManager.casino_open:
		var casino_world = _get_casino_world()
		if casino_world and casino_world.has_method("get_exit_waypoints"):
			start_leaving(casino_world.get_exit_waypoints())
			return

	var casino_world = _get_casino_world()
	if not casino_world:
		current_state = State.ROAMING
		is_wandering = true
		_pick_new_state()
		return
		
	# Priority 1: Play at slot machine or game table (70% probability if available)
	if randf() < 0.70 and casino_world.has_method("get_available_game_spot"):
		var game_spot = casino_world.get_available_game_spot()
		if not game_spot.is_empty():
			assign_game(game_spot.get("type", "slot_rusty"), game_spot.get("pos", Vector2.ZERO))
			return
			
	# Priority 2: Visit drink vending machine (stand at front or queue up in line!)
	if casino_world.has_method("can_have_bar_idea") and casino_world.can_have_bar_idea(self):
		if randf() < 0.65:
			if casino_world.claim_bar_idea(self):
				has_bar_claim = true
				var spot = casino_world.get_vending_spot_for_npc(self)
				if casino_world.active_bar_visitor == self:
					show_bubble("💡 Durst! Zum Automaten!", 2.2, Color(1.0, 0.95, 0.4))
					var table_pos = Vector2.ZERO
					if casino_world.has_method("get_available_table"):
						table_pos = casino_world.get_available_table()
					assign_bar_order(spot, table_pos)
					return
				else:
					assign_vending_queue(spot)
					return

	# Priority 3: Sit down on a chair (stool) or table to relax!
	if randf() < 0.70:
		if casino_world.has_method("get_available_bar_seat"):
			var stool_pos = casino_world.get_available_bar_seat()
			if stool_pos != Vector2.ZERO:
				show_bubble("Mal hinsetzen... 🪑", 1.8, Color(0.9, 0.9, 0.5))
				assign_bar_seat(stool_pos)
				return
		if casino_world.has_method("get_available_table"):
			var table_pos = casino_world.get_available_table()
			if table_pos != Vector2.ZERO:
				show_bubble("Pause am Tisch! 🪑", 1.8, Color(0.85, 0.95, 0.8))
				assign_table(table_pos)
				return
			
	# Priority 4: Stand around peacefully ("die anderen dürfen auch nur rumstehen")
	current_state = State.ROAMING
	is_wandering = true
	_pick_new_state()

func _get_casino_world() -> Node:
	var cw = get_tree().get_first_node_in_group("casino_world")
	if cw: return cw
	var p = get_parent()
	if p:
		if p.name == "CasinoWorld": return p
		var pp = p.get_parent()
		if pp and pp.name == "CasinoWorld": return pp
	return null

func _update_animations(is_moving: bool) -> void:
	if is_moving:
		var step_bob = abs(sin(anim_time * 9.0)) * 2.5
		sprite.position.y = -step_bob
		sprite.rotation = sin(anim_time * 9.0) * 0.09
		sprite.scale = Vector2(1.0 + sin(anim_time * 9.0) * 0.04, 1.0 - sin(anim_time * 9.0) * 0.04)
	elif current_state == State.SEATED_STOOL:
		sprite.position.y = -8.0
		sprite.rotation = 0.0
		sprite.scale = Vector2(1.0, 0.85)
	elif current_state == State.SEATED_TABLE:
		sprite.position.y = -4.0
		sprite.rotation = 0.0
		sprite.scale = Vector2(1.0, 0.90)
	elif current_state == State.DRINKING_STANDING:
		sprite.position.y = sin(anim_time * 3.0) * 1.0
		sprite.rotation = 0.0
		sprite.scale = Vector2(1.0, 1.0)
	elif current_state == State.PLAYING_GAME:
		sprite.rotation = 0.0
		sprite.scale = Vector2(1.0, 1.0)
	else:
		sprite.position.y = 0.0
		sprite.rotation = 0.0
		sprite.scale = Vector2(1.0, 1.0 + sin(anim_time * 2.2) * 0.02)

func _face_towards_nearest_table() -> void:
	for item in GameManager.placed_furniture:
		if item.get("type") == "table":
			var p_vec = _parse_pos_to_vec2(item.get("pos"))
			if p_vec != Vector2.ZERO and position.distance_to(p_vec) < 80.0:
				sprite.flip_h = (p_vec.x < position.x)
				return

func _parse_pos_to_vec2(pos_val: Variant) -> Vector2:
	if pos_val is Vector2:
		return pos_val
	elif pos_val is String:
		var s: String = pos_val.strip_edges().trim_prefix("(").trim_suffix(")")
		var parts := s.split(",")
		if parts.size() >= 2:
			return Vector2(parts[0].to_float(), parts[1].to_float())
	elif pos_val is Dictionary:
		return Vector2(float(pos_val.get("x", 0.0)), float(pos_val.get("y", 0.0)))
	return Vector2.ZERO

func _pick_new_state() -> void:
	# NPCs predominantly stand around peacefully ("rumstehen")
	if randf() > 0.20:
		pause_timer = randf_range(7.0, 16.0)
		move_direction = Vector2.ZERO
		if randf() < 0.30:
			_decide_next_activity()
	else:
		move_timer = randf_range(1.0, 2.2)
		var angle = randf() * TAU
		move_direction = Vector2(cos(angle), sin(angle)).normalized()
		var casino_world = _get_casino_world()
		if casino_world and not has_bar_claim and casino_world.has_method("get_bar_location"):
			var bar_loc = casino_world.get_bar_location()
			if bar_loc != Vector2.ZERO and position.distance_to(bar_loc) < 32.0:
				move_direction = (position - bar_loc).normalized()
