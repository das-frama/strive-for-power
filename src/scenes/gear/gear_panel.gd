# gear_panel.gd
extends Panel

# Imports.
const Character = preload("res://src/character/character.gd")
# Scenes.
const CellScene = preload("res://src/scenes/gear/cell.tscn")

var character = null setget character_set

onready var List = $VBox

# Gear lines.
var gear_lines = {
	"helmet": tr("GEAR_HELMET"),
	"chest": tr("GEAR_CHEST"),
	"gloves": tr("GEAR_GLOVES"),
	"boots": tr("GEAR_BOOTS"),
	"right_hand": tr("GEAR_RIGHT_HAND"),
	"left_hand": tr("GEAR_LEFT_HAND"),
	"neck": tr("GEAR_NECK"),
	"ring_1": tr("GEAR_RING"),
	"ring_2": tr("GEAR_RING"),
}

func character_set(c):
	assert(c is Character)
	
	character = c
	character.connect("item_equipped", self, "_on_item_equipped")
	character.connect("item_unequipped", self, "_on_item_unequipped")
	
	# Clean current state.
	for GearCell in List.get_children():
		GearCell.delete()
	
	# Add new gear items.	
	for gear in gear_lines:
		var GearCell = CellScene.instance()
		GearCell.type = gear
		GearCell.name = gear
		GearCell.character = character
		List.add_child(GearCell)

func get_gear(gear):
	if List.has_node(gear):
		return List.get_node(gear)
	else:
		return null

func _on_item_equipped(item, gear):
	var GearCell = get_gear(gear)
	if GearCell == null:
		return
		
	GearCell.equip(item)

func _on_item_unequipped(item, gear):
	var GearCell = get_gear(gear)
	if GearCell == null:
		return
		
	GearCell.unequip()
