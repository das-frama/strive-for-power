# inventory.gd
extends Panel

# Imports.
const Inventory = preload("res://src/state/inventory/inventory.gd")
const Character = preload("res://src/character/character.gd")
# Scenes.
const ItemScene = preload("res://src/scenes/inventory/item.tscn")

# Reference to the inventory object to be handled.
var inventory = null setget inventory_set
var character = null setget character_set

onready var Grid = $HBox/Grid
onready var Gear = $HBox/Gear

func can_drop_data(position, data):
	if typeof(data) == TYPE_STRING:
		return character.is_item_equipped(data)
	else:
		return false
	
func drop_data(position, data):
	character.unequip_item(data)
	
# Setter for inventory.
func inventory_set(i):
	assert(i is Inventory)
	
	# Clear items.
	for ItemCell in Grid.get_children():
		ItemCell.delete()

	inventory = i
	inventory.connect("item_inserted", self, "insert_item")
	inventory.connect("item_deleted", self, "delete_item")
	
	var items = inventory.get_sorted_items()
	for item in items:
		insert_item(item)
		
func character_set(c):
	assert(c is Character)
	
	character = c
	Gear.character_set(c)

func get_item(item_id):
	if Grid.has_node("%d" % item_id):
		return Grid.get_node("%d" % item_id)
	else:
		return null

# Update state of the inventory.
func insert_item(item):
	if not item.is_connected("item_used", self, "_on_item_used"):
		item.connect("item_used", self, "_on_item_used", [item])
	
	var ItemCell = ItemScene.instance()
	ItemCell.name = "%d" % item.id
	ItemCell.item = item
	Grid.add_child(ItemCell)

# Delete item,
func delete_item(item_id):
	get_item(item_id).delete()

# If item were used by the player. 
func _on_item_used(item):
	var ItemCell = get_item(item.id)
	if ItemCell == null:
		return
		
	if item.amount == 0:
		ItemCell.delete()
	else:
		ItemCell.update()
		