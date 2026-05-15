class_name Element

var name: String;
var id: int;
var image: Texture2D;
var image_path: String
var color: Color;
var description: String;

func _init(e_name: String = "", e_id: int = 0, e_image: String = "", e_color: Color = Color.BLACK, e_desc: String = "") -> void:
	name = e_name;
	id = e_id;
	image_path = e_image if e_image != "" else e_name
	image = Global.load_elem_image(image_path);
	color = e_color;
	description = e_desc;

func to_json() -> Dictionary:
	return {
		"name": name,
		"id": id,
		"image": image_path,
		"color": color.to_rgba32(),
		"desc": description,
	}

func from_json(json: Dictionary):
	_init(json["name"], json["id"], json["image"], Color.hex(json["color"]), json["desc"])
