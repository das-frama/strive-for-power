# item.gd
extends Object

# Imports.
const Character = preload("res://src/character/character.gd")

# Signals.
signal item_used
signal item_equipped

var id = 0
var code = ""
var name = ""
var icon setget load_icon
var description = ""
var effect = ""
var recipe = ""
var cost = 0
var type = []
var amount = 1
var weight = 0
var stackable = true
var requires = true

var icon_texture = null
var sort = 1

func _init(item = {}):
	for property in item:
		if not property in self:
			continue
		self.set(property, item[property])
		
	if amount == 0:
		amount = 1
		
	generate_id()
	
func generate_id():
#	var item = {
#		code: code,
#		name: name,
#		weight: weight,
#	}
#	id = item.hash()
	id = globals.state.get_autoinc("item")
	
func load_icon(path):
	icon = path
	icon_texture = load(path)

# Check if item can be equipped.
func is_equippable():
	match self.type:
		["gear", ..]:
			return true
			
	return false
	
func has_gear(gear):
	match self.type:
		["gear", _, var gears]:
			if typeof(gears) == TYPE_ARRAY:
				return gears.has(gear)
			else:
				return gears == gear
					
	return false
	
func get_gear():
	match self.type:
		["gear", _, var gear]:
			return gear
					
	return null
	
# Use item.
func use(character):
	if not character.check_requirements(self.requires):
		return false
		
	if is_equippable():
		var gear = get_gear()
		if gear == null:
			return false
			
		var gear_item = gear
		if typeof(gear) == TYPE_ARRAY:
			gear_item = gear[0]
			for g in gear:
				if not character.is_item_equipped(g):
					gear_item = g
					break
		
		if character.equip_item(self, gear_item):
			apply_effect(character)
	
	else:
		apply_effect(character)
		self.amount -= 1
		emit_signal("item_used")
		
	return true

func apply_effect(character):
	if typeof(self.effect) != TYPE_DICTIONARY:
		return false
		
	for property in self.effect:
		var value = character.get_indexed(property)
			
		if typeof(value) == TYPE_NIL || typeof(self.effect[property]) != TYPE_ARRAY:
			continue
		
		var effect = self.effect[property]
		# Match operator.
		match effect[0]:
			"+": 
				character.set_indexed(property, value + effect[1])
			"-": 
				character.set_indexed(property, value - effect[1])

	return true
