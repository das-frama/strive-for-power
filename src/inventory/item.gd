extends Node

var id
var code
var icon setget load_icon
var description
var effect
var recipe
var cost
var type
var amount
var weight
var stackable
var requires

var icon_texture

func _init(item = {}):
	for property in item:
		if not property in self:
			continue
		self.set(property, item[property])
		
	generate_id()
	amount = 1
	
func generate_id():
	var item = {
		code: code,
		name: name,
		weight: weight,
		amount: amount
	}
	id = item.hash()
	
func load_icon(path):
	icon = path
	icon_texture = load(path)

