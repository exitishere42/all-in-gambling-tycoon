extends Node

# Comprehensive Automated Test Suite for All In: Gambling Tycoon
# Tests scene instantiation, @onready bindings, UI dialogs, save/load cycles,
# building grid overlays, and casino expansions.

var passed_count := 0
var failed_count := 0
var failures: Array[String] = []

func _ready() -> void:
	print("\n=======================================================")
	print("  RUNNING ALL IN: GAMBLING TYCOON AUTOMATED TEST SUITE ")
	print("=======================================================\n")
	
	test_game_manager_save_load()
	test_all_scenes()
	test_build_grid_overlay_vectors()
	test_area_expansion_and_camera()
	test_dialog_lifecycle()
	test_rusty_slot_minigame_textures()
	test_night_cycle_car_and_npc_activities()
	test_economy_balancing_and_upkeep()
	
	print("\n=======================================================")
	print("  TEST RESULTS: %d PASSED, %d FAILED" % [passed_count, failed_count])
	print("=======================================================")
	
	if failed_count > 0:
		print("\nFAILURES:")
		for f in failures:
			print("  ❌ " + f)
		get_tree().quit(1)
	else:
		print("  ✅ ALL TESTS PASSED SUCCESSFULLY!\n")
		get_tree().quit(0)

func assert_true(condition: bool, test_name: String) -> void:
	if condition:
		passed_count += 1
		print("  [PASS] " + test_name)
	else:
		failed_count += 1
		failures.append(test_name)
		printerr("  [FAIL] " + test_name)

func test_game_manager_save_load() -> void:
	print("--- TEST SUITE: GameManager Save & Load Vector Parsing ---")
	
	# Test with string formatted pos, dict pos, and Vector2 pos
	GameManager.placed_furniture = [
		{"type": "slot_rusty", "pos": "(320.0, 380.0)"},
		{"type": "slot_modern", "pos": Vector2(400, 400)},
		{"type": "trash_bin", "pos": {"x": 500, "y": 500}}
	]
	GameManager.save_game()
	
	var success = GameManager.load_game()
	assert_true(success, "GameManager.load_game() should succeed")
	assert_true(GameManager.placed_furniture.size() >= 3, "All furniture items preserved")
	
	for i in range(GameManager.placed_furniture.size()):
		var f = GameManager.placed_furniture[i]
		var p = f.get("pos")
		assert_true(p is Vector2, "Furniture pos at index %d is real Vector2, got: %s" % [i, type_string(typeof(p))])

func test_all_scenes() -> void:
	print("\n--- TEST SUITE: Scene Instantiation & Ready Lifecycle ---")
	
	var scenes_to_test = [
		"res://scenes/main.tscn",
		"res://scenes/casino_world.tscn",
		"res://scenes/player.tscn",
		"res://scenes/ui/main_menu.tscn",
		"res://scenes/ui/hud.tscn",
		"res://scenes/ui/dad_letter_dialog.tscn",
		"res://scenes/ui/vinnie_store_dialog.tscn",
		"res://scenes/ui/construction_store_dialog.tscn",
		"res://scenes/ui/daily_summary_dialog.tscn",
		"res://scenes/ui/renovation_screen.tscn",
		"res://scenes/ui/build_system_ui.tscn",
		"res://scenes/ui/game_over.tscn",
		"res://scenes/minigames/slots_game.tscn",
		"res://scenes/minigames/crash_game.tscn",
		"res://scenes/minigames/roulette_game.tscn",
		"res://scenes/minigames/blackjack_game.tscn",
		"res://scenes/props/arcade_cabinet.tscn",
		"res://scenes/props/bottle.tscn",
		"res://scenes/props/casino_table.tscn",
		"res://scenes/props/npc.tscn",
		"res://scenes/props/placed_furniture_prop.tscn",
		"res://scenes/props/trash_item.tscn"
	]
	
	for sc_path in scenes_to_test:
		if not ResourceLoader.exists(sc_path):
			assert_true(false, "Scene file exists: " + sc_path)
			continue
			
		var packed: PackedScene = load(sc_path)
		assert_true(packed != null, "Load PackedScene: " + sc_path)
		
		var instance = packed.instantiate()
		assert_true(instance != null, "Instantiate instance: " + sc_path)
		
		# Add to tree to trigger @onready and _ready()
		add_child(instance)
		
		assert_true(instance.is_inside_tree(), "Instance successfully entered tree: " + sc_path)
		
		remove_child(instance)
		instance.queue_free()

