extends Control


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("back"):
		_on_quit_button_button_up()
	
	if Input.is_action_just_pressed("next"):
		_on_play_button_button_up()


func _on_play_button_button_up() -> void:
	SaveData.set("is_loading_level_for_editor", false)
	get_tree().change_scene("res://src/menu/pack_select.tscn")


func _on_LinkButton_button_up() -> void:
	OS.shell_open("https://mantevian.itch.io/")


func _on_menu_tree_entered() -> void:
	SaveData.load_data()


func _on_quit_button_button_up() -> void:
	get_tree().quit()


func _on_editor_button_button_up() -> void:
	get_tree().change_scene("res://src/editor/editor_menu.tscn")
