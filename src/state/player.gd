extends "res://src/character/character.gd"

# Stats.
const STAT_MIN = 2
const STAT_MAX = 7

# Bonus points.
var bonus_points = 2

var _slaves = {}

# Initialization.
func _init().(0):
	gender = "male"
	age = "adult"
	origin = "poor"
	stats.strength.max = 4
	stats.agility.max = 4
	stats.magic.max = 4
	stats.endurance.max = 4
