extends Panel

var is_animated = false

var TweenNode = null

func _ready():
	var CloseButton = preload("res://src/scenes/buttons/close_button.tscn").instance()
	add_child(CloseButton)
	CloseButton.connect("pressed", self, "hide")
	
	# Create Tween node for animation.
	TweenNode = Tween.new()
	TweenNode.name = "Tween"
	add_child(TweenNode)

func show():
	visible = true
	_animate(["fade_in", "max"])

func hide():
	yield(_animate(["fade_out", "min"]), "completed")
	visible = false

func _animate(animations = []):
	if is_animated:
		return false
		
	is_animated = true
	
	for animation in animations:
		_set_animation(animation)
		
	if not TweenNode.is_active():
		TweenNode.start()
	yield(TweenNode, "tween_completed")
	
	is_animated = false
	
	return true
	
func _set_animation(anim):
	match anim:
		"fade_in":
			TweenNode.interpolate_property(self, "modulate", Color(1,1,1,0), Color(1,1,1,1), 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		"fade_out":
			TweenNode.interpolate_property(self, "modulate", Color(1,1,1,1), Color(1,1,1,0), 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		"max":
			TweenNode.interpolate_property(self, "rect_scale", Vector2(0.7,0.6), Vector2(1,1), 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		"min":
			TweenNode.interpolate_property(self, "rect_scale", Vector2(1,1), Vector2(0.7,0.6), 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	