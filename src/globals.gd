# This script is registered as an AutoLoad singleton in the Project settings. 
# It will load before every over node in the scene
extends Node

const VERSION = "0.1.0"

# Dictionaries util.
var races = preload("res://src/dictionary/races.gd")
var sexuals = preload("res://src/dictionary/sexuals.gd")
var traits = preload("res://src/dictionary/traits.gd")
var specs = preload("res://src/dictionary/specs.gd")
var jobs = preload("res://src/dictionary/jobs.gd")

# Main Player member.
var player

# Cached json dicts.
var _json = {}

# Initialization.
func _ready():
	# Seed the random.
	randomize()

# Helper function for read json into dictionary.
func read_json(path):
	# Check for cache.
	if not _json.has(path):
		var file = File.new()
		file.open(path, file.READ)
		_json[path]  = parse_json(file.get_as_text())
		file.close()
		
	return _json[path]
	
# Read and returns files in dir.
func read_dir(path):
	var files = []
	var dir = Directory.new()
	dir.open(path)
	if dir.list_dir_begin() != OK:
		print("Cannot read path: %s" % path)
		return []
		
	while 1:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with(".") and not file.ends_with(".import"):
			files.append(path + "/" + file)
	dir.list_dir_end()
	
	return files
	
# Merge two dicts.
func merge_dict(dest, source):
	for key in source:
		if dest.has(key):
			var dest_value = dest[key]
			var source_value = source[key]
			if typeof(dest_value) == TYPE_DICTIONARY:       
				if typeof(source_value) == TYPE_DICTIONARY: 
					merge_dict(dest_value, source_value)  
				else:
					dest[key] = source_value
			else:
				dest[key] = source_value
		else:
			dest[key] = source[key]

# Convert PascalCase string to snake_case style.
func to_snake_case(string):
	var regex = RegEx.new()
	regex.compile("(.)([A-Z][a-z]+)")
	var s = regex.sub(string, "$1_$2", true)
	regex.compile("([a-z0-9])([A-Z])")
	
	return regex.sub(s, "$1_$2", true).to_lower()


var SpriteDict = {}
var TranslationData = {}

var items
var TownData
var workersdict
var enemydata


var skills

var gearlist = ['helm', 'chest', 'gloves', 'boots', 'rhand', 'lhand', 'neck', 'ring1', 'ring2']

var file = File.new()
var dir = Directory.new()

var LocalizationFolder = "res://localization/"
var state

var userfolder = 'user://'

var globalsettings = { 
	ActiveLocalization = 'en',
	mastervol = -15,
	mastermute = false,
	musicvol = -15,
	musicmute = false,
	soundvol = -15,
	soundmute = false,
	fullscreen = false,
} setget settings_save

func settings_load():
	var config = ConfigFile.new()
	config.load(userfolder + "Settings.ini")
	var settings = config.get_section_keys("settings") 
	for i in settings:
		globalsettings[i] = config.get_value("settings", i, null)

func settings_save(value):
	globalsettings = value
	var config = ConfigFile.new()
	config.load(userfolder + "Settings.ini")
	for i in globalsettings:
		config.set_value('settings', i, globalsettings[i])
	config.save(userfolder + "Settings.ini")



func _newready():
	OS.window_size = Vector2(1280,720)
	OS.window_position = Vector2(300,0)
	#Settings and folders
	settings_load()
	if dir.dir_exists(userfolder + 'saves') == false:
		dir.make_dir(userfolder + 'saves')
	
	
	#Storing available translations
	for i in scanfolder(LocalizationFolder):
		for ifile in dir_contents(i):
			TranslationData[i.replace(LocalizationFolder, '')] = ifile
