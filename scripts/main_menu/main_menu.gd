extends Control

@onready var IPText = $VBoxContainer/HBoxContainer/TextEdit

func _on_invalid_ip() -> void:
	IPText.text = ""
	IPText.placeholder_text = "Invalid IP"

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
