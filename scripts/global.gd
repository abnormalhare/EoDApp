extends Node

var is_server := false;
var curr_player_name := ""
var server_ip := ""
var element_pos: Array[Vector2] = [];
var next_draggable_element_id := 0;
var next_element_id := 4;
var is_typing := false;
var dragged_element = null;
var failed_to_connect := false;

func change_scene(to: String):
	get_tree().change_scene_to_file("res://scenes/" + to + ".tscn")

func load_node(scene: String) -> Node:
	var node: PackedScene = load("res://scenes/" + scene + ".tscn")
	return node.instantiate();

func load_image(image: String) -> CompressedTexture2D:
	return load("res://assets/" + image + ".png");

func load_elem_image(image: String) -> ImageTexture:
	return load("user://server/elements/" + image + ".png")

func save_elem_image(image: Image, path: String):
	image.save_png("user://server/elements/" + path + ".png")

func is_valid_ip_addr(ip: String) -> bool:
	var ip_nums = ip.split(".")
	
	if len(ip_nums) < 4:
		return false

	for num in ip_nums:
		if not num.is_valid_int():
			return false
		if int(num) < 0 or int(num) > 255:
			return false

	return true

func sanitize_message(msg: String) -> String:
	return msg.strip_edges();
