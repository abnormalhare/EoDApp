extends Node

var default_elements: Array[int] = [0, 1, 2, 3]

# assumes ID is also array index
var elements: Array[Element] = []
var combos: Dictionary[String, int] = {}
var player_data := {}

const server_info_path = "user://server/server.json"

func save_new_element(combo_hash: String, element: Element, creator_id: int):
	elements.append(element)
	combos[combo_hash] = element.id;
	player_data[creator_id].elements.append(element.id)
	save_server()

func init_server():
	var dir = server_info_path.get_base_dir()
	DirAccess.make_dir_recursive_absolute(dir)

	elements = [
		Element.new("Air", 0),
		Element.new("Earth", 1),
		Element.new("Fire", 2),
		Element.new("Water", 3),
	]

	save_server()

func save_server():
	var elem_json := []
	for e in elements:
		elem_json.append(e.to_json())
	
	var player_data_json := {}
	for p in player_data:
		player_data_json[str(p)] = player_data[p]

	var file = FileAccess.open(server_info_path, FileAccess.WRITE)
	file.store_string('{ "defaults": %s, "elements": %s, "combos": %s, "players": %s }' % [default_elements, elem_json, combos, player_data_json])
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

	combos = {}
	for c in json["combos"]:
		combos[c] = json["combos"][c]

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
