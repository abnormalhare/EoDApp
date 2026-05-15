extends Node2D

var element_list_updated: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	init_multiplayer();
	$GameUI.update_elements(SaveData.elements);

func init_multiplayer():
	var peer = ENetMultiplayerPeer.new();
	var error: Error;
	if Global.is_server:
		error = peer.create_server(3043);
	else:
		error = peer.create_client(Global.server_ip, 3043);

	match error:
		ERR_ALREADY_IN_USE:
			print("Uh oh! Multiplayer Peer already open!");
		ERR_CANT_CREATE:
			print("Uh oh! Multiplayer Peer can't be made!");

	multiplayer.multiplayer_peer = peer;
	multiplayer.connection_failed.connect(on_failed_connection);

	if Global.is_server:
		SaveData.init()
		multiplayer.peer_connected.connect(init_player);
		await get_tree().create_timer(0.2).timeout; # takes time to load multiplayer
		init_player_server(multiplayer.get_unique_id())
	
	Global.is_server = multiplayer.is_server()

@rpc("authority", "call_local", "reliable")
func init_player_data(id: int):
	if SaveData.player_data.has(id): return

	SaveData.player_data[id] = {};
	SaveData.player_data[id]["elements"] = SaveData.default_elements.duplicate();

@rpc("any_peer", "call_local", "reliable")
func send_username(username: String):
	if not multiplayer.is_server(): return
	
	var sender_id = multiplayer.get_remote_sender_id();
	SaveData.player_data[sender_id]["username"] = username;

@rpc("authority", "call_local", "reliable")
func recieve_elements(new_elements: Array[Element]):
	$GameUI.update_elements(new_elements);

@rpc("any_peer", "call_local", "reliable")
func init_player_client(username: String):
	visible = true
	send_username.rpc(username);
	send_chat_message.rpc("Connected.");

@rpc("authority", "call_local", "reliable")
func init_player_server(id: int):
	init_player_data.rpc(id);
	recieve_elements.rpc_id(id, SaveData.player_data[id]["elements"]);
	init_player_client.rpc_id(id, Global.curr_player_name);
	SaveData.save_server()

@rpc("any_peer", "call_local", "reliable")
func send_init_player():
	if not multiplayer.is_server(): return
	
	init_player_server.rpc(multiplayer.get_remote_sender_id())

func init_player():
	send_init_player()

func on_failed_connection():
	Global.change_scene("game_ui");

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("quit"):
		return_to_menu()
	if Global.is_typing:
		return

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		send_disconnect_message()
		await get_tree().create_timer(0.1).timeout;
		get_tree().quit()

func send_disconnect_message():
	send_chat_message.rpc("Disconnected");
	if multiplayer.is_server():
		send_server_message.rpc("THIS SERVER HAS CLOSED.")

@rpc("any_peer", "call_local", "reliable")
func send_chat_message(msg: String):
	if not multiplayer.is_server(): return;
	
	var sanitized_msg = Global.sanitize_message(msg);
	
	var sender_id = multiplayer.get_remote_sender_id();
	var sender_name = SaveData.player_data[sender_id]["username"];
	receive_chat_message.rpc(sender_name, sanitized_msg);

@rpc("authority", "call_local", "reliable")
func receive_chat_message(sender_name: String, msg: String):
	$GameUI.append_chat_log("%s: %s" % [sender_name, msg]);

@rpc("authority", "call_local", "reliable")
func send_server_message(msg: String):
	$GameUI.append_chat_log("SERVER: %s" % [msg]);

func return_to_menu():
	send_disconnect_message()
	
	await get_tree().create_timer(0.1).timeout;
	multiplayer.multiplayer_peer.close();
	Global.change_scene("main_menu");

func _on_game_ui_send_message(text) -> void:
	send_chat_message.rpc(text)

func remove_element(idx: int):
	for i in get_children():
		if i is not Sprite2D: continue
		if i.id != idx: continue
		remove_child(i)
		i.queue_free()
		break

func check_element_in_combiner(idx: int, e_idx: int, pos: Vector2):
	var element: Element = SaveData.elements[e_idx];
	$GameUI.check_element_in_combiner(element, idx, pos)

func _on_delete_element(idx: int) -> void:
	remove_element(idx);

func make_new_element(element: Element, pos: Vector2) -> Node2D:
	var draggable_element = Global.load_node("element");
	add_child(draggable_element)
	draggable_element.load_init(element, pos);
	draggable_element.combine_check.connect(check_element_in_combiner);
	draggable_element.dup_element.connect(duplicate_element)
	return draggable_element

func _on_game_ui_make_new_element(e_name: String, pos: Vector2) -> void:
	var element;
	for elem in SaveData.elements:
		if elem.name == e_name:
			element = elem;
	
	var draggable_element = make_new_element(element, pos)
	draggable_element.is_clicked = true;

const RANDOM_MIN_RADIUS := 40.0
const RANDOM_MAX_RADIUS := 60.0
func duplicate_element(elem_id: int, pos: Vector2):
	var angle = randf() * TAU
	var radius = randf_range(RANDOM_MIN_RADIUS, RANDOM_MAX_RADIUS)
	pos += Vector2.from_angle(angle) * radius

	make_new_element(SaveData.elements[elem_id], pos)
