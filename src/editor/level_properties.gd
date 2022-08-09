extends Control


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("esc"):
		_on_back_button_up()


func _on_level_properties_tree_entered() -> void:
	var index = 0
	var current_index = 0
	
	for pack in LevelManager.get_packs(1):
		$container/pack_name_edit.add_item(pack.display_name)
		if pack.pack_name == SaveData._data.editor_data.pack_name:
			current_index = index
		index += 1
	
	$container/pack_name_edit.select(current_index)
	
	$container/level_name_edit.text = SaveData._data.editor_data.save.level_name
	$container/author_edit.text = SaveData._data.editor_data.save.author
	$container/description_edit.text = SaveData._data.editor_data.save.description
	$container/label_edit.text = SaveData._data.editor_data.save.label
	$container/level_size/width_edit.value = SaveData._data.editor_data.save.size.x
	$container/level_size/height_edit.value = SaveData._data.editor_data.save.size.y
	$container/player_spawn/x_edit.value = SaveData._data.editor_data.save.spawn.x
	$container/player_spawn/y_edit.value = SaveData._data.editor_data.save.spawn.y


func _on_back_button_up() -> void:
	var current_pack = SaveData._data.editor_data.pack_name
	var current_order = SaveData._data.editor_data.level_order
	var new_pack = LevelManager.get_packs()[$container/pack_name_edit.get_selected_id()].pack_name
	
	if current_pack != new_pack:
		SaveData._data.editor_data.level_order = LevelManager.get_levels_from_pack(new_pack).size() + 1
		LevelManager.move_level(current_pack, current_order, new_pack)
	
	SaveData._data.editor_data.pack_name = new_pack
	
	SaveData._data.editor_data.save.level_name = $container/level_name_edit.text
	SaveData._data.editor_data.save.author = $container/author_edit.text
	SaveData._data.editor_data.save.description = $container/description_edit.text
	SaveData._data.editor_data.save.label = $container/label_edit.text
	SaveData._data.editor_data.save.size.x = $container/level_size/width_edit.value
	SaveData._data.editor_data.save.size.y = $container/level_size/height_edit.value
	SaveData._data.editor_data.save.spawn.x = $container/player_spawn/x_edit.value
	SaveData._data.editor_data.save.spawn.y = $container/player_spawn/y_edit.value
	SaveData.save_data()
	
	get_tree().change_scene("res://src/editor/level_editor.tscn")
