extends Control

signal renovation_completed

@onready var title_lbl: Label = $Panel/VBoxContainer/TitleLabel
@onready var sub_lbl: Label = $Panel/VBoxContainer/SubLabel
@onready var progress_bar: ProgressBar = $Panel/VBoxContainer/ProgressBar
@onready var status_lbl: Label = $Panel/VBoxContainer/StatusLabel
@onready var bob_icon: TextureRect = $Panel/BobIcon

var target_area_name: String = ""
var is_de: bool = true

func _ready() -> void:
	is_de = (GameManager.current_lang == "de")
	title_lbl.text = "CASINO-AUSBAU IM GANGE" if is_de else "CASINO EXPANSION IN PROGRESS"
	sub_lbl.text = "Bob's Bautrupp versetzt die Wände..." if is_de else "Bob's crew is moving the walls..."
	status_lbl.text = "0%"
	progress_bar.value = 0.0
	
	if SoundManager:
		SoundManager.play_sfx("lever_pull")

func start_renovation(area_id: String) -> void:
	is_de = (GameManager.current_lang == "de")
	if area_id == "east_wing":
		target_area_name = "Ost-Flügel" if is_de else "East Wing"
	elif area_id == "vip_lounge":
		target_area_name = "VIP-Lounge" if is_de else "VIP Lounge"
	else:
		target_area_name = "Upgrade"
		
	title_lbl.text = ("BAUARBEITEN: %s" if is_de else "EXPANDING: %s") % target_area_name.to_upper()
	sub_lbl.text = ("Wände werden abgerissen & Raum verdoppelt..." if is_de else "Tearing down walls & expanding casino floor...")
	
	var tw = create_tween()
	tw.tween_property(progress_bar, "value", 100.0, 1.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	var pulse_tw = create_tween().set_loops(8)
	pulse_tw.tween_property(bob_icon, "scale", Vector2(1.1, 1.1), 0.1)
	pulse_tw.tween_property(bob_icon, "scale", Vector2(1.0, 1.0), 0.1)
	
	tw.finished.connect(_on_progress_finished)

func _process(_delta: float) -> void:
	status_lbl.text = "%d%%" % int(progress_bar.value)

func _on_progress_finished() -> void:
	status_lbl.text = "FERTIG!" if is_de else "COMPLETE!"
	status_lbl.modulate = Color(0.3, 1.0, 0.5)
	
	if SoundManager:
		SoundManager.play_sfx("jackpot")
		
	var fade_tw = create_tween()
	fade_tw.tween_interval(0.3)
	fade_tw.tween_property(self, "modulate:a", 0.0, 0.4)
	fade_tw.finished.connect(func():
		renovation_completed.emit()
		queue_free()
	)