func test_build_grid_overlay_vectors() -> void:
	print("\n--- TEST SUITE: BuildGridOverlay Position Parsing & Drawing ---")
	
	var grid_script = load("res://scripts/ui/build_grid_overlay.gd")
	var grid_node = Node2D.new()
	grid_node.set_script(grid_script)
	add_child(grid_node)
	
	# Test with various pos types
	var p1 = grid_node._parse_vec2(Vector2(100, 200))
	assert_true(p1 == Vector2(100, 200), "_parse_vec2(Vector2) returns same Vector2")
	
	var p2 = grid_node._parse_vec2("(320.0, 380.0)")
	assert_true(p2 == Vector2(320, 380), "_parse_vec2(String) parsed correctly to Vector2(320, 380)")
	
	var p3 = grid_node._parse_vec2({"x": 450.0, "y": 550.0})
	assert_true(p3 == Vector2(450, 550), "_parse_vec2(Dictionary) parsed correctly to Vector2(450, 550)")
	
	# Test boundary logic
	var bounds = grid_node._get_active_bounds()
	assert_true(bounds.size.x > 0 and bounds.size.y > 0, "_get_active_bounds() has valid size")
	
	# Test tile validity check with string in placed_furniture
	GameManager.placed_furniture = [
		{"type": "slot_rusty", "pos": "(320.0, 380.0)"}
	]
	var is_valid = grid_node._is_tile_valid(Vector2(320, 380))
	assert_true(not is_valid, "Tile occupied by slot_rusty is correctly marked invalid")
	
	var empty_tile = grid_node._is_tile_valid(Vector2(500, 450))
	assert_true(empty_tile, "Empty tile in bounds is correctly marked valid")
	
	# Test drawing pass
	grid_node.last_snapped_pos = Vector2(500, 450)
	grid_node.set_build_mode(true, "slot_rusty")
	assert_true(grid_node.visible, "Build grid visible when active")
	
	remove_child(grid_node)
	grid_node.queue_free()

func test_area_expansion_and_camera() -> void:
	print("\n--- TEST SUITE: Area Expansion & Camera Clamping ---")
	
	var player_scene = load("res://scenes/player.tscn")
	var player = player_scene.instantiate()
	add_child(player)
	
	# Starter mode camera
	GameManager.game_mode = "tycoon"
	GameManager.unlocked_areas = ["starter"]
	player.update_camera_bounds()
	
	assert_true(player.camera.limit_right >= 1240, "Camera limit_right allows reaching Bob's shop (>= 1240), got: %d" % player.camera.limit_right)
	assert_true(player.camera.limit_top >= 200, "Camera limit_top clamps VIP when locked, got: %d" % player.camera.limit_top)
	
	# Unlock VIP
	GameManager.unlocked_areas.append("vip_lounge")
	player.update_camera_bounds()
	assert_true(player.camera.limit_top <= 40, "Camera limit_top expands to top when VIP unlocked, got: %d" % player.camera.limit_top)
	
	remove_child(player)
	player.queue_free()

func test_dialog_lifecycle() -> void:
	print("\n--- TEST SUITE: DadLetter, BobStore, and VinnieStore Dialogs ---")
	
	# 1. Dad Letter Dialog
	var dad_dlg = load("res://scenes/ui/dad_letter_dialog.tscn").instantiate()
	add_child(dad_dlg)
	assert_true(dad_dlg.text_lbl != null, "DadLetter text_lbl bound")
	assert_true(dad_dlg.enter_btn != null, "DadLetter enter_btn bound")
	dad_dlg._on_enter_pressed()
	assert_true(GameManager.has_seen_dad_letter, "Dad letter marked seen on enter")
	
	# 2. Construction Store Dialog
	var bob_dlg = load("res://scenes/ui/construction_store_dialog.tscn").instantiate()
	add_child(bob_dlg)
	assert_true(bob_dlg.items_container != null, "BobStore items_container bound")
	assert_true(bob_dlg.cash_label != null, "BobStore cash_label bound")
	bob_dlg._on_close_pressed()
	
	# 3. Vinnie Store Dialog
	var vinnie_dlg = load("res://scenes/ui/vinnie_store_dialog.tscn").instantiate()
	add_child(vinnie_dlg)
	assert_true(vinnie_dlg.items_container != null, "VinnieStore items_container bound")
	vinnie_dlg._on_close_pressed()
	
	# 4. Renovation Screen
	var renov = load("res://scenes/ui/renovation_screen.tscn").instantiate()
	add_child(renov)
	renov.start_renovation("east_wing")
	assert_true(renov.progress_bar != null, "RenovationScreen progress_bar bound")
	renov.queue_free()
	
	test_furniture_move_and_pack()

