extends Node

# SoundManager with high-quality real audio files
var sfx_players: Array[AudioStreamPlayer] = []
const POOL_SIZE := 8

var audio_streams := {
	"lever_pull": preload("res://assets/audio/sfx/lever_pull.wav"),
	"lever_release": preload("res://assets/audio/sfx/lever_release.wav"),
	"spin": preload("res://assets/audio/sfx/reel_tick.wav"),
	"coin_win": preload("res://assets/audio/sfx/coin_win.wav"),
	"jackpot": preload("res://assets/audio/sfx/jackpot.wav"),
	"button_click": preload("res://assets/audio/sfx/button_click.wav"),
	"bottle_pickup": preload("res://assets/audio/sfx/bottle_clink.mp3")
}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i in range(POOL_SIZE):
		var player := AudioStreamPlayer.new()
		player.bus = "Master"
		add_child(player)
		sfx_players.append(player)

func play_sfx(sfx_name: String) -> void:
	var stream = audio_streams.get(sfx_name, null)
	if stream == null:
		# Fallback to button_click if unknown
		stream = audio_streams.get("button_click", null)
	if stream == null:
		return
		
	for player in sfx_players:
		if not player.playing:
			player.stream = stream
			player.volume_db = -3.0
			player.play()
			return
			
	# Fallback to pool[0]
	sfx_players[0].stream = stream
	sfx_players[0].volume_db = -3.0
	sfx_players[0].play()
