extends Control
signal send_message

@onready var Chat = $Game/Multplayer/Chat/ChatLog;

func append_chat_log(text: String):
	Chat.text += text + "\n";
	Chat.scroll_vertical = INF;

func _on_message_send_message(text: String) -> void:
	send_message.emit(text);
