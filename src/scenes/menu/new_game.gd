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
	STAGE_TRAIT,
	STAGE_JOB,
	STAGE_FINAL,
}
var _current_stage

# UI Elements.
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
	change_stage(STAGE_RACE)
	
# Change current state to stage param.
func change_stage(stage):
	if _current_stage == stage:
		return
	# Prapare stages.
	match stage:
		STAGE_RACE:
			_populate_races_list()
			_load_portraits()
		STAGE_GENDER:
			_populate_stats()
		STAGE_APPEARANCE:
			_populate_appearance()
		STAGE_TRAIT:
			_populate_traits()
		STAGE_JOB:
			_populate_jobs()
			_populate_specs()
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
	if RaceList.has_meta("loaded"):
		return
	RaceList.set_meta("loaded", true)
		
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
	if StatsContainer.has_meta("loaded"):
		return
	StatsContainer.set_meta("loaded", true)
	
	# Find and duplicate hbox for all player stats.
	var HBoxBase = StatsContainer.get_node("HBoxBase")
	for stat in ["strength", "agility", "magic", "endurance"]:
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
	if _player.stats[stat]["max"] + d >= Player.STAT_MIN && _player.stats[stat]["max"] + d <= Player.STAT_MAX:
		_player.stats[stat]["max"] += d
		_player.bonus_points -= d
	# Set text to labels.
	StatLabel.set_text("%s: %d" % [stat.capitalize(), _player.stats[stat]["max"]])
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
	# Others.
	var apperance_list = {}
	global.merge_dict(apperance_list, global.races.list(_player.race, ["eye_color", "hair_color", "ears", "fur_color", "penis_type", "skin", "horns", "wings", "tail"]))
	global.merge_dict(apperance_list, global.sexuals.list(_player.gender, _player.age))
	for NodeElement in get_tree().get_nodes_in_group("player_property"):
		var key = global.to_snake_case(NodeElement.name)
		if apperance_list.has(key):
			_populate_option_button(NodeElement, key, apperance_list[key])
		else:
			NodeElement.clear()
			NodeElement.set_disabled(true)
			NodeElement.add_item("none")
	
# Helper function to populate options with items.
func _populate_option_button(OptionBtn, property, list):
	OptionBtn.clear()
	OptionBtn.set_disabled(false)	
	if list.size() == 0:
		OptionBtn.add_item("none")
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
	if not OptionBtn.has_meta("connected"):
		OptionBtn.connect("item_selected", self, "_on_change_property", [property, OptionBtn])
		OptionBtn.set_meta("connected", true)
# 
func _on_change_property(value, property, OptionBtn):
	_player.set(property, OptionBtn.get_item_text(value).replace(" ", "_"))
	
# ------------------
# ------Traits------
# ------------------
func _populate_traits():
	var TraitList = StagePanels.get_node("Trait/HBox/TraitsList/VBox")
	# Prevent rerun.
	if TraitList.has_meta("loaded"):
		return
	TraitList.set_meta("loaded", true)
		
	var TraitButton = TraitList.get_node("BaseButton")
	var traits = global.read_json("res://assets/data/traits.json")
	# Iterate over traits and duplicate base button.
	for key in traits:
		var trait = traits[key]
		var NewTraitButton = TraitButton.duplicate()
		NewTraitButton.set_text(trait.name)
		NewTraitButton.connect("toggled", self, "_select_trait", [key, NewTraitButton])
		TraitList.add_child(NewTraitButton)
	# Remove original base button.
	TraitButton.queue_free()

func _select_trait(button_pressed, key, TraitButton):
	var Description = StagePanels.get_node("Trait/HBox/Description")
	
	var traits = global.read_json("res://assets/data/traits.json")		
	var text = traits[key].description
	Description.set_bbcode(_player.process_labels(text))
	# Add / remove trait.
	if button_pressed:
		TraitButton.set_pressed(_player.add_trait(key))
	else:
		_player.remove_trait(key)
		
