# jobs.gd
# Imports.
const Util = preload("res://src/util.gd")

static func list():
	return Util.read_json("res://assets/data/jobs.json")

static func test(args):
	print(args)
	
static func test2(args):
	print(args)