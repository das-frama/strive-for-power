extends Control

# Initialization.
func _ready():
	# Set version.
	$Version.set_text("ver. %s" % globals.VERSION)

## Social Section
# Patreon
func _on_patreon_pressed():
	OS.shell_open('https://www.patreon.com/maverik')
	
# Blogger
func _on_blogger_pressed():
	OS.shell_open('https://strivefopower.blogspot.com')

# Itchio
func _on_itchio_pressed():
	OS.shell_open('https://strive4power.itch.io/strive-for-power')

# Wikia
func _on_wikia_pressed():
	OS.shell_open('http://strive4power.wikia.com/wiki/Strive4power_Wiki')
	
## Menu Section
# New Game
func _on_new_game_pressed():
	$NewGame.show()

# Options
func _on_options_pressed():
	$Options.show()
	
# Exit
func _on_exit_pressed():
	get_tree().quit()
