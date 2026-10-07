extends Node2D

const BOTTLE_SCENE := preload("res://scenes/props/bottle.tscn")
const TRASH_SCENE := preload("res://scenes/props/trash_item.tscn")
const FURNITURE_PROP_SCENE := preload("res://scenes/props/placed_furniture_prop.tscn")
const DAD_LETTER_SCENE := preload("res://scenes/ui/dad_letter_dialog.tscn")
const VINNIE_STORE_SCENE := preload("res://scenes/ui/vinnie_store_dialog.tscn")
const BOB_STORE_SCENE := preload("res://scenes/ui/construction_store_dialog.tscn")
const DAILY_SUMMARY_SCENE := preload("res://scenes/ui/daily_summary_dialog.tscn")
const NPC_SCENE := preload("res://scenes/props/npc.tscn")

@onready var bottle_container: Node2D = $BottleContainer
@onready var respawn_timer: Timer = $BottleRespawnTimer
@onready var arcade_row: Node2D = $ArcadeRow
@onready var tables: Node2D = $Tables
@onready var table_guests: Node2D = $TableGuests
@onready var wandering_npcs: Node2D = $WanderingNPCs
@onready var city_street: Node2D = $CityStreet
@onready var trash_container: Node2D = $TrashContainer
@onready var dynamic_furniture_container: Node2D = $DynamicFurnitureContainer
@onready var guest_spawn_timer: Timer = $GuestSpawnTimer
@onready var tycoon_atmosphere: Node2D = $TycoonAtmosphere
@onready var shop_door_area: Area2D = $CityStreet/VinnieShop/ShopDoorArea
@onready var shop_label: Label = $CityStreet/VinnieShop/ShopDoorArea/ShopLabel
@onready var build_grid_overlay: Node2D = $BuildGridOverlay

# Modular Room Expansion & Geometry
@onready var dark_backdrop: ColorRect = $DarkBackdrop
@onready var modular_floors: Node2D = $ModularFloors
@onready var starter_floor: TextureRect = $ModularFloors/StarterFloor
@onready var east_wing_floor: TextureRect = $ModularFloors/EastWingFloor
@onready var vip_floor: TextureRect = $ModularFloors/VIPFloor

@onready var modular_walls: Node2D = $ModularWalls
@onready var north_wall_starter: StaticBody2D = $ModularWalls/NorthWallStarter
@onready var north_wall_east: StaticBody2D = $ModularWalls/NorthWallEast
@onready var east_wall_lower: StaticBody2D = $ModularWalls/EastWallLower
@onready var east_wall_upper: StaticBody2D = $ModularWalls/EastWallUpper

@onready var bob_door_area: Area2D = $CityStreet/BobShop/BobDoorArea
@onready var bob_label: Label = $CityStreet/BobShop/BobDoorArea/BobLabel
@onready var car_door_area: Area2D = $CityStreet/PlayerCar/CarInteractArea
@onready var car_label: Label = $CityStreet/PlayerCar/CarInteractArea/CarLabel

var active_vinnie_dialog: Control = null
var active_bob_dialog: Control = null
var active_summary_dialog: Control = null

# Night cycle simulation stats
var tonight_guests_count: int = 0
var tonight_game_revenue_cents: int = 0
var tonight_bar_revenue_cents: int = 0

var spawn_points: Array[Vector2] = [
	Vector2(225, 230), Vector2(255, 230),
	Vector2(555, 230), Vector2(585, 230),
	Vector2(225, 450), Vector2(255, 450),
	Vector2(555, 450), Vector2(585, 450),
	Vector2(885, 450), Vector2(915, 450)
]

var is_near_shop_door: bool = false
var is_near_bob_door: bool = false
var is_near_car: bool = false

func _ready() -> void:
	_setup_for_game_mode()
	respawn_timer.timeout.connect(_on_respawn_timer_timeout)
	guest_spawn_timer.timeout.connect(_on_guest_spawn_tick)
	
	# Connect shop door area (Vinnie)
	var is_de = (GameManager.current_lang == "de")
	shop_label.text = "[E] Vinnie's Laden" if is_de else "[E] Vinnie's Shop"
	shop_label.visible = false
	shop_door_area.add_to_group("interactable")
	shop_door_area.set_meta("owner_cabinet", self)
	shop_door_area.body_entered.connect(_on_shop_door_entered)
	shop_door_area.body_exited.connect(_on_shop_door_exited)
	shop_door_area.area_entered.connect(_on_shop_door_area_entered)
	shop_door_area.area_exited.connect(_on_shop_door_area_exited)
	
	# Connect Bob's Bauamt door area
	bob_label.text = "[E] Bob's Bauamt" if is_de else "[E] Bob's Construction"
	bob_label.visible = false
	bob_door_area.add_to_group("interactable")
	bob_door_area.set_meta("owner_cabinet", self)
	bob_door_area.body_entered.connect(_on_bob_door_entered)
	bob_door_area.body_exited.connect(_on_bob_door_exited)
	bob_door_area.area_entered.connect(_on_bob_door_area_entered)
	bob_door_area.area_exited.connect(_on_bob_door_area_exited)
	
	# Connect Player Car interact area
	if car_door_area:
		car_label.text = "[E] Tag beenden (Auto)" if is_de else "[E] End Day (Car)"
		car_label.visible = false
		car_door_area.add_to_group("interactable")
		car_door_area.set_meta("owner_cabinet", self)
		car_door_area.body_entered.connect(_on_car_entered)
		car_door_area.body_exited.connect(_on_car_exited)
		car_door_area.area_entered.connect(_on_car_area_entered)
		car_door_area.area_exited.connect(_on_car_area_exited)
	
	GameManager.area_unlocked.connect(_on_area_unlocked)
	update_room_geometry()
	_start_neon_flicker()

