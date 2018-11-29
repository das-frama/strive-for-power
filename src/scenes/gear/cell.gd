# gear.gd
extends Control

# Imports.
const Item = preload("res://src/state/inventory/item.gd")

var type = ""
var item = null
var is_equipped = false
var character = null

onready var IconNode = $Center/Icon
onready var EquippedNode = $Center/Equipped

func _ready():
	$Label.set_text(name)
	
func _gui_input(event):
	if event.is_action_pressed("ui_alt_click"):
		if is_equipped:
			character.unequip_item(type)
			
func get_drag_data(position):
	if not is_equipped:
		return null
		
	var node = IconNode.duplicate()
	node.rect_size = Vector2(64, 64)
	node.modulate = Color(1, 1, 1, 0.5)
	set_drag_preview(node)

	return type

func can_drop_data(position, data):
	if typeof(data) != TYPE_OBJECT:
		return false
		
	var item = data
	
	if not item.has_gear(type):
		return false
	
	return character.check_requirements(item.requires)
	
func drop_data(position, data):
	character.equip_item(data, type)

func equip(item):
	assert(item is Item)
	
	self.item = item
	self.is_equipped = true
	IconNode.texture = self.item.icon_texture
	EquippedNode.visible = true

func unequip():
	self.item = null
	self.is_equipped = false
	IconNode.texture = null
	EquippedNode.visible = false
	