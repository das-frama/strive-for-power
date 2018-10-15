# This script is registered as an AutoLoad singleton in the Project settings. 
# It will load before every over node in the scene.
extends Node

# Constants, codes to check and see if loading was successful or not.
enum { 
	LOAD_SUCCESS, 
	LOAD_ERROR_COULDNT_OPEN
}
# Working range for audio bus.
const AUDIO_DB_RANGE = Vector2(-60, 0)
# Save path to config file.
const SAVE_PATH = "res://config.cfg"

# Config file.
var _config_file = ConfigFile.new()
# All the data to save is stored in a dictionary.
var _settings = {
	"settings": {
		"fullscreen": false,
		"use_animation": true,
		"show_sprites": false,
		"skip_combat": false,
		"random_portraits": false,
		"font_size": 22.0,
		"music_volume": 60,
		"sound_volume": 60
	}
}

# Initialization.
func _ready():
	# If loading has an error (file does not exist)...
	if load_config() == LOAD_ERROR_COULDNT_OPEN:
		# Then save default settings and save it.
		save_config()
	setup_settings()

# Save settings to *.cfg file.
func save_config():
	for section in _settings.keys():
		for key in _settings[section].keys():
			_config_file.set_value(section, key, _settings[section][key])
			
	_config_file.save(SAVE_PATH)

# Load settings from *.cfg file.
func load_config():
	var err = _config_file.load(SAVE_PATH)
	# Error handler.
	if err != OK:
		print("Error loading the settings. Error code: %s" % err)
		return LOAD_ERROR_COULDNT_OPEN

	# Load settings from file to dictionary.
	for section in _settings.keys():
		for key in _settings[section].keys():
			var val = _config_file.get_value(section, key)
			_settings[section][key] = val
			# TODO (frama): Add debug output.

	return LOAD_SUCCESS

# Set up system settings.
func setup_settings():
	# Fullscreen check.
	OS.set_window_fullscreen(_settings["settings"]["fullscreen"])
	# Set music bus volume.
	set_bus_volume("Music", _settings["settings"]["music_volume"])

# Public method for getter.
func get_setting(category, key):
	return _settings[category][key]

# Public method for setter.
func set_setting(category, key, val):
	_settings[category][key] = val
	
# Set Music bus to proper db volume by linear interpolation.
func set_bus_volume(bus_name, value):
	# Linear interpolation.
	var db = AUDIO_DB_RANGE.linear_interpolate(Vector2(0, 100), value)
	var bus_index = AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_volume_db(bus_index, db.x)
	AudioServer.set_bus_mute(bus_index, value <= 0)

