extends PanelContainer

onready var SettingsNode = $TabContainer/Settings/VBox/HBoxSettings

# Initialization
func _ready():
	# Setting all buttons according to current state.
	# Fullscreen
	SettingsNode.get_node("VBoxLeft/Fullscreen").set_pressed(settings.get_setting("settings", "fullscreen"))
	# Use Animation
	SettingsNode.get_node("VBoxLeft/UseAnimation").set_pressed(settings.get_setting("settings", "use_animation"))
	# Show Sprites
	SettingsNode.get_node("VBoxLeft/ShowSprites").set_pressed(settings.get_setting("settings", "show_sprites"))
	# Skip Combat Animation
	SettingsNode.get_node("VBoxLeft/SkipCombatAnimation").set_pressed(settings.get_setting("settings", "skip_combat"))
	# Random Portraits
	SettingsNode.get_node("VBoxLeft/RandomPortraits").set_pressed(settings.get_setting("settings", "random_portraits"))
	# Main Font Size
	SettingsNode.get_node("VBoxRight/MainFontSize").set_value(settings.get_setting("settings", "font_size"))
	# Music Volume
	set_music_label(settings.get_setting("settings", "music_volume"))
	# Sound Volume
	set_sound_label(settings.get_setting("settings", "sound_volume"))

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
