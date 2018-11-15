# Imports.
var Item = preload("item.gd")

var cells = 0 # Zero = Endless.

var _items = {}

func _init(c = 0):
	cells = c
	
func items():
	return _items
	
func item(id):
	if _items.has(id):
		return _items[id]
	else:
		return null
	
func add_item(item, amount = 1, check_requirements = true):
	assert(typeof(item) == TYPE_DICTIONARY)
	
	if check_requirements:
		# TODO (frama): Implement requirements check.
		pass

	var item_object = Item.new(item)	
	if item_object.stackable:
		if _items.has(item_object.id):
			_items[item_object.id].amount += amount
			return true
	else:
		if _items.has(item_object.id):
			item_object.generate_id()
			
	_items[item_object.id] = item_object
	
	return true
	
func remove_item(id):
	_items.erase(id)	
	