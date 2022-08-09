extends Control


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("back"):
		get_tree().change_scene("res://src/menu/menu.tscn")
	
	$load.disabled = SaveData._data.editor_data.pack_name == ""


func _on_load_button_up() -> void:
	get_tree().change_scene("res://src/editor/level_editor.tscn")


func _on_manage_packs_button_up() -> void:
	SaveData.set("is_loading_level_for_editor", true)
	SaveData.set("viewing_packs", 1)
	get_tree().change_scene("res://src/menu/pack_select.tscn")


func _on_menu_button_up() -> void:
	get_tree().change_scene("res://src/menu/menu.tscn")