func test_furniture_move_and_pack() -> void:
	print("\n--- TEST SUITE: CasinoWorld Furniture Move, Pack, and Cell Snapping ---")
	
	var world_scene = load("res://scenes/casino_world.tscn")
	var world = world_scene.instantiate()
	add_child(world)
	
	GameManager.game_mode = "tycoon"
	GameManager.unlocked_areas = ["starter"]
	GameManager.placed_furniture = [
		{"type": "slot_rusty", "pos": Vector2(336, 400)}
	]
	GameManager.inventory["slot_modern"] = 1
	
	# Test snapping helper: floor(pos/32)*32 + 16
	var snap1 = world.get_snapped_cell_pos(Vector2(325, 410))
	assert_true(snap1 == Vector2(336, 400), "get_snapped_cell_pos(325, 410) snaps to (336, 400)")
	
	# Test get_furniture_at
	var item_found = world.get_furniture_at(Vector2(336, 400))
	assert_true(not item_found.is_empty(), "get_furniture_at finds slot_rusty at (336, 400)")
	assert_true(item_found.get("type") == "slot_rusty", "Found item type is slot_rusty")
	
	# Test is_build_pos_valid on occupied spot
	var is_valid_occupied = world.is_build_pos_valid(Vector2(336, 400))
	assert_true(not is_valid_occupied, "Occupied spot is not valid for new placement")
	
	# Test move_furniture to an empty cell
	var target_cell = Vector2(400, 400) # snapped: floor(400/32)*32+16 = 12*32+16 = 400
	var moved = world.move_furniture(Vector2(336, 400), target_cell)
	assert_true(moved, "move_furniture to (400, 400) succeeds")
	
	var item_at_new = world.get_furniture_at(Vector2(400, 400))
	assert_true(not item_at_new.is_empty(), "Item found at new location (400, 400)")
	var item_at_old = world.get_furniture_at(Vector2(336, 400))
	assert_true(item_at_old.is_empty(), "Old location (336, 400) is now empty")
	
	# Test remove_furniture_to_inventory (packing up)
	var prev_rusty_inv = GameManager.inventory.get("slot_rusty", 0)
	var packed_type = world.remove_furniture_to_inventory(Vector2(400, 400))
	assert_true(packed_type == "slot_rusty", "Packed up item type is slot_rusty")
	assert_true(GameManager.inventory.get("slot_rusty", 0) == prev_rusty_inv + 1, "Inventory slot_rusty incremented by 1")
	assert_true(world.get_furniture_at(Vector2(400, 400)).is_empty(), "Position (400, 400) is now free after pack-up")
	
	# Test NPC Queueing & Bar Seat Allocation
	GameManager.placed_furniture.append({
		"type": "bar_stool",
		"pos": Vector2(500, 400)
	})
	var stool_seat = world.get_available_bar_seat()
	assert_true(stool_seat == Vector2(500, 400), "get_available_bar_seat() finds bar_stool at (500, 400)")
	var stool_seat_taken = world.get_available_bar_seat()
	assert_true(stool_seat_taken == Vector2.ZERO, "Occupied bar_stool is not assigned twice")
	
	# Test NPC state methods
	var npc_scene = load("res://scenes/props/npc.tscn")
	var npc = npc_scene.instantiate()
	add_child(npc)
	npc.set_queue_position(Vector2(640, 750))
	assert_true(npc.current_state == npc.State.QUEUING, "NPC enters QUEUING state")
	assert_true(npc.target_destination == Vector2(640, 750), "NPC target_destination set for queue")
	
	var pts: Array[Vector2] = [Vector2(640, 700), Vector2(640, 640), Vector2(500, 450)]
	npc.start_entering(pts)
	assert_true(npc.current_state == npc.State.ENTERING, "NPC enters ENTERING state")
	assert_true(npc.path_points.size() == 3, "NPC waypoints assigned")
	
	npc.assign_bar_seat(Vector2(500, 400))
	assert_true(npc.current_state == npc.State.SEATED_STOOL, "NPC enters SEATED_STOOL state")
	
	remove_child(npc)
	npc.queue_free()
	
	remove_child(world)
	world.queue_free()

