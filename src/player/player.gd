extends "res://src/character/character.gd"

# Stats.
const STAT_MIN = 2
const STAT_MAX = 7

# Bonus points.
var bonus_points = 2

# Initialization.
func _init():
	id = 0
	gender = "male"
	age = "teen"
	origin = "poor"
	stats.strength.max = 4
	stats.agility.max = 4
	stats.magic.max = 4
	stats.endurance.max = 4
