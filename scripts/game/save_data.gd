extends Node

var default_elements: Array[int] = [0, 1, 2, 3]

# assumes ID is also array index
var elements: Array[Element] = []
var combos: Dictionary[String, Element] = {}
var player_data := {}

const server_info_path = "user://server/server.json"

func convert_elements() -> Array:
	var ret := []
	for e in elements:
		ret.append(e.to_json())
	
	return ret

func init_server():
	var dir = server_info_path.get_base_dir()
	DirAccess.make_dir_recursive_absolute(dir)
	
	elements = [
		Element.new("Air", 0),
		Element.new("Earth", 1),
		Element.new("Fire", 2),
		Element.new("Water", 3),
	]
	var elem_json = convert_elements();

	var file = FileAccess.open(server_info_path, FileAccess.WRITE)
	file.store_string('{
	"defaults": %s,
	"elements": %s,
	"combos": %s,
	"players": %s,
}' % [default_elements, elem_json, combos, player_data])
	file.close()

func load_server():
	var file = FileAccess.open(server_info_path, FileAccess.READ)
	var text = file.get_as_text()
	file.close()
	
	var json = JSON.parse_string(text)
	
	default_elements = []
	for n in default_elements:
		default_elements.append(int(n))
	
	elements = []
	for e in json["elements"]:
		elements.append(Element.new().from_json(e))

	combos = json["combos"]
	player_data = json["players"]

func init():
	if not FileAccess.file_exists(server_info_path):
		init_server()
	else:
		load_server()

const AIR_PATH := "user://server/elements/Air.png"
func save_default_elements():
	if ResourceLoader.exists(AIR_PATH): return
	var dir = AIR_PATH.get_base_dir()
	DirAccess.make_dir_recursive_absolute(dir)
	
	Global.save_elem_image(Global.load_image("Air").get_image(), "Air")
	Global.save_elem_image(Global.load_image("Earth").get_image(), "Earth")
	Global.save_elem_image(Global.load_image("Fire").get_image(), "Fire")
	Global.save_elem_image(Global.load_image("Water").get_image(), "Water")
