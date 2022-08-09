extends Node


const PATH: String = "user://save_data.glt"
const VERSION: int = 4


const DEFAULT_DATA = {
	"version": VERSION,
	"selected_pack": "",
	"selected_level": 1,
	"viewing_packs": 0,
	"is_loading_level_for_editor": false,
	"editor_data": {
		"save": {
			"version": 1,
			"level_name": "unknown",
			"author": "unknown",
			"description": "",
			"label": "",
			"size": {
				"x": 32,
				"y": 16
			},
			"spawn": {
				"x": 0,
				"y": 0
			},
			"tiles": []
		},
		"level_order": 0,
		"pack_name": ""
	}
}


var _data = DEFAULT_DATA.duplicate(true)


func get(key: String):
	return _data[key]


func set(key: String, value):
	_data[key] = value
	save_data()


func save_data() -> void:
	var file = File.new()
	file.open_compressed(PATH, File.WRITE, File.COMPRESSION_FASTLZ)
	file.store_string(JSON.print(_data))
	file.close()


func reset_editor() -> void:
	set("editor_data", DEFAULT_DATA.editor_data.duplicate(true))
	save_data()


func load_data() -> void:
	if !save_exists():
		save_data()
		return
	
	_data = json_from_glt(PATH)

	for key in DEFAULT_DATA.keys():
		if !_data.has(key):
			set(key, DEFAULT_DATA[key])
	
	match _data.version:
		1:
			set("selected_level", int(get("selected_level")))
		2:
			_data.erase("is_internal_pack_selected")
		3:
			_data.erase("is_internal_pack_selected")
		4:
			_data.erase("level_select_scroll_value")
			_data.erase("pack_select_scroll_value")
	
	set("version", VERSION)
	LevelManager.repair_folders("default", { "display_name": "default", "author": "system", "description": "levels without an assigned pack save here" })


func save_exists() -> bool:
	var file = File.new()
	return file.file_exists(PATH)


func json_from_glt(_path: String):
	var file = File.new()
	file.open_compressed(_path, File.READ, File.COMPRESSION_FASTLZ)
	
	var text = ""
	while file.get_position() < file.get_len():
		text += file.get_line()
	
	file.close()
	return JSON.parse(text).get_result()
