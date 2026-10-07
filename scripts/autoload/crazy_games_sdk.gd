extends Node

# CrazyGames HTML5 SDK v3 JavaScript Bridge for Godot 4
# Handles: SDK Initialization, Ads, Gameplay Lifecycle, and Cloud Data Saving

signal ad_finished
@warning_ignore("unused_signal")
signal ad_error
signal cloud_data_loaded(key: String, value: String)

var is_web: bool = false
var is_initialized: bool = false
var _mute_callback_ref: JavaScriptObject = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	is_web = OS.has_feature("web")
	if is_web:
		_init_crazygames_sdk()

func _init_crazygames_sdk() -> void:
	# Initialize SDK v3 and register window callbacks
	JavaScriptBridge.eval("""
		window.__initCrazyGames = async function() {
			try {
				if (window.CrazyGames && window.CrazyGames.SDK) {
					await window.CrazyGames.SDK.init();
					console.log('[CrazyGames] SDK v3 initialized successfully');
					
					// Initial audio mute check from SDK settings
					if (window.CrazyGames.SDK.game && window.CrazyGames.SDK.game.settings) {
						if (window.__godotSetMute && typeof window.CrazyGames.SDK.game.settings.muteAudio === 'boolean') {
							window.__godotSetMute(window.CrazyGames.SDK.game.settings.muteAudio);
						}
					}
					
					// Listen for audio mute/unmute changes triggered by CrazyGames portal
					if (window.CrazyGames.SDK.game && window.CrazyGames.SDK.game.addSettingsChangeListener) {
						window.CrazyGames.SDK.game.addSettingsChangeListener(function(newSettings) {
							if (window.__godotSetMute && newSettings && typeof newSettings.muteAudio === 'boolean') {
								console.log('[CrazyGames] Audio mute change event:', newSettings.muteAudio);
								window.__godotSetMute(newSettings.muteAudio);
							}
						});
					}
				}
			} catch(e) {
				console.error('[CrazyGames] Init error', e);
			}
		};
	""", true)
	
	# Create JavaScript callback bridge for audio muting
	_mute_callback_ref = JavaScriptBridge.create_callback(_on_sdk_mute_changed)
	var window = JavaScriptBridge.get_interface("window")
	if window:
		window.__godotSetMute = _mute_callback_ref

	JavaScriptBridge.eval("""
		if (window.CrazyGames) {
			window.__initCrazyGames();
		}
	""", true)
	is_initialized = true

func _on_sdk_mute_changed(args: Array) -> void:
	if args.size() > 0:
		var should_mute: bool = bool(args[0])
		set_master_mute(should_mute)

func set_master_mute(should_mute: bool) -> void:
	var master_bus_idx := AudioServer.get_bus_index("Master")
	if master_bus_idx >= 0:
		AudioServer.set_bus_mute(master_bus_idx, should_mute)
		print("[CrazyGames SDK] Master audio mute set to: ", should_mute)

# ==================== CLOUD SAVE / DATA MODULE ====================

func save_data(key: String, value_json: String) -> void:
	if not is_web:
		return
	var escaped_val = value_json.replace("\\", "\\\\").replace("`", "\\`").replace("$", "\\$")
	var js_code := """
		try {
			if (window.CrazyGames && window.CrazyGames.SDK && window.CrazyGames.SDK.data) {
				window.CrazyGames.SDK.data.setItem('%s', `%s`);
				console.log('[CrazyGames] Data saved to Cloud Data module: %s');
			} else {
				localStorage.setItem('%s', `%s`);
			}
		} catch(e) {
			console.error('[CrazyGames] Save error', e);
		}
	""" % [key, escaped_val, key, key, escaped_val]
	JavaScriptBridge.eval(js_code, true)

func load_data(key: String) -> String:
	if not is_web:
		return ""
	var js_code := """
		(function() {
			try {
				if (window.CrazyGames && window.CrazyGames.SDK && window.CrazyGames.SDK.data) {
					return window.CrazyGames.SDK.data.getItem('%s') || '';
				}
				return localStorage.getItem('%s') || '';
			} catch(e) {
				return '';
			}
		})()
	""" % [key, key]
	var res = JavaScriptBridge.eval(js_code, true)
	return str(res) if res != null else ""

# ==================== GAMEPLAY LIFECYCLE ====================

func gameplay_start() -> void:
	if is_web:
		JavaScriptBridge.eval("""
			if (window.CrazyGames && window.CrazyGames.SDK && window.CrazyGames.SDK.game) {
				window.CrazyGames.SDK.game.gameplayStart();
			}
		""", true)

func gameplay_stop() -> void:
	if is_web:
		JavaScriptBridge.eval("""
			if (window.CrazyGames && window.CrazyGames.SDK && window.CrazyGames.SDK.game) {
				window.CrazyGames.SDK.game.gameplayStop();
			}
		""", true)

func happy_time() -> void:
	if is_web:
		JavaScriptBridge.eval("""
			if (window.CrazyGames && window.CrazyGames.SDK && window.CrazyGames.SDK.game) {
				window.CrazyGames.SDK.game.happytime();
			}
		""", true)

# ==================== ADS (DISABLED FOR PURELY FREE GAMEPLAY) ====================

var ads_enabled: bool = false

func request_midroll_ad() -> void:
	# Ads completely disabled - pure uninterrupted gameplay
	ad_finished.emit()
