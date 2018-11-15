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
const CONFIG_PATH = "user://settings.cfg"

# Config file.
var _config_file = ConfigFile.new()

# All the data to save is stored in a dictionary with default values.
var _settings = {
	"window": {
		"width": 1280,
		"height": 720,
		"pos_x": 300,
		"pos_y": 0,
		"fullscreen": false,
	},
	"settings": {
		"use_animation": true,
		"show_sprites": false,
		"skip_combat": false,
		"random_portraits": false,
		"font_size": 20.0,
		"music_volume": 0,
		"sound_volume": 0,
	},
	"game": {
		"futa": false,
		"futa_testicles": false,
		"furry": false,
		"furry_nipples": false,
		"allow_races": false,
		"receiving_sex": false,
		"permadeath": true,
		"childlike_characters": false,
		"futa_occurrence": 0.0,
		"gender_occurrence": 0.0,
		"alise_on_day": 0,
		"adult_characters": false,
	}
}

# Initialization.
func _ready():
	if load_config() == LOAD_ERROR_COULDNT_OPEN:
		save_config()
		
	setup_settings()

# Save settings to *.cfg file.
func save_config():
	for section in _settings.keys():
		for key in _settings[section].keys():
			_config_file.set_value(section, key, _settings[section][key])
			
	_config_file.save(CONFIG_PATH)

# Load settings from *.cfg file.
func load_config():
	var err = _config_file.load(CONFIG_PATH)
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
	# Window.
	set_window_size(
		Vector2(_settings["window"]["width"], _settings["window"]["height"]), 
		Vector2(_settings["window"]["pos_x"], _settings["window"]["pos_y"])
	)
	OS.set_window_fullscreen(_settings["window"]["fullscreen"])
	# Sound.
	set_bus_volume("Music", _settings["settings"]["music_volume"])

# Public method for getter.
func get_setting(category, key):
	return _settings[category][key]

# Public method for setter.
func set_setting(category, key, val):
	# Check if category exist in dictionary.
	if !_settings.has(category):
		_settings[category] = {}
	
	_settings[category][key] = val
	
# Set Music bus to proper db volume by linear interpolation.
func set_bus_volume(bus_name, value):
	# Linear interpolation.
	var db = AUDIO_DB_RANGE.linear_interpolate(Vector2(0, 100), value)
	var bus_index = AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_volume_db(bus_index, db.x)
	AudioServer.set_bus_mute(bus_index, value <= 0)

# Set window size by given Vector2 object.
func set_window_size(size, position = null):
	OS.window_size = size
	if position != null:
		OS.window_position = position
