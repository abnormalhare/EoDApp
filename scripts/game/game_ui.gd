extends Control

signal send_message
signal make_new_element
signal delete_element

@onready var Chat = $Game/Multplayer/Chat/ChatLog;
@onready var ElemList: ItemList = $Game/ElemInfo/ElemList;
@onready var CombineList: ItemList = $Game/CombineArea/CombineList;
@onready var Search: TextEdit = $Game/ElemInfo/Search;

@onready var NEPTitle: Label	      = $NewElementPopup/Options/Container/Panel/Title;
@onready var NEPElemName: TextEdit = $NewElementPopup/Options/Container/Panel/Name;
@onready var NEPElemDesc: TextEdit = $NewElementPopup/Options/Container/Panel/Desc;
@onready var NEPCombine: Button    = $NewElementPopup/Options/Container/Panel/CreateElement;

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

@rpc("any_peer", "call_local", "reliable")
func clear_combiner():
	CombineList.clear()

@rpc("any_peer", "call_local", "reliable")
func add_element_to_elemlist(element: Element):
	for i in elems_in_elemlist.size():
		if i == elems_in_elemlist.size() - 1 and elems_in_elemlist[i].id < element.id:
			elems_in_elemlist.append(element)

		if elems_in_elemlist[i].id < element.id: continue
		if elems_in_elemlist[i].id == element.id: break
		elems_in_elemlist.insert(i, element)
	filter_elemlist("")

func filter_elemlist(text: String):
	ElemList.clear()
	for elem in elems_in_elemlist:
		if text.to_lower() in elem.name.to_lower() or text == "":
			ElemList.add_item(elem.name, elem.image)

func _on_search_text_changed() -> void:
	filter_elemlist(Search.text)

@rpc("any_peer", "call_local", "reliable")
func enable_element_popup():
	$NewElementPopup.visible = true
	NEPCombine.disabled = false

@rpc("any_peer", "call_local", "reliable")
func disable_element_popup():
	$NewElementPopup.visible = false

@rpc("authority", "call_local", "reliable")
func combine_element_server(id: int, elements: Array[Element]):
	var hash_val = Global.get_combo_hash(elements)
	# if element already exists
	if hash_val in SaveData.combos:
		SaveData.player_data["elements"].append(SaveData.combos[hash_val])
		add_element_to_elemlist.rpc_id(id, SaveData.combos[hash_val])
		clear_combiner.rpc_id(id)
		return
	# otherwise, popup create element screen
	enable_element_popup.rpc_id(id)

@rpc("any_peer", "call_local", "reliable")
func combine_element_client(elements: Array[Element]):
	if not multiplayer.is_server(): return
	
	combine_element_server.rpc(multiplayer.get_remote_sender_id(), elements)

func _on_combine_pressed() -> void:
	if len(elems_in_combiner) < 2:
		return
	combine_element_client.rpc(elems_in_combiner)

@rpc("any_peer", "call_local", "reliable")
func element_already_created():
	NEPTitle.text = "Element already exists!"
	await get_tree().create_timer(1).timeout;
	disable_element_popup()

@rpc("authority", "call_local", "reliable")
func create_element_server(id: int, elements: Array[Element], e_name: String, e_desc: String):
	var hash_val = Global.get_combo_hash(elements)
	# if someone else made the element before we could
	if hash_val in SaveData.combos:
		element_already_created.rpc_id(id)
		return
	# otherwise, make new element
	var new_element = Element.new(e_name, Global.next_element_id(), "", Color.BLACK, e_desc)
	SaveData.save_new_element(hash_val, new_element, id)
	add_element_to_elemlist.rpc_id(id, new_element)
	disable_element_popup.rpc_id(id)
	clear_combiner.rpc_id(id)

@rpc("any_peer", "call_local", "reliable")
func create_element_client(elements: Array[Element], e_name: String, e_desc: String):
	if not multiplayer.is_server(): return
	
	create_element_server.rpc(multiplayer.get_remote_sender_id(), elements, e_name, e_desc)

func _on_create_element_pressed() -> void:
	NEPCombine.disabled = true
	create_element_client.rpc(elems_in_combiner, NEPElemName.text, NEPElemDesc.text)

func _on_nep_escape_pressed() -> void:
	disable_element_popup()
