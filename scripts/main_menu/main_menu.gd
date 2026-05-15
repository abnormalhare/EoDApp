extends Control

@onready var IPText = $Container/JoinContainer/IPAddress

func _ready() -> void:
	SaveData.save_default_elements()
	if Global.failed_to_connect:
		$ConnectFail.visible = true;

func _on_invalid_ip() -> void:
	IPText.text = ""
	IPText.placeholder_text = "Invalid IP"

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("quit"):
		if $HostOptions.visible:
			$HostOptions.visible = false
		else:
			get_tree().quit()

func _on_host_pressed() -> void:
	$HostOptions.visible = true

func _on_host_escape_pressed() -> void:
	$HostOptions.visible = false

func _on_host_confirm_pressed() -> void:
	Global.is_server = true;
	Global.change_scene("game")


func _on_connect_fail_escape_pressed() -> void:
	$ConnectFail.visible = false
