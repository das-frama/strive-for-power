extends Node

#This script handles inputs, sounds, closes windows and plays animation
var CloseableWindowsArray = []
var ShakingNodes = []
var CurrentScreen = 'Town'

var BeingAnimated = []

signal ScreenChanged

func _input(event):
	if event.is_echo() == true || event.is_pressed() == false :
		return
	if event.is_action("ESC") && event.is_pressed() && CloseableWindowsArray.size() != 0:
		CloseTopWindow()
	if CurrentScreen == 'Town' && str(event.as_text().replace("Kp ",'')) in str(range(1,9)) && CloseableWindowsArray.size() == 0:
		if str(int(event.as_text())) in str(range(1,4)):
			get_tree().get_current_scene().changespeed(get_tree().get_current_scene().timebuttons[int(event.as_text())-1])

var musicfading = false
var musicraising = false
var musicvalue

func _process(delta):
	for i in CloseableWindowsArray:
		if i.is_visible_in_tree() == false:
			i.hide()
	for i in ShakingNodes:
		if i.time > 0:
			i.time -= delta
			i.node.rect_position = i.originpos + Vector2(rand_range(-1.0,1.0)*i.magnitude, rand_range(-1.0,1.0)*i.magnitude)
		else:
			i.node.rect_position = i.originpos
			ShakingNodes.erase(i)
	
	
	if musicfading:
		AudioServer.set_bus_volume_db(1, AudioServer.get_bus_volume_db(1) - delta*10)
		if AudioServer.get_bus_volume_db(1) <= -80:
			musicfading = false
	if musicraising:
		AudioServer.set_bus_volume_db(1, AudioServer.get_bus_volume_db(1) + delta*10)
		if AudioServer.get_bus_volume_db(1) >= globals.globalsettings.musicvol:
			AudioServer.set_bus_volume_db(1, globals.globalsettings.musicvol)
			musicraising = false
	




func CloseTopWindow():
	var node = CloseableWindowsArray.back()
	Close(node)

func OpenClose(node):
	node.show()
	OpenAnimation(node)
	CloseableWindowsArray.append(node)

func Close(node):
	CloseableWindowsArray.erase(node)
	CloseAnimation(node)

func Open(node):
	if CloseableWindowsArray.has(node):
		return
	OpenAnimation(node)
	CloseableWindowsArray.append(node)

func GetTweenNode(node):
	var tweennode
	if node.find_node('tween'):
		tweennode = node.get_node('tween')
	else:
		tweennode = Tween.new()
		tweennode.name = 'tween'
		node.add_child(tweennode)
	return tweennode

func SetMusic(name):
	var musicnode = GetMusicNode()
	musicnode.stream = globals.audio.music[name]
	musicnode.play(0)
	AudioServer.set_bus_volume_db(1, -200)
	musicraising = true

func GetMusicNode():
	var node = get_tree().get_current_scene()
	var musicnode
	if node.find_node('music'):
		musicnode = node.get_node('music')
	else:
		musicnode = AudioStreamPlayer.new()
		musicnode.name = 'music'
		musicnode.bus = 'Music'
		node.add_child(musicnode)
	return musicnode

#Item shading function

func itemshadeimage(node, item):
	var shader = load("res://files/ItemShader.tres").duplicate()
	if node.get_class() == "TextureButton":
		node.texture_normal = load(item.icon)
	else:
		node.texture = load(item.icon)
	if node.material != shader:
		node.material = shader
	else:
		shader = node.material
	for i in item.parts:
		var part = 'part' +  str(item.partcolororder[i]) + 'color'
		var color = globals.items.Materials[item.parts[i]].color
		node.material.set_shader_param(part, color)
	

#Enlarge/fade out animation


