extends Node


func repair_folders(pack_name: String = "", data = { "display_name": "unknown", "author": "unknown", "description": "" }) -> void:
	var dir = Directory.new()
	var file = File.new()
	var path = "user://levels/" + pack_name
	
	if !dir.dir_exists(path):
		dir.open("user://")
		dir.make_dir("levels")
		if pack_name != "":
			dir.open("user://levels")
			dir.make_dir(pack_name)
			
	if pack_name != "" && !dir.file_exists(path + "/pack.glt"):
		file.open_compressed(path + "/pack.glt", File.WRITE, File.COMPRESSION_FASTLZ)
		file.store_string(JSON.print(data))
		file.close()


func get_pack(pack_name: String, path: int = 1):
	var save_path = "user://levels/" + pack_name
	if path == 0:
		save_path = "res://data/levels/" + pack_name
	else:
		repair_folders(pack_name)
	
	return SaveData.json_from_glt(save_path + "/pack.glt")


func get_packs(path_index: int = 1) -> Array:
	var path = "user://levels/"
	if path_index == 0:
		path = "res://data/levels/"
	else:
		repair_folders()
	
	var packs = []
	var dir = Directory.new()
	
	dir.open(path)
	dir.list_dir_begin()
	
	var file = File.new()
	
	var current = dir.get_next()
	while current != "":
		if dir.current_is_dir():
			if current.begins_with(".") || !file.file_exists(path + current + "/pack.glt"):
				current = dir.get_next()
				continue
				
			var data = SaveData.json_from_glt(path + current + "/pack.glt")
			var display_name = data.display_name
			var description = data.description
			
			if display_name.length() == 0:
				display_name = current
				description = "pack.glt not found"
			
			packs.push_back({
				"pack_name": current,
				"level_count": get_levels_from_pack(current, path_index).size(),
				"display_name": display_name,
				"author": data.author,
				"description": description,
				"internal": path_index == 0
			})
		
		current = dir.get_next()
	
	return packs


func get_levels_from_pack(pack_name: String, path: int = 1) -> Array:
	var save_path = "user://levels/" + pack_name + "/"
	if path == 0:
		save_path = "res://data/levels/" + pack_name + "/"
	else:
		repair_folders(pack_name)
	
	var levels = []
	var i: int = 1

	while File.new().file_exists(save_path + str(i) + ".glt"):
		var data = SaveData.json_from_glt(save_path + str(i) + ".glt")
		
		levels.push_back({
			"level_order": i,
			"level_name": data.level_name,
			"author": data.author,
			"description": data.description
		})
		
		i += 1
	
	return levels


func get_level(pack_name: String, level_order: int, path: int = 1) -> Dictionary:
	var save_path = "user://levels/" + pack_name + "/"
	if path == 0:
		save_path = "res://data/levels/" + pack_name + "/"
	else:
		repair_folders(pack_name)
	
	return SaveData.json_from_glt(save_path + str(level_order) + ".glt")


func parse_level(level: Level) -> void:
	var pack_name = SaveData.get("selected_pack")
	var level_order = SaveData.get("selected_level")
	var path = SaveData.get("viewing_packs")
	
	var save_path = "user://levels/" + pack_name + "/"
	if path == 0:
		save_path = "res://data/levels/" + pack_name + "/"
	else:
		repair_folders(pack_name)
		
	var data = SaveData.json_from_glt(save_path + str(level_order) + ".glt")
	
	level.next_level = level_order + 1
	
	if !File.new().file_exists(save_path + str(level_order + 1) + ".glt"):
		level.next_level = -1
	
	level.level_name = data.level_name
	level.author = data.author
	level.description = data.description
	level.label = data.label
	level.spawn.x = data.spawn.x
	level.spawn.y = data.spawn.y
	
	if data.has("size"):
		level.level_size = Vector2(data.size.x, data.size.y)
	else:
		level.level_size = Vector2(32, 16)
	
	for t in data.tiles:
		level.set_cell(t.x, t.y, t.id)


func tilemap_to_array(tilemap: TileMap, w: int, h: int) -> Array:
	var tiles = []
	
	for x in range(0, w):
		for y in range(0, h):
			var tile = TileHelper.name(tilemap.get_cell(x, y))
			if tile != "air":
				tiles.push_back({ "x": x, "y": y, "id": tile })
	
	return tiles


func array_to_tilemap(array: Array, tilemap: TileMap) -> void:
	for t in array:
		tilemap.set_cell(t.x, t.y, TileHelper.id(t.id))


func save_level_in_editor() -> void:
	var editor = get_tree().get_root().get_node("level_editor")
	SaveData._data.editor_data.save.version = 1
	SaveData._data.editor_data.save.tiles = tilemap_to_array(editor.get_node("world_container/viewport/tilemap"), SaveData._data.editor_data.save.size.x, SaveData._data.editor_data.save.size.y)
	SaveData.save_data()


func save_pack_glt(folder: String, display: String, author: String, description: String) -> void:
	repair_folders(folder)
	
	var file = File.new()
	file.open_compressed("user://levels/" + folder + "/pack.glt", File.WRITE, File.COMPRESSION_FASTLZ)
	file.store_string(JSON.print({ "display_name": display, "author": author, "description": description }))
	file.close()


func save_level() -> void:
	save_level_in_editor()
	
	var save_path = "user://levels/" + SaveData._data.editor_data.pack_name + "/" + str(SaveData._data.editor_data.level_order) + ".glt"
	var file = File.new()
	
	repair_folders(SaveData._data.editor_data.pack_name)
	
	file.open_compressed(save_path, File.WRITE, File.COMPRESSION_FASTLZ)
	file.store_string(JSON.print(SaveData._data.editor_data.save))
	file.close()


func delete_pack(pack_name: String) -> void:
	var dir = Directory.new()
	
	for level in get_levels_from_pack(pack_name):
		dir.remove("user://levels/" + pack_name + "/" + str(level.level_order) + ".glt")
	
	dir.remove("user://levels/" + pack_name + "/pack.glt")
	
	dir.remove("user://levels/" + pack_name)
	
	if SaveData.get("selected_pack") == pack_name:
		SaveData.set("selected_pack", "default")


func delete_level(pack_name: String, level_order: int) -> void:
	var dir = Directory.new()
	var path = "user://levels/" + pack_name + "/"
	var pack_size = get_levels_from_pack(pack_name).size()
	
	dir.remove(path + str(level_order) + ".glt")
	
	for i in range(level_order, pack_size):
		dir.rename(path + str(i + 1) + ".glt", path + str(i) + ".glt")


func swap_levels(pack_name: String, level1: int, level2: int) -> void:
	var dir = Directory.new()
	
	var folder = "user://levels/" + pack_name + "/"
	
	dir.rename(folder + str(level1) + ".glt", folder + str(level2) + ".glt.temp")
	dir.rename(folder + str(level2) + ".glt", folder + str(level1) + ".glt")
	dir.rename(folder + str(level2) + ".glt.temp", folder + str(level2) + ".glt")


func move_level(pack1: String, level1: int, pack2: String) -> void:
	var dir = Directory.new()
	var pack1_size = get_levels_from_pack(pack1).size()
	var path1 = "user://levels/" + pack1 + "/"
	var path2 = "user://levels/" + pack2 + "/"
	dir.rename(path1 + str(level1) + ".glt", path2 + str(get_levels_from_pack(pack2).size() + 1) + ".glt")
	
	for i in range(level1, pack1_size):
		dir.rename(path1 + str(i + 1) + ".glt", path1 + str(i) + ".glt")
