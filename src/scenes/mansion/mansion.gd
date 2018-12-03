# mansion.gd
extends Control

onready var Inventory = $Inventory

func _ready():
	globals.state.inventory.add_item("sword1")
	globals.state.inventory.add_item("armor1")
	globals.state.inventory.add_item("armor2")
	globals.state.inventory.add_item("ring")
	globals.state.inventory.add_item("neck")
	globals.state.inventory.add_item("sword2")
	globals.state.inventory.add_item("ring")
	globals.state.inventory.add_item("potion", 10)
	globals.state.inventory.add_item("potion", 10)
	Inventory.call_deferred("character_set", globals.state.player)
	Inventory.call_deferred("inventory_set", globals.state.inventory)
