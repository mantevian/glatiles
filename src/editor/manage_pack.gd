extends Control


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("esc"):
		_on_save_button_up()


func _on_save_button_up() -> void:
	var folder_name = $container/folder_name_edit.text
	var selected_pack = SaveData.get("selected_pack")
	
	if folder_name != selected_pack:
		var dir = Directory.new()
		dir.rename("user://levels/" + selected_pack, "user://levels/" + folder_name)
	
	LevelManager.save_pack_glt($container/folder_name_edit.text, $container/display_name_edit.text, $container/author_edit.text, $container/description_edit.text)
	get_tree().change_scene("res://src/menu/pack_select.tscn")


func _on_manage_pack_tree_entered() -> void:
	if SaveData.get("selected_pack") == "":
		return
	
	$container/folder_name_edit.text = SaveData.get("selected_pack")
	var data = LevelManager.get_pack(SaveData.get("selected_pack"))
	$container/display_name_edit.text = data.display_name
	$container/author_edit.text = data.author
	$container/description_edit.text = data.description


func _on_cancel_button_up() -> void:
	get_tree().change_scene("res://src/menu/pack_select.tscn")
