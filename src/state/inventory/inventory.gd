# inventory.gd
extends Object

# Imports.
const Item = preload("item.gd")
const Util = preload("res://src/util.gd")

# Signals.
signal item_inserted(item)
signal item_deleted(item)
signal item_updated(item)

var cells = 0 # Zero = Endless.

var _items = {}

func _init(c = 0):
	cells = c
	
func items():
	return _items

# Experimental sorting.
func get_sorted_items():
	var sorted = []
	var items = _items
	for item_id in items:
		var s_arr = PoolStringArray(items[item_id].type)
		var s = s_arr.join("_") + "_" + str(item_id)
		sorted.append(s)
	sorted.sort()
	
	var i = 0
	var result = []
	for s in sorted:
		var split = s.split("_")
		var id = int(split[split.size() - 1])
		result.append(_items[id])
		
	return result
		
# Get item by id.
func item(id):
	if _items.has(id):
		return _items[id]
	else:
		return null

func has_item(id):
	return _items.has(id)
	
func add_item(item_code, amount = 1, check_requirements = true):
	var all_items = Util.read_json("res://assets/data/items.json")
	assert(all_items.has(item_code))
	
	var item = Item.new(all_items[item_code])
	if item.stackable:
		if _items.has(item.id):
			_items[item.id].amount += amount
			return true
		else:
			item.amount = amount
			
	_items[item.id] = item
	emit_signal("item_inserted", item)
	
	return true
	
func remove_item(id):
	_items.erase(id)
	emit_signal("item_deleted", id)

func back_item(item):
	_items[item.id] = item
	emit_signal("item_inserted", item)
	