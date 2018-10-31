extends Panel


func _ready():
	rect_pivot_offset = Vector2(rect_size.x/2, rect_size.y/2)
	var button = load("res://files/Close Panel Button/CloseButton.tscn").instance()
	add_child(button)
	button.connect("pressed", self, 'hide')
	var rect = get_global_rect()
	var pos = Vector2(rect.end.x - button.rect_size.x, rect.position.y)
	button.rect_global_position = pos

func show():
	input_handler.Open(self)

func hide():
	input_handler.Close(self)
