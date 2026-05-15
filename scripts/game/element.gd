extends Sprite2D

signal combine_check(id: int, elem_id: int, pos: Vector2);
signal dup_element(elem_id: int, pos: Vector2);

var is_clicked: bool = false;
var mouse_offset: Vector2;
var id: int
var elem_id: int

func move_element(pos: Vector2):
	position = pos;
	Global.element_pos[id] = pos;

func load_init(elem: Element, pos: Vector2 = position) -> void:
	texture = elem.image;
	position = pos;
	elem_id = elem.id;
	
	init();

func init():
	id = Global.next_draggable_element_id;
	Global.next_draggable_element_id += 1;
	Global.element_pos.append(position);
	move_element.rpc(position);

func _ready() -> void:
	init();

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_released("left_click"):
		is_clicked = false;
	if is_clicked:
		move_element(get_viewport().get_mouse_position() + mouse_offset);

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index != MOUSE_BUTTON_LEFT: return;
		
		if event.double_click:
			print("test")
			dup_element.emit(elem_id, position);
			return
		
		if event.pressed and Global.dragged_element == null:
			is_clicked = true;
			mouse_offset = position - get_viewport().get_mouse_position();
			Global.dragged_element = id;
		if event.is_released():
			is_clicked = false;
			Global.dragged_element = null;
			combine_check.emit(id, elem_id, position);
