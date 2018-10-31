extends Node

# Imports.
var Inventory = preload("res://src/inventory/inventory.gd")

# Base.
var id
var first_name
var last_name
var health = 100
var nickname

# Origin.
var race
var race_name
var gender setget gender_set
var age
var origin
var portrait_path

# Appearance.
var body_shape = "humanoid"
var arms = "normal"
var legs = "normal"
var ears = "human"
var tail = "none"
var wings = "none"
var horns = "none"
var eye_color
var eye_sclera
var fur_color
var skin

# Sexual.
var height
var hair_length
var hair_style
var hair_color
var butt_size
var breast_size
var has_penis = true
var penis_type = "human"
var penis_size = "normal"
var testicle_size = "normal"
var has_vagina = false

# Virgin.
var penis_virgin = true
var vaginal_virgin = true
var butt_virgin = true
var mouth_virgin = true
var preg = { "fertility": 0, "has_womb": false, "duration": 0, "baby": null }

# Stats.
var stats = {
	"strength": { "max": 0, "base": 0, "mod": 0 },
	"agility": { "max": 0, "base": 0, "mod": 0 },
	"magic": { "max": 0, "base": 0, "mod": 0 },
	"endurance": { "max": 0, "base": 0, "mod": 0 },
	"charm": { "max": 0, "base": 0 },
	"cour": { "max": 0, "base": 0 },
	"wit": { "max": 0, "base": 0 },
	"conf": { "max": 0, "base": 0 },
	"obed": { "current": 0, "max": 0, "min": 0, "mod": 0 },
	"loyalty": { "current": 0, "max": 0, "min": 0, "mod": 1 },
	"stress": { "current": 0, "max": 0, "min": 0, "mod": 1 },
	"toxic": { "current": 0, "max": 0, "min": 0, "mod": 1 },
	"lust": { "current": 0, "max": 0, "min": 0, "mod": 1 },
}

# Activities.
var job = "rest"
var spec

var inventory

# Character's lists.
var _traits = []
var _effects = {}

# Constructor.
func _init(r = null, a = null, g = null, o = "slave", generate_random = false):
	race = r
	age = a
	gender = g
	origin = o
	inventory = Inventory.new()
	
	if generate_random:
		random_name()
		random_appearance()
		random_sexuals()
		random_trait()
	
# Setter for gender.
func gender_set(new_gender):
	gender = new_gender
	match new_gender:
		"male":
			has_penis = true
			has_vagina = false
		"female":
			has_penis = false
			has_vagina = true
		"futanari":
			has_penis = true
			has_vagina = true
			
# Generate random name by race and gender.
func random_name():
	first_name = _get_random_name(race, gender)
	last_name = _get_random_name(race, "surname") # TODO (frama): may be we should find a better way to fetch surnames.
	
# Get random name from names.json.
func _get_random_name(race, gender):
	# Read all available names.
	var names = globals.read_json("res://assets/data/names.json")
	
	if not names.has(race):
		race = "human"
	if not names[race].has(gender):
		gender = "female"
	
	# Get random index.
	var index = randi() % names[race][gender].size()
	return names[race][gender][index]
	
# Generate random apperance by race.
# see assets/data/race.json
func random_appearance():
	var races = globals.read_json("res://assets/data/races.json")
	if not races.has(race):
		return
	
	# Set class members by race.
	for key in races[race]:
		if not key in self:
			continue
		# If type is array.
		match typeof(races[race][key]):
			TYPE_ARRAY:
				var index = randi() % races[race][key].size()
				self.set(key, races[race][key][index])
			TYPE_DICTIONARY: # TODO (frama): Implement dictionary type.
				pass
			_: # Default.
				self.set(key, races[race][key])

