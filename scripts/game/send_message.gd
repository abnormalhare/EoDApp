extends TextEdit

signal send_message

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if has_focus() and Input.is_action_just_pressed("send_chat"):
		send_message.emit(text)
		text = ""