func _process(delta: float) -> void:
	if bar_idea_cooldown > 0.0:
		bar_idea_cooldown -= delta
	if GameManager.game_mode == "tycoon" and GameManager.casino_open and not GameManager.night_closed:
		GameManager.night_elapsed += delta
		GameManager.night_time_updated.emit(GameManager.night_elapsed, GameManager.NIGHT_DURATION)
		if GameManager.night_elapsed >= GameManager.NIGHT_DURATION:
			close_casino_for_night()

func _start_neon_flicker() -> void:
	if not tycoon_atmosphere: return
	var sign_node = tycoon_atmosphere.get_node_or_null("FlickeringSign")
	if not sign_node: return
	
	var loop_timer = get_tree().create_timer(randf_range(1.5, 3.5))
	loop_timer.timeout.connect(func():
		if is_instance_valid(sign_node) and sign_node.visible:
			var tw = create_tween()
			tw.tween_property(sign_node, "modulate:a", 0.35, 0.08)
			tw.tween_property(sign_node, "modulate:a", 1.0, 0.08)
			tw.tween_property(sign_node, "modulate:a", 0.45, 0.05)
			tw.tween_property(sign_node, "modulate:a", 1.0, 0.1)
		_start_neon_flicker()
	)

func _set_hierarchy_collision_active(root_node: Node, active: bool) -> void:
	if not root_node: return
	root_node.visible = active
	root_node.process_mode = Node.PROCESS_MODE_INHERIT if active else Node.PROCESS_MODE_DISABLED
	for col in root_node.find_children("*", "CollisionShape2D", true, false):
		col.set_deferred("disabled", not active)
	for body in root_node.find_children("*", "CollisionObject2D", true, false):
		if not active:
			body.collision_layer = 0
			body.collision_mask = 0
		else:
			body.collision_layer = 1
			body.collision_mask = 1

func update_room_geometry() -> void:
	if not modular_floors or not modular_walls:
		return
		
	if GameManager.game_mode == "tycoon":
		$CasinoBackdrop.visible = false
		if dark_backdrop:
			dark_backdrop.visible = true
		modular_floors.visible = true
		modular_walls.visible = true
		
		var east_unlocked = GameManager.is_area_unlocked("east_wing")
		var vip_unlocked = GameManager.is_area_unlocked("vip_lounge")
		
		# Floors
		starter_floor.visible = true
		east_wing_floor.visible = east_unlocked
		vip_floor.visible = vip_unlocked
		
		# Divider walls
		_set_hierarchy_collision_active(east_wall_lower, not east_unlocked)
		_set_hierarchy_collision_active(east_wall_upper, (not east_unlocked) and vip_unlocked)
		_set_hierarchy_collision_active(north_wall_starter, not vip_unlocked)
		_set_hierarchy_collision_active(north_wall_east, (not vip_unlocked) and east_unlocked)
	else:
		$CasinoBackdrop.visible = true
		if dark_backdrop:
			dark_backdrop.visible = false
		modular_floors.visible = false
		modular_walls.visible = false
		_set_hierarchy_collision_active(east_wall_lower, false)
		_set_hierarchy_collision_active(east_wall_upper, false)
		_set_hierarchy_collision_active(north_wall_starter, false)
		_set_hierarchy_collision_active(north_wall_east, false)

func _exit_tree() -> void:
	if GameManager.area_unlocked.is_connected(_on_area_unlocked):
		GameManager.area_unlocked.disconnect(_on_area_unlocked)

func _on_area_unlocked(_area_id: String) -> void:
	if not is_inside_tree() or get_tree() == null:
		return
	update_room_geometry()
	if build_grid_overlay:
		build_grid_overlay.queue_redraw()
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("update_camera_bounds"):
		player.update_camera_bounds()
	var main_c = get_tree().get_first_node_in_group("main_coordinator")
	if main_c and main_c.hud:
		var is_de = (GameManager.current_lang == "de")
		main_c.hud.show_floating_banner("CASINO ERWEITERT! NEUER BEREICH ERÖFFNET!" if is_de else "CASINO EXPANDED! NEW WING OPENED!")

