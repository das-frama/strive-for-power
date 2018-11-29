extends Control

# Imports.
const Item = preload("res://src/state/inventory/item.gd")

var item = null setget item_set

onready var Delete = $Delete

func _gui_input(event):
	if event.is_action_pressed("ui_alt_click"):
		use()

func get_drag_data(position):
	var node = $Center/Icon.duplicate()
	node.rect_size = Vector2(128, 128)
	node.modulate = Color(1, 1, 1, 0.5)
	set_drag_preview(node)
	
	return item
	
func item_set(i):
	assert(i is Item)
	
	item = i
	update()
	
func use():
	self.item.use(globals.state.player)
	
func update():
	$Center/Icon.texture = self.item.icon_texture
	$Amount.set_text("%s" % self.item.amount)

func delete():
	queue_free()

func _on_delete_pressed():
	globals.show_confirm("Are you sure you want to delete this item?", self, "_on_confirmed_delete")

func _on_confirmed_delete():
	globals.state.inventory.remove_item(item.id)