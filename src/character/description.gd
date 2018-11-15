# Class description.gd represent dynamic description of any character.
# TODO (frama): Implement storing open/closed states for description.
# This file respect translation.

# Imports.
const Player = preload("res://src/state/player.gd")
const Util   = preload("res://src/util.gd")

# Constants.
const DESCRIPTION_PATH = "res://assets/data/description/description.json"

# Character object.
var _character = null

# Internal state object. 
var _state = null
var _locale = null

# Constructor.
func _init(character):
	_character = character
	_state = globals.state
	_locale = TranslationServer.get_locale()

# Get character description based on _characteral properties.
func get_text(is_compact = false):
	var text = ""
	text += "%s\n\n%s\n\n%s" % [
		basic(), 
		appearance(),
		genitals()
	]
	
	return Util.process_colors(_character.process_labels(text))

# Basic description.
func basic(is_compact = false):
	var text = ""
	
	if not is_compact:
		text += "[url=basic][color=yellow]%s:[/color][/url] " % tr("DESCRIPTION_BASIC")
		
	if _state.settings.description.basic == true:
		text += "\n%s %s %s %s %s" % [
			_entry(), 
			_race(), 
			_get_description("body_shape"), 
			_get_description("age"),
			_beauty()
		]
	else:
		text += "[color=yellow]$first_name, [url=race]%s[/url], %s[/color]. " % [_character.race, _character.age.capitalize()]

	return text
	
func appearance(is_compact = false):
	var text = ""
	
	if not is_compact:
		text += "[url=appearance][color=yellow]%s:[/color][/url] " % tr("DESCRIPTION_APPEARANCE")
		
	if _state.settings.description.appearance == true:
		text += "\n%s %s %s %s %s %s %s %s %s %s" % [
			_get_description("hair_length"), 
			_get_description("hair_style"), 
			_get_description("eye_color"), 
			_get_description("eye_shape"), 
			_get_description("horns"),
			_get_description("ears"),
			_get_description("skin"),
			_get_description("wings"),
			_get_description("tail"),
			_get_description("height")
		]
	else:
		text += tr("DESCRIPTION_OMITTED")
	
	return text
	
func genitals(is_compact = false):
	var text = ""
	
	if not is_compact:
		text += "[url=genitals][color=yellow]%s:[/color][/url] " % tr("DESCRIPTION_PRIVATES")
		
	if _state.settings.description.genitals == true:
		text += "\n%s %s %s" % [
			_get_description("breast_size"),
			_get_description("butt_size"),
			_lower_genitals()
		]
	else:
		text += tr("DESCRIPTION_OMITTED")
	
	return text
	
func _lower_genitals():
	var descriptions = Util.read_json(DESCRIPTION_PATH)
	var text = ""
	
	if _character.has_vagina:
		if _character.vaginal_virgin == true:
			text += tr("DESCRIPTION_VIRGIN_1")
		else:
			text += tr("DESCRIPTION_VIRGIN_2")
			
	if _character.has_penis:
		if descriptions["penis_type"].has(_character.penis_type) && descriptions["penis_type"][_character.penis_type].has(_character.penis_size):
			text += tr(descriptions["penis_type"][_character.penis_type][_character.penis_size])
			
	if _character.has_testicles:
		text += _get_description("testicle_size")
			
	if not _character.has_vagina && not _character.has_penis && not _character.has_testicles:
		text += tr("DESCRIPTION_NO_GENITALS")
		
	return text
	
func _get_description(property):
	assert(property in _character)
	
	var descriptions = Util.read_json(DESCRIPTION_PATH)
	
	var value = _character.get(property)
	if descriptions.has(property):
		if descriptions[property].has(value):
			return tr(descriptions[property][value])
		elif descriptions[property].has("*"):
			return tr(descriptions[property]["*"])
			
	return ""

func _entry():
	var text = ""
	
	if _character.sleep == "jail":
		text = "%s %s." % [tr("DESCRIPTION_ENTRY_1"), _character.get_fullname()]
	elif _character is Player:
		text = "%s %s." % [tr("DESCRIPTION_ENTRY_2"), _character.get_fullname()]
	elif _state.slaves.has(_character.id):
		text = "%s %s." % [tr("DESCRIPTION_ENTRY_3"), _character.get_fullname()]
	else:
		text = tr("DESCRIPTION_ENTRY_4")
	
	return text
	
func _race():
	var text = tr("DESCRIPTION_RACE_1")
	
	if _locale == "en" && _character.race != "":
		if _character.race[0] in ['E','A','O','U','e','a','o','u']:
			text += " an"
		else:
			text += " a"
			
	text += " [color=yellow][url=race]%s[/url][/color]: " % tr("RACE_" + _character.race.to_upper())
	
	return text
	
func _beauty():
	var descriptions = Util.read_json(DESCRIPTION_PATH)
	
	var key = "" 
	if _character.beauty <= 15:
		key = "ugly"
	elif _character.beauty <= 30:
		key = "boring"
	elif _character.beauty <= 50:
		key = "normal"
	elif _character.beauty <= 70:
		key = "cute"
	elif _character.beauty <= 85:
		key = "pretty"
	else:
		key = "beautiful"
	
	return "%s (%f)" % [tr(descriptions["beauty"][key]), floor(_character.beauty)]
	