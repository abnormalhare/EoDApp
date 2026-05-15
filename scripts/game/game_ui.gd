extends Control

signal send_message
signal make_new_element
signal delete_element

@onready var Chat = $Game/Multplayer/Chat/ChatLog;
@onready var ElemList: ItemList = $Game/ElemInfo/ElemList;
@onready var CombineList: ItemList = $Game/CombineArea/CombineList;
@onready var Search: TextEdit = $Game/ElemInfo/Search;

# why does Godot force this?
var elems_in_combiner: Array[Element] = [];
var elems_in_elemlist: Array[Element] = [];

func append_chat_log(text: String):
	Chat.text += text + "\n";
	Chat.scroll_vertical = INF;

func _on_message_send_message(text: String) -> void:
	send_message.emit(text);

func update_elements(elements: Array[Element]):
	elems_in_elemlist = elements.duplicate();
	if ElemList.item_count > 0:
		ElemList.clear()
	for element in elements:
		ElemList.add_item(element.name, element.image);

func _on_elem_list_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	if mouse_button_index != MOUSE_BUTTON_LEFT: return
	
	var elem_name: String = ElemList.get_item_text(index);
	make_new_element.emit(elem_name, at_position + ElemList.global_position);

func add_element_to_combiner(element: Element, idx: int):
	CombineList.add_item(element.name, element.image)
	elems_in_combiner.append(element)
	elems_in_combiner.sort()
	delete_element.emit(idx)

func check_element_in_combiner(element: Element, idx: int, pos: Vector2):
	if pos > CombineList.global_position and pos < CombineList.global_position + CombineList.size:
		add_element_to_combiner(element, idx)

func add_element_to_elemlist(element: Element):
	for i in elems_in_elemlist.size():
		if i == elems_in_elemlist.size() - 1 and elems_in_elemlist[i].id < element.id:
			elems_in_elemlist.append(element)

		if elems_in_elemlist[i].id < element.id: continue
		if elems_in_elemlist[i].id == element.id: break
		elems_in_elemlist.insert(i, element)

@rpc("authority", "call_local", "reliable")
func combine_element(id: int, elements: Array[Element]):
	var hash_string = "".join(elements)
	var hash_val = hash_string.sha256_text()
	if hash_val in SaveData.combos:
		SaveData.player_data["elements"].append(SaveData.combos[hash_val])
		add_element_to_combiner.rpc_id(id, SaveData.combos[hash_val], )
	

@rpc("any_peer", "call_local", "reliable")
func combine_element_connect(elements: Array[Element]):
	if not multiplayer.is_server(): return
	
	combine_element.rpc(multiplayer.get_remote_sender_id(), elements)

func _on_combine_pressed() -> void:
	combine_element_connect.rpc(elems_in_combiner)

func _on_search_text_changed() -> void:
	var text = Search.text;
	ElemList.clear()
	for elem in elems_in_elemlist:
		if text.to_lower() in elem.name.to_lower() or text == "":
			ElemList.add_item(elem.name, elem.image)
