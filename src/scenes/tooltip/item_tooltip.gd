extends "tooltip.gd"

# Imports.
const Item = preload("res://src/state/inventory/item.gd")

func set_data(item):
	assert(item is Item)
	
	var Icon = $Margin/HBox/Icon
	var TextLabel = $Margin/HBox/Label
	
	if item.icon_texture != null:
		Icon.texture = item.icon_texture
	if item.description != "":
		TextLabel.set_bbcode(item.description)
	