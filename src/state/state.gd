# state.gd represents current state of the game.
# It includes player' inventory, slaves, progress, etc.

# Imports.
const Player    = preload("res://src/state/player.gd")
const Character = preload("res://src/character/character.gd")
const Progress  = preload("res://src/state/progress.gd")
const Inventory = preload("res://src/state/inventory/inventory.gd")

# Player object.
var player = null

# Progress object.
var progress = null

# Array of slaves.
var slaves = {}

# Inventory Manager object to manage player items.
var inventory = null

# Stored autoincrement values.
var _autoincs = {}

# Game version for backward compatibility in the nearest future.
var _game_version = globals.VERSION

# Custom user state preferences.
var settings = {
	# Fold/unfold.
	"description": {
		"full": true,
		"basic": true,
		"appearance": true,
		"genitals": true,
		"piercing": true,
		"tattoo": true,
		"mods": true,
	},
}

# Constructor.
func _init():
	player = Player.new()
	progress = Progress.new()
	inventory = Inventory.new()

# Get serialized data.
func serialize():
	pass
	
func get_autoinc(type = "global"):
	if _autoincs.has(type):
		_autoincs[type] += 1
	else:
		_autoincs[type] = 1
		
	return _autoincs[type]
	
func add_slave(_character):
	assert(_character is Character)
	
	if slaves.has(_character.id):
		return
		
	slaves[_character.id] = _character
	
func get_slave_by_id(id):
	if slaves.has(id):
		return slaves[id]
	else:
		return null