#			file.open(ifile, File.READ)
#			var data = file.get_as_text()
#	for i in dir_contents(LocalizationFolder):
#		TranslationData[i.replace(LocalizationFolder + '/', '').replace('.gd','')] = i
	
	
	#Applying active translation
	var activetranslation = Translation.new()
	var translationscript = load(TranslationData[globalsettings.ActiveLocalization]).new()
	activetranslation.set_locale(globalsettings.ActiveLocalization)
	for i in translationscript.TranslationDict:
		activetranslation.add_message(i, translationscript.TranslationDict[i])
	TranslationServer.add_translation(activetranslation)
	
	items = load("res://files/Items.gd").new()
	TownData = load('res://files/TownData.gd').new()
	enemydata = load("res://assets/data/enemydata.gd").new()
	skills = load("res://assets/data/Skills.gd").new()
	workersdict = TownData.workersdict
	
	state = gamestate.new()
	for i in items.Materials:
		state.materials[i] = 0
	state.materials.wood = 5
	state.materials.stone = 5
	state.money = 200
	

func logupdate(text):
	state.logupdate(text)

class gamestate:
	
	
	var date = 1
	var daytime = 0
	
	#resources
	var itemidcounter = 0
	var heroidcounter = 0
	var workeridcounter = 0
	var money = 0
	var townupgrades = {workerlimit = 5}
	var workers = {}
	var heroes = {}
	var items = {}
	var materials = {} setget materials_set
	var lognode 
	var oldmaterials = {}
	var unlocks = []
	
	var heroguild = []
	
	func _init():
		oldmaterials = materials.duplicate()
	
	func materials_set(value):
		var text = ''
		for i in value:
			if oldmaterials.has(i) == false || oldmaterials[i] != value[i]:
				if oldmaterials.has(i) == false:
					oldmaterials[i] = 0
				else:
					if oldmaterials[i] - value[i] < 0:
						text += 'Gained '
					else:
						text += "Lost "
					text += str(value[i] - oldmaterials[i]) + ' {color=yellow|' + globals.items.Materials[i].name + '}'
					logupdate(text)
		materials = value
		oldmaterials = materials.duplicate()
	
	func logupdate(text):
		if globals.get_tree().get_root().has_node("LogPanel/RichTextLabel") == false:
			return
		lognode = globals.get_tree().get_root().get_node("LogPanel/RichTextLabel")
		text = lognode.bbcode_text + '\n' + text
		
		#lognode.bbcode_text += '\n' + 
		lognode.bbcode_text = globals.TextEncoder(text)





class worker:
	var name
	var type
	var id
	var task
	var energy
	var maxenergy
	var currenttask
	var icon
	var model
	
	func create(data):
		name = data.name
		type = data.type
		id = globals.state.workeridcounter
		globals.state.workeridcounter += 1
		maxenergy = data.maxenergy
		energy = data.maxenergy
		icon = data.icon
		globals.state.workers[id] = self

var scenedict = {
	menu = "res://files/Menu.tscn",
	town = "res://files/MainScreen.tscn"
	
}

func ChangeScene(name):
	input_handler.CloseableWindowsArray.clear()
	var loadscreen = load("res://files/LoadScreen.tscn").instance()
	get_tree().get_root().add_child(loadscreen)
	loadscreen.goto_scene(scenedict[name])



func CreateItem(item, parts, newname = null):
	var newitem = items.gear.new()
	newitem.create(item, parts)
	if newname != null:
		newitem.name = newname
	
	state.items[newitem.id] = newitem

func dir_contents(target = "user://saves"):
	var dir = Directory.new()
	var array = []
	if dir.open(target) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir():
				array.append(target + "/" + file_name)
			elif !file_name in ['.','..', null] && dir.current_is_dir():
				array += dir_contents(target + "/" + file_name)
			file_name = dir.get_next()
		return array
	else:
		print("An error occurred when trying to access the path.")

func evaluate(input): #used to read strings as conditions when needed
	var script = GDScript.new()
	script.set_source_code("func eval():\n\treturn " + input)
	script.reload()
	var obj = Reference.new()
	obj.set_script(script)
	return obj.eval()



func ClearContainer(container):
	for i in container.get_children():
		if i.name != 'Button':
			i.hide()
			i.queue_free()

func DuplicateContainerTemplate(container):
	var newbutton = container.get_node('Button').duplicate()
	newbutton.show()
	container.add_child(newbutton)
	return newbutton

func connecttooltip(node, text):
	if node.is_connected("mouse_entered",self,'showtooltip'):
		node.disconnect("mouse_entered",self,'showtooltip')
	node.connect("mouse_entered",self,'showtooltip', [text,node])

