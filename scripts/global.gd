extends Node

var is_server: bool = false;
var player_names: Dictionary = {}
var curr_player_name: String = ""
var server_ip: String = ""

func change_scene(to: String):
	get_tree().change_scene_to_file("res://scenes/" + to + ".tscn")

func is_valid_ip_addr(ip: String) -> bool:
	var ip_nums = ip.split(".")

	for num in ip_nums:
		if not num.is_valid_int():
			return false
		if int(num) < 0 or int(num) > 255:
			return false

	return true
