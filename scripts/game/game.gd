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
	if Global.is_server:
		peer.create_server(3043);
	else:
		peer.create_client(Global.server_ip, 3043);

	multiplayer.multiplayer_peer = peer;
	
	await get_tree().create_timer(0.5).timeout; # takes time to load multiplayer
	
	if not Global.is_server:
		set_username.rpc(Global.curr_player_name)
	else:
		set_username(Global.curr_player_name)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass;

func sanitize_message(msg: String) -> String:
	return msg;

@rpc("any_peer", "call_remote", "reliable")
func send_chat_message(msg: String):
	if not multiplayer.is_server(): return;
	
	var sanitized_msg = sanitize_message(msg);
	
	var sender_id = multiplayer.get_remote_sender_id();
	var sender_name = Global.player_names[sender_id];
	receive_chat_message.rpc(sender_name, sanitized_msg);

@rpc("authority", "call_local", "reliable")
func receive_chat_message(sender_name: String, msg: String):
	$GameUI.append_chat_log("\n%s: %s" % [sender_name, msg]);

func _on_game_ui_send_message(text) -> void:
	send_chat_message.rpc(text)
