extends Control

signal build_mode_toggled(is_active: bool)
signal item_selected(item_id: String)

@onready var toolbar: HBoxContainer = $BottomPanel/HBoxContainer/ItemsScroll/ItemsList
@onready var close_btn: Button = $BottomPanel/HBoxContainer/DoneBtn
@onready var mode_label: Label = $TopBanner/Label

var is_building: bool = false
var selected_item_type: String = ""

const ITEM_INFO = {
	"slot_rusty": {"name_de": "Rostige Slots", "name_en": "Rusty Slots", "tex": "res://assets/sprites/props/slot_machine_rusty.png"},
	"slot_modern": {"name_de": "Moderne Slots", "name_en": "Modern Slots", "tex": "res://assets/sprites/raw_slots/Slot Machine/slot-machine1.png"},
	"crash": {"name_de": "Crash Terminal", "name_en": "Crash Terminal", "tex": "res://assets/sprites/environment/crash_cabinet.png"},
	"roulette": {"name_de": "Roulette-Tisch", "name_en": "Roulette Table", "tex": "res://assets/sprites/environment/roulette_table.png"},
	"blackjack": {"name_de": "Blackjack-Tisch", "name_en": "Blackjack Table", "tex": "res://assets/sprites/props/blackjack_table.png"},
	"bar_counter": {"name_de": "Getränkeautomat", "name_en": "Drink Vending Machine", "tex": "res://assets/sprites/furniture/bar_counter.png"},
	"bar_stool": {"name_de": "Barhocker", "name_en": "Bar Stool", "tex": "res://assets/sprites/furniture/bar_stool.png"},
	"table": {"name_de": "Casino-Tisch", "name_en": "Casino Table", "tex": "res://assets/sprites/environment/table.png"},
	"atm": {"name_de": "Geldautomat", "name_en": "ATM Machine", "tex": "res://assets/sprites/furniture/atm_machine.png"},
	"plant": {"name_de": "Casino-Palme", "name_en": "Palm Plant", "tex": "res://assets/sprites/furniture/potted_plant.png"},
	"trash_bin": {"name_de": "Mülleimer", "name_en": "Trash Bin", "tex": "res://assets/sprites/furniture/trash_bin.png"}
}

var silkscreen = preload("res://assets/fonts/Silkscreen-Regular.ttf")

func _ready() -> void:
	visible = false
	close_btn.pressed.connect(toggle_build_mode)

func toggle_build_mode() -> void:
	is_building = !is_building
	visible = is_building
	build_mode_toggled.emit(is_building)
	
	var is_de = (GameManager.current_lang == "de")
	close_btn.text = "FERTIG" if is_de else "DONE"
	
	if is_building:
		_refresh_toolbar()
		selected_item_type = ""
		item_selected.emit("")
		mode_label.text = "BAUMODUS: Wähle ein Möbelstück aus deinem Inventar zum Platzieren" if is_de else "BUILD MODE: Select a furniture piece from inventory to place"
		if SoundManager: SoundManager.play_sfx("lever_release")
	else:
		selected_item_type = ""
		item_selected.emit("")
		if SoundManager: SoundManager.play_sfx("lever_pull")

func _refresh_toolbar() -> void:
	for c in toolbar.get_children():
		c.queue_free()
		
	var is_de = (GameManager.current_lang == "de")
	var any_items = false
	for id in ITEM_INFO.keys():
		var count = GameManager.inventory.get(id, 0)
		if count > 0:
			any_items = true
			var btn = Button.new()
			btn.custom_minimum_size = Vector2(100, 60)
			btn.add_theme_font_override("font", silkscreen)
			btn.add_theme_font_size_override("font_size", 10)
			var item_name = ITEM_INFO[id]["name_de"] if is_de else ITEM_INFO[id]["name_en"]
			btn.text = "%s\n(x%d)" % [item_name, count]
			btn.pressed.connect(func(): _select_item(id))
			toolbar.add_child(btn)
			
	if selected_item_type != "" and GameManager.inventory.get(selected_item_type, 0) <= 0:
		selected_item_type = ""
		item_selected.emit("")
		mode_label.text = "Gegenstand platziert! Wähle das nächste Möbelstück." if is_de else "Item placed! Select your next furniture piece."

	if not any_items:
		selected_item_type = ""
		item_selected.emit("")
		var empty_lbl = Label.new()
		empty_lbl.text = "Inventar leer! Kaufe Möbel draußen bei Vinnie's Store." if is_de else "Inventory empty! Buy furniture outside at Vinnie's Store."
		empty_lbl.add_theme_font_override("font", silkscreen)
		empty_lbl.add_theme_font_size_override("font_size", 12)
		empty_lbl.add_theme_color_override("font_color", Color(1, 0.8, 0.3))
		toolbar.add_child(empty_lbl)

func _select_item(item_id: String) -> void:
	selected_item_type = item_id
	item_selected.emit(item_id)
	var is_de = (GameManager.current_lang == "de")
	var item_name = ITEM_INFO[item_id]["name_de"] if is_de else ITEM_INFO[item_id]["name_en"]
	mode_label.text = ("Klicke auf den Casinoboden im Raster, um '%s' zu platzieren!" if is_de else "Click on the floor grid to place '%s'!") % item_name
	if SoundManager: SoundManager.play_sfx("chip_bet")
