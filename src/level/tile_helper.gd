extends Node


func parse_level(pack_name: String, level_name: String, level: Level, internal: bool = false) -> void:
	var save_path = "user://levels/" + pack_name + "/" + level_name + ".glt"
	if internal:
		save_path = "res://data/levels/" + level_name + ".glt"
	
	var file = File.new()

	if (!file.file_exists(save_path)):
		var dir = Directory.new()
		dir.open("user://")
		dir.make_dir("levels")
		dir.open("user://levels")
		dir.make_dir(pack_name)
	
	file.open_compressed(save_path, File.READ, File.COMPRESSION_FASTLZ)
	var data = JSON.parse(file.get_as_text()).get_result()
	
	file.close()
	
	level.level_name = data.level_name
	level.author = data.author
	level.description = data.description
	level.label = data.label
	level.next_level = data.next_level
	level.pack_name = data.pack_name
	level.spawn_x = data.spawn.x
	level.spawn_y = data.spawn.y
	level.player_move_timeout = data.player_move_timeout
	level.max_arrow_cooldown = data.arrow_cooldown
	
	for t in data.tiles:
		level.set_cell(t.x, t.y, t.id)


func save_level(level: Level) -> void:
	var data = {
		"version": 1,
		"level_name": level.level_name,
		"author": level.author,
		"description": level.description,
		"label": level.label,
		"next_level": level.next_level,
		"pack_name": level.pack_name,
		"spawn": {
			"x": level.spawn_x,
			"y": level.spawn_y
		},
		"player_move_timeout": level.player_move_timeout,
		"arrow_cooldown": level.max_arrow_cooldown,
		"tiles": []
	}
	
	for x in range(0, 32):
		for y in range(0, 16):
			var tile = level.get_cell_on_pos(x, y)
			if tile != "air":
				data.tiles.push_back({ "x": x, "y": y, "id": tile })
	
	var save_path = "user://levels/" + level.pack_name + "/" + level.level_name + ".glt"
	var file = File.new()
	if (!file.file_exists(save_path)):
		var dir = Directory.new()
		dir.open("user://")
		dir.make_dir("levels")
		dir.open("user://levels")
		dir.make_dir(level.pack_name)
	
	file.open_compressed(save_path, File.WRITE, File.COMPRESSION_FASTLZ)
	file.store_string(JSON.print(data))
	file.close()


func tile_data(name: String):
	if name == "air":
		return { "id": -1, "name": "air", "passable": true, "colorable": true }
		
	var file = File.new()
	file.open("res://data/tiles.json", File.READ)
	var content = file.get_as_text()
	file.close()
	return JSON.parse(content).get_result()[id(name)]


func id(name: String) -> int:
	var file = File.new()
	file.open("res://data/tiles.json", File.READ)
	var content = file.get_as_text()
	file.close()
	
	for item in JSON.parse(content).get_result():
		if item.name == name:
			return item.id
	
	return -1


func name(id: int) -> String:
	var file = File.new()
	file.open("res://data/tiles.json", File.READ)
	var content = file.get_as_text()
	file.close()
	
	return JSON.parse(content).get_result()[id].name

func color_name(id: int) -> String:
	match id:
		0:
			return "red"
		1:
			return "orange"
		2:
			return "yellow"
		3:
			return "green"
		4:
			return "blue"
		5:
			return "purple"
		
	return "gray"

func color_id(name: String) -> int:
	match name:
		"red":
			return 0
		"orange":
			return 1
		"yellow":
			return 2
		"green":
			return 3
		"blue":
			return 4
		"purple":
			return 5
		
	return -1
