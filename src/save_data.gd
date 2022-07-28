extends Node


const PATH: String = "user://save_data.glt"


export var version: int = 1
export var is_main_level_selected: bool = true
export var selected_pack: String = "main_levels"
export var selected_level: String = "level_1"


func save_data() -> void:
	var file = File.new()
	file.open_compressed(PATH, File.WRITE, File.COMPRESSION_FASTLZ)
	file.store_string(JSON.print({
		"version": version,
		"is_main_level_selected": is_main_level_selected,
		"selected_pack": selected_pack,
		"selected_level": selected_level
	}))
	file.close()


func load_data() -> void:
	var file = File.new()
	if !save_exists():
		save_data()
		return
	
	file.open_compressed(PATH, File.READ, File.COMPRESSION_FASTLZ)
	var data = JSON.parse(file.get_as_text()).get_result()
	file.close()
	
	is_main_level_selected = data.is_main_level_selected
	selected_pack = data.selected_pack
	selected_level = data.selected_level


func save_exists() -> bool:
	var file = File.new()
	return file.file_exists(PATH)