func _setup_for_game_mode() -> void:
	if GameManager.game_mode == "tycoon":
		# Strictly disable both visuals and physics collisions for high-roller static tables
		_set_hierarchy_collision_active(tables, false)
		_set_hierarchy_collision_active(table_guests, false)
		_set_hierarchy_collision_active(arcade_row, false)
		_set_hierarchy_collision_active(wandering_npcs, false)
		
		city_street.visible = true
		tycoon_atmosphere.visible = true
		update_room_geometry()
		
		# Open doorway in bottom wall collision for entering city (center doorway x=580..700)
		$Walls/BottomWallColLeft.disabled = false
		$Walls/BottomWallColRight.disabled = false
		$Walls/BottomWallColCenter.disabled = true
		
		# Show Dad's letter if first time
		if not GameManager.has_seen_dad_letter:
			call_deferred("_show_dad_letter")
			
		# Spawn trash if not cleaned
		_setup_trash()
		
		# Spawn existing placed furniture
		_spawn_all_placed_furniture()
		
	else:
		# High Roller Mode: Luxury Casino fully active
		_set_hierarchy_collision_active(tables, true)
		_set_hierarchy_collision_active(table_guests, true)
		_set_hierarchy_collision_active(arcade_row, true)
		_set_hierarchy_collision_active(wandering_npcs, true)
		
		city_street.visible = false
		tycoon_atmosphere.visible = false
		update_room_geometry()
		
		$Walls/BottomWallColLeft.disabled = true
		$Walls/BottomWallColRight.disabled = true
		$Walls/BottomWallColCenter.disabled = false
		spawn_initial_bottles()

func _show_dad_letter() -> void:
	if not is_inside_tree() or get_tree() == null:
		return
	var dlg = DAD_LETTER_SCENE.instantiate()
	var coord = get_tree().get_first_node_in_group("main_coordinator")
	if coord and coord.has_node("UILayer"):
		coord.get_node("UILayer").add_child(dlg)
	else:
		add_child(dlg)

func _setup_trash() -> void:
	for c in trash_container.get_children():
		c.queue_free()
		
	if GameManager.casino_cleaned:
		return
		
	# Starter trash spots strictly contained inside the starter zone (x: 120..720, y: 300..600)
	var trash_spots = [
		{"type": "trash_bag", "pos": Vector2(240, 360)},
		{"type": "trash_pile", "pos": Vector2(420, 380)},
		{"type": "spilled_chips", "pos": Vector2(580, 340)},
		{"type": "dirt_stain", "pos": Vector2(340, 480)},
		{"type": "cobweb", "pos": Vector2(140, 310)},
		{"type": "trash_bag", "pos": Vector2(680, 420)},
		{"type": "spilled_chips", "pos": Vector2(260, 560)},
		{"type": "trash_pile", "pos": Vector2(500, 520)},
		{"type": "dirt_stain", "pos": Vector2(620, 580)},
		{"type": "trash_bag", "pos": Vector2(380, 600)}
	]
	
	GameManager.total_trash_count = trash_spots.size()
	for s in trash_spots:
		var t = TRASH_SCENE.instantiate()
		t.trash_type = s["type"]
		t.position = s["pos"]
		t.trash_cleaned.connect(_on_trash_item_cleaned)
		trash_container.add_child(t)

func _on_trash_item_cleaned(_type: String, _cash: int) -> void:
	if trash_container.get_child_count() <= 1:
		GameManager.casino_cleaned = true
		GameManager.add_cash(20000) # $200.00 Sauberkeits-Bonus!
		GameManager.save_game()
		
		var main_c = get_tree().get_first_node_in_group("main_coordinator")
		if main_c and main_c.hud:
			var is_de = (GameManager.current_lang == "de")
			main_c.hud.show_floating_banner("CASINO BLITZSAUBER! +$200 BONUS! Besuche Vinnie & Bob draußen!" if is_de else "CASINO SPARKLING CLEAN! +$200 BONUS! Visit Vinnie & Bob outside!")

func _spawn_all_placed_furniture() -> void:
	for c in dynamic_furniture_container.get_children():
		c.queue_free()
		
	# Starter rusty slot machine if not yet placed (aligned to 32x32 cell center)
	if GameManager.placed_furniture.is_empty():
		GameManager.placed_furniture.append({
			"type": "slot_rusty",
			"pos": Vector2(336, 400)
		})
		GameManager.inventory["slot_rusty"] = 0
		GameManager.save_game()
		
	for item in GameManager.placed_furniture:
		var prop = FURNITURE_PROP_SCENE.instantiate()
		prop.item_type = item["type"]
		var p_val = item.get("pos", Vector2.ZERO)
		if p_val is Vector2:
			prop.position = p_val
		elif p_val is String:
			var s: String = p_val.strip_edges().trim_prefix("(").trim_suffix(")")
			var parts := s.split(",")
			if parts.size() >= 2:
				prop.position = Vector2(parts[0].to_float(), parts[1].to_float())
		dynamic_furniture_container.add_child(prop)

