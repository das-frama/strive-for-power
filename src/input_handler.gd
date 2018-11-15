extends Node

#This script handles inputs, sounds, closes windows and plays animation

var BeingAnimated = []

signal ScreenChanged

#func _input(event):
#	if event.is_echo() == true || event.is_pressed() == false :
#		return
	
#	if CurrentScreen == 'Town' && str(event.as_text().replace("Kp ",'')) in str(range(1,9)) && CloseableWindowsArray.size() == 0:
#		if str(int(event.as_text())) in str(range(1,4)):
#			get_tree().get_current_scene().changespeed(get_tree().get_current_scene().timebuttons[int(event.as_text())-1])

var musicfading = false
var musicraising = false
var musicvalue

#func _process(delta):
#	for i in CloseableWindowsArray:
#		if i.is_visible_in_tree() == false:
#			i.hide()
#	for i in ShakingNodes:
#		if i.time > 0:
#			i.time -= delta
#			i.node.rect_position = i.originpos + Vector2(rand_range(-1.0,1.0)*i.magnitude, rand_range(-1.0,1.0)*i.magnitude)
#		else:
#			i.node.rect_position = i.originpos
#			ShakingNodes.erase(i)
#
#
#	if musicfading:
#		AudioServer.set_bus_volume_db(1, AudioServer.get_bus_volume_db(1) - delta*10)
#		if AudioServer.get_bus_volume_db(1) <= -80:
#			musicfading = false
#	if musicraising:
#		AudioServer.set_bus_volume_db(1, AudioServer.get_bus_volume_db(1) + delta*10)
#		if AudioServer.get_bus_volume_db(1) >= globals.globalsettings.musicvol:
#			AudioServer.set_bus_volume_db(1, globals.globalsettings.musicvol)
#			musicraising = false


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


# TODO (frama): Refactor below.

#Item shading function

#func itemshadeimage(node, item):
#	var shader = load("res://files/ItemShader.tres").duplicate()
#	if node.get_class() == "TextureButton":
#		node.texture_normal = load(item.icon)
#	else:
#		node.texture = load(item.icon)
#	if node.material != shader:
#		node.material = shader
#	else:
#		shader = node.material
#	for i in item.parts:
#		var part = 'part' +  str(item.partcolororder[i]) + 'color'
#		var color = globals.items.Materials[item.parts[i]].color
#		node.material.set_shader_param(part, color)
#func ShakeAnimation(node, time = 0.5, magnitude = 5):
#	var newdict = {node = node, time = time, magnitude = magnitude, originpos = node.rect_position}
#	for i in ShakingNodes:
#		if i.node == node:
#			newdict.originpos = i.originpos
#			ShakingNodes.erase(i)
#	ShakingNodes.append(newdict)

#func SmoothTextureChange(node, newtexture):
#	var NodeCopy = node.duplicate()
#	node.get_parent().add_child_below_node(node, NodeCopy)
#	node.texture = newtexture
#	FadeAnimation(NodeCopy, 0.2)
#	yield(get_tree().create_timer(0.3), 'timeout')
#	NodeCopy.queue_free()
#
#func requirementcombatantcheck(req, combatant):#Gear, Race, Types, Resists, stats
#	var result
#	match req.type:
#		'stats':
#			result = input_handler.operate(req.operant, combatant[req.name], req.value)
#		'gear':
#			match req.slot:
#				'any':
#					var tempresult = false
#					for i in combatant.gear.values():
#						if i != null:
#							tempresult = input_handler.operate(req.operant, globals.state.items[i][req.name], globals.state.items[i][req.value])
#							if tempresult == true:
#								result = true
#								break
#				'all':
#					result = true
#					for i in combatant.gear.values():
#						if i != null:
#							if input_handler.operate(req.operant, globals.state.items[i][req.name], globals.state.items[i][req.value]) == false:
#								result = false
#								break
#
#	return result

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
	