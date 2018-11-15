extends Control

# Imports.
const Item = preload("res://src/state/inventory/item.gd")

# Initialization.
func _ready():
	# Set version.
	$Version.set_text("ver. %s" % globals.VERSION)
	
	# Connect tooltip.
	globals.connect_tooltip("Start a new game", $MenuPanel/VBoxMenu/NewGame)
	
	var item = Item.new({
        "code": "supply",
        "name": "Supplies",
        "icon": "res://assets/items/supply.png",
        "description": "An assemblance of various commodities which can be sold or used in certain tasks. Required for outside camping",
        "effect": "supplypurchase",
        "recipe": "",
        "cost": 5,
        "type": "ingredient",
        "amount": 0,
        "weight": 2,
        "stackable": true,
        "requires": true
    })
	globals.connect_tooltip(item, $MenuPanel/VBoxMenu/Load, "item_tooltip")

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
# Load
func _on_load_pressed():
	globals.change_scene("mansion")

# Options
func _on_options_pressed():
	$Options.show()
	
# Credits.
func _on_credits_pressed():
	globals.save_game("savegame.bin")
	
# Exit
func _on_exit_pressed():
	get_tree().quit()