func get_snapped_cell_pos(world_pos: Vector2) -> Vector2:
	var cell_x: float = floor(world_pos.x / 32.0) * 32.0
	var cell_y: float = floor(world_pos.y / 32.0) * 32.0
	return Vector2(cell_x + 16.0, cell_y + 16.0)

func get_active_build_bounds() -> Rect2:
	var x_min := 96.0
	var x_max := 1216.0 if GameManager.is_area_unlocked("east_wing") else 736.0
	var y_min := 64.0 if GameManager.is_area_unlocked("vip_lounge") else 288.0
	var y_max := 672.0
	return Rect2(x_min, y_min, x_max - x_min, y_max - y_min)

func is_build_pos_valid(world_pos: Vector2, ignore_pos: Vector2 = Vector2.ZERO) -> bool:
	var bounds = get_active_build_bounds()
	var snapped_pos = get_snapped_cell_pos(world_pos)
	
	if snapped_pos.x < bounds.position.x or snapped_pos.x > bounds.end.x:
		return false
	if snapped_pos.y < bounds.position.y or snapped_pos.y > bounds.end.y:
		return false
		
	# Doorway clearance (entrance to street)
	if snapped_pos.y >= 640.0 and snapped_pos.x >= 576.0 and snapped_pos.x <= 704.0:
		return false
		
	for item in GameManager.placed_furniture:
		var p = item.get("pos")
		var p_vec: Vector2 = Vector2.ZERO
		if p is Vector2:
			p_vec = p
		elif p is String:
			var s: String = p.strip_edges().trim_prefix("(").trim_suffix(")")
			var parts := s.split(",")
			if parts.size() >= 2:
				p_vec = Vector2(parts[0].to_float(), parts[1].to_float())
		if ignore_pos != Vector2.ZERO and p_vec.distance_to(ignore_pos) < 10.0:
			continue
		if p_vec.distance_to(snapped_pos) < 24.0:
			return false
			
	return true

func get_furniture_at(world_pos: Vector2) -> Dictionary:
	var target = get_snapped_cell_pos(world_pos)
	for item in GameManager.placed_furniture:
		var p = item.get("pos")
		var p_vec: Vector2 = Vector2.ZERO
		if p is Vector2:
			p_vec = p
		elif p is String:
			var s: String = p.strip_edges().trim_prefix("(").trim_suffix(")")
			var parts := s.split(",")
			if parts.size() >= 2:
				p_vec = Vector2(parts[0].to_float(), parts[1].to_float())
		if p_vec.distance_to(target) < 24.0:
			return item
	return {}

func place_new_furniture(item_type: String, world_pos: Vector2) -> bool:
	if GameManager.inventory.get(item_type, 0) <= 0:
		return false
		
	if not is_build_pos_valid(world_pos):
		return false
		
	var snapped_pos = get_snapped_cell_pos(world_pos)
	
	var prop = FURNITURE_PROP_SCENE.instantiate()
	prop.item_type = item_type
	prop.position = snapped_pos
	dynamic_furniture_container.add_child(prop)
	
	GameManager.placed_furniture.append({
		"type": item_type,
		"pos": snapped_pos
	})
	
	GameManager.inventory[item_type] = max(0, GameManager.inventory.get(item_type, 0) - 1)
	GameManager.save_game()
	
	if build_grid_overlay:
		build_grid_overlay.queue_redraw()
		
	if SoundManager:
		SoundManager.play_sfx("lever_release")
	return true

func move_furniture(old_pos: Vector2, new_world_pos: Vector2) -> bool:
	if not is_build_pos_valid(new_world_pos, old_pos):
		return false
		
	var snapped_pos = get_snapped_cell_pos(new_world_pos)
	var found = false
	for item in GameManager.placed_furniture:
		var p = item.get("pos")
		var p_vec: Vector2 = Vector2.ZERO
		if p is Vector2:
			p_vec = p
		elif p is String:
			var s: String = p.strip_edges().trim_prefix("(").trim_suffix(")")
			var parts := s.split(",")
			if parts.size() >= 2:
				p_vec = Vector2(parts[0].to_float(), parts[1].to_float())
		if p_vec.distance_to(old_pos) < 20.0:
			item["pos"] = snapped_pos
			found = true
			break
			
	if not found:
		return false
		
	for c in dynamic_furniture_container.get_children():
		if c.position.distance_to(old_pos) < 20.0:
			c.position = snapped_pos
			break
			
	GameManager.save_game()
	if build_grid_overlay:
		build_grid_overlay.queue_redraw()
	if SoundManager:
		SoundManager.play_sfx("lever_release")
	return true

