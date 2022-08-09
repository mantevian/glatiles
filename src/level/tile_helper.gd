extends Node


func tile_data(name: String):
	if name == "air":
		return { "id": -1, "name": "air", "passable": "always", "colorable": "always" }
		
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
	if id == -1:
		return "air"
	
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
