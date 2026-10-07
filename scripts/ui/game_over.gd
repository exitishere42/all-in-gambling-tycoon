extends Control

signal restart_pressed

@onready var reason_label: Label = $Panel/ReasonLabel
@onready var bottles_stat_lbl: Label = $Panel/Stats/BottlesRow/BottlesVal
@onready var winnings_stat_lbl: Label = $Panel/Stats/WinningsRow/WinningsVal
@onready var restart_button: Button = $Panel/ButtonBox/RestartButton
@onready var menu_button: Button = $Panel/ButtonBox/MenuButton

func _ready() -> void:
	restart_button.pressed.connect(_on_restart_pressed)
	menu_button.pressed.connect(_on_menu_pressed)

func setup(reason: String) -> void:
	reason_label.text = reason
	bottles_stat_lbl.text = str(GameManager.total_bottles_collected)
	winnings_stat_lbl.text = GameManager.format_cash(GameManager.total_winnings_cents)

func _on_restart_pressed() -> void:
	restart_pressed.emit()

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
