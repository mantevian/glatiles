extends Control


func _process(delta: float) -> void:
	SaveData.set("pack_select_scroll_value", $pack_container.scroll_vertical)
	if Input.is_action_just_pressed("back"):
		get_tree().change_scene("res://src/menu/menu.tscn")


func _on_pack_select_tree_entered() -> void:
	var pack_thumbnail_scene = preload("res://src/menu/pack_thumbnail.tscn")
	
	for pack in LevelManager.get_packs():
		var pack_thumbnail_instance = pack_thumbnail_scene.instance()
		var level_count_text = "(" + str(pack.level_count) + " levels)"
		if pack.internal:
			level_count_text += " [main]"
			
		pack_thumbnail_instance.get_node("title/pack_name").text = pack.display_name
		pack_thumbnail_instance.get_node("title/author").text = pack.author
		pack_thumbnail_instance.get_node("description").text = pack.description
		pack_thumbnail_instance.get_node("title/level_count").text = level_count_text
		pack_thumbnail_instance.pack_name = pack.pack_name
		$pack_container/pack_list.add_child(pack_thumbnail_instance)
	
	yield(get_tree(), "idle_frame")
	$pack_container.scroll_vertical = SaveData.get("pack_select_scroll_value")
