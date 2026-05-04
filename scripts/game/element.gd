extends Sprite2D

signal combine_check

var is_clicked: bool = false;
var mouse_offset: Vector2;
var id: int
var elem_id: int
var peer_moving_id: int

@rpc("any_peer", "call_local", "reliable")
func move_element(pos: Vector2):
	position = pos;
	Global.element_pos[id] = pos;

func load_init(elem: Element, uid: int, pos: Vector2 = position) -> void:
	texture = elem.image;
	position = pos;
	elem_id = elem.id;
	peer_moving_id = uid;
	
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
	if Input.is_action_just_released("left_click"):
		is_clicked = false;
	if is_clicked and multiplayer.get_unique_id() == peer_moving_id:
		move_element.rpc(get_viewport().get_mouse_position() + mouse_offset);

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT and Global.is_being_dragged == null:
			is_clicked = true;
			mouse_offset = position - get_viewport().get_mouse_position();
			Global.is_being_dragged = id;
			peer_moving_id = multiplayer.get_unique_id();
		elif event.is_released() and event.button_index == MOUSE_BUTTON_LEFT:
			is_clicked = false;
			Global.is_being_dragged = null;
			combine_check.emit(id, elem_id, position)
