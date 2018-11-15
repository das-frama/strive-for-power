# Helper static function for read json into dictionary.
static func read_json(path):
	# Check for cache.
	if not globals.json.has(path):
		var file = File.new()
		file.open(path, file.READ)
		globals.json[path] = parse_json(file.get_as_text())
		file.close()
		
	return globals.json[path]
	
# Read and returns files in dir.
static func read_dir(path, full_path = true):
	var files = []
	var dir = Directory.new()
	dir.open(path)
	if dir.list_dir_begin() != OK:
		print("Cannot read path: %s" % path)
		return []
		
	while 1:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with(".") and not file.ends_with(".import"):
			if full_path:
				files.append(path + "/" + file)
			else:
				files.append(file)
	dir.list_dir_end()
	
	return files

# Merge two dicts.
static func merge_dict(dest, source):
	for key in source:
		if dest.has(key):
			var dest_value = dest[key]
			var source_value = source[key]
			if typeof(dest_value) == TYPE_DICTIONARY:       
				if typeof(source_value) == TYPE_DICTIONARY: 
					merge_dict(dest_value, source_value)  
				else:
					dest[key] = source_value
			else:
				dest[key] = source_value
		else:
			dest[key] = source[key]

# Convert PascalCase string to snake_case style.
static func to_snake_case(string):
	var regex = RegEx.new()
	regex.compile("(.)([A-Z][a-z]+)")
	var s = regex.sub(string, "$1_$2", true)
	regex.compile("([a-z0-9])([A-Z])")
	
	return regex.sub(s, "$1_$2", true).to_lower()

# Convert arabic number from 1 to 10 to roman numeric.
static func to_roman_numeral(value):
	assert(value >= 1 && value <= 10)

	var roman_numerals = ["I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"]

	return roman_numerals[value - 1]
	
static func clear_container(container):
	for i in container.get_children():
		if i.name != 'Button':
			i.hide()
			i.queue_free()

static func duplicate_container_template(container):
	var NewButton = container.get_node('Button').duplicate()
	NewButton.show()
	container.add_child(NewButton)
	
	return NewButton

static func calculate_percent(v1, v2):
	return v1 * 100 / max(v2, 1)

static func add_increment_dict(dict, new_dict):
	for i in new_dict:
		if dict.has(i):
			dict[i] += new_dict[i]
		else:
			dict[i] = new_dict[i]

# Replace string "[color={color}] for globals.colors.{color}"
static func process_colors(text):
	var result = text
	for color in globals.colors:
		var color_string = "[color=%s]" % color
		var color_replace_string = "[color=%s]" % globals.colors[color]
		if result.find(color_string) != -1:
			result = result.replace(color_string, color_replace_string)
			
	return result
	
# Array must be made out of dictionaries with {value = name, weight = number} 
# Number is relative to other elements which may appear.
static func weighted_random(array): 
	var total = 0
	var counter = 0
	for i in array:
		if typeof(i) == TYPE_DICTIONARY:
			total += i.weight
		else:
			total += i[1]
	var random = rand_range(0,total)
	for i in array:
		if typeof(i) == TYPE_DICTIONARY:
			if counter + i.weight >= random:
				return i.value
			counter += i.weight
		else:
			if counter + i[1] >= random:
				return i[0]
			counter += i[1]
