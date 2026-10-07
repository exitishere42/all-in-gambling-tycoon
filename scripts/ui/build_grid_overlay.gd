extends Node2D

# Build Grid Overlay
# Renders a high-contrast retro 32x32 construction grid on the casino floor during Build Mode.
# Highlights valid/invalid placement tiles, locked expansion zones, and renders an item ghost preview.

const GRID_MIN := Vector2(96, 288)
const GRID_MAX := Vector2(1216, 672)
const CELL_SIZE := 32.0

const ITEM_TEXTURES := {
	"slot_rusty": preload("res://assets/sprites/props/slot_machine_rusty.png"),
	"slot_modern": preload("res://assets/sprites/raw_slots/Slot Machine/slot-machine1.png"),
	"crash": preload("res://assets/sprites/environment/crash_cabinet.png"),
	"roulette": preload("res://assets/sprites/environment/roulette_table.png"),
	"blackjack": preload("res://assets/sprites/props/blackjack_table.png"),
	"bar_counter": preload("res://assets/sprites/furniture/bar_counter.png"),
	"bar_stool": preload("res://assets/sprites/furniture/bar_stool.png"),
	"atm": preload("res://assets/sprites/furniture/atm_machine.png"),
	"plant": preload("res://assets/sprites/furniture/potted_plant.png"),
	"trash_bin": preload("res://assets/sprites/furniture/trash_bin.png")
}

var is_active: bool = false
var selected_item_type: String = ""
var moving_item_type: String = ""
var moving_orig_pos: Vector2 = Vector2.ZERO
var last_snapped_pos: Vector2 = Vector2.ZERO
var pulse_time: float = 0.0

var silkscreen_font = preload("res://assets/fonts/Silkscreen-Regular.ttf")

func _ready() -> void:
	visible = false
	z_index = 5 # Over floor and rugs, under characters and dialogue
	process_mode = Node.PROCESS_MODE_ALWAYS

func set_build_mode(active: bool, item_type: String = "") -> void:
	is_active = active
	selected_item_type = item_type
	moving_item_type = ""
	moving_orig_pos = Vector2.ZERO
	visible = active
	queue_redraw()

func set_selected_item(item_type: String) -> void:
	selected_item_type = item_type
	moving_item_type = ""
	moving_orig_pos = Vector2.ZERO
	queue_redraw()

func set_moving_item(item_type: String, orig_pos: Vector2) -> void:
	moving_item_type = item_type
	moving_orig_pos = orig_pos
	selected_item_type = ""
	queue_redraw()

func clear_moving_item() -> void:
	moving_item_type = ""
	moving_orig_pos = Vector2.ZERO
	queue_redraw()

func _process(delta: float) -> void:
	if not visible:
		return
		
	pulse_time += delta * 4.0
	var cam = get_viewport().get_camera_2d()
	var m_pos = get_global_mouse_position() if cam else Vector2.ZERO
	var cell_x = floor(m_pos.x / CELL_SIZE) * CELL_SIZE + 16.0
	var cell_y = floor(m_pos.y / CELL_SIZE) * CELL_SIZE + 16.0
	var snapped_pos = Vector2(cell_x, cell_y)
	
	if snapped_pos != last_snapped_pos:
		last_snapped_pos = snapped_pos
		queue_redraw()
	else:
		# Periodic update for smooth pulse animation
		queue_redraw()

func _get_active_bounds() -> Rect2:
	var x_min := 96.0
	var x_max := 1216.0 if GameManager.is_area_unlocked("east_wing") else 736.0
	var y_min := 64.0 if GameManager.is_area_unlocked("vip_lounge") else 288.0
	var y_max := 672.0
	return Rect2(x_min, y_min, x_max - x_min, y_max - y_min)