func remove_furniture_to_inventory(pos: Vector2) -> String:
	var item_type := ""
	var to_remove = -1
	for i in range(GameManager.placed_furniture.size()):
		var item = GameManager.placed_furniture[i]
		var p = item.get("pos")
		var p_vec: Vector2 = Vector2.ZERO
		if p is Vector2:
			p_vec = p
		elif p is String:
			var s: String = p.strip_edges().trim_prefix("(").trim_suffix(")")
			var parts := s.split(",")
			if parts.size() >= 2:
				p_vec = Vector2(parts[0].to_float(), parts[1].to_float())
		if p_vec.distance_to(pos) < 20.0:
			to_remove = i
			item_type = item.get("type", "")
			break
			
	if to_remove >= 0 and item_type != "":
		GameManager.placed_furniture.remove_at(to_remove)
		for c in dynamic_furniture_container.get_children():
			if c.position.distance_to(pos) < 20.0:
				c.queue_free()
				break
		GameManager.inventory[item_type] = GameManager.inventory.get(item_type, 0) + 1
		GameManager.save_game()
		if build_grid_overlay:
			build_grid_overlay.queue_redraw()
		if SoundManager:
			SoundManager.play_sfx("bottle_pickup")
		return item_type
	return ""

func set_build_mode(is_active: bool, item_type: String = "") -> void:
	if build_grid_overlay:
		build_grid_overlay.set_build_mode(is_active, item_type)

func set_build_item(item_type: String) -> void:
	if build_grid_overlay:
		build_grid_overlay.set_selected_item(item_type)

# Night cycle simulation & guest activities
var guest_queue: Array[Node] = []
var occupied_activity_spots: Dictionary = {}
var active_bar_visitor: Node = null # NPC currently at front of vending machine
var vending_queue: Array[Node] = [] # NPCs waiting in line behind machine
var bar_idea_cooldown: float = 0.0

func can_have_bar_idea(npc: Node = null) -> bool:
	var loc = get_bar_location()
	if loc == Vector2.ZERO:
		return false
	if is_instance_valid(active_bar_visitor) and active_bar_visitor == npc:
		return true
	if vending_queue.has(npc):
		return true
	# Up to 1 serving + 2 waiting in queue (total 3)
	if is_instance_valid(active_bar_visitor):
		return vending_queue.size() < 2
	return bar_idea_cooldown <= 0.0

func claim_bar_idea(npc: Node) -> bool:
	if not is_instance_valid(npc):
		return false
	var loc = get_bar_location()
	if loc == Vector2.ZERO:
		return false
	if active_bar_visitor == npc or vending_queue.has(npc):
		return true
	if not is_instance_valid(active_bar_visitor):
		# Front spot is free!
		active_bar_visitor = npc
		return true
	elif vending_queue.size() < 2 and not vending_queue.has(npc):
		# Join line behind front visitor!
		vending_queue.append(npc)
		return true
	return false

func release_bar_idea(npc: Node = null) -> void:
	if npc == null:
		active_bar_visitor = null
		vending_queue.clear()
		bar_idea_cooldown = randf_range(3.0, 8.0)
		return
	
	if active_bar_visitor == npc:
		active_bar_visitor = null
		# Next guest in line steps forward to the vending machine!
		if vending_queue.size() > 0:
			var next_npc = vending_queue.pop_front()
			if is_instance_valid(next_npc):
				active_bar_visitor = next_npc
				var loc = get_bar_location()
				if next_npc.has_method("advance_to_vending_machine"):
					next_npc.advance_to_vending_machine(loc + Vector2(0, 24))
			_update_vending_queue_positions()
		else:
			bar_idea_cooldown = randf_range(3.0, 8.0)
	elif vending_queue.has(npc):
		vending_queue.erase(npc)
		_update_vending_queue_positions()

func _update_vending_queue_positions() -> void:
	var loc = get_bar_location()
	if loc == Vector2.ZERO: return
	for i in range(vending_queue.size()):
		var waiter = vending_queue[i]
		if is_instance_valid(waiter) and waiter.has_method("update_queue_destination"):
			waiter.update_queue_destination(loc + Vector2(0, 48 + i * 22))

func get_vending_spot_for_npc(npc: Node) -> Vector2:
	var loc = get_bar_location()
	if loc == Vector2.ZERO: return Vector2.ZERO
	if active_bar_visitor == npc:
		return loc + Vector2(0, 24)
	var q_idx = vending_queue.find(npc)
	if q_idx >= 0:
		return loc + Vector2(0, 48 + q_idx * 22)
	return loc + Vector2(0, 24)

func get_bar_location() -> Vector2:
	for item in GameManager.placed_furniture:
		if item.get("type") == "bar_counter":
			var p_vec = _parse_pos_to_vec2(item.get("pos"))
			if p_vec != Vector2.ZERO:
				return p_vec
	return Vector2.ZERO

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

