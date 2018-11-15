# item.gd
var id = 0
var code = ""
var name = ""
var icon setget load_icon
var description = ""
var effect = ""
var recipe = ""
var cost = 0
var type = ""
var amount = 1
var weight = 0
var stackable = true
var requires = true

var icon_texture = null

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

