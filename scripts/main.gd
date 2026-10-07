extends Node2D

const SLOTS_SCENE := preload("res://scenes/minigames/slots_game.tscn")
const CRASH_SCENE := preload("res://scenes/minigames/crash_game.tscn")
const ROULETTE_SCENE := preload("res://scenes/minigames/roulette_game.tscn")
const BLACKJACK_SCENE := preload("res://scenes/minigames/blackjack_game.tscn")
const GAME_OVER_SCENE := preload("res://scenes/ui/game_over.tscn")

@onready var ui_layer: CanvasLayer = $UILayer
@onready var hud: Control = $UILayer/HUD
@onready var player: CharacterBody2D = $CasinoWorld/Player

var current_minigame_node: Control = null
var game_over_node: Control = null

func _ready() -> void:
	add_to_group("main_coordinator")
	GameManager.game_over_triggered.connect(_on_game_over)
	
	# Load previous save (from CrazyGames Cloud Data or local)
	GameManager.load_game()
	
	if CrazyGamesSDK:
		CrazyGamesSDK.gameplay_start()

func open_minigame(machine_id: String) -> void:
	if current_minigame_node != null:
		return
		
	GameManager.active_minigame = machine_id
	player.can_move = false
	
	match machine_id:
		GameManager.MACHINE_SLOTS, "slot_rusty", "slot_modern":
			current_minigame_node = SLOTS_SCENE.instantiate()
		GameManager.MACHINE_CRASH:
			current_minigame_node = CRASH_SCENE.instantiate()
		GameManager.MACHINE_ROULETTE:
			current_minigame_node = ROULETTE_SCENE.instantiate()
		GameManager.MACHINE_BLACKJACK:
			current_minigame_node = BLACKJACK_SCENE.instantiate()
			
	if current_minigame_node:
		ui_layer.add_child(current_minigame_node)
		current_minigame_node.minigame_closed.connect(_on_minigame_closed)

func _on_minigame_closed() -> void:
	if current_minigame_node:
		current_minigame_node.queue_free()
		current_minigame_node = null
		
	GameManager.active_minigame = ""
	player.can_move = true
	GameManager.check_game_over_condition()

func _on_game_over(reason: String) -> void:
	if current_minigame_node:
		current_minigame_node.queue_free()
		current_minigame_node = null
		
	player.can_move = false
	if game_over_node == null:
		game_over_node = GAME_OVER_SCENE.instantiate()
		ui_layer.add_child(game_over_node)
		game_over_node.setup(reason)
		game_over_node.restart_pressed.connect(_on_restart_pressed)

func _on_restart_pressed() -> void:
	if game_over_node:
		game_over_node.queue_free()
		game_over_node = null
	GameManager.reset_game(GameManager.is_hardcore)
	player.can_move = true
	# Reload scene
	get_tree().reload_current_scene()
