extends Control
signal send_message

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func append_chat_log(text: String):
	$Game/Multplayer/Chat/ChatLog.text += text;

func _on_message_send_message(text: String) -> void:
	send_message.emit(text);
