extends Control

signal send_message
signal make_new_element
signal combine_element

@onready var Chat = $Game/Multplayer/Chat/ChatLog;
@onready var ElemList: ItemList = $Game/ElemInfo/ElemList;

# why does Godot force this?
var elems_in_combiner: Array[int] = [];

func append_chat_log(text: String):
	Chat.text += text + "\n";
	Chat.scroll_vertical = INF;

func _on_message_send_message(text: String) -> void:
	send_message.emit(text);

func update_elements(elements: Array[Element]):
	if ElemList.item_count > 0:
		ElemList.clear()
	for element in elements:
		ElemList.add_item(element.name, element.image);


func _on_elem_list_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	if mouse_button_index != MOUSE_BUTTON_LEFT: return
	
	var elem_name: String = ElemList.get_item_text(index);
	make_new_element.emit(elem_name, at_position + ElemList.global_position);

@rpc("any_peer", "call_local", "reliable")
func place_element_in_combiner(idx: int):
	pass

func check_element_in_combiner(idx: int, pos: Vector2):
	var top_left = Vector2(pos.x - 16, pos.y - 16);
	var bottom_right = Vector2(pos.x + 16, pos.y + 16);
	if top_left > ElemList.global_position and bottom_right < ElemList.global_position + ElemList.size:
		place_element_in_combiner.rpc(idx)
		return true
	return false

func _on_button_pressed() -> void:
	pass