func itemtooltip(item, node):
	var screen = get_viewport().get_visible_rect()
	var text = ''
	var tooltip 
	if get_tree().get_root().has_node("itemtooltip") == false:
		tooltip = load("res://files/Simple Tooltip/Imagetooltip.tscn").instance()
		get_tree().get_root().add_child(tooltip)
		tooltip.name = 'itemtooltip'
	else:
		tooltip = get_tree().get_root().get_node('itemtooltip')
	var type
	if item.get('itembase'):
		type = 'gear'
	else:
		type = 'material'
	
	if type == 'gear':
		tooltip.get_node("Image").texture = load(item.icon)
		text = item.tooltip()
	else:
		tooltip.get_node("Image").texture = item.icon
		text = item.description
	
	#tooltip.get_node("RichTextLabel").bbcode_text = text
	var pos = node.get_global_rect()
	pos = Vector2(pos.position.x, pos.end.y + 10)
	tooltip.set_global_position(pos)
	tooltip.showup(node, text)

func showtooltip(text, node):
	var screen = get_viewport().get_visible_rect()
	var tooltip 
	if get_tree().get_root().has_node("tooltip") == false:
		tooltip = load("res://files/Simple Tooltip/SimpleTooltip.tscn").instance()
		get_tree().get_root().add_child(tooltip)
		tooltip.name = 'tooltip'
	else:
		tooltip = get_tree().get_root().get_node('tooltip')
	tooltip.get_node("RichTextLabel").bbcode_text = text
	var pos = node.get_global_rect()
	pos = Vector2(pos.position.x, pos.end.y + 10)
	tooltip.set_global_position(pos)
	tooltip.showup(node, text)
#	tooltip.get_node("RichTextLabel").rect_size.y = tooltip.get_node("RichTextLabel").get_v_scroll().get_max()
#	tooltip.rect_size.y = tooltip.get_node("RichTextLabel").rect_size.y + 30
#	if tooltip.get_rect().end.x >= screen.size.x:
#		tooltip.rect_global_position.x -= tooltip.get_rect().end.x - screen.size.x
#	if tooltip.get_rect().end.y >= screen.size.y:
#		tooltip.rect_global_position.y -= tooltip.get_rect().end.y - screen.size.y

func hidetooltip(empty = null):
	if get_tree().get_root().has_node("tooltip") == false:
		var tooltip = load("res://files/Simple Tooltip/SimpleTooltip.tscn").instance()
		get_tree().get_root().add_child(tooltip)
		tooltip.name = 'tooltip'
	get_tree().get_root().get_node("tooltip").hide()

func RomanNumberConvert(value):
	var rval = ''
	match value:
		1:
			rval = 'I'
		2:
			rval = 'II'
		3:
			rval = 'III'
		4:
			rval = 'IV'
		5:
			rval = 'V'
		6:
			rval = 'VI'
		7:
			rval = 'VII'
		8:
			rval = 'VIII' 
		9:
			rval = 'IX'
		10:
			rval = 'X'

func AddPanelOpenCloseAnimation(node):
	if node.get_script() == null:
		node.set_script(load("res://files/Close Panel Button/ClosingPanel.gd"))
	node._ready()

func MaterialTooltip(value):
	var text = '[center][color=yellow]' + globals.items.Materials[value].name + '[/color][/center]\n' + globals.items.Materials[value].description + '\n\n' + tr("INPOSESSION") + ': ' + str(globals.state.materials[value])
	return text



var hexcolordict = {
	red = '#ff0000',
	yellow = "#ffff00",
	brown = "#8B572A",
	gray = "#4B4B4B",
	green = '#3af459',
}
var textcodedict = {
	color = {start = '[color=', end = '[/color]'},
	url = {start = '[url=',end = '[/url]'}
}

