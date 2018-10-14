# This script is registered as an AutoLoad singleton in the Project settings. 
# It will load before every over node in the scene
extends Node

const VERSION = '0.5.19d'

# Working range for audio bus.
const AUDIO_DB_RANGE = Vector2(-60, 0)

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

# Set Music bus to proper db volume by linear interpolation.
func set_music_volume(value):
	# Linear interpolation.
	var db = AUDIO_DB_RANGE.linear_interpolate(Vector2(0, 100), value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), db.x)
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), value <= 0)