func CloseAnimation(node):
	if BeingAnimated.has(node) == true:
		return
	BeingAnimated.append(node)
	var tweennode = GetTweenNode(node)
	tweennode.interpolate_property(node, 'modulate', Color(1,1,1,1), Color(1,1,1,0), 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tweennode.interpolate_property(node, 'rect_scale', Vector2(1,1), Vector2(0.7,0.6), 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tweennode.start()
	yield(get_tree().create_timer(0.3), 'timeout')
	node.visible = false
	BeingAnimated.erase(node)
	globals.hidetooltip()

func OpenAnimation(node):
	if BeingAnimated.has(node) == true:
		return
	BeingAnimated.append(node)
	node.visible = true
	var tweennode = GetTweenNode(node)
	tweennode.interpolate_property(node, 'modulate', Color(1,1,1,0), Color(1,1,1,1), 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tweennode.interpolate_property(node, 'rect_scale', Vector2(0.7,0.6), Vector2(1,1), 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tweennode.start()
	yield(get_tree().create_timer(0.3), 'timeout')
	BeingAnimated.erase(node)

func FadeAnimation(node, time = 0.3, delay = 0):
	var tweennode = GetTweenNode(node)
	tweennode.interpolate_property(node, 'modulate', Color(1,1,1,1), Color(1,1,1,0), time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, delay)
	tweennode.start()

func UnfadeAnimation(node, time = 0.3, delay = 0):
	var tweennode = GetTweenNode(node)
	tweennode.interpolate_property(node, 'modulate', Color(1,1,1,0), Color(1,1,1,1), time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, delay)
	tweennode.start()

func ShakeAnimation(node, time = 0.5, magnitude = 5):
	var newdict = {node = node, time = time, magnitude = magnitude, originpos = node.rect_position}
	for i in ShakingNodes:
		if i.node == node:
			newdict.originpos = i.originpos
			ShakingNodes.erase(i)
	ShakingNodes.append(newdict)

func SmoothTextureChange(node, newtexture):
	var NodeCopy = node.duplicate()
	node.get_parent().add_child_below_node(node, NodeCopy)
	node.texture = newtexture
	FadeAnimation(NodeCopy, 0.2)
	yield(get_tree().create_timer(0.3), 'timeout')
	NodeCopy.queue_free()


func requirementcombatantcheck(req, combatant):#Gear, Race, Types, Resists, stats
	var result
	match req.type:
		'stats':
			result = input_handler.operate(req.operant, combatant[req.name], req.value)
		'gear':
			match req.slot:
				'any':
					var tempresult = false
					for i in combatant.gear.values():
						if i != null:
							tempresult = input_handler.operate(req.operant, globals.state.items[i][req.name], globals.state.items[i][req.value])
							if tempresult == true:
								result = true
								break
				'all':
					result = true
					for i in combatant.gear.values():
						if i != null:
							if input_handler.operate(req.operant, globals.state.items[i][req.name], globals.state.items[i][req.value]) == false:
								result = false
								break
	
	return result

func operate(operation, value1, value2):
	var result
	
	match operation:
		'eq':
			result = value1 == value2
		'neq':
			result = value1 != value2
		'gte':
			result = value1 >= value2
		'gt':
			result = value1 > value2
		'lte':
			result = value1 <= value2
		'lt':
			result = value1 < value2
	return result

func weightedrandom(array): #array must be made out of dictionaries with {value = name, weight = number} Number is relative to other elements which may appear
	var total = 0
	var counter = 0
	for i in array:
		if typeof(i) == TYPE_DICTIONARY:
			total += i.weight
		else:
			total += i[1]
	var random = rand_range(0,total)
	for i in array:
		if typeof(i) == TYPE_DICTIONARY:
			if counter + i.weight >= random:
				return i.value
			counter += i.weight
		else:
			if counter + i[1] >= random:
				return i[0]
			counter += i[1]

func open_shell(string):
	var path
	match string:
		'Itch':
			path = 'https://strive4power.itch.io/strive-for-power'
		'Patreon':
			path = 'https://www.patreon.com/maverik'
	OS.shell_open(path)
