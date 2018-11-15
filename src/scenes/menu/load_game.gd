extends PanelContainer

# Imports.
const Util = preload("res://src/util.gd")

onready var List = $VBox/Scroll/VBox

# Init.
func _ready():
	_populate_saves_buttons()
	
# Populate load buttons according to save path.
func _populate_saves_buttons():
	var LoadButton = List.get_node("LoadButton")
	
	var files = Util.read_dir(globals.SAVE_PATH, false)
	for file in files:
		var NewButton = LoadButton.duplicate()
		NewButton.set_text(file)
		NewButton.connect("pressed", self, "_on_load_button_pressed", [file])
		List.add_child(NewButton)

	# Remove original mockup button.
	LoadButton.queue_free()
	
func _on_load_button_pressed(save_name):
	globals.load_game(save_name)

func _on_close_pressed():
	hide()
