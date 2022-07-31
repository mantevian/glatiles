extends Node


func repair_folders(pack_name: String = "") -> void:
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
		file.store_string(JSON.print({
			"author": "unknown",
			"description": ""
		}))
		file.close()


func get_pack(pack_name: String, internal: bool = false):
	var save_path = "user://levels/" + pack_name
	if internal:
		save_path = "res://data/levels/" + pack_name
	else:
		repair_folders(pack_name)
	
	var file = File.new()

	file.open_compressed(save_path + "/pack.glt", File.READ, File.COMPRESSION_FASTLZ)
	var data = JSON.parse(file.get_as_text()).get_result()
	file.close()
	return data


func get_packs() -> Array:
	var paths = ["res://data/levels/", "user://levels/"]
	repair_folders()
	
	var packs = []
	
	var dir = Directory.new()
	var file = File.new()
	
	for i in range(0, 2):
		var path = paths[i]
		dir.open(path)
		dir.list_dir_begin()
		
		var current = dir.get_next()
		while current != "":
			if dir.current_is_dir():
				if current.length() < 3:
					current = dir.get_next()
					continue
				
				file.open_compressed(path + current + "/pack.glt", File.READ, File.COMPRESSION_FASTLZ)
				var data = JSON.parse(file.get_as_text()).get_result()
				
				packs.push_back({
					"pack_name": current,
					"level_count": get_levels_from_pack(current, i == 0).size(),
					"display_name": data.display_name,
					"author": data.author,
					"description": data.description,
					"internal": i == 0
				})
			
			current = dir.get_next()
			
	return packs


func get_levels_from_pack(pack_name: String, internal: bool = false) -> Array:
	var save_path = "user://levels/" + pack_name + "/"
	if internal:
		save_path = "res://data/levels/" + pack_name + "/"
	else:
		repair_folders(pack_name)
	
	var levels = []
	var i: int = 1
	var file = File.new()
	
	while file.file_exists(save_path + str(i) + ".glt"):
		file.open_compressed(save_path + str(i) + ".glt", File.READ, File.COMPRESSION_FASTLZ)
		var data = JSON.parse(file.get_as_text()).get_result()
		file.close()
		
		levels.push_back({
			"level_name": data.level_name,
			"author": data.author,
			"description": data.description
		})
		
		i += 1
	
	return levels


func parse_level(pack_name: String, level_order: int, level: Level, internal: bool = false) -> void:
	var save_path = "user://levels/" + pack_name + "/"
	if internal:
		save_path = "res://data/levels/" + pack_name + "/"
	else:
		repair_folders(pack_name)
	
	var file = File.new()
	
	file.open_compressed(save_path + str(level_order) + ".glt", File.READ, File.COMPRESSION_FASTLZ)
	var data = JSON.parse(file.get_as_text()).get_result()
	
	level.next_level = level_order + 1
	if !file.file_exists(save_path + str(level_order + 1) + ".glt"):
		level.next_level = -1
	
	file.close()
	
	level.level_name = data.level_name
	level.author = data.author
	level.description = data.description
	level.label = data.label
	level.spawn_x = data.spawn.x
	level.spawn_y = data.spawn.y
	
	for t in data.tiles:
		level.set_cell(t.x, t.y, t.id)


func save_level(level: Level) -> void:
	var data = {
		"version": 1,
		"level_name": level.level_name,
		"author": level.author,
		"description": level.description,
		"label": level.label,
		"spawn": {
			"x": level.spawn_x,
			"y": level.spawn_y
		},
		"tiles": []
	}
	
	for x in range(0, 32):
		for y in range(0, 16):
			var tile = level.get_cell_on_pos(x, y)
			if tile != "air":
				data.tiles.push_back({ "x": x, "y": y, "id": tile })
	
	var file_name: String
	if level.next_level == -1:
		file_name = "1"
	else:
		file_name = str(level.next_level + 1)
	var save_path = "user://levels/" + level.pack_name + "/" + file_name + ".glt"
	var file = File.new()
	
	repair_folders(level.pack_name)
	
	file.open_compressed(save_path, File.WRITE, File.COMPRESSION_FASTLZ)
	file.store_string(JSON.print(data))
	file.close()
