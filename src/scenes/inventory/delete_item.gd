# delete_item.gd
extends TextureButton

# Imports.
const Item = preload("res://src/state/inventory/item.gd")

func can_drop_data(position, data):
	if typeof(data) == TYPE_OBJECT && data is Item:	
		return globals.state.inventory.has_item(data.id)
	else:
		return false
	
func drop_data(position, data):
	globals.show_confirm("Are you sure you want to delete this item?", self, "_on_confirmed", [data.id])

func _ready():
	pass

func _on_confirmed(item_id):
	globals.state.inventory.remove_item(item_id)
