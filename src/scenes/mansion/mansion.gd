# mansion.gd
extends Control

# Imports.
const Character = preload("res://src/character/character.gd")

onready var Description = $HBox/Panel/VBox/Description
onready var SlaveList = $HBox/Panel2/VBox

func _ready():
	_populate_slaves()
	
func _populate_slaves():
	for i in range(5):
		var s = Character.new(null, true)
		s.job = "rest"
		globals.state.add_slave(s)
		var SlaveNode = Button.new()
		SlaveNode.set_text("#%d %s" % [s.id, s.get_fullname()])
		SlaveNode.connect("pressed", self, "_on_slave_pressed", [s.id])
		SlaveList.add_child(SlaveNode)
		
func _on_slave_pressed(id):
	var s = globals.state.get_slave_by_id(id)
	Description.set_bbcode(s.description.get_text())
	s.invoke_conditions()

func _on_show_window_toggled(button_pressed):
	if button_pressed:
		$Panel.show()
	else:
		$Panel.hide()
	
func _on_hide_top_pressed():
	globals.close_top_window()