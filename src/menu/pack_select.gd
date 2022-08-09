extends Control


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("back"):
		get_tree().change_scene("res://src/menu/menu.tscn")


func _on_pack_select_tree_entered() -> void:
	var pack_thumbnail_scene = preload("res://src/menu/pack_thumbnail.tscn")

	$switch_button.visible = !SaveData.get("is_loading_level_for_editor")
	$new.visible = SaveData.get("is_loading_level_for_editor")
	
	match int(SaveData.get("viewing_packs")):
		0:
			$switch_button.text = "main"
		1:
			$switch_button.text = "custom"
	
	for pack in LevelManager.get_packs(SaveData.get("viewing_packs")):
		var pack_thumbnail_instance = pack_thumbnail_scene.instance()
		var level_count_text = "(" + str(pack.level_count) + " levels)"
		
		pack_thumbnail_instance.get_node("title/pack_name").text = pack.display_name
		pack_thumbnail_instance.get_node("title/author").text = pack.author
		pack_thumbnail_instance.get_node("description").text = pack.description
		pack_thumbnail_instance.get_node("title/level_count").text = level_count_text
		
		pack_thumbnail_instance.get_node("editor_buttons").visible = SaveData.get("is_loading_level_for_editor")
			
		pack_thumbnail_instance.pack_name = pack.pack_name
		$pack_container/pack_list.add_child(pack_thumbnail_instance)


func _on_switch_button_button_up() -> void:
	SaveData.set("viewing_packs", int(SaveData.get("viewing_packs") + 1) % 2)
	get_tree().reload_current_scene()


func _on_back_button_up() -> void:
	if SaveData.get("is_loading_level_for_editor"):
		get_tree().change_scene("res://src/editor/editor_menu.tscn")
	else:
		get_tree().change_scene("res://src/menu/menu.tscn")


func _on_new_button_up() -> void:
	SaveData.set("selected_pack", "")
	get_tree().change_scene("res://src/editor/manage_pack.tscn")
