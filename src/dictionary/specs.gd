static func player_list():
	var specs = list()
	var result = {}
	for key in specs:
		var spec = specs[key]
		if spec.has("for_player") && spec.for_player == true:
			result[key] = spec
			
	return result

static func get(key):
	var specs = list()
	if specs.has(key):
		return specs[key]
	else:
		return null
		
static func list():
	return globals.read_json("res://assets/data/specs.json")
	