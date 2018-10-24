extends HBoxContainer

# Constants.
const PORTRAIT_PATH = "res://assets/portraits"

# Player.
const Player = preload("res://src/player/player.gd")
var _player

# Stages.
enum { 
	STAGE_RACE,
	STAGE_GENDER,
	STAGE_APPEARANCE,
	STAGE_FINAL,
}
var _current_stage = STAGE_RACE
onready var StageButtons = $StageButtons/VBox
onready var StagePanels = $StagePanels/Margin

# Portraits.
var _portraits_textures = []
var _portrait_index = 0

# Initialization.
func _ready():
	# Init player.
	_player = Player.new()
	# Set current stage.
	change_stage(_current_stage)
	
# Change current state to stage param.
func change_stage(stage):
	# Prapare stages.
	match stage:
		STAGE_RACE:
			_populate_races_list()
			_load_portraits()
		STAGE_GENDER:
			_populate_stats()
		STAGE_APPEARANCE:
			print(_player.eye_color)
			_populate_appearance()
		STAGE_FINAL:
			_print_player()

	# Set other buttons disabled except Cancel button.
	for i in range(0, StageButtons.get_child_count() - 1):
		var StageButton = StageButtons.get_child(i)
		StageButton.set_pressed(i == stage)
		StageButton.set_disabled(i > stage)
	# Hide other panels except the current.
	for i in range(0, StagePanels.get_child_count()):
		StagePanels.get_child(i).visible = i == stage
		
	_current_stage = stage
	
# -----------------
# ------Race-------
# -----------------
# Populate races list.
func _populate_races_list():
	var RaceList = StagePanels.get_node("Race/RaceList/VBox")
	# Prevent rerun.
	if not RaceList.has_node("BaseButton"):
		return
		
	var RaceButton = RaceList.get_node("BaseButton")
	# Open .json file with races. It's almost a data base.
	var races = global.read_json("res://assets/data/races.json")
	# Iterate over races and duplicate base button.
	for key in races:
		var race = races[key]
		var NewRaceButton = RaceButton.duplicate()
		NewRaceButton.set_text(race.race_name)
		NewRaceButton.show()
		NewRaceButton.connect("pressed", self, "_select_race", [key])
		RaceList.add_child(NewRaceButton)
	# Remove original base button.
	RaceButton.queue_free()
# Set race.
func _select_race(race_key):
	var races = global.read_json("res://assets/data/races.json")
	# Get race object.
	var race_object = races[race_key]	
	# Set description.
	var Description = StagePanels.get_node("Race/VBox/Description")
	var text = ""
	# Set race bonus if its exist.
	if race_object.bonus != "":
		text += "[color=aqua]%s[/color]\n\n" % race_object.bonus
	text += race_object.description
	Description.set_bbcode(text)
	# Set confirm button enabled.
	StagePanels.get_node("Race/VBox/Confirm").set_disabled(false)
	# Set player member.
	_player.race = race_key
	_player.race_name = race_object.race_name

# Load portraits.
func _load_portraits():
	# Prevent rerun.
	if _portraits_textures.size() > 0:
		return
		
	var files = global.read_dir(PORTRAIT_PATH)
	for file in files:
		_portraits_textures.append(load(file))
# Prev portrait.
func _on_prev_portrait_pressed():
	_set_portrait(_portrait_index - 1)
# Next portrait.
func _on_next_portrait_pressed():
	_set_portrait(_portrait_index + 1)
# Set current portrait with given index.
func _set_portrait(index):
	if index >= _portraits_textures.size():
		index = 0
	elif index < 0:
		index = _portraits_textures.size() - 1
	var Portrait = StagePanels.get_node("Race/VBox/PortraitBox/HBox/Portrait")
	Portrait.texture = _portraits_textures[index]
	_portrait_index = index
	# Set player member.
	_player.portrait_path = Portrait.texture

# -------------------------
# ------Gender & Age-------
# -------------------------
func _on_gender_item_selected(ID):
	_player.gender = StagePanels.get_node("GenderAge/HBoxGenderAge/Gender").get_item_text(ID)
func _on_age_item_selected(ID):
	_player.age = StagePanels.get_node("GenderAge/HBoxGenderAge/Age").get_item_text(ID)

# Populate player stats.
func _populate_stats():
	var StatsContainer = StagePanels.get_node("GenderAge/StatsContainer/VBox")
	# Prevent rerun.
	if not StatsContainer.has_node("HBoxBase"):
		return
	# Find and duplicate hbox for all player stats.
	var HBoxBase = StatsContainer.get_node("HBoxBase")
	for stat in _player.stats:
		var NewHBox = HBoxBase.duplicate()
		var NewHSeparator = StatsContainer.get_node("HSeparator").duplicate()
		var StatLabel = NewHBox.get_node("Label")
		StatLabel.set_text(stat.capitalize())
		NewHBox.get_node("Down").connect("pressed", self, "_change_stat", [StatLabel, stat, -1])
		NewHBox.get_node("Up").connect("pressed", self, "_change_stat", [StatLabel, stat, 1])
		_change_stat(StatLabel, stat, 0)
		StatsContainer.add_child_below_node(HBoxBase, NewHBox)
		StatsContainer.add_child_below_node(NewHBox, NewHSeparator)
	# Remove original hbox.
	HBoxBase.queue_free()
# Change stats.
func _change_stat(StatLabel, stat, d):
	if d > 0 && _player.bonus_points == 0:
		return
	# If we between min and max range.
	if _player.stats[stat].m + d >= Player.STAT_MIN && _player.stats[stat].m + d <= Player.STAT_MAX:
		_player.stats[stat].m += d
		_player.bonus_points -= d
	# Set text to labels.
	StatLabel.set_text("%s: %d" % [stat.capitalize(), _player.stats[stat].m])
	StagePanels.get_node("GenderAge/StatsContainer/VBox/PointsLeft").set_text("Points Left: %d" % _player.bonus_points)

