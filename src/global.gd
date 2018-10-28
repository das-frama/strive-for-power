# This script is registered as an AutoLoad singleton in the Project settings. 
# It will load before every over node in the scene
extends Node

const VERSION = '0.5.19d'

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
	