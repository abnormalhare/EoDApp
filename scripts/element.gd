class_name Element

var name: String;
var id: int;
var image: Texture2D;
var color: Color;
var description: String;

func _init(e_name: String, e_id: int, e_image: Texture2D, e_color: Color = Color.BLACK, e_desc: String = "") -> void:
	name = e_name;
	id = e_id;
	image = e_image;
	color = e_color;
	description = e_desc;
