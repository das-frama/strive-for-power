# This script is registered as an AutoLoad singleton in the Project settings.
# It will load before every over node in the scene.
extends Node

# Imports.
const State = preload("res://src/state/state.gd")

# Constants.
const VERSION     = "0.1.1"
const SECRET_PASS = "h0142ps"

# Paths.
const SAVE_PATH = "user://saves"

# Paths to the game screens.
const scenes = {
	"menu":    "res://src/scenes/menu/menu.tscn",
	"options": "res://src/scenes/menu/options.tscn",
	"mansion": "res://src/scenes/mansion/mansion.tscn",
}

# Preloaded scenes.
const preloaded_scenes = {
	"loading":      preload("res://src/scenes/background_loading.tscn"),
	"tooltip":      preload("res://src/scenes/tooltip/tooltip.tscn"),
	"item_tooltip": preload("res://src/scenes/tooltip/item_tooltip.tscn"),
}

# Used colors.
const colors = {
	"red":    "#ff0000",
	"green":  "#3af459",
	"yellow": "#f0e68c",
	"brown":  "#8b572a",
	"gray":   "#4b4b4b",
}

# Main objects.
var current_scene = null
var state = null

var closable_windows = []

# Cached json dicts.
var json = {}

# Initialization.
func _ready():
	# Seed the random.
	randomize()
	
	init_game()
	
	# @DEVELOP
	TranslationServer.set_locale("en")

func _input(event):
	if event.is_action("ESC") && closable_windows.size() > 0:
		CloseTopWindow()

# Init game stuff.
# Since we want init game things after new/loaded game.
func init_game():
	# Init state.
	state = State.new()

func change_scene(scene_name):
	assert(scenes.has(scene_name))

	var path = scenes[scene_name]
	# input_handler.CloseableWindowsArray.clear()
	var scene = preloaded_scenes["loading"].instance()
	get_tree().get_root().add_child(scene)
	scene.load_scene(path)

	current_scene = scene_name

# Save current game state.
func save_game(save_name):
	var file = File.new()
	var dir = Directory.new()
	if not dir.dir_exists(SAVE_PATH):
		dir.make_dir(SAVE_PATH)
	# TODO (frama): Think about generating unique string for user device to prevent hijacking saves.
	file.open_encrypted_with_pass(SAVE_PATH + "/" + save_name, File.WRITE, SECRET_PASS)
	file.store_var(state)
	file.close()

# Loads current state.
func load_game(save_name):
	var file = File.new()
	var path = SAVE_PATH + "/" + save_name
	if not file.file_exists(path):
		return false
		
	file.open_encrypted_with_pass(path, File.READ, SECRET_PASS)
	state = file.get_var()

	file.close()
	
	# Change screen to Mansion.
	change_scene("mansion")
	
	return true

# Tooltip section
func connect_tooltip(data, node, tooltip_type = "tooltip"):
	assert(node is Node)
	assert(preloaded_scenes.has(tooltip_type))
	
	var Root = get_tree().get_root()
	var Tooltip = null
	
	var tooltip_name = tooltip_type.capitalize()
	if Root.has_node(tooltip_name):
		Tooltip = Root.get_node(tooltip_name)
	else:
		Tooltip = preloaded_scenes[tooltip_type].instance()
		Tooltip.name = tooltip_name
		Root.call_deferred("add_child", Tooltip)
		
	Tooltip.set_data(data)
		
	node.connect("mouse_entered", Tooltip, "show_tooltip", [node])
	node.connect("mouse_exited",  Tooltip, "hide_tooltip")

func disconnect_tooltip(node):
	assert(node is Node)
	
	var Root = get_tree().get_root()
	if get_tree().get_root().has_node("Tooltip"):
		var Tooltip = Root.get_node("Tooltip")
		node.disconnect("mouse_entered", Tooltip, "show_tooltip")
		node.disconnect("mouse_exited",  Tooltip, "hide_tooltip")
		Tooltip.queue_free()
		
func show_confirm(text, object, confirmed_method, binds = Array()):
	destroy_confirm()
	
	var ConfirmDialog = ConfirmationDialog.new()
	ConfirmDialog.name = "Confirm"
	ConfirmDialog.dialog_text = text
	ConfirmDialog.connect("confirmed", object, confirmed_method, binds)
	ConfirmDialog.connect("confirmed", self, "destroy_confirm")
	get_tree().get_root().call_deferred("add_child", ConfirmDialog)
	ConfirmDialog.show()
	
func destroy_confirm():
	var Root = get_tree().get_root()
	if Root.has_node("Confirm"):
		Root.get_node("Confirm").queue_free()

func close_top_window():
	var windows = get_tree().get_nodes_in_group("closeable_windows")
	if windows.size() > 0:
		windows.back().hide()
		

#func material_tooltip(value):
#	return "[center][color=yellow]" + globals.items.Materials[value].name + "[/color][/center]\n" + globals.items.Materials[value].description + "\n\n" + tr("INPOSESSION") + ": " + str(globals.state.materials[value])

# ----------- To refeactor

var text_codes = {
	"color": { "start": "[color=", "end": "[/color]" },
	"url": { "start": "[url=", "end": "[/url]" },
}

func text_encoder(text, node = null):
	var tooltiparray = []
	var counter = 0
	while text.find("{") != -1:
		var newtext = text.substr(text.find("{"), text.find("}") - text.find("{")+1)
		var newtextarray = newtext.split("|")
		var originaltext = newtextarray[newtextarray.size()-1].replace("}","")
		newtextarray.remove(newtextarray.size()-1)
		var startcode = ""
		var endcode = ""
		for data in newtextarray:
			data = data.replace("{","").split("=")
			match data[0]:
				"color":
					startcode += "[color=" + colors[data[1]] + "]"
					endcode = "[/color]" + endcode
				"url":
					tooltiparray.append(data[1])
					startcode += "[url=" + str(counter) + "]"
					endcode = "[/url]" + endcode
					counter += 1


		text = text.replace(newtext, startcode + originaltext + endcode)
	if tooltiparray.size() != 0 && node != null:
		node.set_meta("tooltips", tooltiparray)
		node.bbcode_text = text
		if node.is_connected("meta_hover_started", self, "bb_code_tooltip") == false:
			node.connect("meta_hover_started", self, "BBCodeTooltip", [node])
			node.connect("meta_hover_ended",self, "hidetooltip")
	else:
		return text
