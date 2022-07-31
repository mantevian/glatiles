extends Control


func _process(delta: float) -> void:
	SaveData.set("level_select_scroll_value", $level_container.scroll_vertical)
	if Input.is_action_just_pressed("back"):
		get_tree().change_scene("res://src/menu/pack_select.tscn")


func _on_level_select_tree_entered() -> void:
	$pack_name.text = LevelManager.get_pack(SaveData.get("selected_pack"), SaveData.get("is_internal_pack_selected")).display_name
	
	var level_thumbnail_scene = preload("res://src/menu/level_thumbnail.tscn")
	var order: int = 1
	for level in LevelManager.get_levels_from_pack(SaveData.get("selected_pack"), SaveData.get("is_internal_pack_selected")):
		var level_thumbnail_instance = level_thumbnail_scene.instance()
		level_thumbnail_instance.get_node("title/level_name").text = level.level_name
		level_thumbnail_instance.get_node("title/author").text = level.author
		level_thumbnail_instance.get_node("description").text = level.description
		level_thumbnail_instance.level_order = order
		$level_container/level_list.add_child(level_thumbnail_instance)
		order += 1
	
	yield(get_tree(), "idle_frame")
	$level_container.set_v_scroll(SaveData.get("level_select_scroll_value"))

