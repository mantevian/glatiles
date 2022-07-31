extends Node2D

class_name Level

var level_name: String = ""
var author: String = ""
var description: String = ""
var label: String = ""
var next_level: int = -1
var pack_name: String = ""
var spawn_x: int
var spawn_y: int
var player_move_timeout: int = 6
var max_arrow_cooldown: int = 1

var _arrow_cooldown: int = 0


func _process(delta: float) -> void:
	if !$next_level.disabled && Input.is_action_just_pressed("next"):
		_on_next_level_button_up()
	
	if Input.is_action_just_pressed("back"):
		get_tree().change_scene("res://src/menu/level_select.tscn")
	
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()

func _on_level_tree_exited() -> void:
	get_tree().reload_current_scene()


func _on_level_tree_entered() -> void:
	$tilemap.clear()
	
	LevelManager.parse_level(SaveData.get("selected_pack"), SaveData.get("selected_level"), self, SaveData.get("is_internal_pack_selected"))
	$label.text = label
	
	if next_level > -1:
		$next_level.visible = true
	else:
		$next_level.visible = false
	
	$player.x = spawn_x
	$player.y = spawn_y
	
	$player.update_position()
	set_colored_cell()


func _physics_process(delta: float) -> void:
	if _arrow_cooldown == 0:
		_arrow_cooldown = max_arrow_cooldown
		match get_cell_on_player():
			"arrow_up":
				if (is_cell_passable($player.x, $player.y - 1)):
					$player.y -= 1
					update_tile_on_player()
			"arrow_right":
				if (is_cell_passable($player.x + 1, $player.y)):
					$player.x += 1
					update_tile_on_player()
			"arrow_down":
				if (is_cell_passable($player.x, $player.y + 1)):
					$player.y += 1
					update_tile_on_player()
			"arrow_left":
				if (is_cell_passable($player.x - 1, $player.y)):
					$player.x -= 1
					update_tile_on_player()
	else:
		_arrow_cooldown -= 1


func _on_player_move() -> void:
	if !is_passable(get_next_cell()):
		return
	
	match $player.direction:
		0:
			$player.y -= 1
		1:
			$player.x += 1
		2:
			$player.y += 1
		3:
			$player.x -= 1
	
	update_tile_on_player()


func update_tile_on_player() -> void:
	$player.update_position()
	
	if get_cell_on_player() == "gray_plus":
		$player.color = $player.next_color()
	elif get_cell_on_player().ends_with("_plus"):
		$player.color = TileHelper.color_id(TileHelper.tile_data(get_cell_on_player()).color)
		
	if get_cell_on_player() == "minus":
		$player.color = $player.prev_color()

func get_next_cell() -> int:
	match $player.direction:
		0:
			return $tilemap.get_cell($player.x, $player.y - 1)
		1:
			return $tilemap.get_cell($player.x + 1, $player.y)
		2:
			return $tilemap.get_cell($player.x, $player.y + 1)
		3:
			return $tilemap.get_cell($player.x - 1, $player.y)
	return -1


func set_colored_cell() -> void:
	var t = TileHelper.tile_data(get_cell_on_player())
	if t.colorable:
		if t.has("replace"):
			$tilemap.set_cell($player.x, $player.y, TileHelper.id(t.replace))
		else:
			$tilemap.set_cell($player.x, $player.y, $player.color + 1)


func is_cell_passable(x: int, y: int) -> bool:
	return is_passable($tilemap.get_cell(x, y))


func is_passable(n: int) -> bool:
	var t = TileHelper.tile_data(TileHelper.name(n))
	if t.has("color") && TileHelper.color_id(t.color) == $player.color && t.passable == "same_color":
		return true
	return t.passable == "always"


func check_level_completion() -> bool:
	for x in range(0, 32):
		for y in range(0, 16):
			if $tilemap.get_cell(x, y) >= 7 && $tilemap.get_cell(x, y) <= 13:
				return false
	return true


func get_cell_on_player() -> String:
	return get_cell_on_pos($player.x, $player.y)


func get_cell_on_pos(var x: int, var y: int) -> String:
	var i = $tilemap.get_cell(x, y)
	if i == -1:
		return "air"
	return TileHelper.name(i)


func _on_player_end_moving() -> void:
	set_colored_cell()
	
	if $next_level:
		$next_level.disabled = !check_level_completion()


func set_cell(var x: int, var y: int, var tile: String) -> void:
	$tilemap.set_cell(x, y, TileHelper.id(tile))


func _on_next_level_button_up() -> void:
	SaveData.set("selected_level", next_level)
	get_tree().reload_current_scene()


func _on_restart_button_up() -> void:
	get_tree().reload_current_scene()
