extends Node

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
var body_shape = 'humanoid'
var arms = 'normal'
var legs = 'normal'
var ears = 'human'
var tail = 'none'
var wings = 'none'
var horns = 'none'
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
var penis_type = 'human'
var penis_size = 'normal'
var testicle_size = 'normal'
var has_vagina = false

# Virgin.
var penis_virgin = true
var vaginal_virgin = true
var butt_virgin = true
var mouth_virgin = true

var preg = { "fertility": 0, "has_womb": false, "duration": 0, "baby": null }

# Stats.
var stats = {
	# Max, Base, Delta.
	"strength": { "m": 0, "b": 0, "d": 0 },
	"agility": { "m": 0, "b": 0, "d": 0 },
	"magic": { "m": 0, "b": 0, "d": 0 },
	"endurance": { "m": 0, "b": 0, "d": 0 },
}

# Constructor.
func _init(r = null, a = null, g = null, o = 'slave', generate_random = false):
	race = r
	age = a
	gender = g
	origin = o
	if generate_random:
		random_name()
		random_appearance()
		random_sexuals()
	
# Setter for gender.
func gender_set(new_gender):
	gender = new_gender
	match new_gender:
		'male':
			has_penis = true
			has_vagina = false
		'female':
			has_penis = false
			has_vagina = true
		'futanari':
			has_penis = true
			has_vagina = true
			
# Generate random name by race and gender.
func random_name():
	randomize()
	first_name = _get_random_name(race, gender)
	last_name = _get_random_name(race, "surname") # TODO (frama): may be we should find a better way to fetch surnames.
	
# Generate random apperance by race.
# see assets/data/race.json
func random_appearance():
	randomize()
	var races = global.read_json("res://assets/data/races.json")
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
			# TODO (frama): Implement dictionary type.
			TYPE_DICTIONARY:
				pass
			_: # Default.
				self.set(key, races[race][key])

# Generate random sexual features by gender.
# see assets/data/sexual.json
func random_sexuals():
	randomize()
	var sexuals = global.read_json("res://assets/data/sexual.json")
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
		if age == 'child' && probability < 0.1:
			vaginal_virgin = false
		elif age == 'teen' && probability < 0.3:
			vaginal_virgin = false
		elif age == 'adult' && probability < 0.65:
			vaginal_virgin = false

# Get random name from names.json.
func _get_random_name(race, gender):
	# Read all available names.
	var names = global.read_json("res://assets/data/names.json")
	
	if not names.has(race):
		race = "human"
	if not names[race].has(gender):
		gender = "female"
	
	# Get random index.
	var index = randi() % names[race][gender].size()
	return names[race][gender][index]

# Get list of properties by given property.
func appearance_list(property):
	var races = global.read_json("res://assets/data/races.json")
	
	var key
	if races[race].has(property):
		key = race
	elif races["human"].has(property):
		key = "human"
	else:
		return []
		
	if typeof(races[key][property]) == TYPE_ARRAY:
		return races[key][property]
	else:
		return [races[key][property]]
		

# Get list of properties by given attribute.
func sexual_list(property):
	var sexual = global.read_json("res://assets/data/sexual.json")
	
	var key
	if sexual[property].has(gender):
		key = gender
	elif sexual[property].has("*"):
		key = "*"
	else:
		return []
	
	# Try to match.
	if sexual[property][key].has(age):
		return sexual[property][key][age]
	elif sexual[property][key].has("*"):
		return sexual[property][key]["*"]
	
	return []
	