func TextEncoder(text, node = null):
	var tooltiparray = []
	var counter = 0
	while text.find("{") != -1:
		var newtext = text.substr(text.find("{"), text.find("}") - text.find("{")+1)
		var newtextarray = newtext.split("|")
		var originaltext = newtextarray[newtextarray.size()-1].replace("}",'')
		newtextarray.remove(newtextarray.size()-1)
		var startcode = ''
		var endcode = ''
		for data in newtextarray:
			data = data.replace('{','').split("=")
			
			match data[0]:
				'color':
					startcode += '[color=' + hexcolordict[data[1]] + ']'
					endcode = '[/color]' + endcode
				'url':
					tooltiparray.append(data[1])
					startcode += '[url=' + str(counter) + ']'
					endcode = '[/url]' + endcode
					counter += 1
		
		
		text = text.replace(newtext, startcode + originaltext + endcode)
	if tooltiparray.size() != 0 && node != null:
		node.set_meta('tooltips', tooltiparray)
		node.bbcode_text = text
		if node.is_connected("meta_hover_started", self, "BBCodeTooltip") == false:
			node.connect("meta_hover_started", self, "BBCodeTooltip", [node])
			node.connect("meta_hover_ended",self, 'hidetooltip')
	else:
		return text

func BBCodeTooltip(meta, node):
	var text = node.get_meta('tooltips')[int(meta)]
	showtooltip(text, node)

func CharacterSelect(targetscript, type, function, requirements):
	var node 
	if get_tree().get_root().has_node("CharacterSelect"):
		node = get_tree().get_root().get_node("CharacterSelect")
	else:
		node = load("res://CharacterSelect.tscn").instance()
		get_tree().get_root().add_child(node)
		node.name = 'CharacterSelect'
		AddPanelOpenCloseAnimation(node)
	
	node.show()
	node.set_as_toplevel(true)
	ClearContainer(node.get_node("ScrollContainer/VBoxContainer"))
	
	var array = []
	if type == 'workers':
		array = state.workers.values()
	
	for i in array:
		if requirements == 'notask' && i.task != null:
			continue
		var newnode = globals.DuplicateContainerTemplate(node.get_node("ScrollContainer/VBoxContainer"))
		newnode.text = i.name
		newnode.connect('pressed', targetscript, function, [i])
		newnode.connect('pressed',self,'CloseSelection', [node])

func ItemSelect(targetscript, type, function, requirements = true):
	var node 
	if get_tree().get_root().has_node("ItemSelect"):
		node = get_tree().get_root().get_node("ItemSelect")
	else:
		node = load("res://ItemSelect.tscn").instance()
		get_tree().get_root().add_child(node)
		AddPanelOpenCloseAnimation(node)
		node.name = 'ItemSelect'
	node.show()
	node.set_as_toplevel(true)
	
	ClearContainer(node.get_node("ScrollContainer/GridContainer"))
	
	var array = []
	if type == 'gear':
		for i in state.items.values():
			if i.subtype == requirements && i.task == null && i.owner == null:
				array.append(i)
	elif type == 'repairable':
		for i in state.items:
			if i.durability < i.maxdurability:
				array.append(i)
	
	for i in array:
		var newnode = globals.DuplicateContainerTemplate(node.get_node("ScrollContainer/GridContainer"))
		if type == 'gear':
			input_handler.itemshadeimage(newnode, i)
			newnode.get_node("Percent").show()
			newnode.get_node("Percent").text = str(calculatepercent(i.durability, i.maxdurability)) + '%'
			connecttooltip(newnode, i.tooltip())
		newnode.connect('pressed', targetscript, function, [i])
		newnode.connect('pressed',self,'CloseSelection', [node])

func CloseSelection(panel):
	panel.hide()



func calculatepercent(value1, value2):
	return value1*100/max(value2,1)

func AddOrIncrementDict(dict, newdict):
	for i in newdict:
		if dict.has(i):
			dict[i] += newdict[i]
		else:
			dict[i] = newdict[i]

func MergeDicts(dict1, dict2, overwrite = false):
	var returndict = dict1
	for i in dict2:
		if returndict.has(i) && overwrite == false:
			returndict[i] += dict2[i]
		else:
			returndict[i] = dict2[i]
	
	return returndict

func scanfolder(path): #makes an array of all folders in modfolder
	var dir = Directory.new()
	var array = []
	if dir.dir_exists(path) == false:
		dir.make_dir(path)
	if dir.open(path) == OK:
		dir.list_dir_begin()
		
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir() && !file_name in ['.','..',null]:
				array.append(path + file_name)
			file_name = dir.get_next()
		return array



