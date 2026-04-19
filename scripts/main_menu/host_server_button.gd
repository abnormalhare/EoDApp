extends Button

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if button_pressed:
		Global.is_server = true;
		Global.change_scene("game")
