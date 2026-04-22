extends Sprite2D

var is_clicked: bool = false;
var mouse_offset: Vector2;

@rpc("any_peer", "call_local", "reliable")
func move_element(pos: Vector2):
	position = pos;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if is_clicked:
		move_element.rpc(get_viewport().get_mouse_position() + mouse_offset);
		return;

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			is_clicked = true;
			mouse_offset = position - get_viewport().get_mouse_position();
		elif event.is_released() and event.button_index == MOUSE_BUTTON_LEFT:
			is_clicked = false;
