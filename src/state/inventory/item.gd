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

func _init(code, item = {}):
	self.code = code
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
	var gear = null
	
	match self.type:
		["gear", _, var g]:
			gear = g

	return gear
	
# Use item.
func use(character):
	if not character.check_requirements(self.requires):
		return false
		
	if is_equippable():
		character.equip_item(self)
	else:
		character.apply_effect(self.effect)
		self.amount -= 1
		emit_signal("item_used")
		
	return true