func _parse_vec2(val) -> Vector2:
	if val is Vector2:
		return val
	if val is String:
		var s: String = val.strip_edges().trim_prefix("(").trim_suffix(")")
		var parts := s.split(",")
		if parts.size() >= 2:
			return Vector2(parts[0].to_float(), parts[1].to_float())
	if val is Dictionary:
		return Vector2(float(val.get("x", 0.0)), float(val.get("y", 0.0)))
	return Vector2.ZERO

func _is_tile_valid(pos: Vector2) -> bool:
	var bounds = _get_active_bounds()
	if pos.x < bounds.position.x or pos.x > bounds.end.x:
		return false
	if pos.y < bounds.position.y or pos.y > bounds.end.y:
		return false
		
	# Doorway clearance (entrance to street)
	if pos.y >= 640.0 and pos.x >= 576.0 and pos.x <= 704.0:
		return false
		
	# Check collision with already placed furniture (ignoring moving item's original spot)
	for item in GameManager.placed_furniture:
		var item_pos = _parse_vec2(item.get("pos", Vector2.ZERO))
		if moving_orig_pos != Vector2.ZERO and item_pos.distance_to(moving_orig_pos) < 10.0:
			continue
		if item_pos.distance_to(pos) < 24.0:
			return false
			
	return true