# Generate random sexual features by gender.
# see assets/data/sexual.json
func random_sexuals():
	var sexuals = globals.read_json("res://assets/data/sexual.json")
	for key in sexuals:
		if not key in self:
			continue

		var matcher
		if sexuals[key].has(gender):
			matcher = gender
		elif sexuals[key].has("*"):
			matcher = "*"
		else:
			continue
		
		# Try to match.
		if sexuals[key][matcher].has(age):
			var index = randi() % sexuals[key][matcher][age].size()
			self.set(key, sexuals[key][matcher][age][index])
		elif sexuals[key][matcher].has("*"):
			var index = randi() % sexuals[key][matcher]["*"].size()
			self.set(key, sexuals[key][matcher]["*"][index])
			
	# If character has a vagina, we set random virginity.
	if has_vagina:
		var probability = randf()
		if age == "child" && probability < 0.1:
			vaginal_virgin = false
		elif age == "teen" && probability < 0.3:
			vaginal_virgin = false
		elif age == "adult" && probability < 0.65:
			vaginal_virgin = false

# Generate random trait
func random_trait():
	var traits = globals.traits.get_any()
	var index = randi() % traits.size()
	add_trait(traits[index])

## Traits.
func traits():
	return _traits

func get_trait(key):
	if _traits.has(key):
		return _traits[key]
	else:
		return null

func add_trait(key):
	var traits = globals.read_json("res://assets/data/traits.json")
	if not traits.has(key):
		return false
		
	var trait = traits[key]
	# Check for conflict.
	for t in trait.conflict:
		if _traits.has(t):
			return false 
	
	_traits.append(key)
	# Apply effect.
	if not trait.effect.empty():
		for effect_key in trait.effect:
			add_effect(effect_key, trait.effect[key])
	
	return true

func remove_trait(key):
	if _traits.has(key):
		_traits.erase(key)
		
## Effects.
func effects():
	return _effects
	
func has_effect(key):
	return _effects.has(key)
	
func add_effect(key, effect = {}):
	assert(typeof(effect) == TYPE_DICTIONARY)
	
	_effects[key] = effect
	# Set class properties from affects.
	for property in effect:
		if not property in stats || typeof(effect[property]) != TYPE_DICTIONARY:
			continue
		for subproperty in effect[property]:
			if not subproperty in stats[property]:
				continue
			stats[property][subproperty] += effect[property][subproperty]
			
func remove_effect(key):
	if not _effects.has(key):
		return
		
	var effect = _effects[key]
	for property in effect:
		if not property in stats || typeof(effect[property]) != TYPE_DICTIONARY:
			continue
		for subproperty in effect[property]:
			if not subproperty in stats[property]:
				continue
			stats[property][subproperty] -= effect[property][subproperty]

func process_labels(text):
	var result = text
	result = result.replace("{first_name}", first_name)
	result = result.replace("{fullname}", get_fullname())
	result = result.replace("{He}", "He" if gender == "male" else "She")
	result = result.replace("{he}", "he" if gender == "male" else "she")
	result = result.replace("{His}", "His" if gender == "male" else "Her")
	result = result.replace("{his}", "his" if gender == "male" else "her")
	result = result.replace("{Him}", "Him" if gender == "male" else "Her")
	result = result.replace("{him}", "him" if gender == "male" else "her")
	# TODO (frama): Add more labels.
	return result

func check_requirements(rules):
	assert(typeof(rules) == TYPE_DICTIONARY)

	# Rules.
	for property in rules:
		var value
		if property.find(":") != -1:
			value = self.get_indexed(property)
		else:
			value = self.get(property)
		
		if typeof(value) == TYPE_NIL:
			return false
		
		var rule = rules[property]
		if typeof(rule) == TYPE_ARRAY:
			var operator = rule[0]
			var r = []
			for i in range(1, rule.size()):
				r.append(rule[i])
			match operator:
				"=":
					return value == r[0]
				">=":
					return value >= r[0]
				"<=":
					return value <= r[0]
				">":
					return value > r[0]
				"<":
					return value < r[0]
				"in":
					return value in r
				"not in":
					return not value in r
				_:
					return false
		else:
			return value == rule
			
	return false

func get_fullname():
	return first_name + " " + last_name
