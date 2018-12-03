# character.gd
extends Object
# Imports.
const Description = preload("res://src/character/description.gd")
const Util        = preload("res://src/util.gd")
const Traits      = preload("res://src/dictionaries/traits.gd")
const Jobs        = preload("res://src/dictionaries/jobs.gd")
const Item        = preload("res://src/state/inventory/item.gd")

# Signals.
signal item_equipped(item, gear)
signal item_unequipped(item, gear)

# Base.
var id = null
var first_name = ""
var last_name = ""
var health = 100
var nickname = ""

# Origin.
var race = ""
var race_name = ""
var gender setget gender_set
var age = ""
var origin = "slave"
var portrait_path = ""

# Appearance.
var body_shape = "humanoid"
var arms = "normal"
var legs = "normal"
var ears = "human"
var tail = "none"
var wings = "none"
var horns = "none"
var eye_color = ""
var eye_sclera = ""
var eye_shape = ""
var fur_color = ""
var skin = ""
var skin_cover = ""
var beauty = 0

# Sexual.
var height = ""
var hair_length = ""
var hair_style = ""
var hair_color = ""
var butt_size = ""
var breast_size = ""
var has_penis = true
var penis_type = "human"
var penis_size = "normal"
var has_testicles = true
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
var sleep = null
var spec = null

var description = null

# Gear.
var gear = {
	"helmet": null,
	"chest": null,
	"gloves": null,
	"boots": null,
	"right_hand": null,
	"left_hand": null,
	"neck": null,
	"ring_1": null,
	"ring_2": null,
}

# Character's lists.
var _traits = []
var _effects = {}

# Constructor.
func _init(id = null, generate_random = false):
	if id == null:
		autoinc_id()
	
	if generate_random:
		random_gender()
		random_race()
		random_name()
		random_appearance()
		random_sexuals()
		random_trait()
		
	description = Description.new(self)	
		
# Autoincrement ID.
func autoinc_id():
	id = globals.state.get_autoinc("character")
	
# Setter for gender.
func gender_set(new_gender):
	gender = new_gender
	match new_gender:
		"male":
			has_penis = true
			has_testicles = true
			has_vagina = false
		"female":
			has_penis = false
			has_vagina = true
			has_testicles = false
		"futanari":
			has_penis = true
			has_vagina = true
			has_testicles = true
			
# Generate random name by race and gender.
func random_name():
	first_name = _get_random_name(race, gender)
	last_name  = _get_random_name(race, "surname") # TODO (frama): may be we should find a better way to fetch surnames.
	
# Get random name from names.json.
func _get_random_name(race, gender):
	var names = Util.read_json("res://assets/data/names.json")
	
	if not names.has(race):
		race = "human"
	if not names[race].has(gender):
		gender = "female"
	
	# Get random index.
	var index = randi() % names[race][gender].size()
	return names[race][gender][index]
	
func random_gender():
	var genders = ["male", "female", "futanari"]
	self.set("gender", genders[randi() % genders.size()])
	
func random_race():
	var races = Util.read_json("res://assets/data/races.json").keys()
	race = races[randi() % races.size()]
	
# Generate random apperance by race.
# see assets/data/race.json
func random_appearance():
	var races = Util.read_json("res://assets/data/races.json")
	if not races.has(race):
		return
	
	# Set class members by race.
	for key in races[race]:
		if not key in self:
			continue
		if key in ["description", "details", "bonus"]:
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
	var sexuals = Util.read_json("res://assets/data/sexual.json")
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
	var traits = Traits.get_any()
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
	var traits = Util.read_json("res://assets/data/traits.json")
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
	assert(typeof(key) == TYPE_STRING)
	if typeof(effect) != TYPE_DICTIONARY:
		return false
	
	var result = apply_effect(effect)
	if result == null:
		return false
		
	_effects[key] = result
	
	return true
			