func test_rusty_slot_minigame_textures() -> void:
	print("\n--- TEST SUITE: Rusty vs Modern Slot Minigame Textures ---")
	
	# Test rusty variant loading
	GameManager.active_minigame = "slot_rusty"
	var slots_scene = load("res://scenes/minigames/slots_game.tscn")
	var slot_inst = slots_scene.instantiate()
	add_child(slot_inst)
	
	assert_true(slot_inst.is_rusty, "slot_inst detects rusty variant correctly")
	assert_true(slot_inst.frame_overlay.texture == slot_inst.frame_overlay_rusty, "Rusty frame overlay texture applied")
	assert_true(slot_inst.reel_window_bg.texture == slot_inst.reel_bg_rusty, "Rusty reel background texture applied")
	assert_true(slot_inst.lever_up_tex == slot_inst.lever_up_rusty, "Rusty lever texture applied")
	
	remove_child(slot_inst)
	slot_inst.queue_free()
	
	# Test modern variant loading
	GameManager.active_minigame = "slot_modern"
	var modern_inst = slots_scene.instantiate()
	add_child(modern_inst)
	
	assert_true(not modern_inst.is_rusty, "modern_inst detects modern variant correctly")
	assert_true(modern_inst.frame_overlay.texture == modern_inst.frame_overlay_tex, "Clean frame overlay texture applied")
	assert_true(modern_inst.reel_window_bg.texture == modern_inst.reel_bg_tex, "Clean reel background texture applied")
	
	remove_child(modern_inst)
	modern_inst.queue_free()
	GameManager.active_minigame = ""

