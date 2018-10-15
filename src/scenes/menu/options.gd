extends PanelContainer

onready var SettingsNode = $TabContainer/Settings/VBox/HBoxSettings
onready var GameNode = $TabContainer/Game/VBox

# Initialization
func _ready():
	# Setting all buttons according to current state.
	SettingsNode.get_node("VBoxLeft/Fullscreen").set_pressed(settings.get_setting("settings", "fullscreen"))
	SettingsNode.get_node("VBoxLeft/UseAnimation").set_pressed(settings.get_setting("settings", "use_animation"))
	SettingsNode.get_node("VBoxLeft/ShowSprites").set_pressed(settings.get_setting("settings", "show_sprites"))
	SettingsNode.get_node("VBoxLeft/SkipCombatAnimation").set_pressed(settings.get_setting("settings", "skip_combat"))
	SettingsNode.get_node("VBoxLeft/RandomPortraits").set_pressed(settings.get_setting("settings", "random_portraits"))
	SettingsNode.get_node("VBoxRight/MainFontSize").set_value(settings.get_setting("settings", "font_size"))
	set_music_label(settings.get_setting("settings", "music_volume"))
	set_sound_label(settings.get_setting("settings", "sound_volume"))
	GameNode.get_node("VBoxCheck/HBoxFuta/Futa").set_pressed(settings.get_setting("game", "futa"))
	GameNode.get_node("VBoxCheck/HBoxFuta/FutaTesticles").set_pressed(settings.get_setting("game", "futa_testicles"))
	GameNode.get_node("VBoxCheck/HBoxFuta/FutaTesticles").set_disabled(!settings.get_setting("game", "futa"))
	GameNode.get_node("VBoxCheck/HBoxFurry/Furry").set_pressed(settings.get_setting("game", "furry"))
	GameNode.get_node("VBoxCheck/HBoxFurry/FurryNipples").set_pressed(settings.get_setting("game", "furry_nipples"))
	GameNode.get_node("VBoxCheck/HBoxFurry/FurryNipples").set_disabled(!settings.get_setting("game", "furry"))
	GameNode.get_node("VBoxCheck/AllowRaces").set_pressed(settings.get_setting("game", "allow_races"))
	GameNode.get_node("VBoxCheck/ReceivingSex").set_pressed(settings.get_setting("game", "receiving_sex"))
	GameNode.get_node("VBoxCheck/Permadeath").set_pressed(settings.get_setting("game", "permadeath"))
	GameNode.get_node("VBoxCheck/HBoxAdult/ChildlikeCharacters").set_pressed(settings.get_setting("game", "childlike_characters"))
	GameNode.get_node("VBoxCheck/HBoxAdult/AdultCharacters").set_pressed(settings.get_setting("game", "adult_characters"))
	GameNode.get_node("VBoxCheck/HBoxAdult/AdultCharacters").set_visible(settings.get_setting("game", "childlike_characters"))
	GameNode.get_node("VBoxSlider/GenderSlider").set_value(settings.get_setting("game", "gender_occurrence"))
	GameNode.get_node("VBoxSlider/RandomFutaSlider").set_value(settings.get_setting("game", "futa_occurrence"))
	GameNode.get_node("VBoxOption/AliseOnDay").select(settings.get_setting("game", "alise_on_day"))
	

## Slots
# Fullscreen
func _on_fullscreen_toggled(button_pressed):
	settings.set_setting("settings", "fullscreen", button_pressed)
	OS.set_window_fullscreen(button_pressed)
	
# Use animation on screen change
func _on_use_animation_toggled(button_pressed):
	settings.set_setting("settings", "use_animation", button_pressed)

# Show sprites in dialogues
func _on_show_sprites_toggled(button_pressed):
	settings.set_setting("settings", "show_sprites", button_pressed)

# Skip combat animation
func _on_skip_combat_animation_toggled(button_pressed):
	settings.set_setting("settings", "skip_combat", button_pressed)