func get_available_game_spot() -> Dictionary:
	var available_games: Array[Dictionary] = []
	for item in GameManager.placed_furniture:
		var itype: String = item.get("type", "")
		if itype in ["slot_rusty", "slot_modern", "crash", "roulette", "blackjack"]:
			var p_vec = _parse_pos_to_vec2(item.get("pos"))
			if p_vec != Vector2.ZERO:
				var spot = p_vec + Vector2(0, 20)
				var key = "%.0f_%.0f" % [spot.x, spot.y]
				if not occupied_activity_spots.has(key):
					available_games.append({"type": itype, "pos": spot, "key": key})
	if available_games.size() > 0:
		var chosen = available_games[randi() % available_games.size()]
		occupied_activity_spots[chosen["key"]] = true
		return chosen
	return {}

func get_available_bar_counter() -> Vector2:
	var available_counters: Array[Vector2] = []
	for item in GameManager.placed_furniture:
		if item.get("type") == "bar_counter":
			var p_vec = _parse_pos_to_vec2(item.get("pos"))
			if p_vec != Vector2.ZERO:
				var spot = p_vec + Vector2(0, 24)
				var key = "%.0f_%.0f" % [spot.x, spot.y]
				if not occupied_activity_spots.has(key):
					available_counters.append(spot)
	if available_counters.size() > 0:
		var chosen = available_counters[randi() % available_counters.size()]
		var key = "%.0f_%.0f" % [chosen.x, chosen.y]
		occupied_activity_spots[key] = true
		return chosen
	return Vector2.ZERO

func get_available_table() -> Vector2:
	var available_tables: Array[Vector2] = []
	for item in GameManager.placed_furniture:
		if item.get("type") == "table":
			var p_vec = _parse_pos_to_vec2(item.get("pos"))
			if p_vec != Vector2.ZERO:
				# Offer 2 seating spots: left and right next to table, NEVER inside table!
				var spot_left = p_vec + Vector2(-48, 2)
				var key_l = "%.0f_%.0f" % [spot_left.x, spot_left.y]
				if not occupied_activity_spots.has(key_l):
					available_tables.append(spot_left)
				var spot_right = p_vec + Vector2(48, 2)
				var key_r = "%.0f_%.0f" % [spot_right.x, spot_right.y]
				if not occupied_activity_spots.has(key_r):
					available_tables.append(spot_right)
	if available_tables.size() > 0:
		var chosen = available_tables[randi() % available_tables.size()]
		var key = "%.0f_%.0f" % [chosen.x, chosen.y]
		occupied_activity_spots[key] = true
		return chosen
	return Vector2.ZERO

func get_available_bar_seat() -> Vector2:
	var available_stools: Array[Vector2] = []
	for item in GameManager.placed_furniture:
		if item.get("type") == "bar_stool":
			var p_vec = _parse_pos_to_vec2(item.get("pos"))
			if p_vec != Vector2.ZERO:
				var spot = p_vec
				var key = "%.0f_%.0f" % [spot.x, spot.y]
				if not occupied_activity_spots.has(key):
					available_stools.append(spot)
	if available_stools.size() > 0:
		var chosen = available_stools[randi() % available_stools.size()]
		var key = "%.0f_%.0f" % [chosen.x, chosen.y]
		occupied_activity_spots[key] = true
		return chosen
	return Vector2.ZERO

func release_activity_spot(pos: Vector2) -> void:
	var key = "%.0f_%.0f" % [pos.x, pos.y]
	occupied_activity_spots.erase(key)


func spawn_table_trash(table_pos: Vector2) -> void:
	if randf() < 0.70:
		var b = BOTTLE_SCENE.instantiate()
		var offset = Vector2(randf_range(-16, 16), randf_range(-10, 8))
		b.position = table_pos + offset
		bottle_container.add_child(b)
	else:
		var t = TRASH_SCENE.instantiate()
		t.trash_type = "trash_pile" if randf() < 0.5 else "dirt_stain"
		var offset = Vector2(randf_range(-16, 16), randf_range(-10, 8))
		t.position = table_pos + offset
		trash_container.add_child(t)

func get_exit_waypoints() -> Array[Vector2]:
	return [
		Vector2(640.0, 640.0),
		Vector2(640.0, 710.0),
		Vector2(640.0, 840.0),
		Vector2(950.0, 840.0),
		Vector2(1340.0, 840.0)
	]

func start_business_night() -> void:
	GameManager.casino_open = true
	GameManager.night_closed = false
	GameManager.night_elapsed = 0.0
	tonight_guests_count = 0
	tonight_game_revenue_cents = 0
	tonight_bar_revenue_cents = 0
	occupied_activity_spots.clear()
	active_bar_visitor = null
	bar_idea_cooldown = 0.0
	guest_queue.clear()
	
	var initial_queue_size = 2
	for i in range(initial_queue_size):
		_add_guest_to_queue()
		
	guest_spawn_timer.start(5.0)