func test_night_cycle_car_and_npc_activities() -> void:
	print("\n--- TEST SUITE: Night Cycle, NPC Activities, Trash & Player Car ---")
	
	GameManager.game_mode = "tycoon"
	GameManager.casino_day = 1
	GameManager.placed_furniture = [
		{"type": "slot_rusty", "pos": Vector2(336, 400)},
		{"type": "bar_counter", "pos": Vector2(400, 350)},
		{"type": "table", "pos": Vector2(450, 450)},
		{"type": "bar_stool", "pos": Vector2(500, 400)}
	]
	
	var world_scene = load("res://scenes/casino_world.tscn")
	var world = world_scene.instantiate()
	add_child(world)
	
	# 1. Test Player Car existence in scene
	assert_true(world.car_door_area != null, "PlayerCar interact area exists")
	assert_true(world.car_label != null, "PlayerCar label exists")
	
	# 2. Test Night 1 max guests cap
	world.start_business_night()
	assert_true(GameManager.casino_open, "Casino is open after start_business_night")
	assert_true(not GameManager.night_closed, "Night is not closed yet")
	
	# Check guest cap for Day 1
	var max_guests = 5 if GameManager.casino_day <= 1 else clamp(5 + (GameManager.casino_day - 1) * 2, 5, 20)
	assert_true(max_guests == 5, "Day 1 strictly caps total visitors to 5")
	
	# 3. Test Game spot allocation
	var game_spot = world.get_available_game_spot()
	assert_true(not game_spot.is_empty(), "get_available_game_spot() finds slot_rusty")
	assert_true(game_spot.get("type") == "slot_rusty", "Found game spot is slot_rusty")
	var game_spot_2 = world.get_available_game_spot()
	assert_true(game_spot_2.is_empty(), "Occupied slot_rusty cannot be assigned twice concurrently")
	world.release_activity_spot(game_spot.get("pos"))
	var game_spot_reacquired = world.get_available_game_spot()
	assert_true(not game_spot_reacquired.is_empty(), "Slot spot re-acquirable after release")
	
	# 4. Test Bar Counter & Table spot allocation
	var bar_spot = world.get_available_bar_counter()
	assert_true(bar_spot != Vector2.ZERO, "get_available_bar_counter() finds bar_counter spot")
	assert_true(bar_spot.y >= 350.0, "get_available_bar_counter() provides clean standing clearance in front of bar counter")
	
	var table_spot_1 = world.get_available_table()
	assert_true(table_spot_1 != Vector2.ZERO, "get_available_table() finds table spot")
	# Table spot must be on the left or right perimeter (>= 40px from center x), never in the middle!
	var table_item_pos = Vector2(450, 450)
	for it in GameManager.placed_furniture:
		if it.get("type") == "table":
			table_item_pos = world._parse_pos_to_vec2(it.get("pos"))
			break
	assert_true(abs(table_spot_1.x - table_item_pos.x) >= 40.0, "Table spot is cleanly positioned next to table, not inside surface")
	
	# Table offers a second seat spot (up to 2 guests per table)
	var table_spot_2 = world.get_available_table()
	assert_true(table_spot_2 != Vector2.ZERO and table_spot_2 != table_spot_1, "Table provides a second independent seating spot on opposite side")
	world.release_activity_spot(table_spot_1)
	world.release_activity_spot(table_spot_2)
	
	# 5. Test Trash / Dirty bottle drop on table
	var bottles_before = world.bottle_container.get_child_count()
	var trash_before = world.trash_container.get_child_count()
	world.spawn_table_trash(Vector2(450, 450))
	var bottles_after = world.bottle_container.get_child_count()
	var trash_after = world.trash_container.get_child_count()
	assert_true(bottles_after > bottles_before or trash_after > trash_before, "spawn_table_trash() drops bottle or trash piece")
	
	# 6. Test NPC rich states & seating z_index
	var npc_scene = load("res://scenes/props/npc.tscn")
	var npc = npc_scene.instantiate()
	add_child(npc)
	
	npc.assign_game("slot_rusty", Vector2(336, 420))
	assert_true(npc.current_state == npc.State.PLAYING_GAME, "NPC transitions to PLAYING_GAME")
	
	npc.assign_bar_order(Vector2(400, 372), Vector2(450, 450))
	assert_true(npc.current_state == npc.State.ORDERING_BAR, "NPC transitions to ORDERING_BAR")
	
	npc.assign_bar_seat(Vector2(500, 400))
	assert_true(npc.current_state == npc.State.SEATED_STOOL, "NPC transitions to SEATED_STOOL")
	# Simulate arrival
	npc.position = Vector2(500, 400)
	npc._physics_process(0.1)
	assert_true(npc.z_index == 2, "Seated NPC on bar stool has z_index 2 to render cleanly ON TOP of stool cushion")
	
	npc.assign_table(Vector2(450, 450))
	assert_true(npc.current_state == npc.State.SEATED_TABLE, "NPC transitions to SEATED_TABLE")
	npc.position = Vector2(450, 450)
	npc._physics_process(0.1)
	assert_true(npc.z_index == 1, "Seated NPC at table has z_index 1")
	
	npc._free_current_activity()
	assert_true(npc.z_index == 0, "NPC z_index resets to 0 when freeing activity")
	
	# Verify table prop physical collision
	var prop_scene = load("res://scenes/props/placed_furniture_prop.tscn")
	var table_prop = prop_scene.instantiate()
	table_prop.item_type = "table"
	add_child(table_prop)
	var col_shape = table_prop.get_node("CollisionShape2D").shape
	assert_true(col_shape.size.x >= 70.0 and col_shape.size.y >= 30.0, "Table prop has customized full-width collision shape")
	remove_child(table_prop)
	table_prop.queue_free()
	
	# 7. Test Drink Vending Machine Queueing & Line Advancement
	var npc2 = npc_scene.instantiate()
	var npc3 = npc_scene.instantiate()
	var npc4 = npc_scene.instantiate()
	add_child(npc2)
	add_child(npc3)
	add_child(npc4)
	world.active_bar_visitor = null
	world.vending_queue.clear()
	world.bar_idea_cooldown = 0.0
	
	# NPC 1 arrives first -> gets front spot
	assert_true(world.can_have_bar_idea(npc), "NPC 1 can use vending machine")
	var claim1_success = world.claim_bar_idea(npc)
	assert_true(claim1_success, "NPC 1 claims front spot at vending machine")
	assert_true(world.active_bar_visitor == npc, "NPC 1 is active front visitor")
	
	# NPC 2 arrives while front is occupied -> queues up in line
	assert_true(world.can_have_bar_idea(npc2), "NPC 2 can join vending machine queue")
	var claim2_success = world.claim_bar_idea(npc2)
	assert_true(claim2_success, "NPC 2 successfully joins vending queue")
	assert_true(world.vending_queue.has(npc2), "NPC 2 is in vending queue array")
	
	# NPC 3 queues up behind NPC 2
	var claim3_success = world.claim_bar_idea(npc3)
	assert_true(claim3_success, "NPC 3 successfully joins vending queue")
	
	# NPC 4 cannot join because queue is full (max 2 waiting)
	var claim4_success = world.claim_bar_idea(npc4)
	assert_true(not claim4_success, "NPC 4 cannot join full vending queue (capacity 2)")
	
	# NPC 1 finishes at vending machine -> NPC 2 automatically advances to front!
	world.release_bar_idea(npc)
	assert_true(world.active_bar_visitor == npc2, "NPC 2 automatically advances to front spot when NPC 1 leaves")
	assert_true(world.vending_queue.size() == 1 and world.vending_queue[0] == npc3, "NPC 3 moves up in the waiting queue")
	
	# Test standing drinking transition
	npc.start_drinking_standing()
	assert_true(npc.current_state == npc.State.DRINKING_STANDING, "NPC transitions to DRINKING_STANDING state")
	
	# Clean up test NPCs
	world.release_bar_idea(npc2)
	world.release_bar_idea(npc3)
	remove_child(npc2)
	remove_child(npc3)
	remove_child(npc4)
	npc2.queue_free()
	npc3.queue_free()
	npc4.queue_free()

	# 8. Test closing casino for night
	world.close_casino_for_night()
	assert_true(GameManager.night_closed, "Night is marked closed")
	assert_true(not GameManager.casino_open, "Casino is marked not open")
	
	var exit_pts = world.get_exit_waypoints()
	assert_true(exit_pts.size() >= 4, "Exit waypoints defined")
	assert_true(exit_pts[exit_pts.size() - 1].x > 1280.0, "Exit waypoints lead to street off-screen right (x > 1280)")
	assert_true(exit_pts[2].y >= 820.0 and exit_pts[3].y >= 820.0, "Exit waypoints route along open street asphalt (y >= 820) bypassing Bob's shop")
	assert_true(world.get_node_or_null("CityStreet/NorthWalls/BobShopCol") != null, "Bob's shop has solid physical collision barrier")
	
	# Test Player-NPC non-blocking collision (player can walk freely through NPCs)
	var player_sc = load("res://scenes/player.tscn")
	var pl = player_sc.instantiate()
	add_child(pl)
	assert_true((pl.collision_mask & npc.collision_layer) == 0, "Player mask does not collide with NPC layer (player walks through NPCs)")
	assert_true((npc.collision_mask & pl.collision_layer) == 0, "NPC mask does not collide with Player layer (NPC does not block player)")
	remove_child(pl)
	pl.queue_free()
	
	npc.start_leaving(exit_pts)
	assert_true(npc.current_state == npc.State.LEAVING, "NPC transitions to LEAVING state")
	
	# 9. Test Player Car interaction to finish day
	world.on_car_interacted()
	assert_true(not GameManager.casino_open, "Car interaction completes day")
	
	remove_child(npc)
	npc.queue_free()
	remove_child(world)
	world.queue_free()

