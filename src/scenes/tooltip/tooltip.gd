# tooltip.gd
extends PanelContainer

const OFFSET_Y = 5

func _ready():
	hide()

func show_tooltip(node):
	assert(node is Node)
	
	var pos = node.get_global_position()
	pos.y = node.get_global_rect().end.y + OFFSET_Y
	set_global_position(pos)
	
	show()
	
func hide_tooltip():
	hide()
	
func set_data(text):
	assert(typeof(text) == TYPE_STRING)
	
	$Margin/Label.set_bbcode(text)
	