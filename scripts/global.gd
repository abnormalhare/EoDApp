extends Node

var is_server: bool = false;
var player_names: Dictionary = {}
var curr_player_name: String = ""
var server_ip: String = ""
var element_pos: Array[Vector2] = [];
var next_element_id: int = 0;

func change_scene(to: String):
	get_tree().change_scene_to_file("res://scenes/" + to + ".tscn")

func load_node(scene: String) -> Node:
	var node: PackedScene = load("res://scenes/" + scene + ".tscn")
	return node.instantiate();

func is_valid_ip_addr(ip: String) -> bool:
	var ip_nums = ip.split(".")

	for num in ip_nums:
		if not num.is_valid_int():
			return false
		if int(num) < 0 or int(num) > 255:
			return false

	return true
