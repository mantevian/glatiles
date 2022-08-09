extends Control


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("back"):
		get_tree().change_scene("res://src/menu/pack_select.tscn")


func _on_level_select_tree_entered() -> void:
	$pack_name.text = LevelManager.get_pack(SaveData.get("selected_pack"), SaveData.get("viewing_packs")).display_name
	
	$new.visible = SaveData.get("is_loading_level_for_editor")
	
	var level_thumbnail_scene = preload("res://src/menu/level_thumbnail.tscn")
	var order: int = 1
	
	var level_array = LevelManager.get_levels_from_pack(SaveData.get("selected_pack"), SaveData.get("viewing_packs"))
	
	for level in level_array:
		var level_thumbnail_instance = level_thumbnail_scene.instance()
		level_thumbnail_instance.get_node("title/level_name").text = level.level_name
		level_thumbnail_instance.get_node("title/author").text = level.author
		level_thumbnail_instance.get_node("description").text = level.description
		
		if SaveData.get("is_loading_level_for_editor"):
			level_thumbnail_instance.get_node("play_button").text = "select"
		else:
			level_thumbnail_instance.get_node("play_button").text = "play"
		
		level_thumbnail_instance.get_node("editor_buttons").visible = SaveData.get("is_loading_level_for_editor")
		level_thumbnail_instance.get_node("editor_buttons/up").visible = !(order <= 1)
		level_thumbnail_instance.get_node("editor_buttons/down").visible = !(order >= level_array.size())
		
		level_thumbnail_instance.level_order = order
		$level_container/level_list.add_child(level_thumbnail_instance)
		order += 1


func _on_packs_button_up() -> void:
	get_tree().change_scene("res://src/menu/pack_select.tscn")


func _on_new_button_up() -> void:
	SaveData.reset_editor()
	var pack = SaveData.get("selected_pack")
	SaveData._data.editor_data.save.author = LevelManager.get_pack(pack).author
	SaveData._data.editor_data.pack_name = pack
	SaveData._data.editor_data.level_order = LevelManager.get_levels_from_pack(pack).size() + 1
	SaveData.save_data()
	get_tree().change_scene("res://src/editor/level_editor.tscn")
