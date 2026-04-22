extends Control

signal send_message
signal make_new_element

@onready var Chat = $Game/Multplayer/Chat/ChatLog;
@onready var ElemList: ItemList = $Game/ElemInfo/ElemList;

func append_chat_log(text: String):
	Chat.text += text + "\n";
	Chat.scroll_vertical = INF;

func _on_message_send_message(text: String) -> void:
	send_message.emit(text);

func update_elements(elements: Array[Element]):
	for element in elements:
		ElemList.add_item(element.name, element.image);


func _on_elem_list_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	if mouse_button_index != MOUSE_BUTTON_LEFT: return
	
	var elem_name: String = ElemList.get_item_text(index);
	make_new_element.emit(elem_name, at_position + ElemList.global_position);
