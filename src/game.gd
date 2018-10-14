extends Node2D

# Game Current Screen
var current_screen
# We preload all screens at once.
var screens = {
	"main_menu": load("res://src/scenes/menu/menu.tscn")
}

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