# -----------------------
# ------Appearance-------
# -----------------------
# TODO (frama): May be in the future we should implement adding all UI dynamically.
func _populate_appearance():
	var Grid = StagePanels.get_node("Appearance/Grid")
	# Name.
	Grid.get_node("FirstName").set_text(_player.first_name)
	Grid.get_node("LastName").set_text(_player.last_name)
	# Body Shape.
	var BodyShape = Grid.get_node("BodyShape")
	BodyShape.clear()
	BodyShape.add_item(_player.body_shape)
	BodyShape.set_disabled(true)
	# Virgin.
	var Virgin = Grid.get_node("Virgin")
	Virgin.set_pressed(_player.vaginal_virgin)
	Virgin.visible = _player.has_vagina
	# Eye Color.
	_populate_option_button(Grid.get_node("EyeColor"), "eye_color", _player.appearance_list("eye_color"))
	# Breast Size.
	_populate_option_button(Grid.get_node("BreastSize"), "breast_size", _player.sexual_list("breast_size"))
	# Fur Color.
	_populate_option_button(Grid.get_node("FurColor"), "fur_color", _player.appearance_list("fur_color"))
	# Hair Color.
	_populate_option_button(Grid.get_node("HairColor"), "hair_color", _player.appearance_list("hair_color"))
	# Height
	_populate_option_button(Grid.get_node("Height"), "height", _player.sexual_list("height"))
	# Butt Size.
	_populate_option_button(Grid.get_node("ButtSize"), "butt_size", _player.sexual_list("butt_size"))
	# Ear Shape.
	_populate_option_button(Grid.get_node("EarShape"), "ears", _player.appearance_list("ears"))
	# Skin Color.
	_populate_option_button(Grid.get_node("SkinColor"), "skin", _player.appearance_list("skin"))
	# Penis Size.
	_populate_option_button(Grid.get_node("PenisSize"), "penis_size", _player.sexual_list("penis_size"))
	# Horn Shape.
	_populate_option_button(Grid.get_node("HornShape"), "horns", _player.appearance_list("horns"))
	# Hair Length.
	_populate_option_button(Grid.get_node("HairLength"), "hair_length", _player.sexual_list("hair_length"))
	# Penis Type.
	_populate_option_button(Grid.get_node("PenisType"), "penis_type", _player.appearance_list("penis_type"))
	# Wings Shape.
	_populate_option_button(Grid.get_node("WingsShape"), "wings", _player.appearance_list("wings"))
	# Testicle Size.
	_populate_option_button(Grid.get_node("TesticleSize"), "testicle_size", _player.sexual_list("testicle_size"))
	# Tail Shape.
	_populate_option_button(Grid.get_node("TailShape"), "tail", _player.appearance_list("tail"))
	
# Helper function to populate options with items.
func _populate_option_button(OptionBtn, property, list):
	OptionBtn.clear()
	OptionBtn.set_disabled(false)	
	if list.size() == 0:
		OptionBtn.add_item('none')
		OptionBtn.set_disabled(true)
		return
	elif list.size() == 1:
		OptionBtn.add_item(list[0])
		OptionBtn.set_disabled(true)
		return
	var n = 0
	for i in list:
		OptionBtn.add_item(i.replace("_", " "))
		if _player.get(property) == i:
			OptionBtn.select(n)
		n += 1
	OptionBtn.connect("item_selected", self, "_on_change_property", [property, OptionBtn])
# 
func _on_change_property(value, property, OptionBtn):
	_player.set(property, OptionBtn.get_item_text(value).replace(" ", "_"))
	
# ------------------
# ------Final-------
# ------------------
func _print_player():
	var text = "First Name: %s\nLast Name: %s\nRace: %s\nGender: %s\nAge: %s\nOrigin: %s\nPortrait: %s\nBody Shape: %s\nEars: %s\nTail: %s\nWings: %s\nHorns: %s\nEye Color: %s\nFur Color: %s\nSkin: %s\nHeight: %s\nHair Length: %s\nHair Color: %s\nButt Size: %s\nBreast Size: %s\nPenis Type: %s\nPenis Size: %s\nTesticle Size: %s\nVirgin: %s\nStrength: %s\nAgility: %s\nMagic: %s\nEndurance: %s" % \
	 [_player.first_name, _player.last_name, _player.race, _player.gender, _player.age, _player.origin, _player.portrait_path, _player.body_shape, 	_player.ears, _player.tail, _player.wings, _player.horns, _player.eye_color, _player.fur_color, _player.skin, _player.height, _player.hair_length, 	_player.hair_color, _player.butt_size, _player.breast_size, _player.penis_type, _player.penis_size, _player.testicle_size, _player.vaginal_virgin, 	_player.stats.strength.m, _player.stats.agility.m, _player.stats.magic.m, _player.stats.endurance.m]
	
	StagePanels.get_node("Final/Description").set_bbcode(text)

# Confirm and change stage.
func _on_confirm_pressed(stage):
	var StageButton = StageButtons.get_child(stage)
	match stage:
		STAGE_RACE:
			StageButton.set_text(_player.race_name)
			_player.random_appearance()
		STAGE_GENDER:
			StageButton.set_text("%s %s" % [_player.gender.capitalize(), _player.age.capitalize()])
			_player.random_name()
			_player.random_sexuals()
		STAGE_APPEARANCE:
			pass
		STAGE_FINAL:
			pass

	change_stage(_current_stage + 1)

# Cancel.
func _on_cancel_pressed():
	hide()