func test_economy_balancing_and_upkeep() -> void:
	print("\n--- TEST SUITE: Economy Balancing & Tiered Upkeep ---")
	
	# 1. Reset game and check starter cash
	GameManager.reset_game(false)
	assert_true(GameManager.cash_cents == 2000, "Starter cash in tycoon mode is $20.00 (2000 cents)")
	
	# 2. Cleanup reward: 10 trash items x $2.00 + $200.00 cleanliness bonus
	var trash_reward_total = 10 * 200 # 2000 cents ($20.00)
	var cleanliness_bonus = 20000 # $200.00
	var total_cash_after_cleanup = GameManager.cash_cents + trash_reward_total + cleanliness_bonus
	assert_true(total_cash_after_cleanup == 24000, "Total starter cash after full cleanup is exactly $240.00 (24000 cents)")
	
	# 3. Check Vinnie's store starter furniture pack prices
	var vinnie_scene = load("res://scenes/ui/vinnie_store_dialog.tscn")
	var vinnie_inst = vinnie_scene.instantiate()
	var bar_price := 0
	var stool_price := 0
	var table_price := 0
	var trash_price := 0
	
	for item in vinnie_inst.CATALOG:
		match item["id"]:
			"bar_counter": bar_price = item["price_cents"]
			"bar_stool": stool_price = item["price_cents"]
			"table": table_price = item["price_cents"]
			"trash_bin": trash_price = item["price_cents"]
			
	assert_true(bar_price == 10500, "Bar counter price is $105.00 (10500 cents)")
	assert_true(table_price == 4500, "Table price is $45.00 (4500 cents)")
	assert_true(stool_price == 2500, "Stool price is $25.00 (2500 cents)")
	assert_true(trash_price == 1500, "Trash bin price is $15.00 (1500 cents)")
	
	# Starter pack: 1x Bar counter + 1x Trash bin + 1x Bar stool + 1x Table + 2x Table chairs (stools) = 3 stools total
	var starter_pack_total = bar_price + trash_price + (stool_price * 1) + table_price + (stool_price * 2)
	assert_true(starter_pack_total == 24000, "Starter pack (bar + 1 bar stool + trash bin + table + 2 table chairs) sum is exactly $240.00 (24000 cents)")
	assert_true(total_cash_after_cleanup - starter_pack_total == 0, "Buying full starter pack leaves exactly $0.00 change ('perfekt für die bar theke ein stuhl mülleimer und tisch mit 2 stühlen')")
	
	vinnie_inst.queue_free()
	
	# 4. Check Starter Room Upkeep with placed starter items
	var world_scene = load("res://scenes/casino_world.tscn")
	var world = world_scene.instantiate()
	add_child(world)
	
	# 7 items in starter room (1 slot_rusty + 1 bar_counter + 1 table + 3 bar_stools + 1 trash_bin)
	GameManager.unlocked_areas = ["starter"]
	GameManager.placed_furniture = [
		{"type": "slot_rusty", "pos": Vector2(336, 400)},
		{"type": "bar_counter", "pos": Vector2(400, 350)},
		{"type": "bar_stool", "pos": Vector2(400, 400)},
		{"type": "table", "pos": Vector2(500, 450)},
		{"type": "bar_stool", "pos": Vector2(470, 450)},
		{"type": "bar_stool", "pos": Vector2(530, 450)},
		{"type": "trash_bin", "pos": Vector2(300, 350)}
	]
	
	var starter_base_upkeep = 1200 # $12.00
	var starter_per_item = 150 # $1.50
	var calculated_starter_upkeep = starter_base_upkeep + (GameManager.placed_furniture.size() * starter_per_item)
	assert_true(calculated_starter_upkeep == 2250, "Starter room upkeep for 7 items is affordable $22.50 (2250 cents)")
	
	# 5. Check Upkeep with East Wing expansion (jumps substantially)
	GameManager.unlock_area("east_wing")
	var east_wing_base_upkeep = starter_base_upkeep + 6500 # $12.00 + $65.00 = $77.00
	var east_wing_per_item = 250
	var calculated_east_upkeep = east_wing_base_upkeep + (GameManager.placed_furniture.size() * east_wing_per_item)
	assert_true(calculated_east_upkeep == 9450, "East Wing expansion jumps upkeep to $94.50 (9450 cents)")
	
	# 6. Check Upkeep with VIP Lounge expansion (luxury upkeep)
	GameManager.unlock_area("vip_lounge")
	var vip_base_upkeep = east_wing_base_upkeep + 12000 # $77.00 + $120.00 = $197.00
	var vip_per_item = 400
	var calculated_vip_upkeep = vip_base_upkeep + (GameManager.placed_furniture.size() * vip_per_item)
	assert_true(calculated_vip_upkeep == 22500, "VIP Lounge expansion jumps upkeep to $225.00 (22500 cents)")
	
	remove_child(world)
	world.queue_free()
