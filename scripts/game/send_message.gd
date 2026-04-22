extends TextEdit

signal send_message

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if has_focus():
		Global.is_typing = true;
		if Input.is_action_just_pressed("send_chat"):
			send_message.emit(text)
			text = ""
			release_focus()
		if Input.is_action_just_pressed("close_chat"):
			release_focus()
	else:
		Global.is_typing = false;