func _draw() -> void:
	if not visible:
		return
		
	var bounds = _get_active_bounds()
	var grid_min = bounds.position
	var grid_max = bounds.end
	
	# 1. Base grid lines and crosshairs strictly inside active room
	var grid_line_color = Color(0.25, 0.75, 1.0, 0.28)
	var crosshair_color = Color(1.0, 0.85, 0.35, 0.5)
	
	# Vertical grid lines
	var x = grid_min.x
	while x <= grid_max.x:
		draw_line(Vector2(x, grid_min.y), Vector2(x, grid_max.y), grid_line_color, 1.0)
		x += CELL_SIZE
		
	# Horizontal grid lines
	var y = grid_min.y
	while y <= grid_max.y:
		draw_line(Vector2(grid_min.x, y), Vector2(grid_max.x, y), grid_line_color, 1.0)
		y += CELL_SIZE
		
	# Corner crosshairs on vertices
	x = grid_min.x
	while x <= grid_max.x:
		y = grid_min.y
		while y <= grid_max.y:
			draw_line(Vector2(x - 2, y), Vector2(x + 2, y), crosshair_color, 1.0)
			draw_line(Vector2(x, y - 2), Vector2(x, y + 2), crosshair_color, 1.0)
			y += CELL_SIZE
		x += CELL_SIZE

	# 2. Outer boundary border
	draw_rect(bounds, Color(0.3, 0.8, 1.0, 0.45), false, 2.0)

	# 3. Mark Existing Placed Furniture tiles
	var hovered_existing_item: Dictionary = {}
	for item in GameManager.placed_furniture:
		var item_pos = _parse_vec2(item.get("pos", Vector2.ZERO))
		# If this is the item currently being moved, highlight original spot faintly
		if moving_orig_pos != Vector2.ZERO and item_pos.distance_to(moving_orig_pos) < 10.0:
			var orig_rect = Rect2(item_pos.x - 16, item_pos.y - 16, 32, 32)
			draw_rect(orig_rect, Color(0.3, 0.7, 1.0, 0.15), true)
			draw_rect(orig_rect, Color(0.3, 0.7, 1.0, 0.4), false, 1.0)
			continue
			
		var occ_rect = Rect2(item_pos.x - 16, item_pos.y - 16, 32, 32)
		draw_rect(occ_rect, Color(1.0, 0.7, 0.2, 0.15), true)
		draw_rect(occ_rect, Color(1.0, 0.75, 0.2, 0.45), false, 1.0)
		
		if item_pos.distance_to(last_snapped_pos) < 16.0:
			hovered_existing_item = item

	# 4. Highlight hovered grid tile & ghost item preview
	var is_in_floor = (last_snapped_pos.x >= grid_min.x and last_snapped_pos.x <= grid_max.x and last_snapped_pos.y >= grid_min.y and last_snapped_pos.y <= grid_max.y)
	if is_in_floor:
		var tile_rect = Rect2(last_snapped_pos.x - 16, last_snapped_pos.y - 16, 32, 32)
		var is_valid = _is_tile_valid(last_snapped_pos)
		
		var pulse_alpha = 0.35 + sin(pulse_time) * 0.1
		var fill_color: Color
		var border_color: Color
		
		if moving_item_type != "" or selected_item_type != "":
			if is_valid:
				fill_color = Color(0.2, 0.95, 0.4, pulse_alpha)
				border_color = Color(0.3, 1.0, 0.5, 0.9)
			else:
				fill_color = Color(0.95, 0.25, 0.25, pulse_alpha)
				border_color = Color(1.0, 0.35, 0.35, 0.9)
		else:
			# Neutral hover or existing furniture pickup highlight
			if not hovered_existing_item.is_empty():
				fill_color = Color(1.0, 0.85, 0.2, 0.4)
				border_color = Color(1.0, 0.9, 0.3, 0.95)
			else:
				fill_color = Color(0.3, 0.75, 1.0, 0.2)
				border_color = Color(0.4, 0.85, 1.0, 0.6)
			
		draw_rect(tile_rect, fill_color, true)
		draw_rect(tile_rect, border_color, false, 2.0)
		
		# Draw item ghost preview if moving or placing
		var active_ghost_type = moving_item_type if moving_item_type != "" else selected_item_type
		if active_ghost_type != "" and ITEM_TEXTURES.has(active_ghost_type):
			var tex: Texture2D = ITEM_TEXTURES[active_ghost_type]
			if tex:
				var tex_w = tex.get_width()
				var tex_h = tex.get_height()
				var dest_rect = Rect2(last_snapped_pos.x - (tex_w / 2.0), last_snapped_pos.y - (tex_h / 2.0), tex_w, tex_h)
				var ghost_color = Color(1.0, 1.0, 1.0, 0.75) if is_valid else Color(1.0, 0.4, 0.4, 0.6)
				draw_texture_rect(tex, dest_rect, false, ghost_color)
				
		# Status badge under tile
		var is_de = (GameManager.current_lang == "de")
		if moving_item_type != "":
			var tip = "HIER PLATZIEREN [R: ABBRECHEN]" if is_valid else "BLOCKIERT [R: ABBRECHEN]"
			if not is_de:
				tip = "PLACE HERE [R: CANCEL]" if is_valid else "BLOCKED [R: CANCEL]"
			var tip_color = Color(0.4, 1.0, 0.5) if is_valid else Color(1.0, 0.4, 0.4)
			draw_string(silkscreen_font, Vector2(last_snapped_pos.x - 70, last_snapped_pos.y + 26), tip, HORIZONTAL_ALIGNMENT_CENTER, 140, 9, tip_color)
		elif selected_item_type != "":
			var tip = "KLICK: PLATZIEREN" if is_valid else "PLATZ BLOCKIERT"
			if not is_de:
				tip = "CLICK: PLACE" if is_valid else "BLOCKED"
			var tip_color = Color(0.4, 1.0, 0.5) if is_valid else Color(1.0, 0.4, 0.4)
			draw_string(silkscreen_font, Vector2(last_snapped_pos.x - 55, last_snapped_pos.y + 26), tip, HORIZONTAL_ALIGNMENT_CENTER, 110, 9, tip_color)
		elif not hovered_existing_item.is_empty():
			var tip = "L: VERSCHIEBEN | R: EINPACKEN" if is_de else "L: MOVE | R: PACK"
			draw_string(silkscreen_font, Vector2(last_snapped_pos.x - 75, last_snapped_pos.y + 26), tip, HORIZONTAL_ALIGNMENT_CENTER, 150, 9, Color(1.0, 0.9, 0.3))