func remove_effect(key):
	if not _effects.has(key):
		return
		
	var effect = _effects[key]
	for property in effect:
		var value = get_indexed(property)
		set_indexed(property, value - effect[property])
	
	_effects.erase(key)
	
# Returns difference between new value and old value.
func apply_effect(effect):
	if typeof(effect) != TYPE_DICTIONARY:
		return null
		
	var result = {}
	for property in effect:
		var value = get_indexed(property)
			
		if typeof(value) == TYPE_NIL || typeof(effect[property]) != TYPE_ARRAY:
			continue
		
		var operator = effect[property][0]
		var delta = effect[property][1]
		var new_value = value
		# Match operator.
		match operator:
			"+": 
				new_value = value + delta
			"-": 
				new_value = value - delta
			"*": 
				new_value = value * delta
			"/": 
				new_value = value / delta
		# Store delta.
		set_indexed(property, new_value)
		result[property] = new_value - value
		# @Debug
		print("%s = %s" % [property, new_value])
		
	print("\n")
	
	return result

# TODO (frama): Add more labels.
func process_labels(text):
	var result = text
	
	var properties = inst2dict(self).keys()
	var pronouns = {
		"he":  [tr("PRONOUN_HE"),  tr("PRONOUN_SHE")],
		"his": [tr("PRONOUN_HIS"), tr("PRONOUN_HER")],
		"him": [tr("PRONOUN_HIM"), tr("PRONOUN_HER")],
	}
	
	# Custom.
	result = result.replace("$fullname", get_fullname())
	
	# Replace properties.
	for property in properties:
		if not property.begins_with('@') && not property.begins_with('_'):
			var value = self.get(property)
			if typeof(value) in [TYPE_STRING, TYPE_INT, TYPE_REAL]:
				result = result.replace("$%s" % property, value)
	
	# Replace pronouns.
	for pronoun in pronouns:
		var index = 0 if gender == "male" else 1
		result = result.replace("$%s" % pronoun.capitalize(), pronouns[pronoun][index].capitalize())
		result = result.replace("$%s" % pronoun, pronouns[pronoun][index])
		
	return result

func check_requirements(rules):
	if typeof(rules) != TYPE_DICTIONARY:
		return rules

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
	if nickname.empty():
		return "%s %s" % [first_name, last_name]
	else:
		return "%s \"%s\" %s" % [first_name, nickname, last_name]

# Invoke character's job conditions.
func invoke_conditions():
	var jobs = Jobs.list()
	if not jobs.has(job):
		return
		
	var j = jobs[job]
	if not j.has("conditions"):
		return
		
	# Run all conditions.
	for method in j["conditions"]:
		if not Jobs.has_method(method):
			continue
		
		var f = funcref(Jobs, method)
		var fd = {
			method: f
		}
		fd[method].call_func(j["conditions"][method])
	
func equip_item(item, gear = null):
	assert(item is Item)
	
	# Check if item can be equipped.
	if not item.is_equippable():
		return false
		
	# Get gear if it's not set.
	if gear == null:
		gear = item.get_gear()
		if gear == null:
			return false
			
		if typeof(gear) == TYPE_ARRAY:
			var gear_list = gear
			for g in gear_list:
				if not is_item_equipped(g):
					gear = g
					break
		
	if is_item_equipped(gear):
		unequip_item(gear)
		
	self.gear[gear] = item
	# Apply item effect.
	if typeof(item.effect) == TYPE_DICTIONARY && not item.effect.empty():
		add_effect("item_%d" % item.id, item.effect)
		
	globals.state.inventory.remove_item(item.id)
	emit_signal("item_equipped", item, gear)
	
	return true

func unequip_item(gear):
	assert(self.gear.has(gear))
	
	var item = self.gear[gear]
	# Clear gear state.
	self.gear[gear] = null
	globals.state.inventory.back_item(item)
	remove_effect("item_%d" % item.id)
	
	emit_signal("item_unequipped", item, gear)

func is_item_equipped(gear):
	return self.gear[gear] != null
	