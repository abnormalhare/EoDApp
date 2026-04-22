extends Node2D

@rpc("any_peer", "call_remote", "reliable")
func set_username(username: String):
	var sender_id = multiplayer.get_remote_sender_id()
	if sender_id == 0:
		Global.player_names[multiplayer.get_unique_id()] = username;
	elif multiplayer.is_server():
		Global.player_names[sender_id] = username;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
	
	await get_tree().create_timer(0.5).timeout; # takes time to load multiplayer
	
	if not Global.is_server:
		set_username.rpc(Global.curr_player_name)
	else:
		set_username(Global.curr_player_name)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Global.is_typing:
		return

	if Input.is_action_just_pressed("new_element"):
		var elem = Global.load_node("element");
		add_child(elem)
		elem.load_init();

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
