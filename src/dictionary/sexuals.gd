# Get list of properties by gender and age.
static func list(gender, age, properties = []):
	var sexuals = globals.read_json("res://assets/data/sexual.json")
	
	var list = {}
	if properties.empty():
		properties = sexuals.keys()
		
	for property in properties:
		var key = ""
		if sexuals[property].has(gender):
			key = gender
		elif sexuals[property].has("*"):
			key = "*"
		else:
			continue
		
		# Try to match.
		if sexuals[property][key].has(age):
			list[property] = sexuals[property][key][age]
		elif sexuals[property][key].has("*"):
			list[property] = sexuals[property][key]["*"]
	
	return list
