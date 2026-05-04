extends Node2D

var elements: Array[Element] = [
	Element.new("Air", 0, Global.load_image("Air")),
	Element.new("Earth", 1, Global.load_image("Earth")),
	Element.new("Fire", 2, Global.load_image("Fire")),
	Element.new("Water", 3, Global.load_image("Water")),
]
var combos: Array[Combination]
var element_list_updated: bool = false

@rpc("any_peer", "call_remote", "reliable")
func set_username(username: String):
	var sender_id = multiplayer.get_remote_sender_id()
	if sender_id == 0:
		Global.player_names[multiplayer.get_unique_id()] = username;
	elif multiplayer.is_server():
		Global.player_names[sender_id] = username;
	send_chat_message.rpc_id(multiplayer.get_unique_id(), "Connected.")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	init_multiplayer();
	$GameUI.update_elements(elements);

func init_multiplayer():
	var peer = ENetMultiplayerPeer.new();
	var error: Error;
	if Global.is_server:
		error = peer.create_server(3043);
	else:
		error = peer.create_client(Global.server_ip, 3043);

	match error:
		ERR_ALREADY_IN_USE:
			print("Uh oh! Multiplayer Peer already open!")
		ERR_CANT_CREATE:
			print("Uh oh! Multiplayer Peer can't be made!")

	multiplayer.multiplayer_peer = peer;
	
	await get_tree().create_timer(0.25).timeout; # takes time to load multiplayer
	
	if not Global.is_server:
		set_username.rpc(Global.curr_player_name)
	else:
		set_username(Global.curr_player_name)
		multiplayer.peer_connected.connect(peer_connected)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("quit"):
		Global.change_scene("main_menu");
	if Global.is_typing:
		return

@rpc("authority", "call_remote", "reliable")
func add_element(elem):
	add_child(elem)

func peer_connected(id: int):
	if not multiplayer.is_server(): return
	
	for i in get_children():
		if i is not Sprite2D: continue
		add_element.rpc(id);

@rpc("any_peer", "call_local", "reliable")
func send_chat_message(msg: String):
	if not multiplayer.is_server(): return;
	
	var sanitized_msg = Global.sanitize_message(msg);
	
	var sender_id = multiplayer.get_remote_sender_id();
	var sender_name = Global.player_names[sender_id];
	receive_chat_message.rpc(sender_name, sanitized_msg);

@rpc("authority", "call_local", "reliable")
func receive_chat_message(sender_name: String, msg: String):
	$GameUI.append_chat_log("%s: %s" % [sender_name, msg]);

func _on_game_ui_send_message(text) -> void:
	send_chat_message.rpc(text)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		multiplayer.multiplayer_peer.close();
		get_tree().quit();

func remove_element(idx: int):
	for i in get_children():
		if i is not Sprite2D: continue
		if i.id != idx: continue
		remove_child(i)
		i.queue_free()
		break

func check_element_in_combiner(idx: int, e_idx: int, pos: Vector2):
	var element: Element = elements[e_idx];
	$GameUI.check_element_in_combiner.rpc(element, idx, pos)

func _on_combine_element(idx: int) -> void:
	remove_element(idx);

@rpc("any_peer", "call_local", "reliable")
func make_new_element(e_name: String, pos: Vector2) -> void:
	var element;
	for elem in elements:
		if elem.name == e_name:
			element = elem;
	
	var draggable_element = Global.load_node("element");
	add_child(draggable_element)
	draggable_element.load_init(element, pos);
	draggable_element.is_clicked = true;
	draggable_element.combine_check.connect(check_element_in_combiner);
	
func _on_game_ui_make_new_element(e_name: String, pos: Vector2) -> void:
	make_new_element.rpc(e_name, pos);
