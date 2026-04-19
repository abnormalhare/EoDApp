extends Node

var is_server: bool = false;
var player_names: Dictionary = {}
var curr_player_name: String = ""

func change_scene(to: String):
	get_tree().change_scene_to_file("res://scenes/" + to + ".tscn")
