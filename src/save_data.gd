extends Node


const PATH: String = "user://save_data.glt"
const VERSION: int = 3


var _data = {
	"version": 3,
	"is_internal_pack_selected": true,
	"selected_pack": "main_levels",
	"selected_level": 1,
	"pack_select_scroll_value": 0,
	"level_select_scroll_value": 0
}


func get(key: String):
	return _data[key]


func set(key: String, value):
	_data[key] = value;
	save_data()


func save_data() -> void:
	var file = File.new()
	file.open_compressed(PATH, File.WRITE, File.COMPRESSION_FASTLZ)
	file.store_string(JSON.print(_data))
	file.close()


func load_data() -> void:
	var file = File.new()
	if !save_exists():
		save_data()
		return
	
	file.open_compressed(PATH, File.READ, File.COMPRESSION_FASTLZ)
	var file_data = JSON.parse(file.get_as_text()).get_result()
	file.close()
	
	_data = file_data
	
	if _data.version == 1:
		set("selected_level", int(get("selected_level")))
		save_data()
	
	set("version", VERSION)


func save_exists() -> bool:
	var file = File.new()
	return file.file_exists(PATH)