# ----------------------
# ------Jobs&Specs------
# ----------------------
func _populate_jobs():
	var JobList = StagePanels.get_node("JobsSpecs/HBox/JobList/VBox")
	# Prevent rerun.
	if JobList.has_meta("loaded"):
		return
	JobList.set_meta("loaded", true)
	var JobButton = JobList.get_node("BaseButton")
	var jobs = global.jobs.list()
	# Iterate over jobs and duplicate base button.
	for key in jobs:
		var job = jobs[key]
		var NewJobButton = JobButton.duplicate()
		NewJobButton.set_text(job.name)
		NewJobButton.connect("pressed", self, "_select_job", [key])
		JobList.add_child(NewJobButton)
	# Remove original base button.
	JobButton.queue_free()
	pass
	
func _select_job(key):
	var jobs = global.jobs.list()
	var Description = StagePanels.get_node("JobsSpecs/HBox/Description")
	var text = jobs[key].description
	Description.set_bbcode(_player.process_labels(text))
	_player.job = key

func _populate_specs():
	var SpecList = StagePanels.get_node("JobsSpecs/HBox/SpecList/VBox")
	# Prevent rerun.
	if SpecList.has_meta("loaded"):
		return
	SpecList.set_meta("loaded", true)
		
	var SpecButton = SpecList.get_node("BaseButton")
	var specs = global.specs.list()
	# Iterate over specs and duplicate base button.
	for key in specs:
		var spec = specs[key]
		var NewSpecButton = SpecButton.duplicate()
		NewSpecButton.set_text(spec.name)
		NewSpecButton.connect("button_up", self, "_select_spec", [key, NewSpecButton])
		SpecList.add_child(NewSpecButton)
	# Remove original base button.
	SpecButton.queue_free()
	
func _select_spec(key, SpecButton):
	var Description = StagePanels.get_node("JobsSpecs/HBox/Description")
	
	var specs = global.specs.list()
	if specs[key].has("rules") && not _player.check_requirements(specs[key].rules):
		Description.set_bbcode("Does not meet the requirements")
		SpecButton.set_pressed(false)
	else:
		Description.set_bbcode(specs[key].description)
		_player.spec = key

# ------------------
# ------Final-------
# ------------------
func _print_player():
	var text = "First Name: %s\nLast Name: %s\nRace: %s\nGender: %s\nAge: %s\nOrigin: %s\nPortrait: %s\nBody Shape: %s\nEars: %s\nTail: %s\nWings: %s\nHorns: %s\nEye Color: %s\nFur Color: %s\nSkin: %s\nHeight: %s\nHair Length: %s\nHair Color: %s\nButt Size: %s\nBreast Size: %s\nPenis Type: %s\nPenis Size: %s\nTesticle Size: %s\nVirgin: %s\nStrength: %s\nAgility: %s\nMagic: %s\nEndurance: %s" % \
	 [_player.first_name, _player.last_name, _player.race, _player.gender, _player.age, _player.origin, _player.portrait_path,\
	 _player.body_shape, _player.ears, _player.tail, _player.wings, _player.horns, _player.eye_color, _player.fur_color,\
	 _player.skin, _player.height, _player.hair_length, 	_player.hair_color, _player.butt_size, _player.breast_size,\
	_player.penis_type, _player.penis_size, _player.testicle_size, _player.vaginal_virgin, 	_player.stats.strength.max,\
	_player.stats.agility.max, _player.stats.magic.max, _player.stats.endurance.max]
	
	text += "\n\nTraits:\n"
	for t in _player.traits():
		text += "\t%s\n" % t
	text += "\nJob: %s\n" % _player.job
	text += "Spec: %s\n" % _player.spec
	text += "\nInventory:\n"
	var items = _player.inventory.items()
	for id in items:
		text += "\t[%s] %s (%d)\n" % [id, items[id].name, items[id].amount]
	
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
		STAGE_JOB:
			var items = global.read_json("res://assets/data/items.json")
			_player.inventory.add_item(items.food)
			_player.inventory.add_item(items.food)
			_player.inventory.add_item(items.supply)
			_player.inventory.add_item(items.rope)
			_player.inventory.add_item(items.rope)
			_player.inventory.add_item(items.rope)
			_player.inventory.add_item(items.torch)
			_player.inventory.add_item(items.torch)
		STAGE_FINAL:
			pass

	change_stage(_current_stage + 1)

# Cancel.
func _on_cancel_pressed():
	hide()
