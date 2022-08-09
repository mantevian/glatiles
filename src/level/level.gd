extends Node2D

class_name Level

var level_name: String = ""
var author: String = ""
var description: String = ""
var label: String = ""
var next_level: int = -1
var pack_name: String = ""
var spawn: Vector2 = Vector2.ZERO
var player_move_timeout: int = 6
var max_arrow_cooldown: int = 1

var _arrow_cooldown: int = 0


const MIN_SIZE = Vector2(32, 16)
var level_size = MIN_SIZE


func _process(delta: float) -> void:
	if $next_level.visible && !$next_level.disabled && Input.is_action_just_pressed("next"):
		_on_next_level_button_up()
	
	if $finish.visible && !$finish.disabled && Input.is_action_just_pressed("next"):
		_on_finish_button_up()
	
	if Input.is_action_just_pressed("back"):
		get_tree().change_scene("res://src/menu/level_select.tscn")
	
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()


func _on_level_tree_exited() -> void:
	get_tree().reload_current_scene()


func _on_level_tree_entered() -> void:
	$world/viewport/tilemap.clear()
	
	LevelManager.parse_level(self)
	$label.text = label
	
	if next_level > -1:
		$next_level.visible = true
		$finish.visible = false
	else:
		$next_level.visible = false
		$finish.visible = true
	
	$world/viewport/player.x = spawn.x
	$world/viewport/player.y = spawn.y
	
	$world/viewport/camera.set_limit(MARGIN_RIGHT, level_size.x * 32)
	$world/viewport/camera.set_limit(MARGIN_BOTTOM, level_size.y * 32)
	
	$world/viewport/player.update_position()
	set_colored_cell()


func _physics_process(delta: float) -> void:
	if _arrow_cooldown == 0:
		_arrow_cooldown = max_arrow_cooldown
		match get_cell_on_player():
			"arrow_up":
				if (is_cell_passable($world/viewport/player.x, $world/viewport/player.y - 1)):
					$world/viewport/player.y -= 1
					update_tile_on_player()
			"arrow_right":
				if (is_cell_passable($world/viewport/player.x + 1, $world/viewport/player.y)):
					$world/viewport/player.x += 1
					update_tile_on_player()
			"arrow_down":
				if (is_cell_passable($world/viewport/player.x, $world/viewport/player.y + 1)):
					$world/viewport/player.y += 1
					update_tile_on_player()
			"arrow_left":
				if (is_cell_passable($world/viewport/player.x - 1, $world/viewport/player.y)):
					$world/viewport/player.x -= 1
					update_tile_on_player()
	else:
		_arrow_cooldown -= 1
	
	$world/viewport/camera.position = $world/viewport/player.position
	
	var camera_pos = $world/viewport/camera.get_camera_screen_center() - Vector2(512, 256)
	$world/viewport/grid.rect_position.x = int((camera_pos.x) / 32) * 32
	$world/viewport/grid.rect_position.y = int((camera_pos.y) / 32) * 32


func _on_player_move() -> void:
	if !is_passable(get_next_cell()):
		return
	
	match $world/viewport/player.direction:
		0:
			$world/viewport/player.y -= 1
		1:
			$world/viewport/player.x += 1
		2:
			$world/viewport/player.y += 1
		3:
			$world/viewport/player.x -= 1
	
	update_tile_on_player()


func update_tile_on_player() -> void:
	$world/viewport/player.update_position()
	
	if get_cell_on_player() == "gray_plus":
		$world/viewport/player.color = $world/viewport/player.next_color()
	elif get_cell_on_player().ends_with("_plus"):
		$world/viewport/player.color = TileHelper.color_id(TileHelper.tile_data(get_cell_on_player()).color)
		
	if get_cell_on_player() == "minus":
		$world/viewport/player.color = $world/viewport/player.prev_color()


func get_next_cell() -> int:
	match $world/viewport/player.direction:
		0:
			return $world/viewport/tilemap.get_cell($world/viewport/player.x, $world/viewport/player.y - 1)
		1:
			return $world/viewport/tilemap.get_cell($world/viewport/player.x + 1, $world/viewport/player.y)
		2:
			return $world/viewport/tilemap.get_cell($world/viewport/player.x, $world/viewport/player.y + 1)
		3:
			return $world/viewport/tilemap.get_cell($world/viewport/player.x - 1, $world/viewport/player.y)
	return -1


func set_colored_cell() -> void:
	var t = TileHelper.tile_data(get_cell_on_player())
	if t.colorable:
		if t.has("replace"):
			$world/viewport/tilemap.set_cell($world/viewport/player.x, $world/viewport/player.y, TileHelper.id(t.replace))
		else:
			$world/viewport/tilemap.set_cell($world/viewport/player.x, $world/viewport/player.y, $world/viewport/player.color + 1)


func is_cell_passable(x: int, y: int) -> bool:
	return is_passable($world/viewport/tilemap.get_cell(x, y))


func is_passable(n: int) -> bool:
	var t = TileHelper.tile_data(TileHelper.name(n))
	if t.has("color") && TileHelper.color_id(t.color) == $world/viewport/player.color && t.passable == "same_color":
		return true
	return t.passable == "always"


func check_level_completion() -> bool:
	for x in range(0, level_size.x):
		for y in range(0, level_size.y):
			if $world/viewport/tilemap.get_cell(x, y) >= 7 && $world/viewport/tilemap.get_cell(x, y) <= 13:
				return false
	return true


func get_cell_on_player() -> String:
	return get_cell_on_pos($world/viewport/player.x, $world/viewport/player.y)


func get_cell_on_pos(var x: int, var y: int) -> String:
	var i = $world/viewport/tilemap.get_cell(x, y)
	if i == -1:
		return "air"
	return TileHelper.name(i)


func _on_player_end_moving() -> void:
	set_colored_cell()
	
	if next_level > -1:
		$next_level.disabled = !check_level_completion()
	else:
		$finish.disabled = !check_level_completion()


func set_cell(var x: int, var y: int, var tile: String) -> void:
	$world/viewport/tilemap.set_cell(x, y, TileHelper.id(tile))


func _on_next_level_button_up() -> void:
	SaveData.set("selected_level", next_level)
	get_tree().reload_current_scene()


func _on_restart_button_up() -> void:
	get_tree().reload_current_scene()


func _on_finish_button_up() -> void:
	get_tree().change_scene("res://src/menu/pack_select.tscn")


func _on_quit_button_up() -> void:
	get_tree().change_scene("res://src/menu/pack_select.tscn")