func _add_guest_to_queue() -> void:
	var g = NPC_SCENE.instantiate()
	var queue_idx = guest_queue.size()
	var queue_x = 640.0 + (12.0 if queue_idx % 2 == 1 else -12.0)
	var queue_y = 730.0 + (queue_idx * 26.0)
	g.position = Vector2(queue_x + randf_range(-15, 15), 900.0)
	
	var npcs = [
		"res://assets/sprites/npcs/npc_gambler1.png",
		"res://assets/sprites/npcs/npc_gambler2.png",
		"res://assets/sprites/npcs/npc_lady.png"
	]
	g.texture_path = npcs[randi() % npcs.size()]
	g.set_queue_position(Vector2(queue_x, queue_y))
	dynamic_furniture_container.add_child(g)
	guest_queue.append(g)

func close_casino_for_night() -> void:
	if GameManager.night_closed: return
	GameManager.night_closed = true
	GameManager.casino_open = false
	guest_spawn_timer.stop()
	GameManager.night_closed_signal.emit()
	
	var exit_pts = get_exit_waypoints()
	for child in dynamic_furniture_container.get_children():
		if child.has_method("start_leaving"):
			child.start_leaving(exit_pts)
	for q_guest in guest_queue:
		if is_instance_valid(q_guest) and q_guest.has_method("start_leaving"):
			q_guest.start_leaving(exit_pts)
	guest_queue.clear()
	active_bar_visitor = null
	vending_queue.clear()
	bar_idea_cooldown = 0.0
	
	var is_de = (GameManager.current_lang == "de")
	var main_c = get_tree().get_first_node_in_group("main_coordinator")
	if main_c and main_c.hud:
		main_c.hud.show_floating_banner(
			"04:00 UHR - SPERRSTUNDE! Gäste verlassen das Casino. Gehe zum Auto links!" if is_de else "04:00 AM - CLOSING TIME! Guests are leaving. Go to your car on the left!"
		)

func on_car_interacted() -> void:
	var is_de = (GameManager.current_lang == "de")
	var main_c = get_tree().get_first_node_in_group("main_coordinator")
	
	if GameManager.casino_open and not GameManager.night_closed:
		close_casino_for_night()
		if SoundManager: SoundManager.play_sfx("lever_release")
		return
		
	if GameManager.night_closed or tonight_guests_count > 0:
		if SoundManager: SoundManager.play_sfx("lever_release")
		if main_c and main_c.hud:
			main_c.hud.show_floating_banner("Fahre nach Hause... Gute Nacht!" if is_de else "Driving home... Good night!")
		end_business_night()
	else:
		if main_c and main_c.hud:
			main_c.hud.show_floating_banner(
				"Öffne erst das Casino heute Nacht!" if is_de else "Open the casino tonight first!"
			)

func end_business_night() -> void:
	GameManager.night_closed = false
	GameManager.casino_open = false
	guest_spawn_timer.stop()
	guest_queue.clear()
	occupied_activity_spots.clear()
	active_bar_visitor = null
	bar_idea_cooldown = 0.0
	
	# Dynamic building & utility upkeep:
	# Starter building is very cheap ($12 base + $1.50 per item) so player exits Day 1 with a tight positive profit.
	# Upkeep jumps significantly once building expansions (East Wing, VIP Lounge) are unlocked!
	var base_upkeep = 1200 # $12.00 starter power, heating & basic license
	var per_item_cost = 150 # $1.50 per placed furniture/machine in starter hall
	
	if GameManager.is_area_unlocked("east_wing"):
		base_upkeep += 6500 # +$65.00 for East Wing expansion
		per_item_cost = 250 # $2.50 per item
		
	if GameManager.is_area_unlocked("vip_lounge"):
		base_upkeep += 12000 # +$120.00 for VIP Lounge luxury upkeep
		per_item_cost = 400 # $4.00 per item
		
	var furniture_count = GameManager.placed_furniture.size()
	var upkeep = base_upkeep + (furniture_count * per_item_cost)
	
	# Security upgrade reduces upkeep costs by 30%
	if GameManager.has_upgrade("security"):
		upkeep = int(upkeep * 0.70)
	
	var dlg = DAILY_SUMMARY_SCENE.instantiate()
	var coord = get_tree().get_first_node_in_group("main_coordinator")
	if coord and coord.has_node("UILayer"):
		coord.get_node("UILayer").add_child(dlg)
	else:
		add_child(dlg)
		
	dlg.setup(
		GameManager.casino_day,
		tonight_guests_count,
		tonight_game_revenue_cents,
		tonight_bar_revenue_cents,
		upkeep
	)

