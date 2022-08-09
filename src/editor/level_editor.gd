extends Control

class_name LevelEditor

var selected_tile: int = 0
var middle_click_position = Vector2.ZERO


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("back"):
		_on_quit_button_up()
		
	var mouse = get_viewport().get_mouse_position()
	var mouse_in_world = $world_container/viewport.get_mouse_position()
	var select_pos = $tile_select.rect_position
	var world_pos = $world_container.rect_position
	var camera_pos = $world_container/viewport/camera.get_camera_screen_center() - Vector2(512, 256)
	var real_pos = mouse_in_world + camera_pos
	
	var level_size = SaveData._data.editor_data.save.size
	$world_container/viewport/camera.set_limit(MARGIN_RIGHT, level_size.x * 32)
	$world_container/viewport/camera.set_limit(MARGIN_BOTTOM, level_size.y * 32)
	
	# mouse is inside select
	if mouse.x > select_pos.x && mouse.x < select_pos.x + 96 && mouse.y > select_pos.y:
		if Input.is_action_just_pressed("left_click"):
			selected_tile = $tile_select/container/tilemap.get_cell((mouse.x - select_pos.x) / 32, (mouse.y - select_pos.y) / 32)
			$tile_select/container/hover.position = Vector2(int((mouse.x - select_pos.x) / 32) * 32 + 16, int((mouse.y - select_pos.y) / 32) * 32 + 16)
	
	var mouse_is_inside_world = mouse.x > world_pos.x && mouse.x < world_pos.x + 1024 && mouse.y > world_pos.y && mouse.y < world_pos.y + 512
	if mouse_is_inside_world:
		$world_container/viewport/hover.visible = true
		
		$world_container/viewport/hover.position = Vector2(int(real_pos.x / 32) + 0.5, int(real_pos.y / 32) + 0.5) * 32
				
		if Input.is_action_pressed("left_click"):
			$world_container/viewport/tilemap.set_cell(real_pos.x / 32, real_pos.y / 32, selected_tile)
				
		if Input.is_action_pressed("right_click"):
			$world_container/viewport/tilemap.set_cell(real_pos.x / 32, real_pos.y / 32, -1)
		
		if Input.is_action_just_pressed("middle_click"):
			middle_click_position = mouse
		
		if Input.is_action_pressed("middle_click"):
			$world_container/viewport/camera.position -= (mouse - middle_click_position)
			$world_container/viewport/camera.position.x = max($world_container/viewport/camera.position.x, 512)
			$world_container/viewport/camera.position.y = max($world_container/viewport/camera.position.y, 256)
			middle_click_position = mouse
		
		$world_container/viewport/grid.rect_position.x = int((camera_pos.x) / 32) * 32
		$world_container/viewport/grid.rect_position.y = int((camera_pos.y) / 32) * 32
	else:
		$world_container/viewport/hover.visible = false
	
	$coordinates.visible = mouse_is_inside_world
	$coordinates.text = "x: " + str(int(real_pos.x / 32)) + ", y: " + str(int(real_pos.y / 32))


func _on_level_editor_tree_entered() -> void:
	LevelManager.array_to_tilemap(SaveData._data.editor_data.save.tiles, $world_container/viewport/tilemap)
	$level_name.text = SaveData._data.editor_data.save.level_name


func _on_save_button_up() -> void:
	LevelManager.save_level()


func _on_properties_button_up() -> void:
	LevelManager.save_level()
	get_tree().change_scene("res://src/editor/level_properties.tscn")


func _on_level_editor_ready() -> void:
	var ids = $tile_select/container/tilemap.tile_set.get_tiles_ids()
	$tile_select/container.rect_min_size.y = ids.size() * 32 / 3 
	for id in ids:
		$tile_select/container/tilemap.set_cell(id % 3, int(id / 3), id)


func _on_quit_button_up() -> void:
	LevelManager.save_level()
	get_tree().change_scene("res://src/menu/level_select.tscn")
