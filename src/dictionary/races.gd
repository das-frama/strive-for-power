# Get list of properties by given race and property.
static func list(race, properties = []):
	var races = global.read_json("res://assets/data/races.json")
	
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
	