func _on_guest_spawn_tick() -> void:
	if not GameManager.casino_open or GameManager.night_closed: return
	
	var max_guests = 5 if GameManager.casino_day <= 1 else clamp(5 + (GameManager.casino_day - 1) * 2, 5, 20)
	if GameManager.has_upgrade("neon_sign"):
		max_guests += 3
	
	if guest_queue.size() > 0:
		var entering_guest = guest_queue.pop_front()
		if is_instance_valid(entering_guest):
			var waypoints: Array[Vector2] = [
				Vector2(640.0, 700.0),
				Vector2(640.0, 640.0),
				Vector2(randf_range(300.0, 700.0), randf_range(420.0, 560.0))
			]
			entering_guest.start_entering(waypoints)
			tonight_guests_count += 1
			
		for idx in range(guest_queue.size()):
			var q_guest = guest_queue[idx]
			if is_instance_valid(q_guest):
				var q_x = 640.0 + (12.0 if idx % 2 == 1 else -12.0)
				var q_y = 730.0 + (idx * 26.0)
				q_guest.set_queue_position(Vector2(q_x, q_y))

	if (tonight_guests_count + guest_queue.size()) < max_guests and guest_queue.size() < 3:
		_add_guest_to_queue()

# Vinnie store door handlers
func _on_shop_door_entered(body: Node2D) -> void:
	if body.name == "Player" or body.is_in_group("player"):
		is_near_shop_door = true
		shop_label.visible = true

func _on_shop_door_exited(body: Node2D) -> void:
	if body.name == "Player" or body.is_in_group("player"):
		is_near_shop_door = false
		shop_label.visible = false

func _on_shop_door_area_entered(area: Area2D) -> void:
	if area.name == "InteractDetector" or area.get_parent().name == "Player":
		is_near_shop_door = true
		shop_label.visible = true

func _on_shop_door_area_exited(area: Area2D) -> void:
	if area.name == "InteractDetector" or area.get_parent().name == "Player":
		is_near_shop_door = false
		shop_label.visible = false

# Bob's Bauamt door handlers
func _on_bob_door_entered(body: Node2D) -> void:
	if body.name == "Player" or body.is_in_group("player"):
		is_near_bob_door = true
		bob_label.visible = true

func _on_bob_door_exited(body: Node2D) -> void:
	if body.name == "Player" or body.is_in_group("player"):
		is_near_bob_door = false
		bob_label.visible = false

func _on_bob_door_area_entered(area: Area2D) -> void:
	if area.name == "InteractDetector" or area.get_parent().name == "Player":
		is_near_bob_door = true
		bob_label.visible = true

func _on_bob_door_area_exited(area: Area2D) -> void:
	if area.name == "InteractDetector" or area.get_parent().name == "Player":
		is_near_bob_door = false
		bob_label.visible = false

# Player car door handlers
func _on_car_entered(body: Node2D) -> void:
	if body.name == "Player" or body.is_in_group("player"):
		is_near_car = true
		if car_label: car_label.visible = true

func _on_car_exited(body: Node2D) -> void:
	if body.name == "Player" or body.is_in_group("player"):
		is_near_car = false
		if car_label: car_label.visible = false

func _on_car_area_entered(area: Area2D) -> void:
	if area.name == "InteractDetector" or area.get_parent().name == "Player":
		is_near_car = true
		if car_label: car_label.visible = true

func _on_car_area_exited(area: Area2D) -> void:
	if area.name == "InteractDetector" or area.get_parent().name == "Player":
		is_near_car = false
		if car_label: car_label.visible = false

func on_interact() -> void:
	if is_near_shop_door:
		open_vinnie_store()
	elif is_near_bob_door:
		open_bob_store()
	elif is_near_car:
		on_car_interacted()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		if is_near_shop_door:
			open_vinnie_store()
		elif is_near_bob_door:
			open_bob_store()
		elif is_near_car:
			on_car_interacted()

func open_vinnie_store() -> void:
	if active_vinnie_dialog != null: return
	active_vinnie_dialog = VINNIE_STORE_SCENE.instantiate()
	var coord = get_tree().get_first_node_in_group("main_coordinator")
	if coord and coord.has_node("UILayer"):
		coord.get_node("UILayer").add_child(active_vinnie_dialog)
	else:
		add_child(active_vinnie_dialog)
	active_vinnie_dialog.store_closed.connect(func(): active_vinnie_dialog = null)

func open_bob_store() -> void:
	if active_bob_dialog != null: return
	active_bob_dialog = BOB_STORE_SCENE.instantiate()
	var coord = get_tree().get_first_node_in_group("main_coordinator")
	if coord and coord.has_node("UILayer"):
		coord.get_node("UILayer").add_child(active_bob_dialog)
	else:
		add_child(active_bob_dialog)
	active_bob_dialog.store_closed.connect(func(): active_bob_dialog = null)

func spawn_initial_bottles() -> void:
	for pt in spawn_points:
		if randf() > 0.3:
			spawn_bottle(pt)

func spawn_bottle(pos: Vector2) -> void:
	for child in bottle_container.get_children():
		if child.global_position.distance_to(pos) < 10.0:
			return
	var b = BOTTLE_SCENE.instantiate()
	b.position = pos
	bottle_container.add_child(b)

func _on_respawn_timer_timeout() -> void:
	if GameManager.game_mode != "high_roller": return
	if bottle_container.get_child_count() < 8:
		for i in range(2):
			var pt = spawn_points[randi() % spawn_points.size()]
			spawn_bottle(pt)
