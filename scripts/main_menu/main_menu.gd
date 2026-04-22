extends Control

@onready var IPText = $VBoxContainer/HBoxContainer/TextEdit

func _on_invalid_ip() -> void:
	IPText.text = ""
	IPText.placeholder_text = "Invalid IP"
