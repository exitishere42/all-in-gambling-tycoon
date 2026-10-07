extends SceneTree

# Comprehensive Automated Test Suite for All In: Gambling Tycoon
# Tests scene instantiation, @onready bindings, UI dialogs, save/load cycles,
# building grid overlays, and casino expansions.

var passed_count := 0
var failed_count := 0
var failures: Array[String] = []

func _init() -> void:
	print("\n=======================================================")
	print("  RUNNING ALL IN: GAMBLING TYCOON AUTOMATED TEST SUITE ")
	print("=======================================================\n")
	
	await process_frame
	
	test_game_manager_save_load()
	test_all_scenes()
	test_build_grid_overlay_vectors()
	test_area_expansion_and_camera()
	test_dialog_lifecycle()
	
	print("\n=======================================================")
	print("  TEST RESULTS: %d PASSED, %d FAILED" % [passed_count, failed_count])
	print("=======================================================")
	
	if failed_count > 0:
		print("\nFAILURES:")
		for f in failures:
			print("  ❌ " + f)
		quit(1)
	else:
		print("  ✅ ALL TESTS PASSED SUCCESSFULLY!\n")
		quit(0)

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
		
		# Add to root tree to trigger @onready and _ready()
		root.add_child(instance)
		
		# Check for common crash issues in scripts
		assert_true(instance.is_inside_tree(), "Instance successfully entered tree: " + sc_path)
		
		root.remove_child(instance)
		instance.queue_free()

func test_build_grid_overlay_vectors() -> void:
	print("\n--- TEST SUITE: BuildGridOverlay Position Parsing & Drawing ---")
	
	var grid_script = load("res://scripts/ui/build_grid_overlay.gd")
	var grid_node = Node2D.new()
	grid_node.set_script(grid_script)
	root.add_child(grid_node)
	
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
	
	root.remove_child(grid_node)
	grid_node.queue_free()

func test_area_expansion_and_camera() -> void:
	print("\n--- TEST SUITE: Area Expansion & Camera Clamping ---")
	
	var player_scene = load("res://scenes/player.tscn")
	var player = player_scene.instantiate()
	root.add_child(player)
	
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
	
	root.remove_child(player)
	player.queue_free()

func test_dialog_lifecycle() -> void:
	print("\n--- TEST SUITE: DadLetter, BobStore, and VinnieStore Dialogs ---")
	
	# 1. Dad Letter Dialog
	var dad_dlg = load("res://scenes/ui/dad_letter_dialog.tscn").instantiate()
	root.add_child(dad_dlg)
	assert_true(dad_dlg.text_lbl != null, "DadLetter text_lbl bound")
	assert_true(dad_dlg.enter_btn != null, "DadLetter enter_btn bound")
	dad_dlg._on_enter_pressed()
	assert_true(GameManager.has_seen_dad_letter, "Dad letter marked seen on enter")
	
	# 2. Construction Store Dialog
	var bob_dlg = load("res://scenes/ui/construction_store_dialog.tscn").instantiate()
	root.add_child(bob_dlg)
	assert_true(bob_dlg.items_container != null, "BobStore items_container bound")
	assert_true(bob_dlg.cash_label != null, "BobStore cash_label bound")
	bob_dlg._on_close_pressed()
	
	# 3. Vinnie Store Dialog
	var vinnie_dlg = load("res://scenes/ui/vinnie_store_dialog.tscn").instantiate()
	root.add_child(vinnie_dlg)
	assert_true(vinnie_dlg.items_container != null, "VinnieStore items_container bound")
	vinnie_dlg._on_close_pressed()
	
	# 4. Renovation Screen
	var renov = load("res://scenes/ui/renovation_screen.tscn").instantiate()
	root.add_child(renov)
	renov.start_renovation("east_wing")
	assert_true(renov.progress_bar != null, "RenovationScreen progress_bar bound")
	renov.queue_free()
