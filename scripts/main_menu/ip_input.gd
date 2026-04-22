extends TextEdit

signal invalid_ip

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not has_focus(): return
	
	if not Input.is_action_just_pressed("send_chat"):
		Global.server_ip = text
		return
	
	if not Global.is_valid_ip_addr(Global.server_ip):
		invalid_ip.emit()
		return

	Global.is_server = false;
	Global.change_scene("game")