# Use random portraits
func _on_random_portraits_toggled(button_pressed):
	settings.set_setting("settings", "random_portraits", button_pressed)
	
# Main Font Size
func _on_main_font_size_value_changed(value):
	settings.set_setting("settings", "font_size", value)
	set_font_size(value)
	
# Music Volume
func _on_music_volume_value_changed(value):
	settings.set_setting("settings", "music_volume", value)
	settings.set_bus_volume("Music", value)
	set_music_label(value)
	
# Sound Volume
func _on_sound_volume_value_changed(value):
	settings.set_setting("settings", "sound_volume", value)
	set_sound_label(value)
	# TODO (frama): Add sfx bus.
	# settings.set_bus_volume("SFX", value)
	
# Futa
func _on_futa_toggled(button_pressed):
	settings.set_setting("game", "futa", button_pressed)
	var FutaTesticles = GameNode.get_node("VBoxCheck/HBoxFuta/FutaTesticles")
	if button_pressed:
		FutaTesticles.set_disabled(false)
	else:
		settings.set_setting("game", "futa_testicles", false)
		FutaTesticles.set_pressed(false)
		FutaTesticles.set_disabled(true)

# Futa with testicles
func _on_futa_testicles_toggled(button_pressed):
	settings.set_setting("game", "futa_testicles", button_pressed)

# Furry
func _on_furry_toggled(button_pressed):
	settings.set_setting("game", "furry", button_pressed)
	var FurryNipples = GameNode.get_node("VBoxCheck/HBoxFurry/FurryNipples")
	if button_pressed:
		FurryNipples.set_disabled(false)
	else:
		settings.set_setting("game", "furry_nipples", false)
		FurryNipples.set_pressed(false)
		FurryNipples.set_disabled(true)

# Additional nipples on furry characters
func _on_furry_nipples_toggled(button_pressed):
	settings.set_setting("game", "furry_nipples", button_pressed)

func _on_allow_races_toggled(button_pressed):
	settings.set_setting("game", "allow_races", button_pressed)

func _on_receiving_sex_toggled(button_pressed):
	settings.set_setting("game", "receiving_sex", button_pressed)

func _on_permadeath_toggled(button_pressed):
	settings.set_setting("game", "permadeath", button_pressed)

func _on_childlike_characters_toggled(button_pressed):
	settings.set_setting("game", "childlike_characters", button_pressed)
	var AdultCharacters = GameNode.get_node("VBoxCheck/HBoxAdult/AdultCharacters")
	if button_pressed:
		AdultCharacters.show()
	else:
		settings.set_setting("game", "adult_characters", false)
		AdultCharacters.set_pressed(false)
		AdultCharacters.hide()

func _on_adult_characters_toggled(button_pressed):
	settings.set_setting("game", "adult_characters", button_pressed)

func _on_gender_slider_value_changed(value):
	settings.set_setting("game", "gender_occurrence", value)

func _on_random_futa_slider_value_changed(value):
	settings.set_setting("game", "futa_occurrence", value)

func _on_alise_on_day_item_selected(ID):
	settings.set_setting("game", "alise_on_day", ID)

# Save settings to file when is confirm pressed.
func _on_confirm_pressed():
	settings.save_config()
	hide()
	
# Set music volume label.
func set_music_label(value):
	SettingsNode.get_node("VBoxRight/MusicVolume").set_value(value)
	SettingsNode.get_node("VBoxRight/MusicVolume/MusicVolumeLabel").set_text("Music Volume: %s" % str(value * 100))
	
# Set sound volume label.
func set_sound_label(value):
	SettingsNode.get_node("VBoxRight/SoundVolume").set_value(value)
	SettingsNode.get_node("VBoxRight/SoundVolume/SoundVolumeLabel").set_text("Sound Volume: %s" % str(value * 100))

# Set default UI theme font size.
func set_font_size(value):
	get_theme().get_font("default_font", "DynamicFont").set_size(value)
