# races.gd
# Imports.
const Util = preload("res://src/util.gd")

static func list():
	return Util.read_json("res://assets/data/races.json")

# Get list of properties by given race and property.
static func list_by_race(race, properties = []):
	var races = Util.read_json("res://assets/data/races.json")
	
	var list = {}
	if properties.empty():
		properties = races.keys()

	for property in properties:
		var key = ""
		# First check given race, second human.
		if races[race].has(property):
			key = race
		elif races["human"].has(property):
			key = "human"
		else:
			continue

		if typeof(races[key][property]) == TYPE_ARRAY:
			list[property] = races[key][property]
		else:
			list[property] = [races[key][property]]
	
	return list
	