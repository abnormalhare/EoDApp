extends Sprite2D

var is_clicked: bool = false;
var mouse_offset: Vector2;
var id: int

@rpc("any_peer", "call_local", "reliable")
func move_element(pos: Vector2):
	position = pos;
	Global.element_pos[id] = pos;

func load_init(elem: Element, pos: Vector2 = position) -> void:
	texture = elem.image;
	position = pos;
	
	init()

func init():
	id = Global.next_draggable_element_id;
	Global.next_draggable_element_id += 1;
	Global.element_pos.append(position)
	move_element.rpc(position)

func _ready() -> void:
	init()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if is_clicked:
		move_element.rpc(get_viewport().get_mouse_position() + mouse_offset);
		return;

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT and Global.is_being_dragged == null:
			is_clicked = true;
			mouse_offset = position - get_viewport().get_mouse_position();
			Global.is_being_dragged = id;
		elif event.is_released() and event.button_index == MOUSE_BUTTON_LEFT:
			is_clicked = false;
			Global.is_being_dragged = null;
