# This script is registered as an AutoLoad singleton in the Project settings. 
# It will load before every over node in the scene
extends Node

const VERSION = "0.1.0"

# Dictionaries util.
var races = preload("res://src/dictionary/races.gd")
var sexuals = preload("res://src/dictionary/sexuals.gd")
var traits = preload("res://src/dictionary/traits.gd")
var specs = preload("res://src/dictionary/specs.gd")
var jobs = preload("res://src/dictionary/jobs.gd")

# Main Player member.
var player

# Cached json dicts.
var _json = {}

# Initialization.
func _ready():
	# Seed the random.
	randomize()

# Helper function for read json into dictionary.
func read_json(path):
	# Check for cache.
	if not _json.has(path):
		var file = File.new()
		file.open(path, file.READ)
		_json[path]  = parse_json(file.get_as_text())
		file.close()
		
	return _json[path]
	
# Read and returns files in dir.
func read_dir(path):
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
			files.append(path + "/" + file)
	dir.list_dir_end()
	
	return files
	
# Merge two dicts.
func merge_dict(dest, source):
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
func to_snake_case(string):
	var regex = RegEx.new()
	regex.compile("(.)([A-Z][a-z]+)")
	var s = regex.sub(string, "$1_$2", true)
	regex.compile("([a-z0-9])([A-Z])")
	
	return regex.sub(s, "$1_$2", true).to_lower()
